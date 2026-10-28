import Foundation

/// Sends each new value to any number of `AsyncStream` subscribers.
///
/// An `AsyncStream` has one consumer. `StreamBroadcast` hands out a new stream to every caller of
/// ``subscribe(current:)`` and delivers each value passed to ``send(_:)`` to all of them. A
/// ``Streamed()`` property uses one to implement its `…Updates` stream, and you can use it on its
/// own.
///
/// Memory stays bounded however slow a subscriber is:
///
/// - Each stream keeps only the newest value it has not delivered yet
///   (`AsyncStream.Continuation.BufferingPolicy.bufferingNewest(1)`). A subscriber that falls
///   behind skips to the latest value instead of queueing every change.
/// - A subscriber is forgotten as soon as its stream ends: when the task iterating it is
///   cancelled, when the loop breaks, or when the stream is dropped without being iterated.
/// - When the broadcast itself is released, every stream finishes and every `for await` loop
///   over one of them ends.
public final class StreamBroadcast<Value: Sendable>: Sendable {
    private struct State {
        var continuations: [UInt64: AsyncStream<Value>.Continuation] = [:]
        var nextID: UInt64 = 0
        var latest: Value?
    }

    private let lock = NSLock()
    // Only read or written while `lock` is held.
    nonisolated(unsafe) private var state = State()

    /// Creates a broadcast with no subscribers.
    public init() {}

    deinit {
        // `finish()` runs the termination handler at once. The handler only takes the lock of a
        // broadcast that still exists, so finishing here, without the lock, cannot deadlock.
        for continuation in state.continuations.values {
            continuation.finish()
        }
    }

    /// The number of streams that have not ended yet.
    public var subscriberCount: Int {
        lock.withLock { state.continuations.count }
    }

    /// Returns a new stream that starts with `current` and then delivers every value passed to
    /// ``send(_:)``.
    ///
    /// - Parameter current: The first value of the stream, normally the value the sender holds
    ///   right now. Call this method and ``send(_:)`` under the same lock as the change of that
    ///   value, so that no change falls between the first value and the next one.
    public func subscribe(current: Value) -> AsyncStream<Value> {
        let (stream, continuation) = AsyncStream<Value>.makeStream(
            bufferingPolicy: .bufferingNewest(1)
        )
        continuation.yield(current)
        let id = lock.withLock {
            let id = state.nextID
            state.nextID &+= 1
            state.continuations[id] = continuation
            state.latest = current
            return id
        }
        continuation.onTermination = { [weak self] _ in
            self?.removeSubscriber(id)
        }
        return stream
    }

    /// Delivers `value` to every current subscriber.
    public func send(_ value: Value) {
        lock.withLock {
            state.latest = value
            for continuation in state.continuations.values {
                continuation.yield(value)
            }
        }
    }

    /// Ends every stream handed out so far. Later calls to ``subscribe(current:)`` start new
    /// streams.
    public func finishAll() {
        let finished = lock.withLock {
            let continuations = state.continuations.values
            state.continuations.removeAll()
            return continuations
        }
        // Outside the lock: `finish()` runs the termination handler, which takes the lock.
        for continuation in finished {
            continuation.finish()
        }
    }

    private func removeSubscriber(_ id: UInt64) {
        lock.withLock {
            _ = state.continuations.removeValue(forKey: id)
        }
    }
}

extension StreamBroadcast where Value: Equatable {
    /// Delivers `value` to every current subscriber unless it equals the last value sent or
    /// subscribed with.
    ///
    /// Assigning a property the value it already has therefore does not wake its subscribers.
    public func send(_ value: Value) {
        lock.withLock {
            if let latest = state.latest, latest == value { return }
            state.latest = value
            for continuation in state.continuations.values {
                continuation.yield(value)
            }
        }
    }
}
