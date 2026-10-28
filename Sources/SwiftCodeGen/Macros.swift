/// Makes a final class `Sendable` by guarding all of its stored `var` properties with one lock.
///
/// ```swift
/// @Synchronized
/// final class SessionStore {
///     var token: String?
///     var requestCount = 0
/// }
/// ```
///
/// The macro
///
/// - turns each stored `var` into a computed property whose getter, setter and in-place
///   modification (`+=`, `append`, …) run while holding the class's ``SynchronizedLock``, with the
///   value kept in a private stored property,
/// - adds `withLock(_:)`, which holds that lock for a block of code, so that several properties
///   change together or a read and a write happen as one step,
/// - adds `Sendable` conformance unless the class already declares it. The conformance is checked
///   by the compiler: there is no `@unchecked`, so a `let` of a non-`Sendable` type is still an
///   error.
///
/// Properties keep working in initializers (`self.token = token`), keep their default values and
/// can be `weak` or `unowned`. `let` constants, computed properties and `static` properties are
/// left as they are.
///
/// The class must be `final` and must not be isolated to a global actor such as `@MainActor`. In a
/// module whose default actor isolation is `MainActor`, declare it `nonisolated final class`.
@attached(member, names: named(_lock), named(withLock))
@attached(memberAttribute)
@attached(extension, conformances: Sendable)
public macro Synchronized() = #externalMacro(module: "SwiftCodeGenMacros", type: "SynchronizedMacro")

/// Adds an `AsyncStream` of the values of a property of a ``Synchronized()`` class.
///
/// ```swift
/// @Synchronized
/// final class DownloadState {
///     @Streamed var progress: Double = 0
/// }
///
/// for await progress in state.progressUpdates {
///     print(progress)
/// }
/// ```
///
/// For a property named `progress`, the macro adds `progressUpdates`, with the same access level
/// as the property. Each read of `progressUpdates` returns a new stream that starts with the
/// current value and then delivers every later value, in the order the changes happened, to
/// every subscriber. When the type is `Equatable`, assigning the value the property already has
/// sends nothing.
///
/// A subscriber that is slower than the changes skips to the newest value; streams end when the
/// object is released. See ``StreamBroadcast`` for the details.
///
/// The property needs an explicit type annotation, and the type must be `Sendable`.
@attached(peer)
public macro Streamed() = #externalMacro(module: "SwiftCodeGenMacros", type: "StreamedMacro")

/// Implementation detail of ``Synchronized()``: generates the locked accessors and storage of one
/// property. `@Synchronized` adds it to every stored `var`; do not write it yourself.
@attached(accessor, names: named(init), named(get), named(set), named(_modify))
@attached(peer, names: prefixed(_), suffixed(Updates), arbitrary)
public macro _SynchronizedProperty() = #externalMacro(
    module: "SwiftCodeGenMacros",
    type: "SynchronizedPropertyMacro"
)
