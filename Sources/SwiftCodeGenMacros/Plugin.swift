import SwiftCompilerPlugin
import SwiftSyntaxMacros

@main
struct SwiftCodeGenPlugin: CompilerPlugin {
    let providingMacros: [any Macro.Type] = [
        SynchronizedMacro.self,
        SynchronizedPropertyMacro.self,
        StreamedMacro.self,
    ]
}
