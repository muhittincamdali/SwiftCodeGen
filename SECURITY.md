# Security policy

## Supported versions

Security fixes go into the latest release and the `main` branch.

## Reporting a vulnerability

Report it privately, not in a public issue: open the repository's
[Security tab](https://github.com/muhittincamdali/SwiftCodeGen/security) and choose **Report a
vulnerability**, or follow the other channels in the
[security policy of the muhittincamdali repositories](https://github.com/muhittincamdali/.github/blob/main/SECURITY.md).
Include the class that shows the problem, the expansion Xcode shows for it (**Editor › Expand
Macro**) and the Swift and OS versions you used.

## What SwiftCodeGen promises

The macros run inside the compiler and read only the declaration they are attached to; the
code they write runs inside your app. These are the properties a report can hold it to:

- It does not log, print, store or send anything. The macros access no files or network, and
  the generated code touches only the properties of the class it is attached to.
- Every read, write and in-place change of a guarded property happens while the object's lock
  is held, and the class's `Sendable` conformance is checked by the compiler. A declaration the
  macro cannot make safe is a compile error, not silently left unguarded; the only unguarded
  stored state is what you mark `nonisolated(unsafe)` yourself.
- Memory stays bounded: each stream subscriber buffers at most one value, and subscribers whose
  stream ended, was cancelled or was dropped are removed. A stream does not keep its object
  alive, and all streams end when the object is released.

What it does not promise: freedom from deadlocks between two objects whose locks two threads
take in opposite orders, or from a crash when code running inside an in-place change of a
property accesses the same property again (Swift's exclusivity check stops that, as it would
without the macro).
