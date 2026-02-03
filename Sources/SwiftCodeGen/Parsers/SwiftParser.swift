import Foundation

/// Parses Swift source files to extract protocol declarations, methods, and properties.
///
/// Uses regex-based parsing to identify protocol definitions and their members
/// including async/throws modifiers, generic parameters, and associated types.
public final class SwiftParser {

    // MARK: - Initialization

    public init() {}

    // MARK: - Protocol Parsing

    /// Parses all protocol declarations from the given Swift source code.
    /// - Parameter source: The Swift source code string to parse.
    /// - Returns: An array of parsed protocol declarations.
    public func parseProtocols(from source: String) -> [ProtocolDeclaration] {
        var protocols: [ProtocolDeclaration] = []
        let lines = source.components(separatedBy: .newlines)
        var index = 0

        while index < lines.count {
            let line = lines[index].trimmingCharacters(in: .whitespaces)

            if let protocolMatch = matchProtocolDeclaration(line) {
                let body = extractBody(from: lines, startingAt: index)
                let methods = parseMethods(from: body)
                let properties = parseProperties(from: body)
                let associatedTypes = parseAssociatedTypes(from: body)

                let proto = ProtocolDeclaration(
                    name: protocolMatch.name,
                    inheritedProtocols: protocolMatch.inherited,
                    methods: methods,
                    properties: properties,
                    associatedTypes: associatedTypes
                )
                protocols.append(proto)

                index += body.count + 1
            } else {
                index += 1
            }
        }

        return protocols
    }

    // MARK: - Protocol Declaration Matching

    private struct ProtocolMatch {
        let name: String
        let inherited: [String]
    }

    private func matchProtocolDeclaration(_ line: String) -> ProtocolMatch? {
        let pattern = #"(?:public\s+)?protocol\s+(\w+)\s*(?::\s*(.+))?\s*\{"#
        guard let regex = try? NSRegularExpression(pattern: pattern),
              let match = regex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let nameRange = Range(match.range(at: 1), in: line) else {
            return nil
        }

        let name = String(line[nameRange])
        var inherited: [String] = []

        if let inheritedRange = Range(match.range(at: 2), in: line) {
            inherited = String(line[inheritedRange])
                .split(separator: ",")
                .map { $0.trimmingCharacters(in: .whitespaces) }
        }

        return ProtocolMatch(name: name, inherited: inherited)
    }

    // MARK: - Body Extraction

    private func extractBody(from lines: [String], startingAt start: Int) -> [String] {
        var braceCount = 0
        var body: [String] = []
        var foundOpen = false

        for i in start..<lines.count {
            let line = lines[i]

            for char in line {
                if char == "{" {
                    braceCount += 1
                    foundOpen = true
                } else if char == "}" {
                    braceCount -= 1
                }
            }

            if foundOpen {
                body.append(line)
            }

            if foundOpen && braceCount == 0 {
                break
            }
        }

        return body
    }

    // MARK: - Method Parsing

    private func parseMethods(from body: [String]) -> [MethodDeclaration] {
        var methods: [MethodDeclaration] = []

        for line in body {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("func ") else { continue }

            if let method = parseMethodSignature(trimmed) {
                methods.append(method)
            }
        }

        return methods
    }

    private func parseMethodSignature(_ line: String) -> MethodDeclaration? {
        let namePattern = #"func\s+(\w+)"#
        guard let nameRegex = try? NSRegularExpression(pattern: namePattern),
              let nameMatch = nameRegex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let nameRange = Range(nameMatch.range(at: 1), in: line) else {
            return nil
        }

        let name = String(line[nameRange])
        let parameters = parseParameters(from: line)
        let isAsync = line.contains(" async ")
        let isThrowing = line.contains(" throws") || line.contains(" throws ")

        var returnType: String?
        var isOptionalReturn = false

        let returnPattern = #"->\s*(.+?)$"#
        if let returnRegex = try? NSRegularExpression(pattern: returnPattern),
           let returnMatch = returnRegex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
           let returnRange = Range(returnMatch.range(at: 1), in: line) {
            let rawReturn = String(line[returnRange]).trimmingCharacters(in: .whitespaces)
            returnType = rawReturn
            isOptionalReturn = rawReturn.hasSuffix("?")
        }

        return MethodDeclaration(
            name: name,
            parameters: parameters,
            returnType: returnType,
            isAsync: isAsync,
            isThrowing: isThrowing,
            isOptionalReturn: isOptionalReturn
        )
    }

