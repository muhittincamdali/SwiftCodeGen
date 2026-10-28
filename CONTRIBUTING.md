# Contributing to SwiftCodeGen

Thank you for helping. This guide covers what you need to build, test and change the package.

## Ground rules

- Be kind; the [code of conduct](CODE_OF_CONDUCT.md) applies everywhere in the project.
- Report security problems privately, as described in [SECURITY.md](SECURITY.md).
- Open an issue before a large change, so we can agree on the API first.

## Set up

You need Xcode 26 or later (Swift 6.2).

```sh
git clone https://github.com/muhittincamdali/SwiftCodeGen.git
cd SwiftCodeGen
swift build
swift test
```

Open `Package.swift` in Xcode to work on the package, and
`Examples/SyncDemo/SyncDemo.xcodeproj` to run the example app. Xcode asks you once to trust the
macros of this package.

## Checks to run before a pull request

```sh
swift test                                    # runtime, MainActor and macro tests on macOS
xcodebuild test -scheme SwiftCodeGen -only-testing:SwiftCodeGenTests \
  -destination 'platform=iOS Simulator,name=iPhone 17 Pro' -skipMacroValidation
xcodebuild docbuild -scheme SwiftCodeGen -destination 'generic/platform=macOS' -skipMacroValidation
xcodebuild build -project Examples/SyncDemo/SyncDemo.xcodeproj -scheme SyncDemo \
  -destination 'generic/platform=iOS Simulator' -skipMacroValidation
```

The macro tests (`SwiftCodeGenMacrosTests`) run only on the Mac, where macros run; on a
simulator, select the runtime tests with `-only-testing:SwiftCodeGenTests`. CI runs the same
steps, builds for tvOS, watchOS and visionOS, and checks links.

## How the macros are built

- `SynchronizedMacro` checks the declaration, adds `_lock` and `withLock`, attaches
  `@_SynchronizedProperty` to each stored `var` and adds the `Sendable` extension.
- `SynchronizedPropertyMacro` writes the accessors and the storage of one property, and the
  stream of a `@Streamed` one.
- `PropertyAnalysis` decides, for one `var`, whether it is guarded, skipped or rejected. All
  three macros use it, so a property is never treated two ways.
- Every error is a case of `SynchronizedDiagnostic`. Report each problem once: the class-level
  errors from the member role, property errors from the member-attribute role, and the
  `@Streamed` misuses that `@Synchronized` skips from `StreamedMacro`.

## Writing tests

- A change to the generated code needs an expansion test in `SwiftCodeGenMacrosTests` (the
  exact output) and a runtime test in `SwiftCodeGenTests` (that the output does what it
  should, for example under concurrent access).
- A new diagnostic needs a test with its message, position and, if it has one, the fixed source.
- Concurrency tests use enough tasks to fail without the lock (a few thousand operations) and
  never `Task.sleep` to wait for a result: await a task's `value` or a stream instead.

## README samples

The README's code comes from `Examples/SyncDemo/SyncDemo/ReadmeSamples.swift`, which the
tests compile through a symlink. Change the sample there first, then copy it into the README.
Regenerate the screenshots with `scripts/capture-example-screens.sh` when a demo screen
changes.

## Commits and pull requests

- Use [Conventional Commits](https://www.conventionalcommits.org/) (`feat:`, `fix:`, `docs:`,
  `test:`, `ci:`), one change per commit, with a body that says why.
- Add a line to the `Unreleased` section of [CHANGELOG.md](CHANGELOG.md) for every change a
  user would notice.
