#if canImport(SwiftCodeGenMacros)
import SwiftSyntaxMacrosGenericTestSupport
import Testing

/// A class body after expansion: the given members, then the lock members, then `Sendable`.
func expandedClass(_ members: String) -> String {
    """
    final class Store {
    \(members)

    \(lockMembers)
    }

    extension Store: Sendable {
    }
    """
}

@Suite("Diagnostics")
struct DiagnosticTests {
    // MARK: - The declaration

    @Test("A struct is rejected")
    func structRejected() {
        assertExpansion(
            """
            @Synchronized
            struct Store {
                var count = 0
            }
            """,
            expandedSource: """
            struct Store {
                var count = 0
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized applies to a final class; a struct or enum is Sendable when its stored properties are",
                    line: 2, column: 1
                ),
            ]
        )
    }

    @Test("An enum is rejected")
    func enumRejected() {
        assertExpansion(
            """
            @Synchronized
            enum Mode {
                case on
            }
            """,
            expandedSource: """
            enum Mode {
                case on
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized applies to a final class; a struct or enum is Sendable when its stored properties are",
                    line: 2, column: 1
                ),
            ]
        )
    }

    @Test("An actor is rejected")
    func actorRejected() {
        assertExpansion(
            """
            @Synchronized
            actor Store {
                var count = 0
            }
            """,
            expandedSource: """
            actor Store {
                var count = 0
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized does not apply to an actor; an actor already protects its state, remove the attribute",
                    line: 2, column: 1
                ),
            ]
        )
    }

    @Test("A class that is not final is rejected, with a fix that adds final")
    func nonFinalRejected() {
        assertExpansion(
            """
            @Synchronized
            public class Store {
                var count = 0
            }
            """,
            expandedSource: """
            public class Store {
                var count = 0
            }
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized requires a final class: a subclass could add state that the lock does not guard",
                    line: 2, column: 8,
                    fixIts: [FixItSpec(message: "Add 'final'")]
                ),
            ],
            fixedSource: """
            @Synchronized
            public final class Store {
                var count = 0
            }
            """
        )
    }

    @Test("The final fix also works without other modifiers")
    func nonFinalWithoutModifiers() {
        assertExpansion(
            """
            @Synchronized
            class Store {}
            """,
            expandedSource: """
            class Store {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized requires a final class: a subclass could add state that the lock does not guard",
                    line: 2, column: 1,
                    fixIts: [FixItSpec(message: "Add 'final'")]
                ),
            ],
            fixedSource: """
            @Synchronized
            final class Store {}
            """
        )
    }

    @Test("A class isolated to a global actor is rejected, with a fix that removes it")
    func globalActorRejected() {
        assertExpansion(
            """
            @Synchronized @MainActor
            final class Store {}
            """,
            expandedSource: """
            @MainActor
            final class Store {}
            """,
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized class must not be isolated to a global actor; the lock already makes it safe to use from any thread",
                    line: 1, column: 15,
                    fixIts: [FixItSpec(message: "Remove the attribute")]
                ),
            ],
            fixedSource: """
            @Synchronized\u{0020}
            final class Store {}
            """
        )
    }

    // MARK: - Properties

    @Test("A lazy property is rejected, with a fix that removes lazy")
    func lazyRejected() {
        assertExpansion(
            """
            @Synchronized
            final class Store {
                lazy var cache: [Int] = []
            }
            """,
            expandedSource: expandedClass("    lazy var cache: [Int] = []"),
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized cannot guard a lazy property; give it a value in the declaration or in init",
                    line: 3, column: 5,
                    fixIts: [FixItSpec(message: "Remove 'lazy'")]
                ),
            ],
            fixedSource: """
            @Synchronized
            final class Store {
                var cache: [Int] = []
            }
            """
        )
    }

    @Test("Observers are rejected")
    func observersRejected() {
        assertExpansion(
            """
            @Synchronized
            final class Store {
                var count = 0 { didSet { print(count) } }
            }
            """,
            expandedSource: expandedClass("    var count = 0 { didSet { print(count) } }"),
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized cannot keep willSet or didSet; move that code into a method that sets the property",
                    line: 3, column: 19
                ),
            ]
        )
    }

    @Test("Several bindings in one declaration are rejected")
    func multipleBindingsRejected() {
        assertExpansion(
            """
            @Synchronized
            final class Store {
                var a = 0, b = 1
            }
            """,
            expandedSource: expandedClass("    var a = 0, b = 1"),
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized needs one property per declaration; declare each var on its own line",
                    line: 3, column: 9
                ),
            ]
        )
    }

    @Test("A tuple pattern is rejected")
    func tupleRejected() {
        assertExpansion(
            """
            @Synchronized
            final class Store {
                var (a, b) = (0, 1)
            }
            """,
            expandedSource: expandedClass("    var (a, b) = (0, 1)"),
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized cannot guard a tuple pattern; declare each var on its own line",
                    line: 3, column: 9
                ),
            ]
        )
    }

    @Test("A property wrapper is rejected")
    func propertyWrapperRejected() {
        assertExpansion(
            """
            @Synchronized
            final class Store {
                @Clamped var level = 0
            }
            """,
            expandedSource: expandedClass("    @Clamped var level = 0"),
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized cannot guard a property that has a property wrapper or another attached macro",
                    line: 3, column: 5
                ),
            ]
        )
    }

    @Test("A property isolated to a global actor is rejected")
    func isolatedPropertyRejected() {
        assertExpansion(
            """
            @Synchronized
            final class Store {
                @MainActor var title = ""
            }
            """,
            expandedSource: expandedClass("    @MainActor var title = \"\""),
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized properties must not be isolated to a global actor; remove the attribute",
                    line: 3, column: 5,
                    fixIts: [FixItSpec(message: "Remove the attribute")]
                ),
            ],
            fixedSource: """
            @Synchronized
            final class Store {
                var title = ""
            }
            """
        )
    }

    @Test("An overriding property is rejected")
    func overrideRejected() {
        assertExpansion(
            """
            @Synchronized
            final class Store {
                override var description: String = ""
            }
            """,
            expandedSource: expandedClass("    override var description: String = \"\""),
            diagnostics: [
                DiagnosticSpec(
                    message: "@Synchronized cannot guard an overriding property; move the value into a stored property of this class",
                    line: 3, column: 5
                ),
            ]
        )
    }

    // MARK: - @Streamed

    @Test("@Streamed outside a @Synchronized class is rejected")
    func streamedOutside() {
        assertExpansion(
            """
            final class Store {
                @Streamed var count: Int = 0
            }
            """,
            expandedSource: """
            final class Store {
                var count: Int = 0
            }
            """,
            diagnostics: [
                DiagnosticSpec(message: "@Streamed can only be used on a property of a @Synchronized class", line: 2, column: 5),
            ]
        )
    }

    @Test("@Streamed on a let, a static, a computed or an unsafe property is rejected")
    func streamedOnUnmanaged() {
        assertExpansion(
            """
            @Synchronized
            final class Store {
                @Streamed let id: Int = 0
                @Streamed static var shared: Int = 0
                @Streamed var double: Int { 2 }
                @Streamed nonisolated(unsafe) var raw: Int = 0
            }
            """,
            expandedSource: expandedClass("""
                let id: Int = 0
                static var shared: Int = 0
                var double: Int { 2 }
                nonisolated(unsafe) var raw: Int = 0
            """),
            diagnostics: [
                DiagnosticSpec(message: "@Streamed needs a var; a let never changes", line: 3, column: 5),
                DiagnosticSpec(message: "@Streamed cannot be used on a static property", line: 4, column: 5),
                DiagnosticSpec(message: "@Streamed needs a stored property; a computed property has no value to watch", line: 5, column: 5),
                DiagnosticSpec(
                    message: "@Streamed cannot be used on a nonisolated(unsafe) property, which @Synchronized does not guard",
                    line: 6, column: 5
                ),
            ]
        )
    }

    @Test("@Streamed without a type annotation or on a weak var is rejected")
    func streamedWithoutTypeOrWeak() {
        assertExpansion(
            """
            @Synchronized
            final class Store {
                @Streamed var count = 0
                @Streamed weak var listener: Listener?
            }
            """,
            expandedSource: expandedClass("""
                var count = 0
                weak var listener: Listener?
            """),
            diagnostics: [
                DiagnosticSpec(
                    message: "@Streamed needs an explicit type annotation, such as 'var progress: Double = 0'",
                    line: 3, column: 19
                ),
                DiagnosticSpec(message: "@Streamed cannot be used on a weak or unowned property", line: 4, column: 15),
            ]
        )
    }
}
#endif
