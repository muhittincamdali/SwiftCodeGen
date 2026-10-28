import Foundation

/// The lock that a ``Synchronized()`` class holds while it reads or writes one of its properties.
///
/// Every `@Synchronized` class owns exactly one `SynchronizedLock`. The macro creates it; you
/// normally use it only through the generated `withLock(_:)` method.
///
/// The lock is *recursive*: a thread that already holds it can take it again. That is what lets
/// the body of `withLock(_:)` read and write the class's properties with plain syntax, each of
/// which takes the lock once more on the same thread.
public final class SynchronizedLock: Sendable {
    // NSRecursiveLock is documented as safe to use from any thread.
    private let base = NSRecursiveLock()

    /// Creates an unlocked lock.
    public init() {}

    /// Takes the lock, waiting until no other thread holds it.
    ///
    /// Every call must be balanced by a call to ``unlock()`` on the same thread.
    public func lock() {
        base.lock()
    }

    /// Gives up the lock taken by the matching ``lock()`` call.
    public func unlock() {
        base.unlock()
    }

    /// Runs `body` while holding the lock and returns its result.
    ///
    /// The lock is given up when `body` returns or throws.
    public func withLock<Result, Failure: Error>(
        _ body: () throws(Failure) -> Result
    ) throws(Failure) -> Result {
        base.lock()
        defer { base.unlock() }
        return try body()
    }
}
