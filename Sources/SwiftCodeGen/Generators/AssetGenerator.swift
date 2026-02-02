import Foundation

/// Generates type-safe Swift accessors from Xcode asset catalogs (.xcassets).
///
/// Supports colors, images, data assets, and symbol images with
/// compile-time safe enum-based access patterns.
public final class AssetGenerator: CodeGenerator {

    // MARK: - Properties

    public let generatorType = "assets"
    public let inputPath: String
    public let outputPath: String

    private let config: CodeGenConfig
    private let catalogParser: AssetCatalogParser

    // MARK: - Initialization

    public init(inputPath: String, outputPath: String, config: CodeGenConfig) {
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.config = config
        self.catalogParser = AssetCatalogParser()
    }

    // MARK: - Generation

    public func generate() throws -> [GeneratedFile] {
        let catalog = try catalogParser.parse(at: inputPath)
        let content = generateAssetCode(from: catalog)
        let fileName = URL(fileURLWithPath: outputPath).lastPathComponent
        return [GeneratedFile(fileName: fileName, content: content)]
    }

    // MARK: - Code Generation

    private func generateAssetCode(from catalog: AssetCatalog) -> String {
        var lines: [String] = []
        let indent = String(repeating: " ", count: config.indentWidth)

        lines.append(config.headerComment)
        lines.append("")
        lines.append("import SwiftUI")
        lines.append("")
        lines.append("// MARK: - Asset Catalog")
        lines.append("")
        lines.append("enum Asset {")

        // Generate color assets
        if !catalog.colors.isEmpty {
            lines.append("")
            lines.append("\(indent)// MARK: - Colors")
            lines.append("")
            lines.append("\(indent)enum Colors {")
            for color in catalog.colors.sorted(by: { $0.name < $1.name }) {
                let propertyName = camelCase(color.name)
                lines.append("\(indent)\(indent)static let \(propertyName) = Color(\"\(color.name)\")")
            }
            lines.append("\(indent)}")
        }

        // Generate image assets
        if !catalog.images.isEmpty {
            lines.append("")
            lines.append("\(indent)// MARK: - Images")
            lines.append("")
            lines.append("\(indent)enum Images {")
            for image in catalog.images.sorted(by: { $0.name < $1.name }) {
                let propertyName = camelCase(image.name)
                lines.append("\(indent)\(indent)static let \(propertyName) = Image(\"\(image.name)\")")
            }
            lines.append("\(indent)}")
        }

        // Generate data assets
        if !catalog.dataAssets.isEmpty {
            lines.append("")
            lines.append("\(indent)// MARK: - Data")
            lines.append("")
            lines.append("\(indent)enum Data {")
            for asset in catalog.dataAssets.sorted(by: { $0.name < $1.name }) {
                let propertyName = camelCase(asset.name)
                lines.append("\(indent)\(indent)static let \(propertyName) = NSDataAsset(name: \"\(asset.name)\")!.data")
            }
            lines.append("\(indent)}")
        }

        // Generate symbol images
        if !catalog.symbols.isEmpty {
            lines.append("")
            lines.append("\(indent)// MARK: - Symbols")
            lines.append("")
            lines.append("\(indent)enum Symbols {")
            for symbol in catalog.symbols.sorted(by: { $0.name < $1.name }) {
                let propertyName = camelCase(symbol.name)
                lines.append("\(indent)\(indent)static let \(propertyName) = Image(systemName: \"\(symbol.name)\")")
            }
            lines.append("\(indent)}")
        }

        lines.append("}")
        lines.append("")

        // Generate UIKit convenience extensions
        lines.append("// MARK: - UIKit Convenience")
        lines.append("")
        lines.append("#if canImport(UIKit)")
        lines.append("import UIKit")
        lines.append("")
        lines.append("extension Asset.Colors {")
        for color in catalog.colors.sorted(by: { $0.name < $1.name }) {
            let propertyName = camelCase(color.name)
            lines.append("\(indent)static var \(propertyName)UIColor: UIColor {")
            lines.append("\(indent)\(indent)UIColor(named: \"\(color.name)\")!")
            lines.append("\(indent)}")
        }
        lines.append("}")
        lines.append("")

        lines.append("extension Asset.Images {")
        for image in catalog.images.sorted(by: { $0.name < $1.name }) {
            let propertyName = camelCase(image.name)
            lines.append("\(indent)static var \(propertyName)UIImage: UIImage {")
            lines.append("\(indent)\(indent)UIImage(named: \"\(image.name)\")!")
            lines.append("\(indent)}")
        }
        lines.append("}")
        lines.append("#endif")
        lines.append("")

        return lines.joined(separator: "\n")
    }

    // MARK: - Helpers

    private func camelCase(_ input: String) -> String {
        let components = input.split(whereSeparator: { $0 == "-" || $0 == "_" || $0 == " " || $0 == "/" })
        guard let first = components.first else { return input }

        let rest = components.dropFirst().map { $0.prefix(1).uppercased() + $0.dropFirst() }
        return first.lowercased() + rest.joined()
    }
}

// MARK: - Asset Catalog Models

/// Represents a parsed asset catalog with all asset types.
public struct AssetCatalog {
    public var colors: [AssetEntry]
    public var images: [AssetEntry]
    public var dataAssets: [AssetEntry]
    public var symbols: [AssetEntry]

    public init(colors: [AssetEntry] = [], images: [AssetEntry] = [],
                dataAssets: [AssetEntry] = [], symbols: [AssetEntry] = []) {
        self.colors = colors
        self.images = images
        self.dataAssets = dataAssets
        self.symbols = symbols
    }
}

/// Represents a single asset entry with its name and optional namespace.
public struct AssetEntry {
    public let name: String
    public let namespace: String?

    public init(name: String, namespace: String? = nil) {
        self.name = name
        self.namespace = namespace
    }
}
