import Foundation

// MARK: - GraphQL Schema Types

/// Represents a GraphQL schema document.
public struct GraphQLSchema: Sendable {
    
    /// The types defined in the schema.
    public let types: [GraphQLType]
    
    /// The query type.
    public let queryType: GraphQLType?
    
    /// The mutation type.
    public let mutationType: GraphQLType?
    
    /// The subscription type.
    public let subscriptionType: GraphQLType?
    
    /// The directives defined in the schema.
    public let directives: [GraphQLDirective]
    
    /// Creates a new GraphQL schema.
    public init(
        types: [GraphQLType],
        queryType: GraphQLType? = nil,
        mutationType: GraphQLType? = nil,
        subscriptionType: GraphQLType? = nil,
        directives: [GraphQLDirective] = []
    ) {
        self.types = types
        self.queryType = queryType
        self.mutationType = mutationType
        self.subscriptionType = subscriptionType
        self.directives = directives
    }
}

// MARK: - GraphQL Type

/// Represents a GraphQL type.
public struct GraphQLType: Sendable {
    
    /// The kind of type.
    public enum Kind: String, Sendable {
        case scalar = "SCALAR"
        case object = "OBJECT"
        case interface = "INTERFACE"
        case union = "UNION"
        case `enum` = "ENUM"
        case inputObject = "INPUT_OBJECT"
        case list = "LIST"
        case nonNull = "NON_NULL"
    }
    
    /// The type kind.
    public let kind: Kind
    
    /// The type name.
    public let name: String?
    
    /// Description of the type.
    public let description: String?
    
    /// Fields for object types.
    public let fields: [GraphQLField]?
    
    /// Input fields for input object types.
    public let inputFields: [GraphQLInputValue]?
    
    /// Interfaces implemented by this type.
    public let interfaces: [GraphQLTypeReference]?
    
    /// Enum values for enum types.
    public let enumValues: [GraphQLEnumValue]?
    
    /// Possible types for unions and interfaces.
    public let possibleTypes: [GraphQLTypeReference]?
    
    /// The wrapped type for LIST and NON_NULL.
    public let ofType: GraphQLTypeReference?
    
    /// Creates a new GraphQL type.
    public init(
        kind: Kind,
        name: String?,
        description: String? = nil,
        fields: [GraphQLField]? = nil,
        inputFields: [GraphQLInputValue]? = nil,
        interfaces: [GraphQLTypeReference]? = nil,
        enumValues: [GraphQLEnumValue]? = nil,
        possibleTypes: [GraphQLTypeReference]? = nil,
        ofType: GraphQLTypeReference? = nil
    ) {
        self.kind = kind
        self.name = name
        self.description = description
        self.fields = fields
        self.inputFields = inputFields
        self.interfaces = interfaces
        self.enumValues = enumValues
        self.possibleTypes = possibleTypes
        self.ofType = ofType
    }
}

// MARK: - GraphQL Field

/// Represents a GraphQL field.
public struct GraphQLField: Sendable {
    
    /// The field name.
    public let name: String
    
    /// Description of the field.
    public let description: String?
    
    /// Arguments for the field.
    public let args: [GraphQLInputValue]
    
    /// The field type.
    public let type: GraphQLTypeReference
    
    /// Whether the field is deprecated.
    public let isDeprecated: Bool
    
    /// Deprecation reason.
    public let deprecationReason: String?
    
    /// Creates a new GraphQL field.
    public init(
        name: String,
        description: String? = nil,
        args: [GraphQLInputValue] = [],
        type: GraphQLTypeReference,
        isDeprecated: Bool = false,
        deprecationReason: String? = nil
    ) {
        self.name = name
        self.description = description
        self.args = args
        self.type = type
        self.isDeprecated = isDeprecated
        self.deprecationReason = deprecationReason
    }
}

// MARK: - GraphQL Input Value

/// Represents a GraphQL input value (argument or input field).
public struct GraphQLInputValue: Sendable {
    
    /// The name of the input value.
    public let name: String
    
    /// Description of the input value.
    public let description: String?
    
    /// The type of the input value.
    public let type: GraphQLTypeReference
    
    /// Default value as a string.
    public let defaultValue: String?
    
    /// Creates a new GraphQL input value.
    public init(
        name: String,
        description: String? = nil,
        type: GraphQLTypeReference,
        defaultValue: String? = nil
    ) {
        self.name = name
        self.description = description
        self.type = type
        self.defaultValue = defaultValue
    }
}

// MARK: - GraphQL Type Reference

/// A reference to a GraphQL type.
public indirect enum GraphQLTypeReference: Sendable {
    case named(String)
    case list(GraphQLTypeReference)
    case nonNull(GraphQLTypeReference)
    
    /// The underlying type name.
    public var typeName: String {
        switch self {
        case .named(let name):
            return name
        case .list(let ofType):
            return ofType.typeName
        case .nonNull(let ofType):
            return ofType.typeName
        }
    }
    
    /// Whether this type is non-null.
    public var isNonNull: Bool {
        if case .nonNull = self { return true }
        return false
    }
    
    /// Whether this type is a list.
    public var isList: Bool {
        switch self {
        case .list:
            return true
        case .nonNull(let inner):
            return inner.isList
        default:
            return false
        }
    }
}

// MARK: - GraphQL Enum Value

/// Represents a GraphQL enum value.
public struct GraphQLEnumValue: Sendable {
    
    /// The enum value name.
    public let name: String
    
    /// Description of the value.
    public let description: String?
    
    /// Whether the value is deprecated.
    public let isDeprecated: Bool
    
    /// Deprecation reason.
    public let deprecationReason: String?
    
    /// Creates a new GraphQL enum value.
    public init(
        name: String,
        description: String? = nil,
        isDeprecated: Bool = false,
        deprecationReason: String? = nil
    ) {
        self.name = name
        self.description = description
        self.isDeprecated = isDeprecated
        self.deprecationReason = deprecationReason
    }
}

// MARK: - GraphQL Directive

/// Represents a GraphQL directive.
public struct GraphQLDirective: Sendable {
    
    /// Directive locations.
    public enum Location: String, Sendable {
        case query = "QUERY"
        case mutation = "MUTATION"
        case subscription = "SUBSCRIPTION"
        case field = "FIELD"
        case fragmentDefinition = "FRAGMENT_DEFINITION"
        case fragmentSpread = "FRAGMENT_SPREAD"
        case inlineFragment = "INLINE_FRAGMENT"
        case schema = "SCHEMA"
        case scalar = "SCALAR"
        case object = "OBJECT"
        case fieldDefinition = "FIELD_DEFINITION"
        case argumentDefinition = "ARGUMENT_DEFINITION"
        case interface = "INTERFACE"
        case union = "UNION"
        case `enum` = "ENUM"
        case enumValue = "ENUM_VALUE"
        case inputObject = "INPUT_OBJECT"
        case inputFieldDefinition = "INPUT_FIELD_DEFINITION"
    }
    
