import Foundation
import SwiftCodeGen
import Testing

@Suite("@Synchronized")
struct SynchronizedTests {
    @Test("The class is Sendable without @unchecked")
    func sendableConformance() {
        requireSendable(Account.self)
        requireSendable(Progress.self)
        requireSendable(PublicModel.self)
        requireSendable(DownloadDelegate.self)
    }

    @Test("An NSObject subclass works, for framework delegates")
    func nsObjectSubclass() async {
        let delegate = DownloadDelegate()
        var finished = delegate.isFinishedUpdates.makeAsyncIterator()
        #expect(await finished.next() == false)
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<100 {
                group.addTask { delegate.receivedBytes += 1_024 }
            }
        }
        delegate.isFinished = true
        #expect(delegate.receivedBytes == 102_400)
        #expect(await finished.next() == true)
    }

    @Test("Initializer assignments, default values and implicit nil are kept")
    func initialValues() {
        let account = Account(owner: "Ada", balance: 50)
        #expect(account.owner == "Ada")
        #expect(account.balance == 50)
        #expect(account.history.isEmpty)
        #expect(account.note == nil)
        #expect(account.counter == 0)
        #expect(account.lastChange == 0)
        #expect(account.listener == nil)
        #expect(Account.bank == "Test Bank")
    }

    @Test("Reads and writes go to the same storage")
    func readWrite() {
        let account = Account(owner: "Ada", balance: 0)
        account.note = "rent"
        account.balance = -5
        #expect(account.note == "rent")
        #expect(account.isOverdrawn)
        account.note = nil
        #expect(account.note == nil)
    }

    @Test("Compound assignment from many tasks loses no update")
    func concurrentIncrements() async {
        let account = Account(owner: "Ada", balance: 0)
        let iterations = 2_000
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<iterations {
                group.addTask {
                    account.counter += 1
                    account.history.append(1)
                }
            }
        }
        #expect(account.counter == iterations)
        #expect(account.history.count == iterations)
    }

    @Test("Mutating through a subscript is one locked step")
    func concurrentSubscriptMutation() async {
        let account = Account(owner: "Ada", balance: 0)
        account.history = [0]
        await withTaskGroup(of: Void.self) { group in
            for _ in 0..<1_000 {
                group.addTask { account.history[0] += 1 }
            }
        }
        #expect(account.history == [1_000])
    }

    @Test("withLock keeps two properties consistent for concurrent readers")
    func withLockInvariant() async {
        let account = Account(owner: "Ada", balance: 0)
        let consistent = await withTaskGroup(of: Bool.self) { group in
            for amount in 1...500 {
                group.addTask {
                    account.deposit(amount)
                    return true
                }
                group.addTask {
                    account.withLock { account.history.reduce(0, +) == account.balance }
                }
            }
            return await group.allSatisfy { $0 }
        }
        #expect(consistent)
        #expect(account.balance == (1...500).reduce(0, +))
        #expect(account.history.count == 500)
    }

    @Test("A typed error thrown in withLock reaches the caller and releases the lock")
    func withLockThrows() async throws {
        let account = Account(owner: "Ada", balance: 10)
        #expect(throws: TransferError()) { try account.withdraw(11) }
        #expect(account.balance == 10)
        #expect(account.history.isEmpty)

        // Another thread can take the lock again: the throw did not leave it held.
        let balance = await Task.detached { account.withLock { account.balance } }.value
        #expect(balance == 10)
        try account.withdraw(10)
        #expect(account.balance == 0)
        #expect(account.lastChange == -10)
    }

    @Test("withLock can be nested on the same thread")
    func nestedWithLock() {
        let account = Account(owner: "Ada", balance: 1)
        let result = account.withLock {
            account.withLock { account.balance * 10 } + account.balance
        }
        #expect(result == 11)
    }

    @Test("Only one withdrawal of the last coin succeeds")
    func checkThenActRace() async {
        let account = Account(owner: "Ada", balance: 1)
        let successes = await withTaskGroup(of: Bool.self) { group in
            for _ in 0..<200 {
                group.addTask { (try? account.withdraw(1)) != nil }
            }
            return await group.reduce(0) { $0 + ($1 ? 1 : 0) }
        }
        #expect(successes == 1)
        #expect(account.balance == 0)
    }

    @Test("A weak property does not keep its object alive")
    func weakProperty() {
        let account = Account(owner: "Ada", balance: 0)
        var listener: Listener? = Listener()
        account.listener = listener
        #expect(account.listener === listener)
        listener = nil
        #expect(account.listener == nil)
    }

    @Test("The object is released when nothing references it")
    func noRetainCycle() {
        weak var weakAccount: Account?
        do {
            let account = Account(owner: "Ada", balance: 0)
            account.deposit(1)
            weakAccount = account
            #expect(weakAccount != nil)
        }
        #expect(weakAccount == nil)
    }
}
