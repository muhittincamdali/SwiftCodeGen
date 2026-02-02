import Foundation

/// Generates strongly-typed Swift accessors from string catalogs (.xcstrings)
/// or legacy .strings / .stringsdict files.
///
/// Supports nested enum grouping based on key prefixes and
/// automatic function generation for parameterized strings.
public final class LocalizationGenerator: CodeGenerator {

    // MARK: - Properties

    public let generatorType = "localization"
    public let inputPath: String
    public let outputPath: String

    private let config: CodeGenConfig
    private let separator: Character = "."

    // MARK: - Initialization

    public init(inputPath: String, outputPath: String, config: CodeGenConfig) {
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.config = config
    }

    // MARK: - Generation

    public func generate() throws -> [GeneratedFile] {
        let entries = try parseLocalizationFile(at: inputPath)
        let grouped = groupEntries(entries)
        let content = generateCode(from: grouped, entries: entries)
        let fileName = URL(fileURLWithPath: outputPath).lastPathComponent
        return [GeneratedFile(fileName: fileName, content: content)]
    }

    // MARK: - Parsing

    private func parseLocalizationFile(at path: String) throws -> [LocalizationEntry] {
        let url = URL(fileURLWithPath: path)
        let data = try Data(contentsOf: url)

        if path.hasSuffix(".xcstrings") {
            return try parseStringCatalog(data: data)
        } else if path.hasSuffix(".strings") {
            return try parseLegacyStrings(data: data)
        } else {
            throw CodeGenError.unsupportedFormat(path)
        }
    }

    private func parseStringCatalog(data: Data) throws -> [LocalizationEntry] {
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
              let strings = json["strings"] as? [String: Any] else {
            throw CodeGenError.invalidFormat("Invalid .xcstrings format")
        }

        var entries: [LocalizationEntry] = []

        for (key, value) in strings {
            guard let info = value as? [String: Any] else { continue }

            let comment = info["comment"] as? String
            var formatArgs: [FormatArgument] = []

            // Parse localizations to detect format specifiers
            if let localizations = info["localizations"] as? [String: Any],
               let enLocalization = localizations["en"] as? [String: Any],
               let stringUnit = enLocalization["stringUnit"] as? [String: Any],
               let baseValue = stringUnit["value"] as? String {
                formatArgs = extractFormatArguments(from: baseValue)
            }

            let entry = LocalizationEntry(
                key: key,
                comment: comment,
                formatArguments: formatArgs,
                hasPluralization: info["localizations"] != nil
            )
            entries.append(entry)
        }

        return entries.sorted { $0.key < $1.key }
    }

    private func parseLegacyStrings(data: Data) throws -> [LocalizationEntry] {
        guard let content = String(data: data, encoding: .utf8) else {
            throw CodeGenError.invalidFormat("Cannot read .strings file")
        }

        var entries: [LocalizationEntry] = []
        let pattern = #"\"([^\"]+)\"\s*=\s*\"([^\"]+)\"\s*;"#

        guard let regex = try? NSRegularExpression(pattern: pattern) else {
            return entries
        }

        let nsRange = NSRange(content.startIndex..., in: content)
        let matches = regex.matches(in: content, range: nsRange)

        for match in matches {
            guard let keyRange = Range(match.range(at: 1), in: content),
                  let valueRange = Range(match.range(at: 2), in: content) else { continue }

            let key = String(content[keyRange])
            let value = String(content[valueRange])
            let formatArgs = extractFormatArguments(from: value)

            entries.append(LocalizationEntry(
                key: key,
                comment: nil,
                formatArguments: formatArgs,
                hasPluralization: false
            ))
        }

        return entries.sorted { $0.key < $1.key }
    }

    // MARK: - Grouping

    private func groupEntries(_ entries: [LocalizationEntry]) -> [String: [LocalizationEntry]] {
        var groups: [String: [LocalizationEntry]] = [:]

        for entry in entries {
            let components = entry.key.split(separator: separator)
            let group = components.count > 1 ? String(components[0]) : ""
            groups[group, default: []].append(entry)
        }

        return groups
    }

