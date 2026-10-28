#if canImport(SwiftCodeGenMacros)
import SwiftCodeGenMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacrosGenericTestSupport
import Testing

/// The members `@Synchronized` adds to every class, indented for a class body.
let lockMembers = """
        private let _lock = SwiftCodeGen.SynchronizedLock()

        /// Runs `body` while holding the lock that guards every synchronized property of this
        /// object, and returns its result.
        ///
        /// Use it to change several properties together, or to read a property and write it
        /// back as one step. Inside `body` the properties keep their plain syntax.
        func withLock<Result, Failure: Error>(
            _ body: () throws(Failure) -> Result
        ) throws(Failure) -> Result {
            try _lock.withLock(body)
        }
    """

/// The locked accessors of a property whose storage is `storage`.
func lockedAccessors(_ storage: String, notify: String? = nil, modify: Bool = true) -> String {
    let send = notify.map { "\n            \($0).send(\(storage))" } ?? ""
    var text = """
            @storageRestrictions(initializes: \(storage))
            init(initialValue) {
                \(storage) = initialValue
            }
            get {
                _lock.lock()
                defer {
                    _lock.unlock()
                }
                return \(storage)
            }
            set {
                _lock.lock()
                defer {
                    _lock.unlock()
                }
                \(storage) = newValue\(send)
            }
    """
    if modify {
        // The send runs in the defer, so that a throwing in-place mutation still sends.
        let release = notify.map { "\($0).send(\(storage))\n                " } ?? ""
        text += """

                _modify {
                    _lock.lock()
                    defer {
                        \(release)_lock.unlock()
                    }
                    yield &\(storage)
                }
        """
    }
    return text
}

@Suite("Macro expansion")
struct ExpansionTests {
    @Test("Stored vars get locked accessors; let, computed and static members stay")
    func basicClass() {
        assertExpansion(
            """
            @Synchronized
            final class Store {
                let id: String
                var count: Int = 0
                var name = "untitled"
                var isEmpty: Bool { count == 0 }
                static var shared = 1
            }
            """,
            expandedSource: """
            final class Store {
                let id: String
                var count: Int {
            \(lockedAccessors("_count"))
                }

                nonisolated(unsafe) private var _count: Int
                var name {
            \(lockedAccessors("_name"))
                }

                nonisolated(unsafe) private var _name = "untitled"
                var isEmpty: Bool { count == 0 }
                static var shared = 1

            \(lockMembers)
            }

            extension Store: Sendable {
            }
            """
        )
    }

    @Test("A weak var keeps weak storage and has no in-place accessor")
    func weakProperty() {
        assertExpansion(
            """
            @Synchronized
            final class Store {
                weak var delegate: Delegate?
            }
            """,
            expandedSource: """
            final class Store {
                weak var delegate: Delegate? {
            \(lockedAccessors("_delegate", modify: false))
                }

                nonisolated(unsafe) private weak var _delegate: Delegate?

            \(lockMembers)
            }

            extension Store: Sendable {
            }
            """
        )
    }

    @Test("@Streamed adds a broadcast and a stream with the property's read access")
    func streamedProperty() {
        assertExpansion(
            """
            @Synchronized
            public final class Store {
                @Streamed public private(set) var name: String!
            }
            """,
            expandedSource: """
            public final class Store {
                public private(set) var name: String! {
            \(lockedAccessors("_name", notify: "_nameUpdates"))
                }

                nonisolated(unsafe) private var _name: String!

                private let _nameUpdates = SwiftCodeGen.StreamBroadcast<String?>()

                /// The values of `name`: the current one first, then every change.
                public var nameUpdates: AsyncStream<String?> {
                    _lock.lock()
                    defer {
                        _lock.unlock()
                    }
                    return _nameUpdates.subscribe(current: _name)
                }

            \(lockMembers)
            }

            extension Store: Sendable {
            }
            """
        )
    }

    @Test("A class that already declares Sendable gets no second conformance")
    func alreadySendable() {
        assertExpansion(
            """
            @Synchronized
            final class Store: Sendable {
            }
            """,
            expandedSource: """
            final class Store: Sendable {

            \(lockMembers)
            }
            """,
            conformances: [
                "Synchronized": MacroSpec(type: SynchronizedMacro.self, conformances: []),
            ]
        )
    }

    @Test("nonisolated(unsafe) opts a property out")
    func unsafeOptOut() {
        assertExpansion(
            """
            @Synchronized
            final class Store {
                nonisolated(unsafe) var cache: [String: Int] = [:]
            }
            """,
            expandedSource: """
            final class Store {
                nonisolated(unsafe) var cache: [String: Int] = [:]

            \(lockMembers)
            }

            extension Store: Sendable {
            }
            """
        )
    }
}
#endif
