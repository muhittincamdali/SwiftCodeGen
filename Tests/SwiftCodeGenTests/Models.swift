import Foundation
import SwiftCodeGen

/// Fails to compile unless `T` is `Sendable`: the conformance the macro adds is checked by the
/// compiler, not `@unchecked`.
func requireSendable<T: Sendable>(_: T.Type) {}

final class Listener: Sendable {}

struct TransferError: Error, Equatable {}

@Synchronized
final class Account {
    let owner: String
    var balance: Int
    var history: [Int] = []
    var note: String?
    var counter = 0
    private(set) var lastChange: Int = 0
    weak var listener: Listener?

    /// Computed properties are left alone.
    var isOverdrawn: Bool { balance < 0 }

    static let bank = "Test Bank"

    init(owner: String, balance: Int) {
        self.owner = owner
        self.balance = balance
    }

    func deposit(_ amount: Int) {
        withLock {
            balance += amount
            history.append(amount)
            lastChange = amount
        }
    }

    /// Moves money only when it stays non-negative; checks and writes as one step.
    func withdraw(_ amount: Int) throws(TransferError) {
        try withLock { () throws(TransferError) in
            guard balance >= amount else { throw TransferError() }
            balance -= amount
            history.append(-amount)
            lastChange = -amount
        }
    }
}

@Synchronized
final class Progress {
    @Streamed var fraction: Double = 0
    @Streamed var title: String?
    @Streamed var log: [String] = []
    @Streamed var token: String!
    @Streamed var tick: Tick = Tick(value: 0)

    init() {}
}

/// Not `Equatable`: every assignment is sent, even the same value.
struct Tick: Sendable {
    var value: Int
}

@Synchronized
public final class PublicModel {
    @Streamed public private(set) var count: Int = 0

    public init() {}

    public func increment() {
        count += 1
    }
}

/// Delegates of Apple frameworks subclass NSObject, the one superclass a Sendable class may have.
@Synchronized
final class DownloadDelegate: NSObject {
    var receivedBytes: Int64 = 0
    @Streamed var isFinished: Bool = false
}
