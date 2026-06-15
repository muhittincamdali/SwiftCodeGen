import Foundation

/// SwiftCodeGen: Xcode Build Tool Plugin Generator.
/// 
/// Automatically generates the boilerplate required to integrate custom 
/// code generation logic directly into the Xcode build pipeline.
public struct XcodePluginGenerator {
    public static func generatePluginManifest(name: String) -> String {
        return """
        import PackageDescription
        
        let plugin = Capability.buildTool(
            name: "\\(name)Plugin",
            inputFiles: [.extension("json")],
            outputFiles: [.extension("swift")]
        )
        """
    }
}
