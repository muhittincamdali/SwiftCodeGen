import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// `@_SynchronizedProperty`: the locked accessors of one property, its storage and, for a
/// `@Streamed` property, its broadcast and `…Updates` stream.
public struct SynchronizedPropertyMacro {
    static func property(_ declaration: some SyntaxProtocol) -> ManagedProperty? {
        guard let variable = declaration.as(VariableDeclSyntax.self),
              case .managed(let property) = PropertyAnalysis(variable.removingExpansionAttribute())
        else { return nil }
        return property
    }
}

extension SynchronizedPropertyMacro: AccessorMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingAccessorsOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AccessorDeclSyntax] {
        guard let property = property(declaration) else { return [] }
        let storage = property.storageName
        // A @Streamed property sends the new value while still holding the lock, so that
        // subscribers see the changes in the order they happened.
        let notify = property.isStreamed
            ? "\n    \(property.broadcastName.text).send(\(storage.text))"
            : ""

        var accessors: [AccessorDeclSyntax] = [
            """
            @storageRestrictions(initializes: \(storage))
            init(initialValue) {
                \(storage) = initialValue
            }
            """,
            """
            get {
                _lock.lock()
                defer { _lock.unlock() }
                return \(storage)
            }
            """,
            """
            set {
                _lock.lock()
                defer { _lock.unlock() }
                \(storage) = newValue\(raw: notify)
            }
            """,
        ]
        // A weak or unowned reference cannot be yielded in place; get and set cover it.
        if property.ownership == nil {
            accessors.append(
                """
                _modify {
                    _lock.lock()
                    defer { _lock.unlock() }
                    yield &\(storage)\(raw: notify)
                }
                """
            )
        }
        return accessors
    }
}

extension SynchronizedPropertyMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        guard let property = property(declaration) else { return [] }
        let ownership = property.ownership.map { "\($0.trimmedDescription) " } ?? ""
        let storage: DeclSyntax = if let type = property.type {
            "nonisolated(unsafe) private \(raw: ownership)var \(property.storageName): \(type)"
        } else {
            // No annotation: the storage infers its type from the same expression.
            "nonisolated(unsafe) private \(raw: ownership)var \(property.storageName) \(property.initializer)"
        }
        guard property.isStreamed, let type = property.type else { return [storage] }

        let element = type.streamElement
        let access = property.readAccess.map { "\($0.trimmedDescription) " } ?? ""
        return [
            storage,
            "private let \(property.broadcastName) = SwiftCodeGen.StreamBroadcast<\(element)>()",
            """
            /// The values of `\(property.name)`: the current one first, then every change.
            \(raw: access)var \(property.streamName): AsyncStream<\(element)> {
                _lock.lock()
                defer { _lock.unlock() }
                return \(property.broadcastName).subscribe(current: \(property.storageName))
            }
            """,
        ]
    }
}

extension VariableDeclSyntax {
    /// The declaration as written, without the attribute that `@Synchronized` added to it.
    func removingExpansionAttribute() -> VariableDeclSyntax {
        with(\.attributes, attributes.filter { $0.attributeName != "_SynchronizedProperty" })
    }
}

extension TypeSyntax {
    /// The element type of the stream: `T?` for an implicitly unwrapped `T!`.
    var streamElement: TypeSyntax {
        if let unwrapped = self.as(ImplicitlyUnwrappedOptionalTypeSyntax.self) {
            return TypeSyntax(OptionalTypeSyntax(wrappedType: unwrapped.wrappedType))
        }
        return self
    }
}
