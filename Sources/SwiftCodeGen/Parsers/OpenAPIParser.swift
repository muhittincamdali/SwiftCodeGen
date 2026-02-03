import Foundation

// MARK: - OpenAPI Specification Types

/// Represents an OpenAPI specification document.
public struct OpenAPIDocument: Codable, Sendable {
    
    /// The OpenAPI version.
    public let openapi: String
    
    /// Information about the API.
    public let info: Info
    
    /// Server configurations.
    public let servers: [Server]?
    
    /// The paths defined in the API.
    public let paths: [String: PathItem]
    
    /// Reusable components.
    public let components: Components?
    
    /// Security schemes.
    public let security: [[String: [String]]]?
    
    /// External documentation.
    public let externalDocs: ExternalDocumentation?
    
    /// Tags for grouping operations.
    public let tags: [Tag]?
}

// MARK: - Info

extension OpenAPIDocument {
    
    /// API information.
    public struct Info: Codable, Sendable {
        public let title: String
        public let description: String?
        public let termsOfService: String?
        public let contact: Contact?
        public let license: License?
        public let version: String
    }
    
    /// Contact information.
    public struct Contact: Codable, Sendable {
        public let name: String?
        public let url: String?
        public let email: String?
    }
    
    /// License information.
    public struct License: Codable, Sendable {
        public let name: String
        public let url: String?
    }
}

// MARK: - Server

extension OpenAPIDocument {
    
    /// Server configuration.
    public struct Server: Codable, Sendable {
        public let url: String
        public let description: String?
        public let variables: [String: ServerVariable]?
    }
    
    /// Server variable.
    public struct ServerVariable: Codable, Sendable {
        public let `default`: String
        public let description: String?
        public let `enum`: [String]?
    }
}

// MARK: - Paths

extension OpenAPIDocument {
    
    /// A single path item.
    public struct PathItem: Codable, Sendable {
        public let summary: String?
        public let description: String?
        public let get: Operation?
        public let put: Operation?
        public let post: Operation?
        public let delete: Operation?
        public let options: Operation?
        public let head: Operation?
        public let patch: Operation?
        public let trace: Operation?
        public let servers: [Server]?
        public let parameters: [ParameterOrReference]?
    }
    
    /// An API operation.
    public struct Operation: Codable, Sendable {
        public let tags: [String]?
        public let summary: String?
        public let description: String?
        public let externalDocs: ExternalDocumentation?
        public let operationId: String?
        public let parameters: [ParameterOrReference]?
        public let requestBody: RequestBodyOrReference?
        public let responses: [String: ResponseOrReference]
        public let callbacks: [String: CallbackOrReference]?
        public let deprecated: Bool?
        public let security: [[String: [String]]]?
        public let servers: [Server]?
    }
}

// MARK: - Parameters

extension OpenAPIDocument {
    
    /// Parameter or reference.
    public enum ParameterOrReference: Codable, Sendable {
        case parameter(Parameter)
        case reference(Reference)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let reference = try? container.decode(Reference.self) {
                self = .reference(reference)
            } else {
                self = .parameter(try container.decode(Parameter.self))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .parameter(let param):
                try container.encode(param)
            case .reference(let ref):
                try container.encode(ref)
            }
        }
    }
    
    /// API parameter.
    public struct Parameter: Codable, Sendable {
        public let name: String
        public let `in`: ParameterLocation
        public let description: String?
        public let required: Bool?
        public let deprecated: Bool?
        public let allowEmptyValue: Bool?
        public let style: String?
        public let explode: Bool?
        public let allowReserved: Bool?
        public let schema: SchemaOrReference?
        public let example: AnyCodable?
        public let examples: [String: ExampleOrReference]?
        public let content: [String: MediaType]?
    }
    
    /// Parameter location.
    public enum ParameterLocation: String, Codable, Sendable {
        case query
        case header
        case path
        case cookie
    }
}

// MARK: - Request Body

extension OpenAPIDocument {
    
    /// Request body or reference.
    public enum RequestBodyOrReference: Codable, Sendable {
        case requestBody(RequestBody)
        case reference(Reference)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let reference = try? container.decode(Reference.self) {
                self = .reference(reference)
            } else {
                self = .requestBody(try container.decode(RequestBody.self))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .requestBody(let body):
                try container.encode(body)
            case .reference(let ref):
                try container.encode(ref)
            }
        }
    }
    
    /// Request body definition.
    public struct RequestBody: Codable, Sendable {
        public let description: String?
        public let content: [String: MediaType]
        public let required: Bool?
    }
}

// MARK: - Responses

extension OpenAPIDocument {
    
