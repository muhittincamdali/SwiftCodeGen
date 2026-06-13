import Foundation

/// Main entry point for the SwiftCodeGen engine.
public enum SwiftCodeGen {
    public static let version = "2.0.0"
}

/// A protocol for code generators
public protocol Generator: Sendable {
    func generate() async throws -> String
}
