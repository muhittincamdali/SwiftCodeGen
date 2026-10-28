#if canImport(SwiftCodeGenMacros)
import SwiftCodeGenMacros
import SwiftSyntaxMacroExpansion
import SwiftSyntaxMacros
import SwiftSyntaxMacrosGenericTestSupport
import Testing

let macroSpecs: [String: MacroSpec] = [
    "Synchronized": MacroSpec(type: SynchronizedMacro.self, conformances: ["Sendable"]),
    "_SynchronizedProperty": MacroSpec(type: SynchronizedPropertyMacro.self),
    "Streamed": MacroSpec(type: StreamedMacro.self),
]

/// `assertMacroExpansion` reporting through Swift Testing.
func assertExpansion(
    _ source: String,
    expandedSource: String,
    diagnostics: [DiagnosticSpec] = [],
    fixedSource: String? = nil,
    conformances: [String: MacroSpec]? = nil,
    sourceLocation: Testing.SourceLocation = #_sourceLocation
) {
    assertMacroExpansion(
        source,
        expandedSource: expandedSource,
        diagnostics: diagnostics,
        macroSpecs: conformances ?? macroSpecs,
        fixedSource: fixedSource,
        indentationWidth: .spaces(4),
        failureHandler: { failure in
            Issue.record(Comment(rawValue: failure.message), sourceLocation: sourceLocation)
        }
    )
}
#endif