    /// Response or reference.
    public enum ResponseOrReference: Codable, Sendable {
        case response(Response)
        case reference(Reference)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let reference = try? container.decode(Reference.self) {
                self = .reference(reference)
            } else {
                self = .response(try container.decode(Response.self))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .response(let response):
                try container.encode(response)
            case .reference(let ref):
                try container.encode(ref)
            }
        }
    }
    
    /// Response definition.
    public struct Response: Codable, Sendable {
        public let description: String
        public let headers: [String: HeaderOrReference]?
        public let content: [String: MediaType]?
        public let links: [String: LinkOrReference]?
    }
}

// MARK: - Schema

extension OpenAPIDocument {
    
    /// Schema or reference.
    public enum SchemaOrReference: Codable, Sendable {
        case schema(Schema)
        case reference(Reference)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let reference = try? container.decode(Reference.self) {
                self = .reference(reference)
            } else {
                self = .schema(try container.decode(Schema.self))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .schema(let schema):
                try container.encode(schema)
            case .reference(let ref):
                try container.encode(ref)
            }
        }
    }
    
    /// Schema definition.
    public struct Schema: Codable, Sendable {
        public let title: String?
        public let description: String?
        public let type: SchemaType?
        public let format: String?
        public let `default`: AnyCodable?
        public let nullable: Bool?
        public let discriminator: Discriminator?
        public let readOnly: Bool?
        public let writeOnly: Bool?
        public let xml: XML?
        public let externalDocs: ExternalDocumentation?
        public let example: AnyCodable?
        public let deprecated: Bool?
        public let allOf: [SchemaOrReference]?
        public let oneOf: [SchemaOrReference]?
        public let anyOf: [SchemaOrReference]?
        public let not: SchemaOrReference?
        public let items: SchemaOrReference?
        public let properties: [String: SchemaOrReference]?
        public let additionalProperties: AdditionalProperties?
        public let required: [String]?
        public let `enum`: [AnyCodable]?
        public let minimum: Double?
        public let maximum: Double?
        public let exclusiveMinimum: Bool?
        public let exclusiveMaximum: Bool?
        public let minLength: Int?
        public let maxLength: Int?
        public let pattern: String?
        public let minItems: Int?
        public let maxItems: Int?
        public let uniqueItems: Bool?
        public let minProperties: Int?
        public let maxProperties: Int?
    }
    
    /// Schema type.
    public enum SchemaType: String, Codable, Sendable {
        case string
        case number
        case integer
        case boolean
        case array
        case object
    }
    
    /// Additional properties configuration.
    public enum AdditionalProperties: Codable, Sendable {
        case bool(Bool)
        case schema(SchemaOrReference)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let bool = try? container.decode(Bool.self) {
                self = .bool(bool)
            } else {
                self = .schema(try container.decode(SchemaOrReference.self))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .bool(let value):
                try container.encode(value)
            case .schema(let schema):
                try container.encode(schema)
            }
        }
    }
    
    /// Discriminator for polymorphism.
    public struct Discriminator: Codable, Sendable {
        public let propertyName: String
        public let mapping: [String: String]?
    }
    
    /// XML configuration.
    public struct XML: Codable, Sendable {
        public let name: String?
        public let namespace: String?
        public let prefix: String?
        public let attribute: Bool?
        public let wrapped: Bool?
    }
}

// MARK: - Components

extension OpenAPIDocument {
    
    /// Reusable components.
    public struct Components: Codable, Sendable {
        public let schemas: [String: SchemaOrReference]?
        public let responses: [String: ResponseOrReference]?
        public let parameters: [String: ParameterOrReference]?
        public let examples: [String: ExampleOrReference]?
        public let requestBodies: [String: RequestBodyOrReference]?
        public let headers: [String: HeaderOrReference]?
        public let securitySchemes: [String: SecuritySchemeOrReference]?
        public let links: [String: LinkOrReference]?
        public let callbacks: [String: CallbackOrReference]?
    }
}

// MARK: - Media Type

extension OpenAPIDocument {
    
    /// Media type definition.
    public struct MediaType: Codable, Sendable {
        public let schema: SchemaOrReference?
        public let example: AnyCodable?
        public let examples: [String: ExampleOrReference]?
        public let encoding: [String: Encoding]?
    }
    
    /// Encoding definition.
    public struct Encoding: Codable, Sendable {
        public let contentType: String?
        public let headers: [String: HeaderOrReference]?
        public let style: String?
        public let explode: Bool?
        public let allowReserved: Bool?
    }
}

// MARK: - Security

extension OpenAPIDocument {
    
