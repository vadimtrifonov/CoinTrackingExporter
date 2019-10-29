import Foundation

public struct TezosTransactionOperation: TezosOperation {
    public let hash: String
    public let sender: String
    public let receiver: String
    public let amount: Decimal
    public let fee: Decimal
    public let timestamp: Date
    public let isSuccessful: Bool

    public init(
        hash: String,
        sender: String,
        receiver: String,
        amount: Decimal,
        fee: Decimal,
        timestamp: Date,
        isSuccessful: Bool
    ) {
        self.hash = hash
        self.sender = sender
        self.receiver = receiver
        self.amount = amount
        self.fee = fee
        self.timestamp = timestamp
        self.isSuccessful = isSuccessful
    }

    public func isIncoming(account: String) -> Bool {
        return receiver.lowercased() == account.lowercased()
    }

    public func isOutgoing(account: String) -> Bool {
        return sender.lowercased() == account.lowercased()
    }
}

extension TezosTransactionOperation: Equatable {
    public static func == (lhs: TezosTransactionOperation, rhs: TezosTransactionOperation) -> Bool {
        return lhs.hash == rhs.hash
    }
}

extension TezosTransactionOperation: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(hash)
    }
}

extension TezosTransactionOperation: Comparable {
    public static func < (lhs: TezosTransactionOperation, rhs: TezosTransactionOperation) -> Bool {
        return lhs.timestamp < rhs.timestamp
    }
}
