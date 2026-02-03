import Foundation

/// Handles writing generated files to disk with directory creation
/// and optional backup of existing files.
public final class FileWriter {

    // MARK: - Properties

    private let fileManager: FileManager

    // MARK: - Initialization

    public init(fileManager: FileManager = .default) {
        self.fileManager = fileManager
    }

    // MARK: - Writing

    /// Writes an array of generated files to the specified output directory.
    /// - Parameters:
    ///   - files: The generated files to write.
    ///   - directory: The target directory path.
    public func write(_ files: [GeneratedFile], to directory: String) throws {
        let dirURL = URL(fileURLWithPath: directory)

        // Create directory if needed
        if !fileManager.fileExists(atPath: dirURL.path) {
            try fileManager.createDirectory(at: dirURL, withIntermediateDirectories: true)
        }

        for file in files {
            let fileURL = dirURL.appendingPathComponent(file.fileName)
            let data = file.content.data(using: .utf8)
            try data?.write(to: fileURL, options: .atomic)
        }
    }

    /// Writes a single generated file to the specified path.
    /// - Parameters:
    ///   - file: The generated file to write.
    ///   - path: The full file path.
    public func writeSingle(_ file: GeneratedFile, to path: String) throws {
        let url = URL(fileURLWithPath: path)
        let parentDir = url.deletingLastPathComponent()

        if !fileManager.fileExists(atPath: parentDir.path) {
            try fileManager.createDirectory(at: parentDir, withIntermediateDirectories: true)
        }

        let data = file.content.data(using: .utf8)
        try data?.write(to: url, options: .atomic)
    }

    /// Removes all previously generated files in the directory.
    /// - Parameter directory: The directory to clean.
    public func clean(directory: String) throws {
        let dirURL = URL(fileURLWithPath: directory)

        guard fileManager.fileExists(atPath: dirURL.path) else { return }

        let contents = try fileManager.contentsOfDirectory(
            at: dirURL,
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        )

        for file in contents where file.pathExtension == "swift" {
            try fileManager.removeItem(at: file)
        }
    }
}
