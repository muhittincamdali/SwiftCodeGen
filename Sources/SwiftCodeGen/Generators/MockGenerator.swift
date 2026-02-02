import Foundation

/// Generates mock implementations from Swift protocol definitions.
///
/// The mock generator parses protocol declarations and creates
/// full mock classes with call tracking, argument capture, and return value stubbing.
public final class MockGenerator: CodeGenerator {

    // MARK: - Properties

    public let generatorType = "mock"
    public let inputPath: String
    public let outputPath: String

    private let config: CodeGenConfig
    private let parser: SwiftParser
    private let templateEngine: TemplateEngine

    // MARK: - Initialization

    public init(inputPath: String, outputPath: String, config: CodeGenConfig) {
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.config = config
        self.parser = SwiftParser()
        self.templateEngine = TemplateEngine()
    }

    // MARK: - Generation

    public func generate() throws -> [GeneratedFile] {
        let sourceFiles = try collectSwiftFiles(at: inputPath)
        var generatedFiles: [GeneratedFile] = []

        for sourceFile in sourceFiles {
            let content = try String(contentsOfFile: sourceFile, encoding: .utf8)
            let protocols = parser.parseProtocols(from: content)

            for proto in protocols {
                let mockContent = generateMock(for: proto)
                let fileName = "Mock\(proto.name).swift"
                generatedFiles.append(GeneratedFile(fileName: fileName, content: mockContent))
            }
        }

        return generatedFiles
    }

    // MARK: - Mock Generation

