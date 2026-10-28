<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg" alt="SwiftCodeGen: Swift macros that make a class Sendable without @unchecked and stream its changes."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml/badge.svg" alt="CI status"></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg" alt="Latest version: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg" alt="Supported platforms: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg" alt="Language version: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg" alt="License: MIT"></picture></a>
</p>

<p align="center">
<a href="#quick-start"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-en-light.svg" alt="Get started"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-en-light.svg" alt="Documentation"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-en-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-en-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-en-light.svg" alt="Examples"></picture></a>
</p>

<!-- brand:end -->

SwiftCodeGen is a small Swift 6 macro package for one problem that strict concurrency makes
common: a class whose state synchronous code shares across threads — a cache, a session, a
download delegate, a counter. Swift 6 only lets such a class cross threads when it is
`Sendable`, and the usual answers are a hand-written lock behind `@unchecked Sendable`, which
the compiler stops checking, or an actor, which turns every call into an `await`. Attach
`@Synchronized` instead: every stored `var` is guarded by one lock, `count += 1` cannot lose an
update, `withLock` groups several steps, and the class becomes `Sendable` with the compiler's
check still on. `@Streamed` adds an `AsyncStream` of a property's values for any number of
subscribers.

## Highlights

- **Checked `Sendable`, no `@unchecked`** — the macro adds a real `Sendable` conformance, so a
  `let` of a non-`Sendable` type is still a compile error.
- **No lost updates** — getters, setters and in-place changes (`+=`, `append`, `dict[key] =`)
  run under the lock; 2,000 concurrent `+=` in the tests count to exactly 2,000.
- **Several steps as one** — `withLock { … }` holds the lock for a block of code with plain
  property syntax inside, and passes typed errors through (`throws(Failure)`).
- **Nothing to rewrite** — default values, `self.x = x` in `init`, implicit `nil`, `weak` and
  `unowned` keep working; `let`, computed and `static` properties are left alone.
- **Streams of changes** — `@Streamed var progress: Double` adds `progressUpdates`: the current
  value first, then every change in order, one buffered value per subscriber, ended when the
  object goes away.
- **Errors instead of surprises** — structs, actors, non-final classes, `@MainActor`, `lazy`,
  observers and property wrappers are rejected with a reason, and with a fix where one is clear.

## Quick start

**1. Add the package**

In Xcode, choose **File › Add Package Dependencies…**, enter the repository URL and add the
**SwiftCodeGen** library to your target. On the first build, choose **Trust & Enable** for the
macros.

```text
https://github.com/muhittincamdali/SwiftCodeGen.git
```

**2. Import the module**

```swift
import SwiftCodeGen
```

**3. Attach `@Synchronized` to a final class**

A cache that any thread can use without `await`
([ReadmeSamples.swift](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift)):

```swift
@Synchronized
final class ImageCache {
    var images: [URL: Data] = [:]
    var hits = 0
    var misses = 0

    func image(for url: URL) -> Data? {
        // Reading the cache and counting the hit or miss happen as one step.
        withLock {
            if let data = images[url] {
                hits += 1
                return data
            }
            misses += 1
            return nil
        }
    }

    func store(_ data: Data, for url: URL) {
        images[url] = data
    }
}
```

`ImageCache` is now `Sendable`: pass it to a `Task.detached`, a task group or a callback on any
queue, and call it without `await`.

## Installation

### Swift Package Manager

Add it to the `dependencies` in your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftCodeGen.git", branch: "main")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwiftCodeGen", package: "SwiftCodeGen")
    ])
]
```

The package depends on [swift-syntax](https://github.com/swiftlang/swift-syntax) (602 to 604),
which the compiler uses to expand the macros; none of it is linked into your app. Command-line
builds with `xcodebuild` need `-skipMacroValidation`, or a one-time trust in Xcode.

## Usage

The samples below are copied from
[`ReadmeSamples.swift`](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift), which the example app
builds with MainActor default isolation and the test suite runs.

### Change several properties together

Each property access is one locked step. Steps that belong together go into `withLock`, so no
other thread sees `progress` and `status` disagree:

```swift
// `nonisolated`: with MainActor default isolation, the Equatable conformance would otherwise be
// isolated to the main actor, and the stream could not skip repeated values off the main actor.
nonisolated enum UploadStatus: Sendable, Equatable {
    case waiting
    case uploading
    case finished
}

