import Foundation

/// SwiftCodeGen: OpenAPI to Swift 6 Client Generator
public struct OpenAPIParser {
    public static func parse(json: String) -> String {
        return "// Auto-generated Swift 6 Network Client\npublic actor APIClient {}"
    }
}