    /// Security scheme or reference.
    public enum SecuritySchemeOrReference: Codable, Sendable {
        case securityScheme(SecurityScheme)
        case reference(Reference)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let reference = try? container.decode(Reference.self) {
                self = .reference(reference)
            } else {
                self = .securityScheme(try container.decode(SecurityScheme.self))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .securityScheme(let scheme):
                try container.encode(scheme)
            case .reference(let ref):
                try container.encode(ref)
            }
        }
    }
    
    /// Security scheme definition.
    public struct SecurityScheme: Codable, Sendable {
        public let type: SecuritySchemeType
        public let description: String?
        public let name: String?
        public let `in`: String?
        public let scheme: String?
        public let bearerFormat: String?
        public let flows: OAuthFlows?
        public let openIdConnectUrl: String?
    }
    
    /// Security scheme type.
    public enum SecuritySchemeType: String, Codable, Sendable {
        case apiKey
        case http
        case oauth2
        case openIdConnect
    }
    
    /// OAuth flows.
    public struct OAuthFlows: Codable, Sendable {
        public let implicit: OAuthFlow?
        public let password: OAuthFlow?
        public let clientCredentials: OAuthFlow?
        public let authorizationCode: OAuthFlow?
    }
    
    /// OAuth flow definition.
    public struct OAuthFlow: Codable, Sendable {
        public let authorizationUrl: String?
        public let tokenUrl: String?
        public let refreshUrl: String?
        public let scopes: [String: String]
    }
}

// MARK: - Supporting Types

extension OpenAPIDocument {
    
    /// Reference object.
    public struct Reference: Codable, Sendable {
        public let ref: String
        
        enum CodingKeys: String, CodingKey {
            case ref = "$ref"
        }
    }
    
    /// External documentation.
    public struct ExternalDocumentation: Codable, Sendable {
        public let description: String?
        public let url: String
    }
    
    /// Tag definition.
    public struct Tag: Codable, Sendable {
        public let name: String
        public let description: String?
        public let externalDocs: ExternalDocumentation?
    }
    
    /// Header or reference.
    public enum HeaderOrReference: Codable, Sendable {
        case header(Header)
        case reference(Reference)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let reference = try? container.decode(Reference.self) {
                self = .reference(reference)
            } else {
                self = .header(try container.decode(Header.self))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .header(let header):
                try container.encode(header)
            case .reference(let ref):
                try container.encode(ref)
            }
        }
    }
    
    /// Header definition.
    public struct Header: Codable, Sendable {
        public let description: String?
        public let required: Bool?
        public let deprecated: Bool?
        public let allowEmptyValue: Bool?
        public let style: String?
        public let explode: Bool?
        public let allowReserved: Bool?
        public let schema: SchemaOrReference?
        public let example: AnyCodable?
        public let examples: [String: ExampleOrReference]?
        public let content: [String: MediaType]?
    }
    
    /// Example or reference.
    public enum ExampleOrReference: Codable, Sendable {
        case example(Example)
        case reference(Reference)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let reference = try? container.decode(Reference.self) {
                self = .reference(reference)
            } else {
                self = .example(try container.decode(Example.self))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .example(let example):
                try container.encode(example)
            case .reference(let ref):
                try container.encode(ref)
            }
        }
    }
    
    /// Example definition.
    public struct Example: Codable, Sendable {
        public let summary: String?
        public let description: String?
        public let value: AnyCodable?
        public let externalValue: String?
    }
    
    /// Link or reference.
    public enum LinkOrReference: Codable, Sendable {
        case link(Link)
        case reference(Reference)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let reference = try? container.decode(Reference.self) {
                self = .reference(reference)
            } else {
                self = .link(try container.decode(Link.self))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .link(let link):
                try container.encode(link)
            case .reference(let ref):
                try container.encode(ref)
            }
        }
    }
    
    /// Link definition.
    public struct Link: Codable, Sendable {
        public let operationRef: String?
        public let operationId: String?
        public let parameters: [String: AnyCodable]?
        public let requestBody: AnyCodable?
        public let description: String?
        public let server: Server?
    }
    
    /// Callback or reference.
    public enum CallbackOrReference: Codable, Sendable {
        case callback([String: PathItem])
        case reference(Reference)
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.singleValueContainer()
            if let reference = try? container.decode(Reference.self) {
                self = .reference(reference)
            } else {
                self = .callback(try container.decode([String: PathItem].self))
            }
        }
        
        public func encode(to encoder: Encoder) throws {
            var container = encoder.singleValueContainer()
            switch self {
            case .callback(let callback):
                try container.encode(callback)
            case .reference(let ref):
                try container.encode(ref)
            }
        }
    }
}

// MARK: - AnyCodable

/// A type-erased Codable value.
public struct AnyCodable: Codable, Sendable {
    public let value: Any
    
    public init(_ value: Any) {
        self.value = value
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self.value = NSNull()
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else if let string = try? container.decode(String.self) {
            self.value = string
        } else if let array = try? container.decode([AnyCodable].self) {
            self.value = array.map { $0.value }
        } else if let dictionary = try? container.decode([String: AnyCodable].self) {
            self.value = dictionary.mapValues { $0.value }
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode value")
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        
        switch value {
        case is NSNull:
            try container.encodeNil()
        case let bool as Bool:
            try container.encode(bool)
        case let int as Int:
            try container.encode(int)
        case let double as Double:
            try container.encode(double)
        case let string as String:
            try container.encode(string)
        case let array as [Any]:
            try container.encode(array.map { AnyCodable($0) })
        case let dictionary as [String: Any]:
            try container.encode(dictionary.mapValues { AnyCodable($0) })
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: encoder.codingPath, debugDescription: "Unable to encode value"))
        }
    }
}

