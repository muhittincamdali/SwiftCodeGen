# Streaming changes

Follow a property of a `@Synchronized` class with `for await`, from as many tasks as you like.

## Overview

Mark a property with ``Streamed()`` and give it an explicit type:

```swift
@Synchronized
final class UploadTracker {
    let totalChunks: Int
    @Streamed var progress: Double = 0
    @Streamed var status: UploadStatus = .waiting
    private var sentChunks = 0

    init(totalChunks: Int) {
        precondition(totalChunks > 0, "An upload has at least one chunk")
        self.totalChunks = totalChunks
    }

    func chunkSent() {
        withLock {
            sentChunks = min(sentChunks + 1, totalChunks)
            progress = Double(sentChunks) / Double(totalChunks)
            status = sentChunks < totalChunks ? .uploading : .finished
        }
    }
}
```

For each streamed property the macro adds a property named after it with `Updates` at the end:
`progressUpdates` and `statusUpdates`, of type `AsyncStream<Double>` and
`AsyncStream<UploadStatus>`, with the same access level as the property's getter.

```swift
for await status in tracker.statusUpdates {
    print(status)
    if status == .finished { break }
}
```

In SwiftUI, follow a stream in a `task` modifier; the loop ends when the view goes away:

```swift
ProgressView(value: progress)
    .task {
        for await value in tracker.progressUpdates {
            progress = value
        }
    }
```

### What a subscriber receives

- **The current value first.** Every read of `progressUpdates` returns a new stream whose first
  element is the value at that moment, so a view never starts empty.
- **Every later change, in order.** The new value is sent while the lock is still held, so two
  threads that change the property one after the other are seen in that order by everyone.
- **Only real changes for `Equatable` types.** Assigning the value the property already has
  sends nothing. Types that are not `Equatable` send every assignment.
- **The newest value when behind.** Each stream keeps one undelivered value. A subscriber that
  is slower than the writer skips to the latest value instead of building a queue; ten thousand
  changes while it is busy cost one buffered value.

### When a stream ends

A stream ends, and the object forgets it, when the task iterating it is cancelled, when the loop
breaks, or when the stream is released without being iterated. When the object itself is
released, every stream ends and every `for await` loop over one finishes; a stream does not keep
its object alive.

### Without the macro

``StreamBroadcast`` is the type behind `@Streamed`, and you can use it on its own: call
``StreamBroadcast/subscribe(current:)`` for each subscriber and `send(_:)`
for each new value. Call both under the lock that protects the value, as the macro does, so that
no change falls between the first value and the next.
