import XCTest
@testable import SwiftCodeGen

final class GraphQLParserTests: XCTestCase {
    
    // MARK: - Properties
    
    var tempDirectory: URL!
    
    // MARK: - Setup
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        try FileManager.default.createDirectory(
            at: tempDirectory,
            withIntermediateDirectories: true
        )
    }
    
    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDirectory)
        try super.tearDownWithError()
    }
    
    // MARK: - Configuration Tests
    
    func testConfigurationDefaultValues() {
        let config = GraphQLParser.Configuration()
        
        XCTAssertTrue(config.generateAsync)
        XCTAssertFalse(config.generateCombine)
        XCTAssertTrue(config.generateFragmentProtocols)
        XCTAssertTrue(config.generateInputInitializers)
        XCTAssertEqual(config.accessLevel, "public")
        XCTAssertEqual(config.typePrefix, "")
        XCTAssertEqual(config.typeSuffix, "")
        XCTAssertTrue(config.scalarMappings.isEmpty)
    }
    
    func testConfigurationCustomValues() {
        let config = GraphQLParser.Configuration(
            generateAsync: false,
            generateCombine: true,
            generateFragmentProtocols: false,
            generateInputInitializers: false,
            accessLevel: "internal",
            typePrefix: "GQL",
            typeSuffix: "Type",
            scalarMappings: ["DateTime": "Date", "JSON": "[String: Any]"]
        )
        
        XCTAssertFalse(config.generateAsync)
        XCTAssertTrue(config.generateCombine)
        XCTAssertFalse(config.generateFragmentProtocols)
        XCTAssertFalse(config.generateInputInitializers)
        XCTAssertEqual(config.accessLevel, "internal")
        XCTAssertEqual(config.typePrefix, "GQL")
        XCTAssertEqual(config.typeSuffix, "Type")
        XCTAssertEqual(config.scalarMappings["DateTime"], "Date")
    }
    
    // MARK: - Parser Initialization
    
    func testParserInitialization() {
        let parser = GraphQLParser()
        XCTAssertNotNil(parser.configuration)
    }
    
    func testParserInitializationWithConfig() {
        let config = GraphQLParser.Configuration(accessLevel: "internal")
        let parser = GraphQLParser(configuration: config)
        
        XCTAssertEqual(parser.configuration.accessLevel, "internal")
    }
    
    // MARK: - Schema Parsing Tests
    
    func testParseSimpleType() throws {
        let schema = """
        type User {
            id: ID!
            name: String!
            email: String
        }
        """
        
        let schemaURL = tempDirectory.appendingPathComponent("schema.graphql")
        try schema.write(to: schemaURL, atomically: true, encoding: .utf8)
        
        let parser = GraphQLParser()
        let parsed = try parser.parseSchema(fileURL: schemaURL)
        
        XCTAssertFalse(parsed.types.isEmpty)
        
        let userType = parsed.types.first { $0.name == "User" }
        XCTAssertNotNil(userType)
        XCTAssertEqual(userType?.kind, .object)
        XCTAssertEqual(userType?.fields?.count, 3)
    }
    
    func testParseEnum() throws {
        let schema = """
        enum Status {
            ACTIVE
            INACTIVE
            PENDING
        }
        """
        
        let schemaURL = tempDirectory.appendingPathComponent("schema.graphql")
        try schema.write(to: schemaURL, atomically: true, encoding: .utf8)
        
        let parser = GraphQLParser()
        let parsed = try parser.parseSchema(fileURL: schemaURL)
        
        let statusType = parsed.types.first { $0.name == "Status" }
        XCTAssertNotNil(statusType)
        XCTAssertEqual(statusType?.kind, .enum)
        XCTAssertEqual(statusType?.enumValues?.count, 3)
        XCTAssertEqual(statusType?.enumValues?[0].name, "ACTIVE")
    }
    
    func testParseInput() throws {
        let schema = """
        input CreateUserInput {
            name: String!
            email: String!
            age: Int
        }
        """
        
        let schemaURL = tempDirectory.appendingPathComponent("schema.graphql")
        try schema.write(to: schemaURL, atomically: true, encoding: .utf8)
        
        let parser = GraphQLParser()
        let parsed = try parser.parseSchema(fileURL: schemaURL)
        
        let inputType = parsed.types.first { $0.name == "CreateUserInput" }
        XCTAssertNotNil(inputType)
        XCTAssertEqual(inputType?.kind, .inputObject)
        XCTAssertEqual(inputType?.inputFields?.count, 3)
    }
    
    func testParseInterface() throws {
        let schema = """
        interface Node {
            id: ID!
        }
        """
        
        let schemaURL = tempDirectory.appendingPathComponent("schema.graphql")
        try schema.write(to: schemaURL, atomically: true, encoding: .utf8)
        
        let parser = GraphQLParser()
        let parsed = try parser.parseSchema(fileURL: schemaURL)
        
        let nodeType = parsed.types.first { $0.name == "Node" }
        XCTAssertNotNil(nodeType)
        XCTAssertEqual(nodeType?.kind, .interface)
    }
    
    func testParseUnion() throws {
        let schema = """
        type Cat {
            name: String!
        }
        
        type Dog {
            name: String!
        }
        
        union Pet = Cat | Dog
        """
        
        let schemaURL = tempDirectory.appendingPathComponent("schema.graphql")
        try schema.write(to: schemaURL, atomically: true, encoding: .utf8)
        
        let parser = GraphQLParser()
        let parsed = try parser.parseSchema(fileURL: schemaURL)
        
        let petType = parsed.types.first { $0.name == "Pet" }
        XCTAssertNotNil(petType)
        XCTAssertEqual(petType?.kind, .union)
        XCTAssertEqual(petType?.possibleTypes?.count, 2)
    }
    
    func testParseScalar() throws {
        let schema = """
        scalar DateTime
        scalar JSON
        """
        
        let schemaURL = tempDirectory.appendingPathComponent("schema.graphql")
        try schema.write(to: schemaURL, atomically: true, encoding: .utf8)
        
        let parser = GraphQLParser()
        let parsed = try parser.parseSchema(fileURL: schemaURL)
        
        let dateTimeType = parsed.types.first { $0.name == "DateTime" }
        XCTAssertNotNil(dateTimeType)
        XCTAssertEqual(dateTimeType?.kind, .scalar)
    }
    
    func testParseQueryMutation() throws {
        let schema = """
        type Query {
            user(id: ID!): User
            users: [User!]!
        }
        
        type Mutation {
            createUser(input: CreateUserInput!): User!
        }
        
        type User {
            id: ID!
            name: String!
        }
        
        input CreateUserInput {
            name: String!
        }
        """
        
        let schemaURL = tempDirectory.appendingPathComponent("schema.graphql")
        try schema.write(to: schemaURL, atomically: true, encoding: .utf8)
        
        let parser = GraphQLParser()
        let parsed = try parser.parseSchema(fileURL: schemaURL)
        
        XCTAssertNotNil(parsed.queryType)
        XCTAssertNotNil(parsed.mutationType)
        XCTAssertEqual(parsed.queryType?.name, "Query")
        XCTAssertEqual(parsed.mutationType?.name, "Mutation")
    }
    
    // MARK: - Operation Parsing Tests
    
    func testParseSimpleQuery() throws {
        let operation = """
        query GetUser {
            user {
                id
                name
            }
        }
        """
        
        let operationURL = tempDirectory.appendingPathComponent("query.graphql")
        try operation.write(to: operationURL, atomically: true, encoding: .utf8)
        
        let parser = GraphQLParser()
        let operations = try parser.parseOperations(fileURL: operationURL)
        
        XCTAssertEqual(operations.count, 1)
        XCTAssertEqual(operations.first?.type, .query)
        XCTAssertEqual(operations.first?.name, "GetUser")
    }
    
    func testParseQueryWithVariables() throws {
        let operation = """
        query GetUser($id: ID!) {
            user(id: $id) {
                id
                name
            }
        }
        """
        
        let operationURL = tempDirectory.appendingPathComponent("query.graphql")
        try operation.write(to: operationURL, atomically: true, encoding: .utf8)
        
        let parser = GraphQLParser()
        let operations = try parser.parseOperations(fileURL: operationURL)
        
        XCTAssertEqual(operations.count, 1)
        XCTAssertEqual(operations.first?.variables.count, 1)
        XCTAssertEqual(operations.first?.variables.first?.name, "id")
    }
    
    func testParseMutation() throws {
        let operation = """
        mutation CreateUser($input: CreateUserInput!) {
            createUser(input: $input) {
                id
                name
            }
        }
        """
        
        let operationURL = tempDirectory.appendingPathComponent("mutation.graphql")
        try operation.write(to: operationURL, atomically: true, encoding: .utf8)
        
        let parser = GraphQLParser()
        let operations = try parser.parseOperations(fileURL: operationURL)
        
        XCTAssertEqual(operations.count, 1)
        XCTAssertEqual(operations.first?.type, .mutation)
        XCTAssertEqual(operations.first?.name, "CreateUser")
    }
    
    // MARK: - Type Reference Tests
    
    func testTypeReferenceNamed() {
        let ref = GraphQLTypeReference.named("String")
        
        XCTAssertEqual(ref.typeName, "String")
        XCTAssertFalse(ref.isNonNull)
        XCTAssertFalse(ref.isList)
    }
    
    func testTypeReferenceNonNull() {
        let ref = GraphQLTypeReference.nonNull(.named("String"))
        
        XCTAssertEqual(ref.typeName, "String")
        XCTAssertTrue(ref.isNonNull)
        XCTAssertFalse(ref.isList)
    }
    
    func testTypeReferenceList() {
        let ref = GraphQLTypeReference.list(.named("String"))
        
        XCTAssertEqual(ref.typeName, "String")
        XCTAssertFalse(ref.isNonNull)
        XCTAssertTrue(ref.isList)
    }
    
    func testTypeReferenceNonNullList() {
        let ref = GraphQLTypeReference.nonNull(.list(.named("String")))
        
        XCTAssertEqual(ref.typeName, "String")
        XCTAssertTrue(ref.isNonNull)
        XCTAssertTrue(ref.isList)
    }
    
    // MARK: - Code Generation Tests
    
    func testGenerateTypesNoSchema() {
        let parser = GraphQLParser()
        
        XCTAssertThrowsError(try parser.generateTypes()) { error in
            XCTAssertEqual(error as? GraphQLParserError, .noSchemaParsed)
        }
    }
    
    func testGenerateTypes() throws {
        let schema = """
        type User {
            id: ID!
            name: String!
        }
        """
        
        let schemaURL = tempDirectory.appendingPathComponent("schema.graphql")
        try schema.write(to: schemaURL, atomically: true, encoding: .utf8)
        
        let parser = GraphQLParser()
        _ = try parser.parseSchema(fileURL: schemaURL)
        let files = try parser.generateTypes()
        
        XCTAssertFalse(files.isEmpty)
        
        let fileNames = files.map { $0.fileName }
        XCTAssertTrue(fileNames.contains("User.swift"))
        XCTAssertTrue(fileNames.contains("GraphQLClient.swift"))
        XCTAssertTrue(fileNames.contains("GraphQLError.swift"))
    }
    
    // MARK: - GraphQL Schema Types Tests
    
    func testGraphQLTypeCreation() {
        let type = GraphQLType(
            kind: .object,
            name: "TestType",
            description: "A test type",
            fields: [
                GraphQLField(
                    name: "id",
                    type: .nonNull(.named("ID"))
                )
            ]
        )
        
        XCTAssertEqual(type.kind, .object)
        XCTAssertEqual(type.name, "TestType")
        XCTAssertEqual(type.description, "A test type")
        XCTAssertEqual(type.fields?.count, 1)
    }
    
    func testGraphQLFieldCreation() {
        let field = GraphQLField(
            name: "user",
            description: "Get a user",
            args: [
                GraphQLInputValue(
                    name: "id",
                    type: .nonNull(.named("ID"))
                )
            ],
            type: .named("User"),
            isDeprecated: true,
            deprecationReason: "Use userById instead"
        )
        
        XCTAssertEqual(field.name, "user")
        XCTAssertEqual(field.description, "Get a user")
        XCTAssertEqual(field.args.count, 1)
        XCTAssertTrue(field.isDeprecated)
        XCTAssertEqual(field.deprecationReason, "Use userById instead")
    }
    
    func testGraphQLEnumValueCreation() {
        let value = GraphQLEnumValue(
            name: "ACTIVE",
            description: "Active status",
            isDeprecated: false
        )
        
        XCTAssertEqual(value.name, "ACTIVE")
        XCTAssertEqual(value.description, "Active status")
        XCTAssertFalse(value.isDeprecated)
    }
    
    func testGraphQLDirectiveCreation() {
        let directive = GraphQLDirective(
            name: "deprecated",
            description: "Marks an element as deprecated",
            locations: [.field, .enumValue],
            args: [
                GraphQLInputValue(
                    name: "reason",
                    type: .named("String"),
                    defaultValue: "\"No longer supported\""
                )
            ]
        )
        
        XCTAssertEqual(directive.name, "deprecated")
        XCTAssertEqual(directive.locations, [.field, .enumValue])
        XCTAssertEqual(directive.args.count, 1)
    }
    
    // MARK: - GraphQL Operation Types Tests
    
    func testGraphQLOperationCreation() {
        let operation = GraphQLOperation(
            type: .query,
            name: "GetUsers",
            variables: [
                GraphQLVariable(
                    name: "limit",
                    type: .named("Int"),
                    defaultValue: "10"
                )
            ],
            selectionSet: GraphQLSelectionSet(selections: [])
        )
        
        XCTAssertEqual(operation.type, .query)
        XCTAssertEqual(operation.name, "GetUsers")
        XCTAssertEqual(operation.variables.count, 1)
    }
    
    func testGraphQLSelectionCreation() {
        let fieldSelection = GraphQLFieldSelection(
            alias: "mainUser",
            name: "user",
            arguments: [
                GraphQLArgument(name: "id", value: .variable("userId"))
            ],
            selectionSet: GraphQLSelectionSet(selections: [
                .field(GraphQLFieldSelection(name: "id")),
                .field(GraphQLFieldSelection(name: "name"))
            ])
        )
        
        XCTAssertEqual(fieldSelection.alias, "mainUser")
        XCTAssertEqual(fieldSelection.name, "user")
        XCTAssertEqual(fieldSelection.arguments.count, 1)
        XCTAssertEqual(fieldSelection.selectionSet?.selections.count, 2)
    }
    
    // MARK: - GraphQL Value Tests
    
    func testGraphQLValueVariable() {
        let value = GraphQLValue.variable("userId")
        if case .variable(let name) = value {
            XCTAssertEqual(name, "userId")
        } else {
            XCTFail("Expected variable value")
        }
    }
    
    func testGraphQLValueInt() {
        let value = GraphQLValue.int(42)
        if case .int(let num) = value {
            XCTAssertEqual(num, 42)
        } else {
            XCTFail("Expected int value")
        }
    }
    
    func testGraphQLValueFloat() {
        let value = GraphQLValue.float(3.14)
        if case .float(let num) = value {
            XCTAssertEqual(num, 3.14, accuracy: 0.001)
        } else {
            XCTFail("Expected float value")
        }
    }
    
    func testGraphQLValueString() {
        let value = GraphQLValue.string("hello")
        if case .string(let str) = value {
            XCTAssertEqual(str, "hello")
        } else {
            XCTFail("Expected string value")
        }
    }
    
    func testGraphQLValueBoolean() {
        let value = GraphQLValue.boolean(true)
        if case .boolean(let bool) = value {
            XCTAssertTrue(bool)
        } else {
            XCTFail("Expected boolean value")
        }
    }
    
    func testGraphQLValueNull() {
        let value = GraphQLValue.null
        if case .null = value {
            // Success
        } else {
            XCTFail("Expected null value")
        }
    }
    
    func testGraphQLValueEnum() {
        let value = GraphQLValue.enum("ACTIVE")
        if case .enum(let name) = value {
            XCTAssertEqual(name, "ACTIVE")
        } else {
            XCTFail("Expected enum value")
        }
    }
    
    func testGraphQLValueList() {
        let value = GraphQLValue.list([.int(1), .int(2), .int(3)])
        if case .list(let items) = value {
            XCTAssertEqual(items.count, 3)
        } else {
            XCTFail("Expected list value")
        }
    }
    
    func testGraphQLValueObject() {
        let value = GraphQLValue.object(["name": .string("John"), "age": .int(30)])
        if case .object(let fields) = value {
            XCTAssertEqual(fields.count, 2)
        } else {
            XCTFail("Expected object value")
        }
    }
    
    // MARK: - Error Tests
    
    func testParserErrorDescriptions() {
        XCTAssertEqual(
            GraphQLParserError.noSchemaParsed.errorDescription,
            "No GraphQL schema has been parsed"
        )
        XCTAssertEqual(
            GraphQLParserError.expectedName.errorDescription,
            "Expected a name token"
        )
        XCTAssertEqual(
            GraphQLParserError.expectedType.errorDescription,
            "Expected a type reference"
        )
        XCTAssertEqual(
            GraphQLParserError.expectedPunctuator("{").errorDescription,
            "Expected punctuator: {"
        )
        XCTAssertEqual(
            GraphQLParserError.invalidToken("@#$").errorDescription,
            "Invalid token: @#$"
        )
        XCTAssertEqual(
            GraphQLParserError.unexpectedEndOfFile.errorDescription,
            "Unexpected end of file"
        )
    }
}
