# Examples

## SyncDemo

A small iOS and macOS app with one screen per macro:

- **Shared counter** — eight background tasks each add one 20,000 times to a `@Synchronized`
  counter, first with `counter.hits += 1` (one locked step: no update is lost), then with a
  read followed by a write (two locked steps: updates are lost, and the screen shows how many).
- **Upload progress** — a background task sends twenty chunks to an `UploadTracker`; one view
  follows `progressUpdates` and another `statusUpdates`, each through its own `@Streamed`
  stream.

The app target uses the settings of a new Xcode 26+ app, MainActor as the default actor
isolation and approachable concurrency, to show that a `@Synchronized` class stays usable from
background tasks there. It uses the package from this checkout (a local package reference to
`../..`), so it always shows the current code.

Run it:

1. Open `Examples/SyncDemo/SyncDemo.xcodeproj` in Xcode 26 or later.
2. Choose the **SyncDemo** scheme and an iPhone simulator or **My Mac** as the run destination.
3. Press **Run** (⌘R). The first build asks you to trust the package's macros.

From the command line:

```sh
cd Examples/SyncDemo
xcodebuild build -scheme SyncDemo -destination 'generic/platform=iOS Simulator' -skipMacroValidation
xcodebuild build -scheme SyncDemo -destination 'platform=macOS' -skipMacroValidation
```

The README samples live in
[`SyncDemo/ReadmeSamples.swift`](SyncDemo/SyncDemo/ReadmeSamples.swift). The README copies its
code from that file, and the package's test target compiles and runs the same file through the
symlink `Tests/SwiftCodeGenTests/ReadmeSamples.swift`.

The screenshots in the README come from this app:
[`scripts/capture-mac-screens.sh`](../scripts/capture-mac-screens.sh) opens each screen of the
Mac build with `-demo counter` or `-demo upload` and `-appearance light` or `-appearance dark`,
lets it play its scenario and captures the window.
[`scripts/capture-example-screens.sh`](../scripts/capture-example-screens.sh) does the same on an
iPhone simulator.

The project file is made with [XcodeGen](https://github.com/yonaskolb/XcodeGen) from
[`project.yml`](SyncDemo/project.yml) and committed, so you only need XcodeGen after editing
`project.yml`.
