import ArgumentParser
import CoinTracking
import Combine
import Ethereum
import EthereumEtherscan
import Foundation

struct EthereumStatementCommand: ParsableCommand {

    static var configuration = CommandConfiguration(
        commandName: "ethereum-statement",
        abstract: "Export Ethereum transactions",
        discussion: """
        Takes into account internal transactions, cancelled transactions (by excluding them, but including thier fees) and fees
        """
    )

    @Argument(help: "Etherium address")
    var address: String

    @Option(name: .customLong("known-transactions"), help: .knownTransactions)
    var knownTransactionsPath: String?

    @Option(help: .startDate())
    var startDate: Date = .distantPast

    func run() throws {
        var subscriptions = Set<AnyCancellable>()
        let gateway = EtherscanEthereumGateway(apiKey: Config.etherscanAPIKey)

        let knownTransactions = try knownTransactionsPath.map(KnownTransactionsCSVDecoder().decode) ?? []

        Publishers.Zip(
            gateway.fetchNormalTransactions(address: address, startDate: startDate),
            gateway.fetchInternalTransactions(address: address, startDate: startDate)
        )
        .sink(receiveCompletion: { completion in
            if case let .failure(error) = completion {
                print(error)
            }
            Self.exit()
        }, receiveValue: { [address] normalTransactions, internalTransactions in
            do {
                let statement = EthereumStatement(
                    normalTransactions: normalTransactions,
                    internalTransactions: internalTransactions,
                    address: address
                )
                let rows = statement.toCoinTrackingRows(knownTransactions: knownTransactions)
                let overriden = rows.filter { row in
                    knownTransactions.contains(where: { $0.transactionID == row.transactionID })
                }
                print(statement.balance)
                print("Known transactions: \(knownTransactions.count)")
                print("Overriden transactions: \(overriden.count)")
                try CoinTrackingCSVEncoder().encode(rows: rows, filename: "EthereumStatement")
            } catch {
                print(error)
            }
        })
        .store(in: &subscriptions)

        RunLoop.main.run()
    }
}

private extension EthereumStatement {
    func toCoinTrackingRows(knownTransactions: [KnownTransaction]) -> [CoinTrackingRow] {
        let rows = incomingNormalTransactions.map(CoinTrackingRow.makeNormalDeposit)
            + incomingInternalTransactions.map(CoinTrackingRow.makeInternalDeposit)
            + successfulOutgoingNormalTransactions.map(CoinTrackingRow.makeNormalWithdrawal)
            + successfulOutgoingInternalTransactions.map(CoinTrackingRow.makeInternalWithdrawal)
            + feeIncurringTransactions.map(CoinTrackingRow.makeFee)
        return rows.overriden(with: knownTransactions).sorted(by: >)
    }
}

private extension CoinTrackingRow {
    static func makeFee(transaction: EthereumTransaction) -> CoinTrackingRow {
        CoinTrackingRow(
            type: .outgoing(.otherFee),
            buyAmount: 0,
            buyCurrency: "",
            sellAmount: transaction.fee,
            sellCurrency: Ethereum.symbol,
            fee: 0,
            feeCurrency: "",
            exchange: transaction.sourceNameForCoinTracking,
            group: "",
            comment: Self.makeComment(eventID: transaction.hash),
            date: transaction.date
        )
    }

    static func makeNormalDeposit(transaction: EthereumTransaction) -> CoinTrackingRow {
        CoinTrackingRow(
            type: .incoming(.deposit),
            buyAmount: transaction.amount,
            buyCurrency: Ethereum.symbol,
            sellAmount: 0,
            sellCurrency: "",
            fee: 0,
            feeCurrency: "",
            exchange: transaction.destinationNameForCoinTracking,
            group: "",
            comment: Self.makeComment(eventID: transaction.hash),
            date: transaction.date,
            transactionID: transaction.hash
        )
    }

    static func makeInternalDeposit(transaction: EthereumTransaction) -> CoinTrackingRow {
        CoinTrackingRow(
            type: .incoming(.deposit),
            buyAmount: transaction.amount,
            buyCurrency: Ethereum.symbol,
            sellAmount: 0,
            sellCurrency: "",
            fee: 0,
            feeCurrency: "",
            exchange: transaction.destinationNameForCoinTracking,
            group: "Internal",
            comment: Self.makeComment(eventID: transaction.hash),
            date: transaction.date,
            transactionID: transaction.hash
        )
    }

    static func makeNormalWithdrawal(transaction: EthereumTransaction) -> CoinTrackingRow {
        CoinTrackingRow(
            type: .outgoing(.withdrawal),
            buyAmount: 0,
            buyCurrency: "",
            sellAmount: transaction.amount,
            sellCurrency: Ethereum.symbol,
            fee: 0,
            feeCurrency: "",
            exchange: transaction.sourceNameForCoinTracking,
            group: "",
            comment: Self.makeComment(eventID: transaction.hash),
            date: transaction.date,
            transactionID: transaction.hash
        )
    }

    static func makeInternalWithdrawal(transaction: EthereumTransaction) -> CoinTrackingRow {
        CoinTrackingRow(
            type: .outgoing(.withdrawal),
            buyAmount: 0,
            buyCurrency: "",
            sellAmount: transaction.amount,
            sellCurrency: Ethereum.symbol,
            fee: 0,
            feeCurrency: "",
            exchange: transaction.sourceNameForCoinTracking,
            group: "Internal",
            comment: Self.makeComment(eventID: transaction.hash),
            date: transaction.date,
            transactionID: transaction.hash
        )
    }
}

private extension EthereumTransaction {
    var sourceNameForCoinTracking: String {
        "Ethereum \(from.prefix(8))."
    }

    var destinationNameForCoinTracking: String {
        "Ethereum \(to.prefix(8))."
    }
}