    // MARK: - Code Generation

    private func generateCode(from groups: [String: [LocalizationEntry]], entries: [LocalizationEntry]) -> String {
        var lines: [String] = []
        let indent = String(repeating: " ", count: config.indentWidth)

        lines.append(config.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Localized Strings")
        lines.append("")
        lines.append("enum L10n {")

        // Top-level entries (no prefix group)
        if let topLevel = groups[""] {
            for entry in topLevel {
                lines.append(contentsOf: generateAccessor(for: entry, indent: indent))
            }
        }

        // Grouped entries as nested enums
        for (group, groupEntries) in groups.sorted(by: { $0.key < $1.key }) where !group.isEmpty {
            lines.append("")
            lines.append("\(indent)// MARK: - \(group.capitalized)")
            lines.append("")
            lines.append("\(indent)enum \(group.capitalized) {")

            for entry in groupEntries {
                lines.append(contentsOf: generateAccessor(for: entry, indent: indent + indent))
            }

            lines.append("\(indent)}")
        }

        lines.append("}")
        lines.append("")

        return lines.joined(separator: "\n")
    }

    private func generateAccessor(for entry: LocalizationEntry, indent: String) -> [String] {
        var lines: [String] = []
        let propertyName = sanitizePropertyName(entry.key)

        if let comment = entry.comment {
            lines.append("\(indent)/// \(comment)")
        }

        if entry.formatArguments.isEmpty {
            lines.append("\(indent)static let \(propertyName) = NSLocalizedString(\"\(entry.key)\", comment: \"\")")
        } else {
            let params = entry.formatArguments.enumerated().map { index, arg in
                "_ p\(index + 1): \(arg.swiftType)"
            }.joined(separator: ", ")

            lines.append("\(indent)static func \(propertyName)(\(params)) -> String {")
            let formatArgs = entry.formatArguments.enumerated().map { "p\($0.offset + 1)" }.joined(separator: ", ")
            lines.append("\(indent)\(String(repeating: " ", count: config.indentWidth))String(format: NSLocalizedString(\"\(entry.key)\", comment: \"\"), \(formatArgs))")
            lines.append("\(indent)}")
        }

        return lines
    }

    // MARK: - Format Argument Extraction

    private func extractFormatArguments(from value: String) -> [FormatArgument] {
        var args: [FormatArgument] = []
        let specifierPattern = #"%(\d+\$)?([+-]?\d*\.?\d*)([@dDuUxXoOfeEgGcCsSpaAF]|l[dDuUxXo]|ll[dDuUxXo])"#

        guard let regex = try? NSRegularExpression(pattern: specifierPattern) else { return args }
        let nsRange = NSRange(value.startIndex..., in: value)
        let matches = regex.matches(in: value, range: nsRange)

        for match in matches {
            guard let specRange = Range(match.range(at: 3), in: value) else { continue }
            let specifier = String(value[specRange])
            let argType = FormatArgument(specifier: specifier)
            args.append(argType)
        }

        return args
    }

    private func sanitizePropertyName(_ key: String) -> String {
        let components = key.split(separator: separator)
        let name = components.last.map(String.init) ?? key
        return name
            .replacingOccurrences(of: "-", with: "_")
            .replacingOccurrences(of: " ", with: "_")
    }
}

// MARK: - Models

struct LocalizationEntry {
    let key: String
    let comment: String?
    let formatArguments: [FormatArgument]
    let hasPluralization: Bool
}

struct FormatArgument {
    let swiftType: String

    init(specifier: String) {
        switch specifier.lowercased() {
        case "d", "ld", "lld", "u", "lu", "llu", "x", "o":
            swiftType = "Int"
        case "f", "e", "g", "a":
            swiftType = "Double"
        case "@", "s":
            swiftType = "String"
        case "c":
            swiftType = "Character"
        case "p":
            swiftType = "UnsafeRawPointer"
        default:
            swiftType = "Any"
        }
    }

    init(swiftType: String) {
        self.swiftType = swiftType
    }
}
