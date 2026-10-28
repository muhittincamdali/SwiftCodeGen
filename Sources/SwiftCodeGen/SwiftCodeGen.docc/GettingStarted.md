# Getting started

Add the package, attach `@Synchronized` to a final class and use it from any thread.

## Overview

SwiftCodeGen needs Swift 6.2 (Xcode 26) or later and runs on iOS 16, macOS 13, tvOS 16,
watchOS 9 and visionOS 1 or later. Its only dependency is
[swift-syntax](https://github.com/swiftlang/swift-syntax), which the compiler uses to expand
the macros; nothing of it ships in your app.

### Add the package

In Xcode, choose **File › Add Package Dependencies…**, enter
`https://github.com/muhittincamdali/SwiftCodeGen` and add the **SwiftCodeGen** library to your
app target. The first build asks you to trust the macros: choose **Trust & Enable**.

In a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftCodeGen.git", branch: "main"),
],
targets: [
    .target(name: "MyApp", dependencies: ["SwiftCodeGen"]),
]
```

### Make a class Sendable

Attach ``Synchronized()`` to a `final` class and write its properties as usual:

```swift
import SwiftCodeGen

@Synchronized
final class Session {
    let id: UUID
    var token: String
    var expiresAt: Date?
    weak var observer: SessionObserver?

    init(token: String) {
        id = UUID()
        self.token = token
    }
}
```

What changes:

- Each stored `var` becomes a computed property. Its getter, setter and in-place modification
  run while the object's ``SynchronizedLock`` is held, so `count += 1`, `items.append(x)` and
  `cache[key] = value` cannot lose an update when two threads run them at once.
- Default values, `self.token = token` in an initializer, implicit `nil` for optionals, and
  `weak` or `unowned` references keep working.
- `let` constants, computed properties and `static` properties are not touched. A `let` must be
  `Sendable`, which the compiler checks as for any `Sendable` class.
- The class gets `Sendable` conformance, checked by the compiler.

### Do several things as one step

A single property access is atomic; two accesses are two steps, and another thread can run
between them. Wrap steps that belong together in `withLock(_:)`:

```swift
func renew(with token: String, validFor duration: TimeInterval) {
    session.withLock {
        session.token = token
        session.expiresAt = Date().addingTimeInterval(duration)
    }
}
```

The lock is recursive: the property accesses inside the closure take it again on the same
thread, so you keep the plain property syntax. `withLock` returns the closure's result and
rethrows its error with its type (`throws(Failure)`).

> Important: Do not call `withLock` of a second object inside `withLock` of a first one when
> another thread may do it the other way round; two threads that take the same two locks in
> opposite order wait for each other forever. Within one object, nesting is fine.

### Apps with MainActor default isolation

New Xcode 26+ app targets set **Default Actor Isolation** to `MainActor`. A `@Synchronized`
class stays usable from background tasks there: its `Sendable` conformance keeps it out of the
main actor (verified with Swift 6.4). If you prefer to state it in the declaration, write
`nonisolated final class`; the example app in the repository builds with these settings.

Value types that a `@Synchronized` class stores or streams are main-actor types too in such a
target. Declare the ones you compare or stream from other threads `nonisolated`, for example
`nonisolated enum UploadStatus: Sendable, Equatable`; see <doc:StreamingChanges>.

### What the macro rejects

The macro reports an error, with a fix where one is clear, instead of producing code that is not
safe:

| Declaration                             | Why                                                                     |
| --------------------------------------- | ----------------------------------------------------------------------- |
| `struct`, `enum`                        | Value types are `Sendable` when their stored properties are.            |
| `actor`                                 | An actor already protects its state.                                    |
| A class that is not `final`             | A subclass could add state the lock does not guard. Fix: add `final`.   |
| `@MainActor` on the class or a property | The lock replaces actor isolation. Fix: remove the attribute.           |
| `lazy var`                              | Its first access would initialize outside the lock. Fix: remove `lazy`. |
| `willSet`, `didSet`                     | Move that code into a method that sets the property.                    |
| A property wrapper                      | The wrapper's storage would not be guarded.                             |
| `var a = 0, b = 1`, `var (a, b) = …`    | Declare each property on its own line.                                  |

The attribute check recognizes a global actor by a name that ends in `Actor`, such as
`@MainActor`. With any other global actor the class stops compiling at the generated
`_requireNoGlobalActor()`, with "call to global actor '…'-isolated instance method 'withLock' in
a synchronous nonisolated context"; remove the attribute there as well.

To leave a property out on purpose, mark it `nonisolated(unsafe)`; the compiler then trusts you
with it, as it would without the macro.