    /// The directive name.
    public let name: String
    
    /// Description of the directive.
    public let description: String?
    
    /// Locations where the directive can be used.
    public let locations: [Location]
    
    /// Arguments for the directive.
    public let args: [GraphQLInputValue]
    
    /// Creates a new GraphQL directive.
    public init(
        name: String,
        description: String? = nil,
        locations: [Location] = [],
        args: [GraphQLInputValue] = []
    ) {
        self.name = name
        self.description = description
        self.locations = locations
        self.args = args
    }
}

// MARK: - GraphQL Operation

/// Represents a GraphQL operation (query, mutation, or subscription).
public struct GraphQLOperation: Sendable {
    
    /// The operation type.
    public enum OperationType: String, Sendable {
        case query
        case mutation
        case subscription
    }
    
    /// The operation type.
    public let type: OperationType
    
    /// The operation name.
    public let name: String?
    
    /// Variables defined by the operation.
    public let variables: [GraphQLVariable]
    
    /// The selection set.
    public let selectionSet: GraphQLSelectionSet
    
    /// Creates a new GraphQL operation.
    public init(
        type: OperationType,
        name: String? = nil,
        variables: [GraphQLVariable] = [],
        selectionSet: GraphQLSelectionSet
    ) {
        self.type = type
        self.name = name
        self.variables = variables
        self.selectionSet = selectionSet
    }
}

// MARK: - GraphQL Variable

/// Represents a GraphQL variable.
public struct GraphQLVariable: Sendable {
    
    /// The variable name.
    public let name: String
    
    /// The variable type.
    public let type: GraphQLTypeReference
    
    /// Default value.
    public let defaultValue: String?
    
    /// Creates a new GraphQL variable.
    public init(name: String, type: GraphQLTypeReference, defaultValue: String? = nil) {
        self.name = name
        self.type = type
        self.defaultValue = defaultValue
    }
}

// MARK: - GraphQL Selection Set

/// Represents a GraphQL selection set.
public struct GraphQLSelectionSet: Sendable {
    
    /// The selections in the set.
    public let selections: [GraphQLSelection]
    
    /// Creates a new selection set.
    public init(selections: [GraphQLSelection]) {
        self.selections = selections
    }
}

// MARK: - GraphQL Selection

/// Represents a selection in a GraphQL query.
public indirect enum GraphQLSelection: Sendable {
    case field(GraphQLFieldSelection)
    case fragmentSpread(String)
    case inlineFragment(GraphQLInlineFragment)
}

/// A field selection.
public struct GraphQLFieldSelection: Sendable {
    public let alias: String?
    public let name: String
    public let arguments: [GraphQLArgument]
    public let selectionSet: GraphQLSelectionSet?
    
    public init(
        alias: String? = nil,
        name: String,
        arguments: [GraphQLArgument] = [],
        selectionSet: GraphQLSelectionSet? = nil
    ) {
        self.alias = alias
        self.name = name
        self.arguments = arguments
        self.selectionSet = selectionSet
    }
}

/// An inline fragment.
public struct GraphQLInlineFragment: Sendable {
    public let typeCondition: String?
    public let selectionSet: GraphQLSelectionSet
    
    public init(typeCondition: String?, selectionSet: GraphQLSelectionSet) {
        self.typeCondition = typeCondition
        self.selectionSet = selectionSet
    }
}

/// A GraphQL argument.
public struct GraphQLArgument: Sendable {
    public let name: String
    public let value: GraphQLValue
    
    public init(name: String, value: GraphQLValue) {
        self.name = name
        self.value = value
    }
}

/// A GraphQL value.
public indirect enum GraphQLValue: Sendable {
    case variable(String)
    case int(Int)
    case float(Double)
    case string(String)
    case boolean(Bool)
    case null
    case `enum`(String)
    case list([GraphQLValue])
    case object([String: GraphQLValue])
}

// MARK: - GraphQL Parser

/// Parses GraphQL schema and operation documents.
public final class GraphQLParser {
    
    // MARK: - Configuration
    
    /// Configuration for GraphQL code generation.
    public struct Configuration: Sendable {
        
        /// Whether to generate async methods.
        public var generateAsync: Bool
        
        /// Whether to generate Combine publishers.
        public var generateCombine: Bool
        
        /// Whether to generate fragment protocols.
        public var generateFragmentProtocols: Bool
        
        /// Whether to generate input type initializers.
        public var generateInputInitializers: Bool
        
        /// Access level for generated types.
        public var accessLevel: String
        
        /// Prefix for generated type names.
        public var typePrefix: String
        
        /// Suffix for generated type names.
        public var typeSuffix: String
        
        /// Custom scalar mappings.
        public var scalarMappings: [String: String]
        
        /// Creates a new configuration.
        public init(
            generateAsync: Bool = true,
            generateCombine: Bool = false,
            generateFragmentProtocols: Bool = true,
            generateInputInitializers: Bool = true,
            accessLevel: String = "public",
            typePrefix: String = "",
            typeSuffix: String = "",
            scalarMappings: [String: String] = [:]
        ) {
            self.generateAsync = generateAsync
            self.generateCombine = generateCombine
            self.generateFragmentProtocols = generateFragmentProtocols
            self.generateInputInitializers = generateInputInitializers
            self.accessLevel = accessLevel
            self.typePrefix = typePrefix
            self.typeSuffix = typeSuffix
            self.scalarMappings = scalarMappings
        }
    }
    
    // MARK: - Lexer Types
    
    private enum Token: Equatable {
        case name(String)
        case intValue(Int)
        case floatValue(Double)
        case stringValue(String)
        case punctuator(Character)
        case spread
        case eof
    }
    
    // MARK: - Properties
    
    /// The parser configuration.
    public let configuration: Configuration
    
    /// The parsed schema.
    private var schema: GraphQLSchema?
    
    /// Built-in scalar type mappings.
    private let builtInScalars: [String: String] = [
        "ID": "String",
        "String": "String",
        "Int": "Int",
        "Float": "Double",
        "Boolean": "Bool"
    ]
    
    // MARK: - Initialization
    
    /// Creates a new parser with the given configuration.
    public init(configuration: Configuration = Configuration()) {
        self.configuration = configuration
    }
    
    // MARK: - Schema Parsing
    
    /// Parses a GraphQL schema from a file URL.
    public func parseSchema(fileURL: URL) throws -> GraphQLSchema {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        return try parseSchema(content: content)
    }
    
