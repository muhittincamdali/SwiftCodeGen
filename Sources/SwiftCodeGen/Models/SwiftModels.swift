import Foundation

/// Represents a Swift class for code generation.
public struct SwiftClass: Sendable {
    public let name: String
    public let properties: [SwiftProperty]
    public let isFinal: Bool
    
    public init(name: String, properties: [SwiftProperty] = [], isFinal: Bool = true) {
        self.name = name
        self.properties = properties
        self.isFinal = isFinal
    }
}

/// Represents a Swift property.
public struct SwiftProperty: Sendable {
    public let name: String
    public let type: String
    public let isMutable: Bool
    
    public init(name: String, type: String, isMutable: Bool = false) {
        self.name = name
        self.type = type
        self.isMutable = isMutable
    }
}