    private func parseParameters(from line: String) -> [ParameterDeclaration] {
        let paramPattern = #"\(([^)]*)\)"#
        guard let paramRegex = try? NSRegularExpression(pattern: paramPattern),
              let paramMatch = paramRegex.firstMatch(in: line, range: NSRange(line.startIndex..., in: line)),
              let paramRange = Range(paramMatch.range(at: 1), in: line) else {
            return []
        }

        let paramString = String(line[paramRange]).trimmingCharacters(in: .whitespaces)
        guard !paramString.isEmpty else { return [] }

        var parameters: [ParameterDeclaration] = []
        let params = splitParameters(paramString)

        for param in params {
            let parts = param.trimmingCharacters(in: .whitespaces).components(separatedBy: ":")
            guard parts.count == 2 else { continue }

            let namePart = parts[0].trimmingCharacters(in: .whitespaces)
            let typePart = parts[1].trimmingCharacters(in: .whitespaces)

            let nameComponents = namePart.split(separator: " ")
            let label: String?
            let name: String

            if nameComponents.count == 2 {
                label = nameComponents[0] == "_" ? nil : String(nameComponents[0])
                name = String(nameComponents[1])
            } else {
                label = String(nameComponents[0])
                name = String(nameComponents[0])
            }

            parameters.append(ParameterDeclaration(
                label: label,
                name: name,
                typeName: typePart
            ))
        }

        return parameters
    }

    private func splitParameters(_ input: String) -> [String] {
        var result: [String] = []
        var current = ""
        var depth = 0

        for char in input {
            if char == "<" || char == "(" || char == "[" { depth += 1 }
            else if char == ">" || char == ")" || char == "]" { depth -= 1 }

            if char == "," && depth == 0 {
                result.append(current)
                current = ""
            } else {
                current.append(char)
            }
        }

        if !current.isEmpty {
            result.append(current)
        }

        return result
    }

    // MARK: - Property Parsing

    private func parseProperties(from body: [String]) -> [PropertyDeclaration] {
        var properties: [PropertyDeclaration] = []

        for line in body {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("var ") else { continue }
            guard !trimmed.contains("func ") else { continue }

            let pattern = #"var\s+(\w+)\s*:\s*(\S+)\s*\{(.+)\}"#
            guard let regex = try? NSRegularExpression(pattern: pattern),
                  let match = regex.firstMatch(in: trimmed, range: NSRange(trimmed.startIndex..., in: trimmed)),
                  let nameRange = Range(match.range(at: 1), in: trimmed),
                  let typeRange = Range(match.range(at: 2), in: trimmed),
                  let accessorRange = Range(match.range(at: 3), in: trimmed) else {
                continue
            }

            let name = String(trimmed[nameRange])
            let typeName = String(trimmed[typeRange])
            let accessors = String(trimmed[accessorRange]).trimmingCharacters(in: .whitespaces)
            let isReadOnly = !accessors.contains("set")

            properties.append(PropertyDeclaration(
                name: name,
                typeName: typeName,
                isReadOnly: isReadOnly
            ))
        }

        return properties
    }

    // MARK: - Associated Type Parsing

    private func parseAssociatedTypes(from body: [String]) -> [String] {
        var types: [String] = []

        for line in body {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            guard trimmed.hasPrefix("associatedtype ") else { continue }

            let name = trimmed
                .replacingOccurrences(of: "associatedtype ", with: "")
                .components(separatedBy: ":")[0]
                .components(separatedBy: " ")[0]
                .trimmingCharacters(in: .whitespaces)

            types.append(name)
        }

        return types
    }
}