    /// Parses a GraphQL schema from a string.
    public func parseSchema(content: String) throws -> GraphQLSchema {
        var types: [GraphQLType] = []
        var queryType: GraphQLType?
        var mutationType: GraphQLType?
        var subscriptionType: GraphQLType?
        var directives: [GraphQLDirective] = []
        
        let tokens = try tokenize(content)
        var index = 0
        
        while index < tokens.count {
            let token = tokens[index]
            
            switch token {
            case .name(let name):
                switch name {
                case "type":
                    let type = try parseObjectType(tokens: tokens, index: &index)
                    types.append(type)
                    if type.name == "Query" { queryType = type }
                    if type.name == "Mutation" { mutationType = type }
                    if type.name == "Subscription" { subscriptionType = type }
                    
                case "input":
                    let type = try parseInputType(tokens: tokens, index: &index)
                    types.append(type)
                    
                case "enum":
                    let type = try parseEnumType(tokens: tokens, index: &index)
                    types.append(type)
                    
                case "interface":
                    let type = try parseInterfaceType(tokens: tokens, index: &index)
                    types.append(type)
                    
                case "union":
                    let type = try parseUnionType(tokens: tokens, index: &index)
                    types.append(type)
                    
                case "scalar":
                    let type = try parseScalarType(tokens: tokens, index: &index)
                    types.append(type)
                    
                case "directive":
                    let directive = try parseDirective(tokens: tokens, index: &index)
                    directives.append(directive)
                    
                case "schema":
                    try parseSchemaDefinition(tokens: tokens, index: &index)
                    
                default:
                    index += 1
                }
                
            default:
                index += 1
            }
        }
        
        let schema = GraphQLSchema(
            types: types,
            queryType: queryType,
            mutationType: mutationType,
            subscriptionType: subscriptionType,
            directives: directives
        )
        
        self.schema = schema
        return schema
    }
    
    // MARK: - Operation Parsing
    
    /// Parses GraphQL operations from a file URL.
    public func parseOperations(fileURL: URL) throws -> [GraphQLOperation] {
        let content = try String(contentsOf: fileURL, encoding: .utf8)
        return try parseOperations(content: content)
    }
    
    /// Parses GraphQL operations from a string.
    public func parseOperations(content: String) throws -> [GraphQLOperation] {
        var operations: [GraphQLOperation] = []
        let tokens = try tokenize(content)
        var index = 0
        
        while index < tokens.count {
            let token = tokens[index]
            
            switch token {
            case .name(let name):
                if let opType = GraphQLOperation.OperationType(rawValue: name) {
                    let operation = try parseOperation(type: opType, tokens: tokens, index: &index)
                    operations.append(operation)
                } else {
                    index += 1
                }
                
            case .punctuator("{"):
                // Anonymous query
                let operation = try parseOperation(type: .query, tokens: tokens, index: &index)
                operations.append(operation)
                
            default:
                index += 1
            }
        }
        
        return operations
    }
    
    // MARK: - Code Generation
    
    /// Generates Swift code from the parsed schema.
    public func generateTypes() throws -> [GeneratedFile] {
        guard let schema = schema else {
            throw GraphQLParserError.noSchemaParsed
        }
        
        var files: [GeneratedFile] = []
        
        // Generate types
        for type in schema.types {
            if let file = try generateType(type) {
                files.append(file)
            }
        }
        
        // Generate base client
        files.append(generateGraphQLClient())
        
        // Generate error types
        files.append(generateGraphQLErrors())
        
        return files
    }
    
    /// Generates Swift code for operations.
    public func generateOperations(_ operations: [GraphQLOperation]) throws -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        
        for operation in operations {
            files.append(try generateOperation(operation))
        }
        
