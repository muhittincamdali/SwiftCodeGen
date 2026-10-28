import SwiftDiagnostics
import SwiftSyntax
import SwiftSyntaxMacros

/// `@Streamed` marks a property; `@_SynchronizedProperty` generates its stream. This macro only
/// reports the uses that `@Synchronized` would otherwise skip without a word.
public struct StreamedMacro: PeerMacro {
    public static func expansion(
        of node: AttributeSyntax,
        providingPeersOf declaration: some DeclSyntaxProtocol,
        in context: some MacroExpansionContext
    ) throws -> [DeclSyntax] {
        let enclosingClass = context.lexicalContext.first?.as(ClassDeclSyntax.self)
        guard let enclosingClass, enclosingClass.attributes.first(named: "Synchronized") != nil else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: node, message: SynchronizedDiagnostic.streamedOutsideSynchronized),
            ])
        }
        guard let variable = declaration.as(VariableDeclSyntax.self) else {
            throw DiagnosticsError(diagnostics: [
                Diagnostic(node: node, message: SynchronizedDiagnostic.streamedComputed),
            ])
        }
        guard case .skipped(let reason) = PropertyAnalysis(variable.removingExpansionAttribute()) else {
            // Managed, or invalid with errors that @Synchronized reports.
            return []
        }
        let message: SynchronizedDiagnostic? = switch reason {
        case .constant: .streamedConstant
        case .staticMember: .streamedStatic
        case .computed: .streamedComputed
        case .unsafeOptOut: .streamedUnsafe
        case .alreadyExpanded: nil
        }
        if let message {
            throw DiagnosticsError(diagnostics: [Diagnostic(node: node, message: message)])
        }
        return []
    }
}
