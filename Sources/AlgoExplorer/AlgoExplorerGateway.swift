import Algorand
import Combine
import Foundation
import FoundationExtensions
import Networking

public struct AlgoExplorerGateway: AlgorandGateway {
    private let urlSession: URLSession

    public init(urlSession: URLSession = .shared) {
        self.urlSession = urlSession
    }

    public func fetchTransactions(address: String) -> AnyPublisher<[AlgorandTransaction], Error> {
        do {
            let endpoint = try Endpoint<AlgoExplorer.TransactionsResponse>(
                .get,
                url: URL(string: "https://api.algoexplorer.io/v1/account/\(address)/transactions")
            )
            return urlSession.dataTaskPublisher(for: endpoint).map { response in
                response.transactions.map(AlgorandTransaction.init)
            }
            .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}