    private func generateMock(for proto: ProtocolDeclaration) -> String {
        var lines: [String] = []
        let indent = String(repeating: " ", count: config.indentWidth)

        lines.append(config.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("class Mock\(proto.name): \(proto.name) {")
        lines.append("")

        // Generate properties for tracking
        for method in proto.methods {
            lines.append(contentsOf: generateMethodTracking(method, indent: indent))
            lines.append("")
        }

        // Generate computed properties
        for property in proto.properties {
            lines.append(contentsOf: generatePropertyMock(property, indent: indent))
            lines.append("")
        }

        // Generate method implementations
        for method in proto.methods {
            lines.append(contentsOf: generateMethodImplementation(method, indent: indent))
            lines.append("")
        }

        // Generate verification helpers
        lines.append(contentsOf: generateVerificationHelpers(for: proto, indent: indent))

        // Generate reset method
        lines.append(contentsOf: generateResetMethod(for: proto, indent: indent))

        lines.append("}")

        return lines.joined(separator: "\n")
    }

    // MARK: - Method Tracking

    private func generateMethodTracking(_ method: MethodDeclaration, indent: String) -> [String] {
        var lines: [String] = []
        let baseName = method.name

        lines.append("\(indent)// MARK: - \(baseName)")
        lines.append("\(indent)var \(baseName)CallCount = 0")
        lines.append("\(indent)var \(baseName)Called: Bool { \(baseName)CallCount > 0 }")

        // Argument capture
        for param in method.parameters {
            let storageName = "\(baseName)Received\(param.name.capitalized)"
            lines.append("\(indent)var \(storageName): \(param.typeName)?")
        }

        // Multi-call argument history
        if !method.parameters.isEmpty {
            let tupleType = method.parameters.map { "\(param: $0.typeName)" }.joined(separator: ", ")
            if method.parameters.count == 1 {
                lines.append("\(indent)var \(baseName)ReceivedInvocations: [\(method.parameters[0].typeName)] = []")
            } else {
                lines.append("\(indent)var \(baseName)ReceivedInvocations: [(\(tupleType))] = []")
            }
        }

        // Return value stub
        if let returnType = method.returnType {
            if method.isOptionalReturn {
                lines.append("\(indent)var \(baseName)ReturnValue: \(returnType)?")
            } else {
                lines.append("\(indent)var \(baseName)ReturnValue: \(returnType)!")
            }
        }

        // Error stub for throwing methods
        if method.isThrowing {
            lines.append("\(indent)var \(baseName)ThrowableError: Error?")
        }

        // Closure stub
        let closureParams = method.parameters.map { $0.typeName }.joined(separator: ", ")
        let closureReturn = method.returnType ?? "Void"
        let throwsClause = method.isThrowing ? " throws" : ""
        lines.append("\(indent)var \(baseName)Closure: ((\(closureParams))\(throwsClause) -> \(closureReturn))?")

        return lines
    }

    // MARK: - Property Mock

    private func generatePropertyMock(_ property: PropertyDeclaration, indent: String) -> [String] {
        var lines: [String] = []

        lines.append("\(indent)// MARK: - \(property.name)")

        if property.isReadOnly {
            lines.append("\(indent)var \(property.name)Value: \(property.typeName)!")
            lines.append("\(indent)var \(property.name): \(property.typeName) {")
            lines.append("\(indent)\(indent)\(property.name)Value")
            lines.append("\(indent)}")
        } else {
            lines.append("\(indent)var \(property.name)SetCallCount = 0")
            lines.append("\(indent)var underlying\(property.name.capitalized): \(property.typeName)!")
            lines.append("\(indent)var \(property.name): \(property.typeName) {")
            lines.append("\(indent)\(indent)get { underlying\(property.name.capitalized) }")
            lines.append("\(indent)\(indent)set {")
            lines.append("\(indent)\(indent)\(indent)\(property.name)SetCallCount += 1")
            lines.append("\(indent)\(indent)\(indent)underlying\(property.name.capitalized) = newValue")
            lines.append("\(indent)\(indent)}")
            lines.append("\(indent)}")
        }

        return lines
    }

    // MARK: - Method Implementation

    private func generateMethodImplementation(_ method: MethodDeclaration, indent: String) -> [String] {
        var lines: [String] = []
        let baseName = method.name

        let asyncKeyword = method.isAsync ? " async" : ""
        let throwsKeyword = method.isThrowing ? " throws" : ""
        let returnClause = method.returnType.map { " -> \($0)" } ?? ""
        let params = method.parameters.map { "\($0.label ?? $0.name) \($0.name): \($0.typeName)" }.joined(separator: ", ")

        lines.append("\(indent)func \(baseName)(\(params))\(asyncKeyword)\(throwsKeyword)\(returnClause) {")
        lines.append("\(indent)\(indent)\(baseName)CallCount += 1")

        // Capture arguments
        for param in method.parameters {
            lines.append("\(indent)\(indent)\(baseName)Received\(param.name.capitalized) = \(param.name)")
        }

        if method.parameters.count == 1 {
            lines.append("\(indent)\(indent)\(baseName)ReceivedInvocations.append(\(method.parameters[0].name))")
        } else if method.parameters.count > 1 {
            let tupleValues = method.parameters.map { $0.name }.joined(separator: ", ")
            lines.append("\(indent)\(indent)\(baseName)ReceivedInvocations.append((\(tupleValues)))")
        }

        // Throw if configured
        if method.isThrowing {
            lines.append("\(indent)\(indent)if let error = \(baseName)ThrowableError {")
            lines.append("\(indent)\(indent)\(indent)throw error")
            lines.append("\(indent)\(indent)}")
        }

        // Closure or return value
        let closureArgs = method.parameters.map { $0.name }.joined(separator: ", ")
        if method.returnType != nil {
            lines.append("\(indent)\(indent)if let closure = \(baseName)Closure {")
            let tryPrefix = method.isThrowing ? "try " : ""
            let awaitPrefix = method.isAsync ? "await " : ""
            lines.append("\(indent)\(indent)\(indent)return \(tryPrefix)\(awaitPrefix)closure(\(closureArgs))")
            lines.append("\(indent)\(indent)}")
            lines.append("\(indent)\(indent)return \(baseName)ReturnValue")
        } else {
            lines.append("\(indent)\(indent)\(baseName)Closure?(\(closureArgs))")
        }

        lines.append("\(indent)}")

        return lines
    }

    // MARK: - Verification Helpers

    private func generateVerificationHelpers(for proto: ProtocolDeclaration, indent: String) -> [String] {
        var lines: [String] = []
        lines.append("\(indent)// MARK: - Verification")
        lines.append("")

        for method in proto.methods {
            lines.append("\(indent)func verify\(method.name.capitalized)(called times: Int, file: StaticString = #file, line: UInt = #line) {")
            lines.append("\(indent)\(indent)assert(\(method.name)CallCount == times,")
            lines.append("\(indent)\(indent)\(indent)\"Expected \(method.name) to be called \\(times) times, but was called \\(\(method.name)CallCount) times\",")
            lines.append("\(indent)\(indent)\(indent)file: file, line: line)")
            lines.append("\(indent)}")
            lines.append("")
        }

        return lines
    }

    // MARK: - Reset

    private func generateResetMethod(for proto: ProtocolDeclaration, indent: String) -> [String] {
        var lines: [String] = []
        lines.append("\(indent)// MARK: - Reset")
        lines.append("")
        lines.append("\(indent)func resetMock() {")

        for method in proto.methods {
            lines.append("\(indent)\(indent)\(method.name)CallCount = 0")
            for param in method.parameters {
                lines.append("\(indent)\(indent)\(method.name)Received\(param.name.capitalized) = nil")
            }
        }

        lines.append("\(indent)}")

        return lines
    }

    // MARK: - Helpers

    private func collectSwiftFiles(at path: String) throws -> [String] {
        let fileManager = FileManager.default
        let url = URL(fileURLWithPath: path)

        var isDirectory: ObjCBool = false
        guard fileManager.fileExists(atPath: path, isDirectory: &isDirectory) else {
            throw CodeGenError.inputNotFound(path)
        }

        if isDirectory.boolValue {
            let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil)
            var files: [String] = []
            while let fileURL = enumerator?.nextObject() as? URL {
                if fileURL.pathExtension == "swift" {
                    files.append(fileURL.path)
                }
            }
            return files.sorted()
        } else {
            return [path]
        }
    }
}