// MARK: - OpenAPI Parser

/// Parses OpenAPI specification files and generates Swift code.
public final class OpenAPIParser {
    
    // MARK: - Configuration
    
    /// Configuration for OpenAPI parsing.
    public struct Configuration: Sendable {
        
        /// Whether to generate async methods.
        public var generateAsync: Bool
        
        /// Whether to generate Combine publishers.
        public var generateCombine: Bool
        
        /// Whether to generate model validations.
        public var generateValidations: Bool
        
        /// Whether to generate mock implementations.
        public var generateMocks: Bool
        
        /// Access level for generated types.
        public var accessLevel: String
        
        /// Prefix for generated type names.
        public var typePrefix: String
        
        /// Suffix for generated type names.
        public var typeSuffix: String
        
        /// Creates a new configuration.
        public init(
            generateAsync: Bool = true,
            generateCombine: Bool = false,
            generateValidations: Bool = true,
            generateMocks: Bool = true,
            accessLevel: String = "public",
            typePrefix: String = "",
            typeSuffix: String = ""
        ) {
            self.generateAsync = generateAsync
            self.generateCombine = generateCombine
            self.generateValidations = generateValidations
            self.generateMocks = generateMocks
            self.accessLevel = accessLevel
            self.typePrefix = typePrefix
            self.typeSuffix = typeSuffix
        }
    }
    
    // MARK: - Properties
    
    /// The parser configuration.
    public let configuration: Configuration
    
    /// The parsed document.
    private var document: OpenAPIDocument?
    
    /// Resolved schemas cache.
    private var resolvedSchemas: [String: OpenAPIDocument.Schema] = [:]
    
    // MARK: - Initialization
    
    /// Creates a new parser with the given configuration.
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
    // MARK: - Parsing
    
    /// Parses an OpenAPI document from a file URL.
    public func parse(fileURL: URL) throws -> OpenAPIDocument {
        let data = try Data(contentsOf: fileURL)
        return try parse(data: data)
    }
    
    /// Parses an OpenAPI document from data.
    public func parse(data: Data) throws -> OpenAPIDocument {
        let decoder = JSONDecoder()
        let document = try decoder.decode(OpenAPIDocument.self, from: data)
        self.document = document
        return document
    }
    
    /// Parses an OpenAPI document from a YAML string.
    public func parseYAML(string: String) throws -> OpenAPIDocument {
        // Convert YAML to JSON for decoding
        let jsonData = try convertYAMLToJSON(string)
        return try parse(data: jsonData)
    }
    
    // MARK: - Code Generation
    
    /// Generates Swift models from the parsed document.
    public func generateModels() throws -> [GeneratedFile] {
        guard let document = document else {
            throw OpenAPIParserError.noDocumentParsed
        }
        
        var files: [GeneratedFile] = []
        
        if let schemas = document.components?.schemas {
            for (name, schemaOrRef) in schemas {
                if case .schema(let schema) = schemaOrRef {
                    let file = try generateModel(name: name, schema: schema)
                    files.append(file)
                }
            }
        }
        
        return files
    }
    
    /// Generates API client from the parsed document.
    public func generateAPIClient() throws -> [GeneratedFile] {
        guard let document = document else {
            throw OpenAPIParserError.noDocumentParsed
        }
        
        var files: [GeneratedFile] = []
        
        // Generate base client
        files.append(generateBaseClient(info: document.info))
        
        // Generate endpoint enums
        files.append(generateEndpoints(paths: document.paths))
        
        // Generate request/response types
        for (path, pathItem) in document.paths {
            files.append(contentsOf: generatePathTypes(path: path, pathItem: pathItem))
        }
        
        // Generate authentication helpers
        if let securitySchemes = document.components?.securitySchemes {
            files.append(generateAuthenticationHelpers(schemes: securitySchemes))
        }
        
        return files
    }
    
    // MARK: - Model Generation
    
