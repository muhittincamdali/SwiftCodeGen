import Foundation

/// Generates dependency injection container registration code
/// from annotated Swift source files.
///
/// Scans for `@Injectable` annotations or configuration files and produces
/// type-safe container setup code with proper resolution ordering.
public final class DIContainerGenerator: CodeGenerator {

    // MARK: - Properties

    public let generatorType = "di"
    public let inputPath: String
    public let outputPath: String

    private let config: CodeGenConfig
    private let parser: SwiftParser

    // MARK: - Initialization

    public init(inputPath: String, outputPath: String, config: CodeGenConfig) {
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.config = config
        self.parser = SwiftParser()
    }

    // MARK: - Generation

    public func generate() throws -> [GeneratedFile] {
        let sourceFiles = try collectSwiftFiles(at: inputPath)
        var registrations: [DIRegistration] = []

        for sourceFile in sourceFiles {
            let content = try String(contentsOfFile: sourceFile, encoding: .utf8)
            let found = parseRegistrations(from: content)
            registrations.append(contentsOf: found)
        }

        let sorted = topologicalSort(registrations)
        let content = generateContainerCode(from: sorted)
        return [GeneratedFile(fileName: "GeneratedContainer.swift", content: content)]
    }

    // MARK: - Parsing

    private func parseRegistrations(from source: String) -> [DIRegistration] {
        var registrations: [DIRegistration] = []
        let lines = source.components(separatedBy: .newlines)

        var pendingAnnotation: [String: String]?

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)

            // Look for @Injectable annotation comments
            if trimmed.hasPrefix("// @Injectable") || trimmed.hasPrefix("/// @Injectable") {
                pendingAnnotation = parseAnnotation(trimmed)
                continue
            }

            // Match class declarations after annotation
            if let annotation = pendingAnnotation {
                if let registration = parseClassDeclaration(trimmed, annotation: annotation) {
                    registrations.append(registration)
                }
                pendingAnnotation = nil
            }
        }

        return registrations
    }

    private func parseAnnotation(_ line: String) -> [String: String] {
        var params: [String: String] = [:]
        let content = line.replacingOccurrences(of: "// @Injectable", with: "")
            .replacingOccurrences(of: "/// @Injectable", with: "")
            .trimmingCharacters(in: .whitespaces)

        if content.hasPrefix("(") && content.hasSuffix(")") {
            let inner = String(content.dropFirst().dropLast())
            let pairs = inner.split(separator: ",")
            for pair in pairs {
                let kv = pair.split(separator: ":", maxSplits: 1)
                if kv.count == 2 {
                    let key = kv[0].trimmingCharacters(in: .whitespaces)
                    let value = kv[1].trimmingCharacters(in: .whitespaces).replacingOccurrences(of: "\"", with: "")
                    params[key] = value
                }
            }
        }

        return params
    }

    private func parseClassDeclaration(_ line: String, annotation: [String: String]) -> DIRegistration? {
        let pattern = #"(?:class|struct)\s+(\w+)\s*(?::\s*(.+))?\s*\{"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let nameRange = Range(match.range(at: 1), in: line) else {
            return nil
        }

        let implName = String(line[nameRange])
        var protocolName = implName

        if let conformanceRange = Range(match.range(at: 2), in: line) {
            let conformances = String(line[conformanceRange])
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
            if let first = conformances.first {
                protocolName = first
            }
        }

        let scope = annotation["scope"] ?? "transient"

        return DIRegistration(
            protocolName: protocolName,
            implementationName: implName,
            scope: DIScope(rawValue: scope) ?? .transient,
            dependencies: []
        )
    }

    // MARK: - Topological Sort

    private func topologicalSort(_ registrations: [DIRegistration]) -> [DIRegistration] {
        // Simple sort: singletons first, then scoped, then transient
        return registrations.sorted { lhs, rhs in
            lhs.scope.priority < rhs.scope.priority
        }
    }

    // MARK: - Code Generation

    private func generateContainerCode(from registrations: [DIRegistration]) -> String {
        var lines: [String] = []
        let indent = String(repeating: " ", count: config.indentWidth)

        lines.append(config.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Container Registration")
        lines.append("")
        lines.append("extension Container {")
        lines.append("")
        lines.append("\(indent)/// Registers all injectable dependencies.")
        lines.append("\(indent)func registerAll() {")

        for reg in registrations {
            let scopeMethod: String
            switch reg.scope {
            case .singleton:
                scopeMethod = "registerSingleton"
            case .scoped:
                scopeMethod = "registerScoped"
            case .transient:
                scopeMethod = "register"
            }
            lines.append("\(indent)\(indent)\(scopeMethod)(\(reg.protocolName).self) { \(reg.implementationName)() }")
        }

        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")

        return lines.joined(separator: "\n")
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
        }

        return [path]
    }
}

// MARK: - Models

struct DIRegistration {
    let protocolName: String
    let implementationName: String
    let scope: DIScope
    let dependencies: [String]
}

enum DIScope: String {
    case singleton
    case scoped
    case transient

    var priority: Int {
        switch self {
        case .singleton: return 0
        case .scoped: return 1
        case .transient: return 2
        }
    }
}
