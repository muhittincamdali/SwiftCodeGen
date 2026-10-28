import SwiftDiagnostics
import SwiftSyntax

/// A stored `var` that `@Synchronized` guards.
struct ManagedProperty {
    let name: TokenSyntax
    let type: TypeSyntax?
    let initializer: InitializerClauseSyntax?
    /// `weak` or `unowned(…)`, copied to the storage.
    let ownership: DeclModifierSyntax?
    let isStreamed: Bool
    /// The access modifier of the property's getter, used for the generated stream.
    let readAccess: DeclModifierSyntax?

    var storageName: TokenSyntax { .identifier("_" + name.text) }
    var streamName: TokenSyntax { .identifier(name.text + "Updates") }
    var broadcastName: TokenSyntax { .identifier("_" + name.text + "Updates") }
}

/// Why `@Synchronized` leaves a member alone.
enum SkipReason {
    case constant
    case staticMember
    case computed
    case unsafeOptOut
    case alreadyExpanded
}

enum PropertyAnalysis {
    case managed(ManagedProperty)
    case skipped(SkipReason)
    case invalid([Diagnostic])

    private static let accessModifiers: Set<String> = [
        "open", "public", "package", "internal", "fileprivate", "private",
    ]
    private static let ownAttributes: Set<String> = ["Streamed", "_SynchronizedProperty"]
    private static let allowedAttributes: Set<String> = ["available", "objc", "nonobjc", "inlinable", "usableFromInline"]

    // swiftlint:disable:next cyclomatic_complexity function_body_length
    init(_ variable: VariableDeclSyntax) {
        let modifiers = variable.modifiers
        if variable.bindingSpecifier.tokenKind == .keyword(.let) {
            self = .skipped(.constant)
            return
        }
        if modifiers.contains(where: { $0.name.tokenKind == .keyword(.static) || $0.name.tokenKind == .keyword(.class) }) {
            self = .skipped(.staticMember)
            return
        }
        if modifiers.contains(where: { $0.name.tokenKind == .keyword(.nonisolated) && $0.detail != nil }) {
            self = .skipped(.unsafeOptOut)
            return
        }
        if variable.attributes.contains(where: { $0.attributeName == "_SynchronizedProperty" }) {
            self = .skipped(.alreadyExpanded)
            return
        }
        if let binding = variable.bindings.first, variable.bindings.count == 1,
           let accessors = binding.accessorBlock, Self.isComputed(accessors) {
            self = .skipped(.computed)
            return
        }

        var diagnostics: [Diagnostic] = []
        func report(_ message: SynchronizedDiagnostic, at node: some SyntaxProtocol, fixIt: FixIt? = nil) {
            diagnostics.append(Diagnostic(node: Syntax(node), message: message, fixIts: fixIt.map { [$0] } ?? []))
        }

        if let lazy = modifiers.first(where: { $0.name.tokenKind == .keyword(.lazy) }) {
            report(.lazyProperty, at: lazy, fixIt: FixIt(
                message: SynchronizedFixIt.removeLazy,
                changes: [Self.removing(lazy)]
            ))
        }
        if let override = modifiers.first(where: { $0.name.tokenKind == .keyword(.override) }) {
            report(.overrideProperty, at: override)
        }
        let isStreamed = variable.attributes.contains { $0.attributeName == "Streamed" }
        for element in variable.attributes {
            guard case .attribute(let attribute) = element, let name = element.attributeName else { continue }
            if Self.ownAttributes.contains(name) || Self.allowedAttributes.contains(name) { continue }
            if name.hasSuffix("Actor") {
                report(.isolatedProperty, at: attribute, fixIt: Self.removal(of: attribute))
            } else {
                report(.propertyWrapper, at: attribute)
            }
        }
        guard variable.bindings.count == 1, let binding = variable.bindings.first else {
            report(.multipleBindings, at: variable.bindings)
            self = .invalid(diagnostics)
            return
        }
        guard let identifier = binding.pattern.as(IdentifierPatternSyntax.self) else {
            report(.patternBinding, at: binding.pattern)
            self = .invalid(diagnostics)
            return
        }
        if let accessors = binding.accessorBlock {
            // Not computed (checked above), so these are willSet / didSet observers.
            report(.observers, at: accessors)
        }
        let ownership = modifiers.first {
            $0.name.tokenKind == .keyword(.weak) || $0.name.tokenKind == .keyword(.unowned)
        }
        let type = binding.typeAnnotation?.type
        if isStreamed, type == nil {
            report(.streamedWithoutType, at: identifier)
        }
        if isStreamed, let ownership {
            report(.streamedWeak, at: ownership)
        }
        guard diagnostics.isEmpty else {
            self = .invalid(diagnostics)
            return
        }
        let readAccess = modifiers.first {
            Self.accessModifiers.contains($0.name.text) && $0.detail == nil
        }
        self = .managed(ManagedProperty(
            name: identifier.identifier.trimmed,
            type: type?.trimmed,
            initializer: binding.initializer?.trimmed,
            ownership: ownership?.trimmed,
            isStreamed: isStreamed,
            readAccess: readAccess?.trimmed
        ))
    }

    /// An accessor block makes a property computed unless it only holds observers.
    private static func isComputed(_ block: AccessorBlockSyntax) -> Bool {
        switch block.accessors {
        case .getter:
            return true
        case .accessors(let list):
            return list.contains { accessor in
                switch accessor.accessorSpecifier.tokenKind {
                case .keyword(.willSet), .keyword(.didSet): false
                default: true
                }
            }
        }
    }

    static func removal(of attribute: AttributeSyntax) -> FixIt {
        FixIt(
            message: SynchronizedFixIt.removeAttribute,
            changes: [removing(attribute)]
        )
    }

    /// Deletes `node` and the space after it, keeping the line break and indentation before it.
    static func removing(_ node: some SyntaxProtocol) -> FixIt.Change {
        .replace(oldNode: Syntax(node), newNode: Syntax(TokenSyntax.unknown("", leadingTrivia: node.leadingTrivia)))
    }
}

extension AttributeListSyntax.Element {
    /// The simple name of an attribute, such as `MainActor` for `@MainActor` or
    /// `Streamed` for `@SwiftCodeGen.Streamed`.
    var attributeName: String? {
        guard case .attribute(let attribute) = self else { return nil }
        return attribute.attributeName.simpleName
    }
}

extension TypeSyntax {
    var simpleName: String {
        if let member = self.as(MemberTypeSyntax.self) {
            return member.name.text
        }
        return trimmedDescription
    }
}

extension AttributeListSyntax {
    func first(named name: String) -> AttributeSyntax? {
        for element in self {
            if case .attribute(let attribute) = element, attribute.attributeName.simpleName == name {
                return attribute
            }
        }
        return nil
    }
}
