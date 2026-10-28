import SwiftDiagnostics
import SwiftSyntax

/// Every error the macros report, with the text the compiler shows.
enum SynchronizedDiagnostic: String, DiagnosticMessage {
    case notAClass
    case actor
    case notFinal
    case globalActor
    case lazyProperty
    case overrideProperty
    case observers
    case multipleBindings
    case patternBinding
    case propertyWrapper
    case isolatedProperty
    case streamedOutsideSynchronized
    case streamedConstant
    case streamedStatic
    case streamedComputed
    case streamedUnsafe
    case streamedWithoutType
    case streamedWeak

    var message: String {
        switch self {
        case .notAClass:
            "@Synchronized applies to a final class; a struct or enum is Sendable when its stored properties are"
        case .actor:
            "@Synchronized does not apply to an actor; an actor already protects its state, remove the attribute"
        case .notFinal:
            "@Synchronized requires a final class: a subclass could add state that the lock does not guard"
        case .globalActor:
            "@Synchronized class must not be isolated to a global actor; the lock already makes it safe to use from any thread"
        case .lazyProperty:
            "@Synchronized cannot guard a lazy property; give it a value in the declaration or in init"
        case .overrideProperty:
            "@Synchronized cannot guard an overriding property; move the value into a stored property of this class"
        case .observers:
            "@Synchronized cannot keep willSet or didSet; move that code into a method that sets the property"
        case .multipleBindings:
            "@Synchronized needs one property per declaration; declare each var on its own line"
        case .patternBinding:
            "@Synchronized cannot guard a tuple pattern; declare each var on its own line"
        case .propertyWrapper:
            "@Synchronized cannot guard a property that has a property wrapper or another attached macro"
        case .isolatedProperty:
            "@Synchronized properties must not be isolated to a global actor; remove the attribute"
        case .streamedOutsideSynchronized:
            "@Streamed can only be used on a property of a @Synchronized class"
        case .streamedConstant:
            "@Streamed needs a var; a let never changes"
        case .streamedStatic:
            "@Streamed cannot be used on a static property"
        case .streamedComputed:
            "@Streamed needs a stored property; a computed property has no value to watch"
        case .streamedUnsafe:
            "@Streamed cannot be used on a nonisolated(unsafe) property, which @Synchronized does not guard"
        case .streamedWithoutType:
            "@Streamed needs an explicit type annotation, such as 'var progress: Double = 0'"
        case .streamedWeak:
            "@Streamed cannot be used on a weak or unowned property"
        }
    }

    var diagnosticID: MessageID {
        MessageID(domain: "SwiftCodeGen", id: rawValue)
    }

    var severity: DiagnosticSeverity { .error }
}

/// The text of the suggested fixes.
struct SynchronizedFixIt: FixItMessage {
    let message: String
    let id: String

    var fixItID: MessageID {
        MessageID(domain: "SwiftCodeGen", id: id)
    }

    static let addFinal = SynchronizedFixIt(message: "Add 'final'", id: "addFinal")
    static let removeAttribute = SynchronizedFixIt(message: "Remove the attribute", id: "removeAttribute")
    static let removeLazy = SynchronizedFixIt(message: "Remove 'lazy'", id: "removeLazy")
}
