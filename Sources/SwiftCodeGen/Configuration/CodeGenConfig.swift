import Foundation

/// Configuration for SwiftCodeGen defining generators, output settings, and options.
public struct CodeGenConfig {

    // MARK: - Properties

    /// Directory where generated files are written.
    public var outputDirectory: String

    /// Number of spaces per indentation level.
    public var indentWidth: Int

    /// Comment inserted at the top of every generated file.
    public var headerComment: String

    /// List of generator configurations to run.
    public var generators: [GeneratorEntry]

    // MARK: - Initialization

    public init(
        outputDirectory: String = "Sources/Generated",
        indentWidth: Int = 4,
        headerComment: String = "// Auto-generated — do not edit manually",
        generators: [GeneratorEntry] = []
    ) {
        self.outputDirectory = outputDirectory
        self.indentWidth = indentWidth
        self.headerComment = headerComment
        self.generators = generators
    }

    /// Default configuration with sensible defaults.
    public static let `default` = CodeGenConfig()

    // MARK: - Loading

    /// Loads configuration from a YAML file at the given URL.
    public static func load(from url: URL) throws -> CodeGenConfig {
        let data = try Data(contentsOf: url)
        guard let content = String(data: data, encoding: .utf8) else {
            throw CodeGenError.invalidFormat("Cannot read configuration file")
        }

        return try parseYAML(content)
    }

    private static func parseYAML(_ content: String) throws -> CodeGenConfig {
        var config = CodeGenConfig()
        let lines = content.components(separatedBy: .newlines)

        var currentGenerator: GeneratorEntry?

        for line in lines {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard !trimmed.isEmpty, !trimmed.hasPrefix("#") else { continue }

            if trimmed.hasPrefix("output_directory:") {
                config.outputDirectory = extractValue(from: trimmed)
            } else if trimmed.hasPrefix("indent_width:") {
                config.indentWidth = Int(extractValue(from: trimmed)) ?? 4
            } else if trimmed.hasPrefix("header_comment:") {
                config.headerComment = extractValue(from: trimmed)
            } else if trimmed.hasPrefix("- type:") {
                if let gen = currentGenerator {
                    config.generators.append(gen)
                }
                currentGenerator = GeneratorEntry(
                    type: extractValue(from: trimmed),
                    inputPath: "",
                    outputPath: ""
                )
            } else if trimmed.hasPrefix("input:"), currentGenerator != nil {
                currentGenerator?.inputPath = extractValue(from: trimmed)
            } else if trimmed.hasPrefix("output:"), currentGenerator != nil {
                currentGenerator?.outputPath = extractValue(from: trimmed)
            }
        }

        if let gen = currentGenerator {
            config.generators.append(gen)
        }

        return config
    }

    private static func extractValue(from line: String) -> String {
        let parts = line.split(separator: ":", maxSplits: 1)
        guard parts.count == 2 else { return "" }
        return parts[1].trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "\"", with: "")
    }
}

// MARK: - Generator Entry

/// Describes a single generator configuration within the config file.
public struct GeneratorEntry {
    public var type: String
    public var inputPath: String
    public var outputPath: String

    public init(type: String, inputPath: String, outputPath: String) {
        self.type = type
        self.inputPath = inputPath
        self.outputPath = outputPath
    }
}

// MARK: - Code Generator Protocol

/// Protocol that all code generators must conform to.
public protocol CodeGenerator {
    var generatorType: String { get }
    var inputPath: String { get }
    var outputPath: String { get }
    func generate() throws -> [GeneratedFile]
}

/// Represents a single generated output file.
public struct GeneratedFile {
    public let fileName: String
    public let content: String

    public init(fileName: String, content: String) {
        self.fileName = fileName
        self.content = content
    }
}

// MARK: - Errors

public enum CodeGenError: Error, LocalizedError {
    case inputNotFound(String)
    case unsupportedFormat(String)
    case invalidFormat(String)
    case templateError(String)

    public var errorDescription: String? {
        switch self {
        case .inputNotFound(let path): return "Input not found: \(path)"
        case .unsupportedFormat(let format): return "Unsupported format: \(format)"
        case .invalidFormat(let message): return "Invalid format: \(message)"
        case .templateError(let message): return "Template error: \(message)"
        }
    }
}

// MARK: - Declaration Models

public struct ProtocolDeclaration {
    public let name: String
    public let inheritedProtocols: [String]
    public let methods: [MethodDeclaration]
    public let properties: [PropertyDeclaration]
    public let associatedTypes: [String]
}

public struct MethodDeclaration {
    public let name: String
    public let parameters: [ParameterDeclaration]
    public let returnType: String?
    public let isAsync: Bool
    public let isThrowing: Bool
    public let isOptionalReturn: Bool
}

public struct ParameterDeclaration {
    public let label: String?
    public let name: String
    public let typeName: String
}

public struct PropertyDeclaration {
    public let name: String
    public let typeName: String
    public let isReadOnly: Bool
}
