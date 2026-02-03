import Foundation

/// A lightweight Mustache-like template engine for code generation.
///
/// Supports variable interpolation, section blocks (conditionals and loops),
/// inverted sections, and comment blocks.
///
/// ## Usage
/// ```swift
/// let engine = TemplateEngine()
/// let output = engine.render("Hello {{name}}!", context: ["name": "World"])
/// // output: "Hello World!"
/// ```
public final class TemplateEngine {

    // MARK: - Token Types

    private enum Token {
        case text(String)
        case variable(String)
        case sectionStart(String)
        case sectionEnd(String)
        case invertedSection(String)
        case comment
    }

    // MARK: - Initialization

    public init() {}

    // MARK: - Rendering

    /// Renders a template string with the provided context dictionary.
    /// - Parameters:
    ///   - template: The template string with `{{variable}}` placeholders.
    ///   - context: A dictionary of values to substitute.
    /// - Returns: The rendered output string.
    public func render(_ template: String, context: [String: Any]) -> String {
        let tokens = tokenize(template)
        return evaluate(tokens: tokens, context: context)
    }

    // MARK: - Tokenization

    private func tokenize(_ template: String) -> [Token] {
        var tokens: [Token] = []
        var remaining = template

        while !remaining.isEmpty {
            guard let openRange = remaining.range(of: "{{") else {
                tokens.append(.text(remaining))
                break
            }

            let textBefore = String(remaining[remaining.startIndex..<openRange.lowerBound])
            if !textBefore.isEmpty {
                tokens.append(.text(textBefore))
            }

            remaining = String(remaining[openRange.upperBound...])

            guard let closeRange = remaining.range(of: "}}") else {
                tokens.append(.text("{{" + remaining))
                break
            }

            let tag = String(remaining[remaining.startIndex..<closeRange.lowerBound])
                .trimmingCharacters(in: .whitespaces)
            remaining = String(remaining[closeRange.upperBound...])

            if tag.hasPrefix("#") {
                tokens.append(.sectionStart(String(tag.dropFirst())))
            } else if tag.hasPrefix("/") {
                tokens.append(.sectionEnd(String(tag.dropFirst())))
            } else if tag.hasPrefix("^") {
                tokens.append(.invertedSection(String(tag.dropFirst())))
            } else if tag.hasPrefix("!") {
                tokens.append(.comment)
            } else {
                tokens.append(.variable(tag))
            }
        }

        return tokens
    }

    // MARK: - Evaluation

    private func evaluate(tokens: [Token], context: [String: Any]) -> String {
        var output = ""
        var index = 0

        while index < tokens.count {
            switch tokens[index] {
            case .text(let text):
                output += text

            case .variable(let key):
                if let value = resolveValue(key, in: context) {
                    output += String(describing: value)
                }

            case .sectionStart(let key):
                let sectionTokens = extractSection(named: key, from: tokens, startingAfter: index)
                let sectionEndIndex = findSectionEnd(named: key, in: tokens, after: index)

                if let value = resolveValue(key, in: context) {
                    if let array = value as? [[String: Any]] {
                        for item in array {
                            let merged = context.merging(item) { _, new in new }
                            output += evaluate(tokens: sectionTokens, context: merged)
                        }
                    } else if isTruthy(value) {
                        output += evaluate(tokens: sectionTokens, context: context)
                    }
                }

                index = sectionEndIndex

            case .invertedSection(let key):
                let sectionTokens = extractSection(named: key, from: tokens, startingAfter: index)
                let sectionEndIndex = findSectionEnd(named: key, in: tokens, after: index)

                let value = resolveValue(key, in: context)
                if value == nil || !isTruthy(value!) {
                    output += evaluate(tokens: sectionTokens, context: context)
                }

                index = sectionEndIndex

            case .sectionEnd:
                break

            case .comment:
                break
            }

            index += 1
        }

        return output
    }

    // MARK: - Helpers

    private func resolveValue(_ key: String, in context: [String: Any]) -> Any? {
        let components = key.split(separator: ".")
        var current: Any? = context

        for component in components {
            guard let dict = current as? [String: Any] else { return nil }
            current = dict[String(component)]
        }

        return current
    }

    private func isTruthy(_ value: Any) -> Bool {
        switch value {
        case let bool as Bool:
            return bool
        case let string as String:
            return !string.isEmpty
        case let number as Int:
            return number != 0
        case let array as [Any]:
            return !array.isEmpty
        default:
            return true
        }
    }

    private func extractSection(named name: String, from tokens: [Token], startingAfter start: Int) -> [Token] {
        var depth = 0
        var result: [Token] = []

        for i in (start + 1)..<tokens.count {
            switch tokens[i] {
            case .sectionStart(let n) where n == name:
                depth += 1
                result.append(tokens[i])
            case .sectionEnd(let n) where n == name:
                if depth == 0 { return result }
                depth -= 1
                result.append(tokens[i])
            default:
                result.append(tokens[i])
            }
        }

        return result
    }

    private func findSectionEnd(named name: String, in tokens: [Token], after start: Int) -> Int {
        var depth = 0

        for i in (start + 1)..<tokens.count {
            switch tokens[i] {
            case .sectionStart(let n) where n == name:
                depth += 1
            case .sectionEnd(let n) where n == name:
                if depth == 0 { return i }
                depth -= 1
            default:
                break
            }
        }

        return tokens.count - 1
    }
}
