## What this changes

<!-- What does the pull request do, and why? Link the issue it closes, e.g. "Closes #12". -->

## How it was tested

<!-- New or changed tests, and anything you checked by hand (the example app, a simulator). -->

## Checklist

- [ ] `swift test` passes on macOS and the tests pass on an iOS simulator
- [ ] New behaviour has tests: a runtime test in `SwiftCodeGenTests` and, for a change to the
      expansion or a diagnostic, an expansion test in `SwiftCodeGenMacrosTests`
- [ ] Public symbols are documented and `xcodebuild docbuild` reports no warnings
- [ ] README samples and `ReadmeSamples.swift` still match
- [ ] `CHANGELOG.md` has an entry under `Unreleased`