/// Progress that a background upload writes and any number of views read.
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
        // The three properties change together; a reader never sees them disagree.
        withLock {
            sentChunks = min(sentChunks + 1, totalChunks)
            progress = Double(sentChunks) / Double(totalChunks)
            status = sentChunks < totalChunks ? .uploading : .finished
        }
    }
}
```

The lock is recursive, so the property accesses inside `withLock` take it again on the same
thread. Do not take the locks of two objects in opposite orders on two threads; that deadlocks,
as with any pair of locks.

### Follow changes with `for await`

`@Streamed` gave `UploadTracker` the properties `progressUpdates` and `statusUpdates`. Each read
returns a new stream that starts with the current value:

```swift
/// Waits until the upload has finished and returns the statuses it went through.
func waitForUpload(_ tracker: UploadTracker) async -> [UploadStatus] {
    var seen: [UploadStatus] = []
    for await status in tracker.statusUpdates {
        seen.append(status)
        if status == .finished { break }
    }
    return seen
}
```

Values are sent while the lock is held, so every subscriber sees the changes in the order they
happened. For an `Equatable` type, assigning the value a property already has sends nothing; in
an app target with MainActor default isolation, declare such a type `nonisolated`, as
`UploadStatus` above, or its conformance belongs to the main actor and every assignment is sent. A
subscriber that falls behind keeps only the newest value. Streams end when the object is
released, and a stream does not keep its object alive.

### Initializers and weak references

Properties keep working in initializers, optionals start as `nil`, and `weak` stays weak:

```swift
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

### What the macro writes

Use **Editor › Expand Macro** in Xcode to see the code for any class. For `var hits = 0` it is:

```swift
var hits {
    @storageRestrictions(initializes: _hits)
    init(initialValue) {
        _hits = initialValue
    }
    get {
        _lock.lock()
        defer {
            _lock.unlock()
        }
        return _hits
    }
    set {
        _lock.lock()
        defer {
            _lock.unlock()
        }
        _hits = newValue
    }
    _modify {
        _lock.lock()
        defer {
            _lock.unlock()
        }
        yield &_hits
    }
}

nonisolated(unsafe) private var _hits = 0
```

plus, once per class, `private let _lock = SwiftCodeGen.SynchronizedLock()`, the `withLock`
method and `extension ImageCache: Sendable {}`. The storage is `nonisolated(unsafe)` because
the lock, not the compiler, guards it; every other member of the class is still checked.

### What the macro rejects

| Declaration | Error, and the fix it offers |
| --- | --- |
| `struct`, `enum` | Value types are `Sendable` when their stored properties are. |
| `actor` | An actor already protects its state. |
| `class` without `final` | A subclass could add state the lock does not guard. Fix: add `final`. |
| `@MainActor` on the class or a property | The lock replaces actor isolation. Fix: remove it. |
| `lazy var` | Fix: remove `lazy`. |
| `willSet` / `didSet` | Move the code into a method that sets the property. |
| A property wrapper | Its storage would not be guarded. |
| `var a = 0, b = 1`, `var (a, b) = …` | Declare each property on its own line. |
| `@Streamed` on a `let`, `static`, computed, `weak` or untyped property | Each with its own message. |

To leave a property out on purpose, mark it `nonisolated(unsafe)`.

## Demo

The example app in [`Examples/SyncDemo`](Examples/SyncDemo) runs both macros on an iPhone or a
Mac. The screenshots below are taken from its Mac build by
[`scripts/capture-mac-screens.sh`](scripts/capture-mac-screens.sh);
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) takes the same
screens on an iPhone simulator.

| Shared counter | Upload progress |
| --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-counter-dark.png"><img src="docs/images/demo-counter-light.png" width="320" alt="Shared counter: eight tasks add one 20,000 times each; one locked step counts 160,000, two locked steps lose updates"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-upload-dark.png"><img src="docs/images/demo-upload-light.png" width="320" alt="Upload progress: one subscriber shows 100 percent after 21 values, the other shows waiting, uploading and finished once each"></picture> |