    private func generateModel(name: String, schema: OpenAPIDocument.Schema) throws -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: name))
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        
        let typeName = "\(configuration.typePrefix)\(name.pascalCased)\(configuration.typeSuffix)"
        
        if let description = schema.description {
            lines.append("/// \(description)")
        }
        
        let accessLevel = configuration.accessLevel
        
        if schema.type == .object, let properties = schema.properties {
            lines.append("\(accessLevel) struct \(typeName): Codable, Sendable, Equatable {")
            lines.append("")
            
            let requiredProperties = Set(schema.required ?? [])
            
            for (propName, propSchemaOrRef) in properties.sorted(by: { $0.key < $1.key }) {
                let isRequired = requiredProperties.contains(propName)
                let swiftType = try resolveSwiftType(from: propSchemaOrRef, required: isRequired)
                let swiftName = propName.camelCased
                
                lines.append("    /// The \(propName) property.")
                lines.append("    \(accessLevel) let \(swiftName): \(swiftType)")
                lines.append("")
            }
            
            // Generate CodingKeys if needed
            let needsCodingKeys = properties.keys.contains { $0.camelCased != $0 }
            if needsCodingKeys {
                lines.append("    enum CodingKeys: String, CodingKey {")
                for propName in properties.keys.sorted() {
                    let swiftName = propName.camelCased
                    if swiftName != propName {
                        lines.append("        case \(swiftName) = \"\(propName)\"")
                    } else {
                        lines.append("        case \(swiftName)")
                    }
                }
                lines.append("    }")
                lines.append("")
            }
            
            // Generate initializer
            lines.append("    /// Creates a new \(typeName) instance.")
            lines.append("    \(accessLevel) init(")
            
            let initParams = properties.sorted(by: { $0.key < $1.key }).map { (propName, propSchemaOrRef) -> String in
                let isRequired = requiredProperties.contains(propName)
                let swiftType = (try? resolveSwiftType(from: propSchemaOrRef, required: isRequired)) ?? "Any"
                let swiftName = propName.camelCased
                return "        \(swiftName): \(swiftType)"
            }.joined(separator: ",\n")
            
            lines.append(initParams)
            lines.append("    ) {")
            
            for propName in properties.keys.sorted() {
                let swiftName = propName.camelCased
                lines.append("        self.\(swiftName) = \(swiftName)")
            }
            
            lines.append("    }")
            lines.append("")
            
            lines.append("}")
            
        } else if let enumValues = schema.enum {
            lines.append("\(accessLevel) enum \(typeName): String, Codable, Sendable, CaseIterable {")
            
            for value in enumValues {
                if let stringValue = value.value as? String {
                    let caseName = stringValue.camelCased
                    if caseName != stringValue {
                        lines.append("    case \(caseName) = \"\(stringValue)\"")
                    } else {
                        lines.append("    case \(caseName)")
                    }
                }
            }
            
            lines.append("}")
        } else {
            lines.append("\(accessLevel) typealias \(typeName) = \(try resolveSwiftType(for: schema))")
        }
        
        return GeneratedFile(
            fileName: "\(typeName).swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    // MARK: - Client Generation
    
    private func generateBaseClient(info: OpenAPIDocument.Info) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: "APIClient"))
        lines.append("")
        lines.append("import Foundation")
        if configuration.generateCombine {
            lines.append("import Combine")
        }
        lines.append("")
        lines.append("// MARK: - APIClient")
        lines.append("")
        lines.append("/// \(info.title) API Client")
        if let description = info.description {
            lines.append("///")
            lines.append("/// \(description)")
        }
        lines.append("/// Version: \(info.version)")
        lines.append("public final class APIClient: Sendable {")
        lines.append("")
        lines.append("    // MARK: - Properties")
        lines.append("")
        lines.append("    /// The base URL for API requests.")
        lines.append("    public let baseURL: URL")
        lines.append("")
        lines.append("    /// The URL session for network requests.")
        lines.append("    public let session: URLSession")
        lines.append("")
        lines.append("    /// The JSON encoder for request bodies.")
        lines.append("    public let encoder: JSONEncoder")
        lines.append("")
        lines.append("    /// The JSON decoder for response bodies.")
        lines.append("    public let decoder: JSONDecoder")
        lines.append("")
        lines.append("    /// Authentication handler.")
        lines.append("    public var authenticationHandler: AuthenticationHandler?")
        lines.append("")
        lines.append("    // MARK: - Initialization")
        lines.append("")
        lines.append("    /// Creates a new API client.")
        lines.append("    public init(")
        lines.append("        baseURL: URL,")
        lines.append("        session: URLSession = .shared,")
        lines.append("        encoder: JSONEncoder = JSONEncoder(),")
        lines.append("        decoder: JSONDecoder = JSONDecoder()")
        lines.append("    ) {")
        lines.append("        self.baseURL = baseURL")
        lines.append("        self.session = session")
        lines.append("        self.encoder = encoder")
        lines.append("        self.decoder = decoder")
        lines.append("    }")
        lines.append("")
        lines.append("    // MARK: - Request Execution")
        lines.append("")
        
        if configuration.generateAsync {
            lines.append("    /// Executes an API request.")
            lines.append("    public func execute<T: Decodable>(_ request: APIRequest) async throws -> T {")
            lines.append("        let urlRequest = try buildRequest(request)")
            lines.append("        let (data, response) = try await session.data(for: urlRequest)")
            lines.append("        try validateResponse(response, data: data)")
            lines.append("        return try decoder.decode(T.self, from: data)")
            lines.append("    }")
            lines.append("")
            lines.append("    /// Executes an API request with no response body.")
            lines.append("    public func execute(_ request: APIRequest) async throws {")
            lines.append("        let urlRequest = try buildRequest(request)")
            lines.append("        let (data, response) = try await session.data(for: urlRequest)")
            lines.append("        try validateResponse(response, data: data)")
            lines.append("    }")
            lines.append("")
        }
        
        if configuration.generateCombine {
            lines.append("    /// Executes an API request and returns a publisher.")
            lines.append("    public func executePublisher<T: Decodable>(_ request: APIRequest) -> AnyPublisher<T, Error> {")
            lines.append("        do {")
            lines.append("            let urlRequest = try buildRequest(request)")
            lines.append("            return session.dataTaskPublisher(for: urlRequest)")
            lines.append("                .tryMap { [weak self] data, response in")
            lines.append("                    try self?.validateResponse(response, data: data)")
            lines.append("                    return data")
            lines.append("                }")
            lines.append("                .decode(type: T.self, decoder: decoder)")
            lines.append("                .eraseToAnyPublisher()")
            lines.append("        } catch {")
            lines.append("            return Fail(error: error).eraseToAnyPublisher()")
            lines.append("        }")
            lines.append("    }")
            lines.append("")
        }
        
        lines.append("    // MARK: - Request Building")
        lines.append("")
        lines.append("    private func buildRequest(_ request: APIRequest) throws -> URLRequest {")
        lines.append("        var url = baseURL.appendingPathComponent(request.path)")
        lines.append("")
        lines.append("        if !request.queryItems.isEmpty {")
        lines.append("            var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!")
        lines.append("            components.queryItems = request.queryItems")
        lines.append("            url = components.url!")
        lines.append("        }")
        lines.append("")
        lines.append("        var urlRequest = URLRequest(url: url)")
        lines.append("        urlRequest.httpMethod = request.method.rawValue")
        lines.append("")
        lines.append("        for (key, value) in request.headers {")
        lines.append("            urlRequest.setValue(value, forHTTPHeaderField: key)")
        lines.append("        }")
        lines.append("")
        lines.append("        if let body = request.body {")
        lines.append("            urlRequest.httpBody = try encoder.encode(body)")
        lines.append("            urlRequest.setValue(\"application/json\", forHTTPHeaderField: \"Content-Type\")")
        lines.append("        }")
        lines.append("")
        lines.append("        if let handler = authenticationHandler {")
        lines.append("            urlRequest = try handler.authenticate(urlRequest)")
        lines.append("        }")
        lines.append("")
        lines.append("        return urlRequest")
        lines.append("    }")
        lines.append("")
        lines.append("    // MARK: - Response Validation")
        lines.append("")
        lines.append("    private func validateResponse(_ response: URLResponse, data: Data) throws {")
        lines.append("        guard let httpResponse = response as? HTTPURLResponse else {")
        lines.append("            throw APIError.invalidResponse")
        lines.append("        }")
        lines.append("")
        lines.append("        guard (200...299).contains(httpResponse.statusCode) else {")
        lines.append("            throw APIError.httpError(statusCode: httpResponse.statusCode, data: data)")
        lines.append("        }")
        lines.append("    }")
        lines.append("")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - APIRequest")
        lines.append("")
        lines.append("/// Represents an API request.")
        lines.append("public struct APIRequest: Sendable {")
        lines.append("")
        lines.append("    /// HTTP method.")
        lines.append("    public enum Method: String, Sendable {")
        lines.append("        case get = \"GET\"")
        lines.append("        case post = \"POST\"")
        lines.append("        case put = \"PUT\"")
        lines.append("        case delete = \"DELETE\"")
        lines.append("        case patch = \"PATCH\"")
        lines.append("        case head = \"HEAD\"")
        lines.append("        case options = \"OPTIONS\"")
        lines.append("    }")
        lines.append("")
        lines.append("    /// The request path.")
        lines.append("    public let path: String")
        lines.append("")
        lines.append("    /// The HTTP method.")
        lines.append("    public let method: Method")
        lines.append("")
        lines.append("    /// Query parameters.")
        lines.append("    public let queryItems: [URLQueryItem]")
        lines.append("")
        lines.append("    /// Request headers.")
        lines.append("    public let headers: [String: String]")
        lines.append("")
        lines.append("    /// Request body.")
        lines.append("    public let body: (any Encodable & Sendable)?")
        lines.append("")
        lines.append("    /// Creates a new API request.")
        lines.append("    public init(")
        lines.append("        path: String,")
        lines.append("        method: Method,")
        lines.append("        queryItems: [URLQueryItem] = [],")
        lines.append("        headers: [String: String] = [:],")
        lines.append("        body: (any Encodable & Sendable)? = nil")
        lines.append("    ) {")
        lines.append("        self.path = path")
        lines.append("        self.method = method")
        lines.append("        self.queryItems = queryItems")
        lines.append("        self.headers = headers")
        lines.append("        self.body = body")
        lines.append("    }")
        lines.append("")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - APIError")
        lines.append("")
        lines.append("/// Errors that can occur during API requests.")
        lines.append("public enum APIError: LocalizedError, Sendable {")
        lines.append("")
        lines.append("    /// The response was invalid.")
        lines.append("    case invalidResponse")
        lines.append("")
        lines.append("    /// An HTTP error occurred.")
        lines.append("    case httpError(statusCode: Int, data: Data)")
        lines.append("")
        lines.append("    /// Request encoding failed.")
        lines.append("    case encodingFailed(Error)")
        lines.append("")
        lines.append("    /// Response decoding failed.")
        lines.append("    case decodingFailed(Error)")
        lines.append("")
        lines.append("    /// Authentication failed.")
        lines.append("    case authenticationFailed")
        lines.append("")
        lines.append("    public var errorDescription: String? {")
        lines.append("        switch self {")
        lines.append("        case .invalidResponse:")
        lines.append("            return \"Invalid response received\"")
        lines.append("        case .httpError(let code, _):")
        lines.append("            return \"HTTP error: \\(code)\"")
        lines.append("        case .encodingFailed(let error):")
        lines.append("            return \"Encoding failed: \\(error.localizedDescription)\"")
        lines.append("        case .decodingFailed(let error):")
        lines.append("            return \"Decoding failed: \\(error.localizedDescription)\"")
        lines.append("        case .authenticationFailed:")
        lines.append("            return \"Authentication failed\"")
        lines.append("        }")
        lines.append("    }")
        lines.append("")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - AuthenticationHandler")
        lines.append("")
        lines.append("/// Protocol for authentication handlers.")
        lines.append("public protocol AuthenticationHandler: Sendable {")
        lines.append("    func authenticate(_ request: URLRequest) throws -> URLRequest")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "APIClient.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    private func generateEndpoints(paths: [String: OpenAPIDocument.PathItem]) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: "Endpoints"))
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Endpoints")
        lines.append("")
        lines.append("/// Available API endpoints.")
        lines.append("public enum Endpoints {")
        lines.append("")
        
        for (path, pathItem) in paths.sorted(by: { $0.key < $1.key }) {
            let operations: [(String, OpenAPIDocument.Operation?)] = [
                ("get", pathItem.get),
                ("post", pathItem.post),
                ("put", pathItem.put),
                ("delete", pathItem.delete),
                ("patch", pathItem.patch)
            ]
            
            for (method, operation) in operations {
                guard let op = operation else { continue }
                
                let operationName = op.operationId ?? "\(method)\(path.replacingOccurrences(of: "/", with: "_"))"
                let safeName = operationName.camelCased
                
                if let summary = op.summary {
                    lines.append("    /// \(summary)")
                }
                
                lines.append("    public static let \(safeName) = \"\(path)\"")
                lines.append("")
            }
        }
        
        lines.append("}")
        
        return GeneratedFile(
            fileName: "Endpoints.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    private func generatePathTypes(path: String, pathItem: OpenAPIDocument.PathItem) -> [GeneratedFile] {
        // Generate request/response types for each operation
        // This is a simplified version - a full implementation would be more comprehensive
        return []
    }
    
    private func generateAuthenticationHelpers(schemes: [String: OpenAPIDocument.SecuritySchemeOrReference]) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: "Authentication"))
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Authentication Handlers")
        lines.append("")
        
        for (name, schemeOrRef) in schemes {
            if case .securityScheme(let scheme) = schemeOrRef {
                lines.append("/// \(name) authentication handler.")
                
                switch scheme.type {
                case .apiKey:
                    lines.append("public final class \(name.pascalCased)Authentication: AuthenticationHandler {")
                    lines.append("")
                    lines.append("    private let apiKey: String")
                    lines.append("    private let headerName: String")
                    lines.append("")
                    lines.append("    public init(apiKey: String, headerName: String = \"\(scheme.name ?? "X-API-Key")\") {")
                    lines.append("        self.apiKey = apiKey")
                    lines.append("        self.headerName = headerName")
                    lines.append("    }")
                    lines.append("")
                    lines.append("    public func authenticate(_ request: URLRequest) throws -> URLRequest {")
                    lines.append("        var request = request")
                    lines.append("        request.setValue(apiKey, forHTTPHeaderField: headerName)")
                    lines.append("        return request")
                    lines.append("    }")
                    lines.append("")
                    lines.append("}")
                    
                case .http:
                    lines.append("public final class \(name.pascalCased)Authentication: AuthenticationHandler {")
                    lines.append("")
                    lines.append("    private let token: String")
                    lines.append("")
                    lines.append("    public init(token: String) {")
                    lines.append("        self.token = token")
                    lines.append("    }")
                    lines.append("")
                    lines.append("    public func authenticate(_ request: URLRequest) throws -> URLRequest {")
                    lines.append("        var request = request")
                    lines.append("        request.setValue(\"Bearer \\(token)\", forHTTPHeaderField: \"Authorization\")")
                    lines.append("        return request")
                    lines.append("    }")
                    lines.append("")
                    lines.append("}")
                    
                case .oauth2:
                    lines.append("public final class \(name.pascalCased)Authentication: AuthenticationHandler {")
                    lines.append("")
                    lines.append("    private var accessToken: String")
                    lines.append("")
                    lines.append("    public init(accessToken: String) {")
                    lines.append("        self.accessToken = accessToken")
                    lines.append("    }")
                    lines.append("")
                    lines.append("    public func authenticate(_ request: URLRequest) throws -> URLRequest {")
                    lines.append("        var request = request")
                    lines.append("        request.setValue(\"Bearer \\(accessToken)\", forHTTPHeaderField: \"Authorization\")")
                    lines.append("        return request")
                    lines.append("    }")
                    lines.append("")
                    lines.append("    public func updateToken(_ token: String) {")
                    lines.append("        self.accessToken = token")
                    lines.append("    }")
                    lines.append("")
                    lines.append("}")
                    
                default:
                    break
                }
                
                lines.append("")
            }
        }
        
        return GeneratedFile(
            fileName: "Authentication.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    // MARK: - Type Resolution
    
    private func resolveSwiftType(from schemaOrRef: OpenAPIDocument.SchemaOrReference, required: Bool) throws -> String {
        let baseType: String
        
        switch schemaOrRef {
        case .schema(let schema):
            baseType = try resolveSwiftType(for: schema)
        case .reference(let ref):
            baseType = extractTypeName(from: ref.ref)
        }
        
        return required ? baseType : "\(baseType)?"
    }
    
    private func resolveSwiftType(for schema: OpenAPIDocument.Schema) throws -> String {
        if let type = schema.type {
            switch type {
            case .string:
                if let format = schema.format {
                    switch format {
                    case "date":
                        return "Date"
                    case "date-time":
                        return "Date"
                    case "uuid":
                        return "UUID"
                    case "uri":
                        return "URL"
                    case "byte":
                        return "Data"
                    default:
                        return "String"
                    }
                }
                return "String"
            case .integer:
                if let format = schema.format {
                    switch format {
                    case "int32":
                        return "Int32"
                    case "int64":
                        return "Int64"
                    default:
                        return "Int"
                    }
                }
                return "Int"
            case .number:
                if schema.format == "float" {
                    return "Float"
                }
                return "Double"
            case .boolean:
                return "Bool"
            case .array:
                if let items = schema.items {
                    let itemType = try resolveSwiftType(from: items, required: true)
                    return "[\(itemType)]"
                }
                return "[Any]"
            case .object:
                if let additionalProperties = schema.additionalProperties {
                    switch additionalProperties {
                    case .bool:
                        return "[String: Any]"
                    case .schema(let valueSchema):
                        let valueType = try resolveSwiftType(from: valueSchema, required: true)
                        return "[String: \(valueType)]"
                    }
                }
                return "[String: Any]"
            }
        }
        
        if schema.allOf != nil || schema.oneOf != nil || schema.anyOf != nil {
            return "Any"
        }
        
        return "Any"
    }
    
    private func extractTypeName(from ref: String) -> String {
        let components = ref.split(separator: "/")
        if let last = components.last {
            return String(last).pascalCased
        }
        return "Unknown"
    }
    
    // MARK: - YAML Conversion
    
    private func convertYAMLToJSON(_ yaml: String) throws -> Data {
        // Simplified YAML to JSON conversion
        // In production, use a proper YAML parser like Yams
        throw OpenAPIParserError.yamlNotSupported
    }
    
    // MARK: - Helpers
    
    private func generateFileHeader(for fileName: String) -> String {
        """
        //
        //  \(fileName).swift
        //  SwiftCodeGen
        //
        //  Auto-generated from OpenAPI specification.
        //
        """
    }
}

// MARK: - Errors

/// Errors that can occur during OpenAPI parsing.
public enum OpenAPIParserError: LocalizedError {
    case noDocumentParsed
    case invalidSchema(String)
    case unsupportedType(String)
    case yamlNotSupported
    case referenceNotFound(String)
    
    public var errorDescription: String? {
        switch self {
        case .noDocumentParsed:
            return "No OpenAPI document has been parsed"
        case .invalidSchema(let name):
            return "Invalid schema: \(name)"
        case .unsupportedType(let type):
            return "Unsupported type: \(type)"
        case .yamlNotSupported:
            return "YAML parsing requires external dependency"
        case .referenceNotFound(let ref):
            return "Reference not found: \(ref)"
        }
    }
}

// MARK: - String Extensions

private extension String {
    
    var pascalCased: String {
        let words = self.components(separatedBy: CharacterSet.alphanumerics.inverted)
        return words.map { $0.capitalized }.joined()
    }
    
    var camelCased: String {
        let pascal = pascalCased
        guard let first = pascal.first else { return self }
        return first.lowercased() + pascal.dropFirst()
    }
}