        return files
    }
    
    // MARK: - Tokenization
    
    private func tokenize(_ content: String) throws -> [Token] {
        var tokens: [Token] = []
        var index = content.startIndex
        
        while index < content.endIndex {
            let char = content[index]
            
            // Skip whitespace
            if char.isWhitespace {
                index = content.index(after: index)
                continue
            }
            
            // Skip comments
            if char == "#" {
                while index < content.endIndex && content[index] != "\n" {
                    index = content.index(after: index)
                }
                continue
            }
            
            // Spread operator
            if char == "." {
                let next1 = content.index(after: index)
                let next2 = content.index(after: next1)
                if next1 < content.endIndex && next2 < content.endIndex &&
                   content[next1] == "." && content[next2] == "." {
                    tokens.append(.spread)
                    index = content.index(after: next2)
                    continue
                }
            }
            
            // Punctuators
            if "{}()[]!:=@|&".contains(char) {
                tokens.append(.punctuator(char))
                index = content.index(after: index)
                continue
            }
            
            // Names
            if char.isLetter || char == "_" {
                var name = ""
                while index < content.endIndex {
                    let c = content[index]
                    if c.isLetter || c.isNumber || c == "_" {
                        name.append(c)
                        index = content.index(after: index)
                    } else {
                        break
                    }
                }
                tokens.append(.name(name))
                continue
            }
            
            // Numbers
            if char.isNumber || char == "-" {
                var number = ""
                var isFloat = false
                
                if char == "-" {
                    number.append(char)
                    index = content.index(after: index)
                }
                
                while index < content.endIndex {
                    let c = content[index]
                    if c.isNumber {
                        number.append(c)
                        index = content.index(after: index)
                    } else if c == "." && !isFloat {
                        number.append(c)
                        isFloat = true
                        index = content.index(after: index)
                    } else {
                        break
                    }
                }
                
                if isFloat {
                    tokens.append(.floatValue(Double(number) ?? 0))
                } else {
                    tokens.append(.intValue(Int(number) ?? 0))
                }
                continue
            }
            
            // Strings
            if char == "\"" {
                var string = ""
                index = content.index(after: index)
                
                // Check for block string
                if index < content.endIndex && content[index] == "\"" {
                    let next = content.index(after: index)
                    if next < content.endIndex && content[next] == "\"" {
                        // Block string
                        index = content.index(after: next)
                        while index < content.endIndex {
                            let c = content[index]
                            if c == "\"" {
                                let next1 = content.index(after: index)
                                let next2 = content.index(after: next1)
                                if next1 < content.endIndex && next2 < content.endIndex &&
                                   content[next1] == "\"" && content[next2] == "\"" {
                                    index = content.index(after: next2)
                                    break
                                }
                            }
                            string.append(c)
                            index = content.index(after: index)
                        }
                    }
                } else {
                    // Regular string
                    while index < content.endIndex {
                        let c = content[index]
                        if c == "\"" {
                            index = content.index(after: index)
                            break
                        } else if c == "\\" {
                            index = content.index(after: index)
                            if index < content.endIndex {
                                string.append(content[index])
                                index = content.index(after: index)
                            }
                        } else {
                            string.append(c)
                            index = content.index(after: index)
                        }
                    }
                }
                
                tokens.append(.stringValue(string))
                continue
            }
            
            // Skip unknown characters
            index = content.index(after: index)
        }
        
        tokens.append(.eof)
        return tokens
    }
    
    // MARK: - Type Parsing
    
    private func parseObjectType(tokens: [Token], index: inout Int) throws -> GraphQLType {
        index += 1 // Skip "type"
        
        guard case .name(let name) = tokens[index] else {
            throw GraphQLParserError.expectedName
        }
        index += 1
        
        var interfaces: [GraphQLTypeReference] = []
        
        // Check for implements
        if case .name("implements") = tokens[index] {
            index += 1
            while case .name(let interfaceName) = tokens[index] {
                interfaces.append(.named(interfaceName))
                index += 1
                if case .punctuator("&") = tokens[index] {
                    index += 1
                }
            }
        }
        
        let fields = try parseFieldDefinitions(tokens: tokens, index: &index)
        
        return GraphQLType(
            kind: .object,
            name: name,
            fields: fields,
            interfaces: interfaces.isEmpty ? nil : interfaces
        )
    }
    
    private func parseInputType(tokens: [Token], index: inout Int) throws -> GraphQLType {
        index += 1 // Skip "input"
        
        guard case .name(let name) = tokens[index] else {
            throw GraphQLParserError.expectedName
        }
        index += 1
        
        let inputFields = try parseInputFieldDefinitions(tokens: tokens, index: &index)
        
        return GraphQLType(
            kind: .inputObject,
            name: name,
            inputFields: inputFields
        )
    }
    
    private func parseEnumType(tokens: [Token], index: inout Int) throws -> GraphQLType {
        index += 1 // Skip "enum"
        
        guard case .name(let name) = tokens[index] else {
            throw GraphQLParserError.expectedName
        }
        index += 1
        
        var values: [GraphQLEnumValue] = []
        
        guard case .punctuator("{") = tokens[index] else {
            throw GraphQLParserError.expectedPunctuator("{")
        }
        index += 1
        
        while index < tokens.count {
            if case .punctuator("}") = tokens[index] {
                index += 1
                break
            }
            
            if case .name(let valueName) = tokens[index] {
                values.append(GraphQLEnumValue(name: valueName))
                index += 1
            } else {
                index += 1
            }
        }
        
        return GraphQLType(
            kind: .enum,
            name: name,
            enumValues: values
        )
    }
    
    private func parseInterfaceType(tokens: [Token], index: inout Int) throws -> GraphQLType {
        index += 1 // Skip "interface"
        
        guard case .name(let name) = tokens[index] else {
            throw GraphQLParserError.expectedName
        }
        index += 1
        
        let fields = try parseFieldDefinitions(tokens: tokens, index: &index)
        
        return GraphQLType(
            kind: .interface,
            name: name,
            fields: fields
        )
    }
    
    private func parseUnionType(tokens: [Token], index: inout Int) throws -> GraphQLType {
        index += 1 // Skip "union"
        
        guard case .name(let name) = tokens[index] else {
            throw GraphQLParserError.expectedName
        }
        index += 1
        
        var possibleTypes: [GraphQLTypeReference] = []
        
        if case .punctuator("=") = tokens[index] {
            index += 1
            
            while case .name(let typeName) = tokens[index] {
                possibleTypes.append(.named(typeName))
                index += 1
                if case .punctuator("|") = tokens[index] {
                    index += 1
                }
            }
        }
        
        return GraphQLType(
            kind: .union,
            name: name,
            possibleTypes: possibleTypes.isEmpty ? nil : possibleTypes
        )
    }
    
    private func parseScalarType(tokens: [Token], index: inout Int) throws -> GraphQLType {
        index += 1 // Skip "scalar"
        
        guard case .name(let name) = tokens[index] else {
            throw GraphQLParserError.expectedName
        }
        index += 1
        
        return GraphQLType(kind: .scalar, name: name)
    }
    
    private func parseDirective(tokens: [Token], index: inout Int) throws -> GraphQLDirective {
        index += 1 // Skip "directive"
        
        guard case .punctuator("@") = tokens[index] else {
            throw GraphQLParserError.expectedPunctuator("@")
        }
        index += 1
        
        guard case .name(let name) = tokens[index] else {
            throw GraphQLParserError.expectedName
        }
        index += 1
        
        var args: [GraphQLInputValue] = []
        
        if case .punctuator("(") = tokens[index] {
            args = try parseArgumentDefinitions(tokens: tokens, index: &index)
        }
        
        var locations: [GraphQLDirective.Location] = []
        
        if case .name("on") = tokens[index] {
            index += 1
            
            while case .name(let locName) = tokens[index] {
                if let location = GraphQLDirective.Location(rawValue: locName) {
                    locations.append(location)
                }
                index += 1
                if case .punctuator("|") = tokens[index] {
                    index += 1
                }
            }
        }
        
        return GraphQLDirective(name: name, locations: locations, args: args)
    }
    
    private func parseSchemaDefinition(tokens: [Token], index: inout Int) throws {
        index += 1 // Skip "schema"
        
        guard case .punctuator("{") = tokens[index] else {
            throw GraphQLParserError.expectedPunctuator("{")
        }
        index += 1
        
        while index < tokens.count {
            if case .punctuator("}") = tokens[index] {
                index += 1
                break
            }
            index += 1
        }
    }
    
    private func parseFieldDefinitions(tokens: [Token], index: inout Int) throws -> [GraphQLField] {
        var fields: [GraphQLField] = []
        
        guard case .punctuator("{") = tokens[index] else {
            throw GraphQLParserError.expectedPunctuator("{")
        }
        index += 1
        
        while index < tokens.count {
            if case .punctuator("}") = tokens[index] {
                index += 1
                break
            }
            
            if case .name(let fieldName) = tokens[index] {
                index += 1
                
                var args: [GraphQLInputValue] = []
                if case .punctuator("(") = tokens[index] {
                    args = try parseArgumentDefinitions(tokens: tokens, index: &index)
                }
                
                guard case .punctuator(":") = tokens[index] else {
                    throw GraphQLParserError.expectedPunctuator(":")
                }
                index += 1
                
                let type = try parseTypeReference(tokens: tokens, index: &index)
                
                fields.append(GraphQLField(name: fieldName, args: args, type: type))
            } else {
                index += 1
            }
        }
        
        return fields
    }
    
    private func parseInputFieldDefinitions(tokens: [Token], index: inout Int) throws -> [GraphQLInputValue] {
        var fields: [GraphQLInputValue] = []
        
        guard case .punctuator("{") = tokens[index] else {
            throw GraphQLParserError.expectedPunctuator("{")
        }
        index += 1
        
        while index < tokens.count {
            if case .punctuator("}") = tokens[index] {
                index += 1
                break
            }
            
            if case .name(let fieldName) = tokens[index] {
                index += 1
                
                guard case .punctuator(":") = tokens[index] else {
                    throw GraphQLParserError.expectedPunctuator(":")
                }
                index += 1
                
                let type = try parseTypeReference(tokens: tokens, index: &index)
                
                var defaultValue: String?
                if case .punctuator("=") = tokens[index] {
                    index += 1
                    defaultValue = try parseDefaultValue(tokens: tokens, index: &index)
                }
                
                fields.append(GraphQLInputValue(name: fieldName, type: type, defaultValue: defaultValue))
            } else {
                index += 1
            }
        }
        
        return fields
    }
    
    private func parseArgumentDefinitions(tokens: [Token], index: inout Int) throws -> [GraphQLInputValue] {
        var args: [GraphQLInputValue] = []
        
        guard case .punctuator("(") = tokens[index] else {
            throw GraphQLParserError.expectedPunctuator("(")
        }
        index += 1
        
        while index < tokens.count {
            if case .punctuator(")") = tokens[index] {
                index += 1
                break
            }
            
            if case .name(let argName) = tokens[index] {
                index += 1
                
                guard case .punctuator(":") = tokens[index] else {
                    throw GraphQLParserError.expectedPunctuator(":")
                }
                index += 1
                
                let type = try parseTypeReference(tokens: tokens, index: &index)
                
                var defaultValue: String?
                if case .punctuator("=") = tokens[index] {
                    index += 1
                    defaultValue = try parseDefaultValue(tokens: tokens, index: &index)
                }
                
                args.append(GraphQLInputValue(name: argName, type: type, defaultValue: defaultValue))
            } else {
                index += 1
            }
        }
        
        return args
    }
    
    private func parseTypeReference(tokens: [Token], index: inout Int) throws -> GraphQLTypeReference {
        var type: GraphQLTypeReference
        
        if case .punctuator("[") = tokens[index] {
            index += 1
            let innerType = try parseTypeReference(tokens: tokens, index: &index)
            guard case .punctuator("]") = tokens[index] else {
                throw GraphQLParserError.expectedPunctuator("]")
            }
            index += 1
            type = .list(innerType)
        } else if case .name(let typeName) = tokens[index] {
            type = .named(typeName)
            index += 1
        } else {
            throw GraphQLParserError.expectedType
        }
        
        if case .punctuator("!") = tokens[index] {
            type = .nonNull(type)
            index += 1
        }
        
        return type
    }
    
    private func parseDefaultValue(tokens: [Token], index: inout Int) throws -> String {
        switch tokens[index] {
        case .intValue(let value):
            index += 1
            return String(value)
        case .floatValue(let value):
            index += 1
            return String(value)
        case .stringValue(let value):
            index += 1
            return "\"\(value)\""
        case .name(let value):
            index += 1
            return value
        default:
            index += 1
            return "null"
        }
    }
    
    // MARK: - Operation Parsing
    
    private func parseOperation(type: GraphQLOperation.OperationType, tokens: [Token], index: inout Int) throws -> GraphQLOperation {
        if case .name = tokens[index] {
            index += 1 // Skip operation type keyword
        }
        
        var name: String?
        if case .name(let opName) = tokens[index] {
            name = opName
            index += 1
        }
        
        var variables: [GraphQLVariable] = []
        if case .punctuator("(") = tokens[index] {
            variables = try parseVariableDefinitions(tokens: tokens, index: &index)
        }
        
        let selectionSet = try parseSelectionSet(tokens: tokens, index: &index)
        
        return GraphQLOperation(
            type: type,
            name: name,
            variables: variables,
            selectionSet: selectionSet
        )
    }
    
    private func parseVariableDefinitions(tokens: [Token], index: inout Int) throws -> [GraphQLVariable] {
        var variables: [GraphQLVariable] = []
        
        guard case .punctuator("(") = tokens[index] else {
            throw GraphQLParserError.expectedPunctuator("(")
        }
        index += 1
        
        while index < tokens.count {
            if case .punctuator(")") = tokens[index] {
                index += 1
                break
            }
            
            if case .punctuator("$") = tokens[index] {
                index += 1
                
                guard case .name(let varName) = tokens[index] else {
                    throw GraphQLParserError.expectedName
                }
                index += 1
                
                guard case .punctuator(":") = tokens[index] else {
                    throw GraphQLParserError.expectedPunctuator(":")
                }
                index += 1
                
                let type = try parseTypeReference(tokens: tokens, index: &index)
                
                var defaultValue: String?
                if case .punctuator("=") = tokens[index] {
                    index += 1
                    defaultValue = try parseDefaultValue(tokens: tokens, index: &index)
                }
                
                variables.append(GraphQLVariable(name: varName, type: type, defaultValue: defaultValue))
            } else {
                index += 1
            }
        }
        
        return variables
    }
    
    private func parseSelectionSet(tokens: [Token], index: inout Int) throws -> GraphQLSelectionSet {
        var selections: [GraphQLSelection] = []
        
        guard case .punctuator("{") = tokens[index] else {
            throw GraphQLParserError.expectedPunctuator("{")
        }
        index += 1
        
        while index < tokens.count {
            if case .punctuator("}") = tokens[index] {
                index += 1
                break
            }
            
            if case .spread = tokens[index] {
                index += 1
                
                if case .name("on") = tokens[index] {
                    index += 1
                    guard case .name(let typeName) = tokens[index] else {
                        throw GraphQLParserError.expectedName
                    }
                    index += 1
                    let innerSet = try parseSelectionSet(tokens: tokens, index: &index)
                    selections.append(.inlineFragment(GraphQLInlineFragment(typeCondition: typeName, selectionSet: innerSet)))
                } else if case .name(let fragmentName) = tokens[index] {
                    selections.append(.fragmentSpread(fragmentName))
                    index += 1
                }
            } else if case .name(let fieldName) = tokens[index] {
                var alias: String?
                var actualName = fieldName
                index += 1
                
                if case .punctuator(":") = tokens[index] {
                    alias = fieldName
                    index += 1
                    guard case .name(let realName) = tokens[index] else {
                        throw GraphQLParserError.expectedName
                    }
                    actualName = realName
                    index += 1
                }
                
                var arguments: [GraphQLArgument] = []
                if case .punctuator("(") = tokens[index] {
                    arguments = try parseArguments(tokens: tokens, index: &index)
                }
                
                var innerSet: GraphQLSelectionSet?
                if case .punctuator("{") = tokens[index] {
                    innerSet = try parseSelectionSet(tokens: tokens, index: &index)
                }
                
                selections.append(.field(GraphQLFieldSelection(
                    alias: alias,
                    name: actualName,
                    arguments: arguments,
                    selectionSet: innerSet
                )))
            } else {
                index += 1
            }
        }
        
        return GraphQLSelectionSet(selections: selections)
    }
    
    private func parseArguments(tokens: [Token], index: inout Int) throws -> [GraphQLArgument] {
        var arguments: [GraphQLArgument] = []
        
        guard case .punctuator("(") = tokens[index] else {
            throw GraphQLParserError.expectedPunctuator("(")
        }
        index += 1
        
        while index < tokens.count {
            if case .punctuator(")") = tokens[index] {
                index += 1
                break
            }
            
            if case .name(let argName) = tokens[index] {
                index += 1
                
                guard case .punctuator(":") = tokens[index] else {
                    throw GraphQLParserError.expectedPunctuator(":")
                }
                index += 1
                
                let value = try parseValue(tokens: tokens, index: &index)
                arguments.append(GraphQLArgument(name: argName, value: value))
            } else {
                index += 1
            }
        }
        
        return arguments
    }
    
    private func parseValue(tokens: [Token], index: inout Int) throws -> GraphQLValue {
        switch tokens[index] {
        case .punctuator("$"):
            index += 1
            guard case .name(let varName) = tokens[index] else {
                throw GraphQLParserError.expectedName
            }
            index += 1
            return .variable(varName)
            
        case .intValue(let value):
            index += 1
            return .int(value)
            
        case .floatValue(let value):
            index += 1
            return .float(value)
            
        case .stringValue(let value):
            index += 1
            return .string(value)
            
        case .name(let value):
            index += 1
            switch value {
            case "true":
                return .boolean(true)
            case "false":
                return .boolean(false)
            case "null":
                return .null
            default:
                return .enum(value)
            }
            
        case .punctuator("["):
            index += 1
            var items: [GraphQLValue] = []
            while index < tokens.count {
                if case .punctuator("]") = tokens[index] {
                    index += 1
                    break
                }
                items.append(try parseValue(tokens: tokens, index: &index))
            }
            return .list(items)
            
        case .punctuator("{"):
            index += 1
            var fields: [String: GraphQLValue] = [:]
            while index < tokens.count {
                if case .punctuator("}") = tokens[index] {
                    index += 1
                    break
                }
                if case .name(let fieldName) = tokens[index] {
                    index += 1
                    guard case .punctuator(":") = tokens[index] else {
                        throw GraphQLParserError.expectedPunctuator(":")
                    }
                    index += 1
                    fields[fieldName] = try parseValue(tokens: tokens, index: &index)
                } else {
                    index += 1
                }
            }
            return .object(fields)
            
        default:
            index += 1
            return .null
        }
    }
    
    // MARK: - Code Generation
    
    private func generateType(_ type: GraphQLType) throws -> GeneratedFile? {
        guard let name = type.name else { return nil }
        
        // Skip built-in types
        if builtInScalars[name] != nil { return nil }
        if name.hasPrefix("__") { return nil }
        
        var lines: [String] = []
        let accessLevel = configuration.accessLevel
        let typeName = "\(configuration.typePrefix)\(name)\(configuration.typeSuffix)"
        
        lines.append(generateFileHeader(for: typeName))
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        
        switch type.kind {
        case .object, .inputObject:
            lines.append(contentsOf: try generateStructType(type, typeName: typeName, accessLevel: accessLevel))
            
        case .enum:
            lines.append(contentsOf: generateEnumType(type, typeName: typeName, accessLevel: accessLevel))
            
        case .interface:
            lines.append(contentsOf: generateInterfaceType(type, typeName: typeName, accessLevel: accessLevel))
            
        case .union:
            lines.append(contentsOf: generateUnionType(type, typeName: typeName, accessLevel: accessLevel))
            
        case .scalar:
            lines.append("\(accessLevel) typealias \(typeName) = String")
            
        default:
            return nil
        }
        
        return GeneratedFile(
            fileName: "\(typeName).swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    private func generateStructType(_ type: GraphQLType, typeName: String, accessLevel: String) throws -> [String] {
        var lines: [String] = []
        
        if let description = type.description {
            lines.append("/// \(description)")
        }
        lines.append("\(accessLevel) struct \(typeName): Codable, Sendable, Equatable {")
        lines.append("")
        
        let fields = type.fields ?? []
        let inputFields = type.inputFields ?? []
        let allFields = fields.isEmpty ? inputFields : fields.map { field in
            GraphQLInputValue(name: field.name, description: field.description, type: field.type)
        }
        
        for field in allFields {
            let swiftType = resolveSwiftType(for: field.type)
            
            if let description = field.description {
                lines.append("    /// \(description)")
            }
            lines.append("    \(accessLevel) let \(field.name.camelCased): \(swiftType)")
            lines.append("")
        }
        
        // Generate CodingKeys if needed
        let needsCodingKeys = allFields.contains { $0.name.camelCased != $0.name }
        if needsCodingKeys {
            lines.append("    enum CodingKeys: String, CodingKey {")
            for field in allFields {
                let swiftName = field.name.camelCased
                if swiftName != field.name {
                    lines.append("        case \(swiftName) = \"\(field.name)\"")
                } else {
                    lines.append("        case \(swiftName)")
                }
            }
            lines.append("    }")
            lines.append("")
        }
        
        // Generate initializer
        if configuration.generateInputInitializers && !allFields.isEmpty {
            lines.append("    /// Creates a new \(typeName) instance.")
            lines.append("    \(accessLevel) init(")
            
            let initParams = allFields.map { field -> String in
                let swiftType = resolveSwiftType(for: field.type)
                let swiftName = field.name.camelCased
                return "        \(swiftName): \(swiftType)"
            }.joined(separator: ",\n")
            
            lines.append(initParams)
            lines.append("    ) {")
            
            for field in allFields {
                let swiftName = field.name.camelCased
                lines.append("        self.\(swiftName) = \(swiftName)")
            }
            
            lines.append("    }")
            lines.append("")
        }
        
        lines.append("}")
        
        return lines
    }
    
    private func generateEnumType(_ type: GraphQLType, typeName: String, accessLevel: String) -> [String] {
        var lines: [String] = []
        
        if let description = type.description {
            lines.append("/// \(description)")
        }
        lines.append("\(accessLevel) enum \(typeName): String, Codable, Sendable, CaseIterable {")
        
        for value in type.enumValues ?? [] {
            if let description = value.description {
                lines.append("    /// \(description)")
            }
            let caseName = value.name.camelCased
            if caseName != value.name {
                lines.append("    case \(caseName) = \"\(value.name)\"")
            } else {
                lines.append("    case \(caseName)")
            }
        }
        
        lines.append("}")
        
        return lines
    }
    
    private func generateInterfaceType(_ type: GraphQLType, typeName: String, accessLevel: String) -> [String] {
        var lines: [String] = []
        
        if let description = type.description {
            lines.append("/// \(description)")
        }
        lines.append("\(accessLevel) protocol \(typeName): Codable, Sendable {")
        
        for field in type.fields ?? [] {
            let swiftType = resolveSwiftType(for: field.type)
            lines.append("    var \(field.name.camelCased): \(swiftType) { get }")
        }
        
        lines.append("}")
        
        return lines
    }
    
    private func generateUnionType(_ type: GraphQLType, typeName: String, accessLevel: String) -> [String] {
        var lines: [String] = []
        
        if let description = type.description {
            lines.append("/// \(description)")
        }
        lines.append("\(accessLevel) enum \(typeName): Codable, Sendable {")
        
        for possibleType in type.possibleTypes ?? [] {
            let caseName = possibleType.typeName.camelCased
            let typeRef = "\(configuration.typePrefix)\(possibleType.typeName)\(configuration.typeSuffix)"
            lines.append("    case \(caseName)(\(typeRef))")
        }
        
        lines.append("}")
        
        return lines
    }
    
    private func generateOperation(_ operation: GraphQLOperation) throws -> GeneratedFile {
        var lines: [String] = []
        
        let operationName = operation.name ?? "\(operation.type.rawValue.capitalized)Operation"
        let typeName = "\(configuration.typePrefix)\(operationName)\(configuration.typeSuffix)"
        
        lines.append(generateFileHeader(for: typeName))
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        
        let accessLevel = configuration.accessLevel
        
        // Generate variables struct if needed
        if !operation.variables.isEmpty {
            lines.append("/// Variables for \(operationName).")
            lines.append("\(accessLevel) struct \(typeName)Variables: Codable, Sendable {")
            
            for variable in operation.variables {
                let swiftType = resolveSwiftType(for: variable.type)
                lines.append("    \(accessLevel) let \(variable.name): \(swiftType)")
            }
            
            lines.append("}")
            lines.append("")
        }
        
        // Generate operation struct
        lines.append("/// \(operation.type.rawValue.capitalized) operation: \(operationName).")
        lines.append("\(accessLevel) struct \(typeName) {")
        lines.append("")
        lines.append("    /// The GraphQL query string.")
        lines.append("    \(accessLevel) static let query = \"\"\"")
        lines.append("    \(operation.type.rawValue) \(operationName)")
        if !operation.variables.isEmpty {
            let varDefs = operation.variables.map { "$\($0.name): \(formatTypeReference($0.type))" }.joined(separator: ", ")
            lines.append("    (\(varDefs))")
        }
        lines.append("    {")
        lines.append(contentsOf: formatSelectionSet(operation.selectionSet, indent: "        "))
        lines.append("    }")
        lines.append("    \"\"\"")
        lines.append("")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "\(typeName).swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    private func generateGraphQLClient() -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: "GraphQLClient"))
        lines.append("")
        lines.append("import Foundation")
        if configuration.generateCombine {
            lines.append("import Combine")
        }
        lines.append("")
        lines.append("// MARK: - GraphQLClient")
        lines.append("")
        lines.append("/// A client for executing GraphQL operations.")
        lines.append("public final class GraphQLClient: Sendable {")
        lines.append("")
        lines.append("    // MARK: - Properties")
        lines.append("")
        lines.append("    /// The GraphQL endpoint URL.")
        lines.append("    public let endpoint: URL")
        lines.append("")
        lines.append("    /// The URL session for network requests.")
        lines.append("    public let session: URLSession")
        lines.append("")
        lines.append("    /// The JSON encoder.")
        lines.append("    public let encoder: JSONEncoder")
        lines.append("")
        lines.append("    /// The JSON decoder.")
        lines.append("    public let decoder: JSONDecoder")
        lines.append("")
        lines.append("    /// Additional headers to include in requests.")
        lines.append("    public var additionalHeaders: [String: String]")
        lines.append("")
        lines.append("    // MARK: - Initialization")
        lines.append("")
        lines.append("    /// Creates a new GraphQL client.")
        lines.append("    public init(")
        lines.append("        endpoint: URL,")
        lines.append("        session: URLSession = .shared,")
        lines.append("        encoder: JSONEncoder = JSONEncoder(),")
        lines.append("        decoder: JSONDecoder = JSONDecoder(),")
        lines.append("        additionalHeaders: [String: String] = [:]")
        lines.append("    ) {")
        lines.append("        self.endpoint = endpoint")
        lines.append("        self.session = session")
        lines.append("        self.encoder = encoder")
        lines.append("        self.decoder = decoder")
        lines.append("        self.additionalHeaders = additionalHeaders")
        lines.append("    }")
        lines.append("")
        
        if configuration.generateAsync {
            lines.append("    // MARK: - Async Execution")
            lines.append("")
            lines.append("    /// Executes a GraphQL query.")
            lines.append("    public func query<T: Decodable>(")
            lines.append("        _ query: String,")
            lines.append("        variables: [String: Any]? = nil,")
            lines.append("        operationName: String? = nil")
            lines.append("    ) async throws -> T {")
            lines.append("        let response: GraphQLResponse<T> = try await execute(")
            lines.append("            query: query,")
            lines.append("            variables: variables,")
            lines.append("            operationName: operationName")
            lines.append("        )")
            lines.append("")
            lines.append("        if let errors = response.errors, !errors.isEmpty {")
            lines.append("            throw GraphQLError.responseErrors(errors)")
            lines.append("        }")
            lines.append("")
            lines.append("        guard let data = response.data else {")
            lines.append("            throw GraphQLError.noData")
            lines.append("        }")
            lines.append("")
            lines.append("        return data")
            lines.append("    }")
            lines.append("")
            lines.append("    /// Executes a GraphQL mutation.")
            lines.append("    public func mutate<T: Decodable>(")
            lines.append("        _ mutation: String,")
            lines.append("        variables: [String: Any]? = nil,")
            lines.append("        operationName: String? = nil")
            lines.append("    ) async throws -> T {")
            lines.append("        return try await query(mutation, variables: variables, operationName: operationName)")
            lines.append("    }")
            lines.append("")
            lines.append("    // MARK: - Private")
            lines.append("")
            lines.append("    private func execute<T: Decodable>(")
            lines.append("        query: String,")
            lines.append("        variables: [String: Any]?,")
            lines.append("        operationName: String?")
            lines.append("    ) async throws -> GraphQLResponse<T> {")
            lines.append("        var body: [String: Any] = [\"query\": query]")
            lines.append("")
            lines.append("        if let variables = variables {")
            lines.append("            body[\"variables\"] = variables")
            lines.append("        }")
            lines.append("")
            lines.append("        if let operationName = operationName {")
            lines.append("            body[\"operationName\"] = operationName")
            lines.append("        }")
            lines.append("")
            lines.append("        var request = URLRequest(url: endpoint)")
            lines.append("        request.httpMethod = \"POST\"")
            lines.append("        request.setValue(\"application/json\", forHTTPHeaderField: \"Content-Type\")")
            lines.append("")
            lines.append("        for (key, value) in additionalHeaders {")
            lines.append("            request.setValue(value, forHTTPHeaderField: key)")
            lines.append("        }")
            lines.append("")
            lines.append("        request.httpBody = try JSONSerialization.data(withJSONObject: body)")
            lines.append("")
            lines.append("        let (data, response) = try await session.data(for: request)")
            lines.append("")
            lines.append("        guard let httpResponse = response as? HTTPURLResponse else {")
            lines.append("            throw GraphQLError.invalidResponse")
            lines.append("        }")
            lines.append("")
            lines.append("        guard (200...299).contains(httpResponse.statusCode) else {")
            lines.append("            throw GraphQLError.httpError(statusCode: httpResponse.statusCode)")
            lines.append("        }")
            lines.append("")
            lines.append("        return try decoder.decode(GraphQLResponse<T>.self, from: data)")
            lines.append("    }")
        }
        
        lines.append("")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - GraphQLResponse")
        lines.append("")
        lines.append("/// A GraphQL response.")
        lines.append("public struct GraphQLResponse<T: Decodable>: Decodable {")
        lines.append("")
        lines.append("    /// The response data.")
        lines.append("    public let data: T?")
        lines.append("")
        lines.append("    /// Response errors.")
        lines.append("    public let errors: [GraphQLResponseError]?")
        lines.append("")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - GraphQLResponseError")
        lines.append("")
        lines.append("/// A GraphQL response error.")
        lines.append("public struct GraphQLResponseError: Decodable, Sendable {")
        lines.append("")
        lines.append("    /// The error message.")
        lines.append("    public let message: String")
        lines.append("")
        lines.append("    /// Error locations in the query.")
        lines.append("    public let locations: [GraphQLErrorLocation]?")
        lines.append("")
        lines.append("    /// Error path.")
        lines.append("    public let path: [String]?")
        lines.append("")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - GraphQLErrorLocation")
        lines.append("")
        lines.append("/// A location in a GraphQL query where an error occurred.")
        lines.append("public struct GraphQLErrorLocation: Decodable, Sendable {")
        lines.append("")
        lines.append("    /// The line number.")
        lines.append("    public let line: Int")
        lines.append("")
        lines.append("    /// The column number.")
        lines.append("    public let column: Int")
        lines.append("")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "GraphQLClient.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    private func generateGraphQLErrors() -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: "GraphQLError"))
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - GraphQLError")
        lines.append("")
        lines.append("/// Errors that can occur during GraphQL operations.")
        lines.append("public enum GraphQLError: LocalizedError, Sendable {")
        lines.append("")
        lines.append("    /// The response was invalid.")
        lines.append("    case invalidResponse")
        lines.append("")
        lines.append("    /// An HTTP error occurred.")
        lines.append("    case httpError(statusCode: Int)")
        lines.append("")
        lines.append("    /// No data was returned.")
        lines.append("    case noData")
        lines.append("")
        lines.append("    /// GraphQL response errors.")
        lines.append("    case responseErrors([GraphQLResponseError])")
        lines.append("")
        lines.append("    /// Encoding failed.")
        lines.append("    case encodingFailed(Error)")
        lines.append("")
        lines.append("    /// Decoding failed.")
        lines.append("    case decodingFailed(Error)")
        lines.append("")
        lines.append("    public var errorDescription: String? {")
        lines.append("        switch self {")
        lines.append("        case .invalidResponse:")
        lines.append("            return \"Invalid response received\"")
        lines.append("        case .httpError(let code):")
        lines.append("            return \"HTTP error: \\(code)\"")
        lines.append("        case .noData:")
        lines.append("            return \"No data returned\"")
        lines.append("        case .responseErrors(let errors):")
        lines.append("            return errors.map { $0.message }.joined(separator: \", \")")
        lines.append("        case .encodingFailed(let error):")
        lines.append("            return \"Encoding failed: \\(error.localizedDescription)\"")
        lines.append("        case .decodingFailed(let error):")
        lines.append("            return \"Decoding failed: \\(error.localizedDescription)\"")
        lines.append("        }")
        lines.append("    }")
        lines.append("")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "GraphQLError.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    // MARK: - Type Resolution
    
    private func resolveSwiftType(for typeRef: GraphQLTypeReference) -> String {
        switch typeRef {
        case .named(let name):
            if let builtIn = builtInScalars[name] {
                return "\(builtIn)?"
            }
            if let custom = configuration.scalarMappings[name] {
                return "\(custom)?"
            }
            return "\(configuration.typePrefix)\(name)\(configuration.typeSuffix)?"
            
        case .nonNull(let inner):
            var type = resolveSwiftType(for: inner)
            if type.hasSuffix("?") {
                type = String(type.dropLast())
            }
            return type
            
        case .list(let inner):
            let innerType = resolveSwiftType(for: inner)
            return "[\(innerType)]?"
        }
    }
    
    private func formatTypeReference(_ typeRef: GraphQLTypeReference) -> String {
        switch typeRef {
        case .named(let name):
            return name
        case .nonNull(let inner):
            return "\(formatTypeReference(inner))!"
        case .list(let inner):
            return "[\(formatTypeReference(inner))]"
        }
    }
    
    private func formatSelectionSet(_ selectionSet: GraphQLSelectionSet, indent: String) -> [String] {
        var lines: [String] = []
        
        for selection in selectionSet.selections {
            switch selection {
            case .field(let field):
                var line = indent
                if let alias = field.alias {
                    line += "\(alias): "
                }
                line += field.name
                
                if !field.arguments.isEmpty {
                    let args = field.arguments.map { "\($0.name): $\($0.name)" }.joined(separator: ", ")
                    line += "(\(args))"
                }
                
                lines.append(line)
                
                if let innerSet = field.selectionSet {
                    lines.append("\(indent){")
                    lines.append(contentsOf: formatSelectionSet(innerSet, indent: indent + "    "))
                    lines.append("\(indent)}")
                }
                
            case .fragmentSpread(let name):
                lines.append("\(indent)...\(name)")
                
            case .inlineFragment(let fragment):
                var line = "\(indent)..."
                if let typeCondition = fragment.typeCondition {
                    line += " on \(typeCondition)"
                }
                lines.append(line)
                lines.append("\(indent){")
                lines.append(contentsOf: formatSelectionSet(fragment.selectionSet, indent: indent + "    "))
                lines.append("\(indent)}")
            }
        }
        
        return lines
    }
    
    // MARK: - Helpers
    
    private func generateFileHeader(for fileName: String) -> String {
        """
        //
        //  \(fileName).swift
        //  SwiftCodeGen
        //
        //  Auto-generated from GraphQL schema.
        //
        """
    }
}

// MARK: - Errors

/// Errors that can occur during GraphQL parsing.
public enum GraphQLParserError: LocalizedError {
    case noSchemaParsed
    case expectedName
    case expectedType
    case expectedPunctuator(String)
    case invalidToken(String)
    case unexpectedEndOfFile
    
    public var errorDescription: String? {
        switch self {
        case .noSchemaParsed:
            return "No GraphQL schema has been parsed"
        case .expectedName:
            return "Expected a name token"
        case .expectedType:
            return "Expected a type reference"
        case .expectedPunctuator(let char):
            return "Expected punctuator: \(char)"
        case .invalidToken(let token):
            return "Invalid token: \(token)"
        case .unexpectedEndOfFile:
            return "Unexpected end of file"
        }
    }
}

// MARK: - String Extensions

private extension String {
    var camelCased: String {
        let words = self.components(separatedBy: CharacterSet.alphanumerics.inverted)
        let first = words.first?.lowercased() ?? ""
        let rest = words.dropFirst().map { $0.capitalized }
        return ([first] + rest).joined()
    }
}