## Documentation

- [SwiftCodeGen reference](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/)
- [Getting started](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/gettingstarted)
- [Streaming changes](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/streamingchanges)
- [Choosing a tool](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/choosingatool)

## Guides

- [Getting started](Sources/SwiftCodeGen/SwiftCodeGen.docc/GettingStarted.md) — what the macro
  changes, `withLock`, MainActor default isolation and the declarations it rejects.
- [Streaming changes](Sources/SwiftCodeGen/SwiftCodeGen.docc/StreamingChanges.md) — what a
  subscriber receives, when a stream ends, and `StreamBroadcast` on its own.
- [Choosing a tool](Sources/SwiftCodeGen/SwiftCodeGen.docc/ChoosingATool.md) — when an actor,
  `Mutex` or another package is the better choice.

## When to use something else

SwiftCodeGen is not a general code generator. For the jobs the well-known tools do, use them:

| You want | Use |
| --- | --- |
| State whose work is `async` (network, disk) | An `actor`: its methods can suspend, a lock must not be held across `await`. |
| One or two guarded values on iOS 18+ | `Mutex` from the Synchronization module. |
| UI state that SwiftUI observes | `@Observable` on the main actor. |
| Mocks and spies of protocols | [Mockable](https://github.com/Kolos65/Mockable), [swift-spyable](https://github.com/Matejkob/swift-spyable) |
| Code generated from templates across many types | [Sourcery](https://github.com/krzysztofzablocki/Sourcery) |
| Clients and servers from an OpenAPI document | [swift-openapi-generator](https://github.com/apple/swift-openapi-generator) |
| Typed names for images, colors and strings | Xcode's generated asset and String Catalog symbols; [SwiftGen](https://github.com/SwiftGen/SwiftGen) for fonts, plists and other files |
| Retries, timeouts, single-flight requests | [SwiftConcurrency](https://github.com/muhittincamdali/SwiftConcurrency) |

## Requirements

| Platform | Minimum version |
| --- | --- |
| iOS | 16 |
| macOS | 13 |
| tvOS | 16 |
| watchOS | 9 |
| visionOS | 1 |
| Toolchain | Swift 6.2 · Xcode 26+ |

## Architecture

| Target | Contents |
| --- | --- |
| `SwiftCodeGen` | The macro declarations, `SynchronizedLock` (a recursive lock) and `StreamBroadcast` (multi-subscriber `AsyncStream`) |
| `SwiftCodeGenMacros` | The compiler plugin: `SynchronizedMacro` (member, member-attribute and extension roles), `SynchronizedPropertyMacro` (accessors and storage), `StreamedMacro` (checks), `PropertyAnalysis` and the diagnostics |
| `SwiftCodeGenTests` | Runtime tests on macOS and the iOS simulator: concurrency, streams, README samples |
| `SwiftCodeGenMainActorTests` | The macros in a target with MainActor default isolation, like a new app |
| `SwiftCodeGenMacrosTests` | Exact expansions and every diagnostic with its fix-it (macOS) |

- **One lock per object, not per property.** A single recursive lock is what makes `withLock`
  cover several properties, and lets the code inside it use plain property syntax.
- **Init accessors, not body macros.** The storage is initialized through
  `@storageRestrictions(initializes:)`, so initializers and default values work as written on
  every Swift 6.2 compiler.
- **`_modify` under the lock.** In-place changes yield the storage while the lock is held; that
  is what makes `+=` and `append` atomic. A `weak` or `unowned` property only gets `get` and
  `set`.

## Roadmap

- An option to name the stream property (`@Streamed(as: "progressStream")`).
- A public `withLock` for public classes, as an opt-in (`@Synchronized(.publicLock)`); today it
  is internal so that code outside the module cannot hold the lock.
- Linux in CI: the package uses only Foundation's `NSRecursiveLock` and `NSLock`, but it is
  tested on Apple platforms only.

## Contributing

Contributions are welcome. Read the [contributing guide](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CONTRIBUTING.md) and the [code of conduct](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CODE_OF_CONDUCT.md) before opening a pull request. Report security issues privately as described in the [security policy](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/SECURITY.md).

## License

Released under the MIT license. See [LICENSE](LICENSE).
