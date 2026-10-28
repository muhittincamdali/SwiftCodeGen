# ``SwiftCodeGen``

Swift macros that make a class `Sendable` without `@unchecked` and stream its changes.

## Overview

Swift 6 refuses to share a class with mutable state between threads unless the class is
`Sendable`. For a class that synchronous code uses from several threads — a cache, a session,
a download delegate, a counter — the usual ways out are `@unchecked Sendable` with a lock
written by hand, which the compiler no longer checks, or an actor, which turns every call into
an `await`.

``Synchronized()`` writes the lock for you and keeps the compiler's check:

```swift
import SwiftCodeGen

@Synchronized
final class ImageCache {
    var images: [URL: Data] = [:]
    var hits = 0
    var misses = 0

    func image(for url: URL) -> Data? {
        withLock {
            if let data = images[url] {
                hits += 1
                return data
            }
            misses += 1
            return nil
        }
    }
}
```

Every stored `var` is read and written under one lock; `hits += 1` and `images[url] = data`
are single locked steps; `withLock(_:)` groups several steps; and the class conforms to
`Sendable` without `@unchecked`, so a `let` of a non-`Sendable` type is still a compile error.

``Streamed()`` adds an `AsyncStream` of a property's values that any number of tasks can
follow with `for await`.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:StreamingChanges>
- <doc:ChoosingATool>

### Macros

- ``Synchronized()``
- ``Streamed()``

### Building blocks

- ``SynchronizedLock``
- ``StreamBroadcast``
