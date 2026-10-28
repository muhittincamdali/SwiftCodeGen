import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxBuilder
import SwiftSyntaxMacros

/// `@Synchronized`: the lock, `withLock(_:)`, the property attributes and `Sendable`.
public struct SynchronizedMacro {
    /// The class the attribute is attached to, or the errors that make it unusable.
    static func validate(_ declaration: some DeclGroupSyntax) -> Result<ClassDeclSyntax, DiagnosticsError> {
        if let actor = declaration.as(ActorDeclSyntax.self) {
            return .failure(DiagnosticsError(diagnostics: [
                Diagnostic(node: actor.actorKeyword, message: SynchronizedDiagnostic.actor),
            ]))
        }
        guard let classDecl = declaration.as(ClassDeclSyntax.self) else {
            return .failure(DiagnosticsError(diagnostics: [
                Diagnostic(node: declaration.introducer, message: SynchronizedDiagnostic.notAClass),
            ]))
        }
        var diagnostics: [Diagnostic] = []
        if !classDecl.modifiers.contains(where: { $0.name.tokenKind == .keyword(.final) }) {
            diagnostics.append(Diagnostic(
                node: classDecl.classKeyword,
                message: SynchronizedDiagnostic.notFinal,
                fixIt: FixIt(
                    message: SynchronizedFixIt.addFinal,
                    changes: [.replace(oldNode: Syntax(classDecl), newNode: Syntax(addingFinal(to: classDecl)))]
                )
            ))
        }
        for element in classDecl.attributes {
            guard case .attribute(let attribute) = element,
                  let name = element.attributeName, name.hasSuffix("Actor") else { continue }
            diagnostics.append(Diagnostic(
                node: attribute,
                message: SynchronizedDiagnostic.globalActor,
                fixIt: PropertyAnalysis.removal(of: attribute)
            ))
        }
        if !diagnostics.isEmpty {
            return .failure(DiagnosticsError(diagnostics: diagnostics))
        }
        return .success(classDecl)
    }

    /// `class A` becomes `final class A`, `public class A` becomes `public final class A`.
    private static func addingFinal(to classDecl: ClassDeclSyntax) -> ClassDeclSyntax {
        var classDecl = classDecl
        var modifier = DeclModifierSyntax(name: .keyword(.final), trailingTrivia: .space)
        if classDecl.modifiers.isEmpty {
            modifier.leadingTrivia = classDecl.classKeyword.leadingTrivia
            classDecl.classKeyword.leadingTrivia = []
        }
        classDecl.modifiers.append(modifier)
        return classDecl
    }
}

extension SynchronizedMacro: MemberMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingMembersOf declaration: some DeclGroupSyntax,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        // Errors about the declaration are reported once, here; the other roles stay silent.
        _ = try validate(declaration).get()
        return [
            """
            private let _lock = SwiftCodeGen.SynchronizedLock()
            """,
            """
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
            """,
            // The attribute check in validate(_:) only knows global actors by name. This call
            // fails to compile when the class is isolated to any global actor, so one named
            // without the "Actor" suffix is caught too.
            """
            /// Does not compile when the class is isolated to a global actor: `@Synchronized`
            /// classes are used from any thread.
            nonisolated private func _requireNoGlobalActor() {
                withLock {
                }
            }
            """,
        ]
    }
}

extension SynchronizedMacro: MemberAttributeMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingAttributesFor member: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [AttributeSyntax] {
        guard case .success = validate(declaration),
              let variable = member.as(VariableDeclSyntax.self) else { return [] }
        switch PropertyAnalysis(variable) {
        case .managed:
            return ["@_SynchronizedProperty"]
        case .skipped:
            return []
        case .invalid(let diagnostics):
            diagnostics.forEach(context.diagnose)
            return []
        }
    }
}

extension SynchronizedMacro: ExtensionMacro {
    public static func expansion(
        of node: AttributeSyntax,
        attachedTo declaration: some DeclGroupSyntax,
        providingExtensionsOf type: some TypeSyntaxProtocol,
        conformingTo protocols: [TypeSyntax],
        in context: some MacroExpansionContext
    ) throws -> [ExtensionDeclSyntax] {
        guard case .success = validate(declaration), !protocols.isEmpty else { return [] }
        return [try ExtensionDeclSyntax("extension \(type.trimmed): Sendable {}")]
    }
}
