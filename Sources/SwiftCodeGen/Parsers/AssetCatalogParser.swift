import Foundation

/// Parses Xcode asset catalogs (.xcassets) to extract asset entries
/// for colors, images, data assets, and symbol images.
public final class AssetCatalogParser {

    // MARK: - Initialization

    public init() {}

    // MARK: - Parsing

    /// Parses an asset catalog at the given path.
    /// - Parameter path: Path to the .xcassets directory.
    /// - Returns: A parsed `AssetCatalog` with all discovered assets.
    public func parse(at path: String) throws -> AssetCatalog {
        let fileManager = FileManager.default
        let url = URL(fileURLWithPath: path)

        guard fileManager.fileExists(atPath: path) else {
            throw CodeGenError.inputNotFound(path)
        }

        var catalog = AssetCatalog()

        let contents = try fileManager.contentsOfDirectory(
            at: url,
            includingPropertiesForKeys: [.isDirectoryKey],
            options: [.skipsHiddenFiles]
        )

        for item in contents {
            try parseAssetEntry(at: item, into: &catalog, namespace: nil)
        }

        return catalog
    }

    // MARK: - Entry Parsing

    private func parseAssetEntry(at url: URL, into catalog: inout AssetCatalog, namespace: String?) throws {
        let ext = url.pathExtension
        let name = url.deletingPathExtension().lastPathComponent
        let qualifiedName = namespace.map { "\($0)/\(name)" } ?? name

        switch ext {
        case "colorset":
            catalog.colors.append(AssetEntry(name: qualifiedName, namespace: namespace))

        case "imageset":
            catalog.images.append(AssetEntry(name: qualifiedName, namespace: namespace))

        case "dataset":
            catalog.dataAssets.append(AssetEntry(name: qualifiedName, namespace: namespace))

        case "symbolset":
            catalog.symbols.append(AssetEntry(name: qualifiedName, namespace: namespace))

        default:
            // Could be a folder/group — recurse into it
            var isDir: ObjCBool = false
            if FileManager.default.fileExists(atPath: url.path, isDirectory: &isDir), isDir.boolValue {
                let children = try FileManager.default.contentsOfDirectory(
                    at: url,
                    includingPropertiesForKeys: nil,
                    options: [.skipsHiddenFiles]
                )
                let newNamespace = namespace.map { "\($0)/\(name)" } ?? name
                for child in children {
                    try parseAssetEntry(at: child, into: &catalog, namespace: newNamespace)
                }
            }
        }
    }
}
