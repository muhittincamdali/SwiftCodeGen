# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.0.0] - 2026-10-28

SwiftCodeGen 2 is a new package under the old name. The 1.x code generators were removed in
June 2026 and what remained did not build; 2.0 replaces them with two Swift macros for Swift 6
strict concurrency, each tested and documented. Nothing from the 1.x API is kept: for asset,
string, OpenAPI or mock generation, the README lists the tools to use.

### Added

- `@Synchronized` for final classes: every stored `var` gets a getter, setter and in-place
  accessor (`_modify`) that run under one recursive `SynchronizedLock`, with the value in a
  private storage property initialized through an init accessor. Default values, assignments in
  `init`, implicit `nil`, `weak` and `unowned` keep working; `let`, computed, `static` and
  `nonisolated(unsafe)` properties are left alone. The macro adds `withLock(_:)` with typed
  throws and a checked `Sendable` conformance.
- `@Streamed` for properties of a `@Synchronized` class: adds `<name>Updates`, an
  `AsyncStream` that starts with the current value and delivers every change in order to any
  number of subscribers, skips equal values of `Equatable` types and ends when the object is
  released.
- `StreamBroadcast`, the multi-subscriber stream behind `@Streamed`: one buffered value per
  subscriber, subscribers forgotten when their stream ends or is dropped.
- Compiler errors, with fix-its where the fix is clear, for structs, enums, actors, non-final
  classes (add `final`), global-actor isolation (remove it), `lazy` (remove it), observers,
  overrides, property wrappers, several bindings, tuple patterns, and misuses of `@Streamed`.
  A class isolated to a global actor whose name does not end in `Actor` fails to compile at a
  generated nonisolated call to `withLock`.
- A DocC catalog with the articles "Getting started", "Streaming changes" and "Choosing a
  tool", published to GitHub Pages.
- The example app `SyncDemo` (iOS and macOS, MainActor default isolation) with a shared
  counter and an upload whose progress two views follow; the README samples are compiled by
  the app and run by the tests.

### Removed

- The 1.x sources: `CodeGenCore`, the OpenAPI parser stub, the Xcode plugin generator, the
  retry, circuit breaker, event bus and metrics helpers, and the command-line tool.
- The CocoaPods podspec: macros need Swift Package Manager.

## [1.0.0] - 2026-02-03

First release, with code generators for assets, strings, models, mocks and dependency
injection.

[Unreleased]: https://github.com/muhittincamdali/SwiftCodeGen/compare/v2.0.0...HEAD
[2.0.0]: https://github.com/muhittincamdali/SwiftCodeGen/compare/v1.0.0...v2.0.0
[1.0.0]: https://github.com/muhittincamdali/SwiftCodeGen/releases/tag/v1.0.0
