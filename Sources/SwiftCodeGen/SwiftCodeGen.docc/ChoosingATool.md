# Choosing a tool

When `@Synchronized` fits, and when an actor, `Mutex` or a code generator does the job better.

## Overview

SwiftCodeGen does one thing: it makes a class whose state synchronous code shares across
threads `Sendable`, with a lock the compiler writes and checks. Many problems that look similar
are better solved with something else.

### Use `@Synchronized` when

- the state is read and written from synchronous code, such as a delegate callback, a
  `URLSession` or `AVFoundation` handler, a logger or a cache that a view model reads, and an
  `await` at every call site is not possible or not wanted;
- you are moving a class with a hand-written lock and `@unchecked Sendable` to Swift 6 and want
  the compiler to check the rest of the class again;
- several properties have to change together (`withLock`), or other code wants to follow them
  with `for await` (`@Streamed`).

### Use something else when

| Situation                                                              | Better choice                                                                                                                                          |
| ---------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| The work on the state is itself `async` (network, disk)                | An `actor`. Its methods can suspend; a lock must never be held across an `await`.                                                                      |
| One or two values, iOS 18 or later                                     | `Mutex` from the Synchronization module, without a macro.                                                                                              |
| UI state that SwiftUI observes on the main actor                       | `@Observable` with `@MainActor`.                                                                                                                       |
| Following an `@Observable` model as an async sequence, iOS 26 or later | `Observations` from the Observation module.                                                                                                            |
| Mocks and spies of protocols for tests                                 | [Mockable](https://github.com/Kolos65/Mockable) or [swift-spyable](https://github.com/Matejkob/swift-spyable).                                         |
| Generating code across many types from templates                       | [Sourcery](https://github.com/krzysztofzablocki/Sourcery).                                                                                             |
| Client and server code from an OpenAPI document                        | [swift-openapi-generator](https://github.com/apple/swift-openapi-generator).                                                                           |
| Typed names for images, colors and strings                             | Xcode itself: asset catalogs and String Catalogs generate symbols; [SwiftGen](https://github.com/SwiftGen/SwiftGen) for fonts, plists and other files. |
| Single-flight requests, retries, timeouts, rate limits                 | [SwiftConcurrency](https://github.com/muhittincamdali/SwiftConcurrency).                                                                               |

### Costs to keep in mind

- Every property access takes and releases a lock. Next to the work an app does with its
  state that is nothing; in a tight loop over thousands of elements, copy the value into a local
  variable once, or do the whole loop inside `withLock`.
- A getter returns a copy. `cache.images.count` copies nothing large (arrays are copy-on-write),
  but code that reads a property, works on it and writes it back is two steps: use
  `withLock` or an in-place mutation such as `cache.images[url] = data`.
- The lock is held while the in-place mutation runs. Code that runs inside it, such as the
  closure passed to `sort(by:)`, must not wait for another thread that needs the same object.
