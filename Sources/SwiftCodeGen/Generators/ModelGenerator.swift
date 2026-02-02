import Foundation

/// Generates Swift `Codable` model structs from JSON files or JSON Schema definitions.
///
/// Supports nested objects, arrays, optional properties, and custom naming strategies.
public final class ModelGenerator: CodeGenerator {

    // MARK: - Properties

    public let generatorType = "model"
    public let inputPath: String
    public let outputPath: String

    private let config: CodeGenConfig

    // MARK: - Initialization

    public init(inputPath: String, outputPath: String, config: CodeGenConfig) {
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.config = config
    }

    // MARK: - Generation

    public func generate() throws -> [GeneratedFile] {
        let fileManager = FileManager.default
        let url = URL(fileURLWithPath: inputPath)
        var isDirectory: ObjCBool = false

        guard fileManager.fileExists(atPath: inputPath, isDirectory: &isDirectory) else {
            throw CodeGenError.inputNotFound(inputPath)
        }

        var files: [URL] = []

        if isDirectory.boolValue {
            let enumerator = fileManager.enumerator(at: url, includingPropertiesForKeys: nil)
            while let fileURL = enumerator?.nextObject() as? URL {
                if fileURL.pathExtension == "json" {
                    files.append(fileURL)
                }
            }
        } else {
            files.append(url)
        }

        var generated: [GeneratedFile] = []

        for file in files.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
            let data = try Data(contentsOf: file)
            let json = try JSONSerialization.jsonObject(with: data)
            let modelName = modelNameFromFileName(file.deletingPathExtension().lastPathComponent)
            let code = generateModel(name: modelName, from: json)
            generated.append(GeneratedFile(fileName: "\(modelName).swift", content: code))
        }

        return generated
    }

    // MARK: - Model Generation

    private func generateModel(name: String, from json: Any) -> String {
        var lines: [String] = []
        let indent = String(repeating: " ", count: config.indentWidth)

        lines.append(config.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")

        generateStruct(name: name, json: json, lines: &lines, indent: indent, level: 0)

        return lines.joined(separator: "\n")
    }

    private func generateStruct(name: String, json: Any, lines: inout [String], indent: String, level: Int) {
        let prefix = String(repeating: indent, count: level)

        guard let dict = json as? [String: Any] else {
            lines.append("\(prefix)typealias \(name) = \(inferType(from: json))")
            return
        }

        let conformances = "Codable, Equatable, Sendable"
        lines.append("\(prefix)struct \(name): \(conformances) {")

        var nestedTypes: [(String, Any)] = []

        for (key, value) in dict.sorted(by: { $0.key < $1.key }) {
            let propertyName = camelCase(key)
            let typeName = inferType(from: value, key: key)

            if let nestedDict = value as? [String: Any] {
                let nestedName = key.prefix(1).uppercased() + key.dropFirst()
                nestedTypes.append((nestedName, nestedDict))
                lines.append("\(prefix)\(indent)let \(propertyName): \(nestedName)")
            } else if let array = value as? [Any], let first = array.first, first is [String: Any] {
                let nestedName = singularize(key).prefix(1).uppercased() + singularize(key).dropFirst()
                nestedTypes.append((String(nestedName), first))
                lines.append("\(prefix)\(indent)let \(propertyName): [\(nestedName)]")
            } else {
                lines.append("\(prefix)\(indent)let \(propertyName): \(typeName)")
            }
        }

        // Add CodingKeys if needed
        let needsCodingKeys = dict.keys.contains(where: { $0.contains("_") || $0.contains("-") })
        if needsCodingKeys {
            lines.append("")
            lines.append("\(prefix)\(indent)enum CodingKeys: String, CodingKey {")
            for key in dict.keys.sorted() {
                let propertyName = camelCase(key)
                if propertyName != key {
                    lines.append("\(prefix)\(indent)\(indent)case \(propertyName) = \"\(key)\"")
                } else {
                    lines.append("\(prefix)\(indent)\(indent)case \(propertyName)")
                }
            }
            lines.append("\(prefix)\(indent)}")
        }

        // Generate nested types
        for (nestedName, nestedJSON) in nestedTypes {
            lines.append("")
            generateStruct(name: nestedName, json: nestedJSON, lines: &lines, indent: indent, level: level + 1)
        }

        lines.append("\(prefix)}")
    }

    // MARK: - Type Inference

    private func inferType(from value: Any, key: String = "") -> String {
        switch value {
        case is String:
            return "String"
        case is Bool:
            return "Bool"
        case let number as NSNumber:
            if CFNumberIsFloatType(number) {
                return "Double"
            }
            return "Int"
        case is [String]:
            return "[String]"
        case is [Int]:
            return "[Int]"
        case is [Double]:
            return "[Double]"
        case is [Any]:
            return "[Any]"
        case is NSNull:
            return "String?"
        default:
            return "Any"
        }
    }

    // MARK: - Naming

    private func modelNameFromFileName(_ name: String) -> String {
        let cleaned = name.replacingOccurrences(of: "-", with: "_")
        let components = cleaned.split(separator: "_")
        return components.map { $0.prefix(1).uppercased() + $0.dropFirst() }.joined()
    }

    private func camelCase(_ input: String) -> String {
        let components = input.split(whereSeparator: { $0 == "_" || $0 == "-" })
        guard let first = components.first else { return input }
        let rest = components.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }
        return first.lowercased() + rest.joined()
    }

    private func singularize(_ word: String) -> String {
        if word.hasSuffix("ies") {
            return String(word.dropLast(3)) + "y"
        } else if word.hasSuffix("ses") || word.hasSuffix("xes") || word.hasSuffix("zes") {
            return String(word.dropLast(2))
        } else if word.hasSuffix("s") && !word.hasSuffix("ss") {
            return String(word.dropLast())
        }
        return word
    }
}
