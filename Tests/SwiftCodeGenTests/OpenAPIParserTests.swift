import XCTest
@testable import SwiftCodeGen

final class OpenAPIParserTests: XCTestCase {
    
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
        let config = OpenAPIParser.Configuration()
        
        XCTAssertTrue(config.generateAsync)
        XCTAssertFalse(config.generateCombine)
        XCTAssertTrue(config.generateValidations)
        XCTAssertTrue(config.generateMocks)
        XCTAssertEqual(config.accessLevel, "public")
        XCTAssertEqual(config.typePrefix, "")
        XCTAssertEqual(config.typeSuffix, "")
    }
    
    func testConfigurationCustomValues() {
        let config = OpenAPIParser.Configuration(
            generateAsync: false,
            generateCombine: true,
            generateValidations: false,
            generateMocks: false,
            accessLevel: "internal",
            typePrefix: "API",
            typeSuffix: "DTO"
        )
        
        XCTAssertFalse(config.generateAsync)
        XCTAssertTrue(config.generateCombine)
        XCTAssertFalse(config.generateValidations)
        XCTAssertFalse(config.generateMocks)
        XCTAssertEqual(config.accessLevel, "internal")
        XCTAssertEqual(config.typePrefix, "API")
        XCTAssertEqual(config.typeSuffix, "DTO")
    }
    
    // MARK: - Parser Initialization
    
    func testParserInitialization() {
        let parser = OpenAPIParser()
        XCTAssertNotNil(parser.configuration)
    }
    
    func testParserInitializationWithConfig() {
        let config = OpenAPIParser.Configuration(accessLevel: "internal")
        let parser = OpenAPIParser(configuration: config)
        
        XCTAssertEqual(parser.configuration.accessLevel, "internal")
    }
    
    // MARK: - Document Parsing
    
    func testParseSimpleDocument() throws {
        let json = """
        {
            "openapi": "3.0.0",
            "info": {
                "title": "Test API",
                "version": "1.0.0"
            },
            "paths": {}
        }
        """
        
        let jsonURL = tempDirectory.appendingPathComponent("openapi.json")
        try json.write(to: jsonURL, atomically: true, encoding: .utf8)
        
        let parser = OpenAPIParser()
        let document = try parser.parse(fileURL: jsonURL)
        
        XCTAssertEqual(document.openapi, "3.0.0")
        XCTAssertEqual(document.info.title, "Test API")
        XCTAssertEqual(document.info.version, "1.0.0")
        XCTAssertTrue(document.paths.isEmpty)
    }
    
    func testParseDocumentWithInfo() throws {
        let json = """
        {
            "openapi": "3.0.0",
            "info": {
                "title": "Pet Store API",
                "description": "A sample API for pets",
                "termsOfService": "https://example.com/terms",
                "contact": {
                    "name": "API Support",
                    "url": "https://example.com/support",
                    "email": "support@example.com"
                },
                "license": {
                    "name": "MIT",
                    "url": "https://opensource.org/licenses/MIT"
                },
                "version": "2.0.0"
            },
            "paths": {}
        }
        """
        
        let jsonURL = tempDirectory.appendingPathComponent("openapi.json")
        try json.write(to: jsonURL, atomically: true, encoding: .utf8)
        
        let parser = OpenAPIParser()
        let document = try parser.parse(fileURL: jsonURL)
        
        XCTAssertEqual(document.info.title, "Pet Store API")
        XCTAssertEqual(document.info.description, "A sample API for pets")
        XCTAssertEqual(document.info.termsOfService, "https://example.com/terms")
        XCTAssertEqual(document.info.contact?.name, "API Support")
        XCTAssertEqual(document.info.contact?.email, "support@example.com")
        XCTAssertEqual(document.info.license?.name, "MIT")
    }
    
    func testParseDocumentWithServers() throws {
        let json = """
        {
            "openapi": "3.0.0",
            "info": { "title": "Test", "version": "1.0" },
            "servers": [
                {
                    "url": "https://api.example.com",
                    "description": "Production"
                },
                {
                    "url": "https://staging-api.example.com",
                    "description": "Staging"
                }
            ],
            "paths": {}
        }
        """
        
        let jsonURL = tempDirectory.appendingPathComponent("openapi.json")
        try json.write(to: jsonURL, atomically: true, encoding: .utf8)
        
        let parser = OpenAPIParser()
        let document = try parser.parse(fileURL: jsonURL)
        
        XCTAssertEqual(document.servers?.count, 2)
        XCTAssertEqual(document.servers?[0].url, "https://api.example.com")
        XCTAssertEqual(document.servers?[0].description, "Production")
    }
    
    func testParseDocumentWithPaths() throws {
        let json = """
        {
            "openapi": "3.0.0",
            "info": { "title": "Test", "version": "1.0" },
            "paths": {
                "/users": {
                    "get": {
                        "summary": "Get all users",
                        "operationId": "getUsers",
                        "responses": {
                            "200": {
                                "description": "Success"
                            }
                        }
                    },
                    "post": {
                        "summary": "Create user",
                        "operationId": "createUser",
                        "responses": {
                            "201": {
                                "description": "Created"
                            }
                        }
                    }
                }
            }
        }
        """
        
        let jsonURL = tempDirectory.appendingPathComponent("openapi.json")
        try json.write(to: jsonURL, atomically: true, encoding: .utf8)
        
        let parser = OpenAPIParser()
        let document = try parser.parse(fileURL: jsonURL)
        
        XCTAssertEqual(document.paths.count, 1)
        XCTAssertNotNil(document.paths["/users"])
        XCTAssertNotNil(document.paths["/users"]?.get)
        XCTAssertNotNil(document.paths["/users"]?.post)
        XCTAssertEqual(document.paths["/users"]?.get?.operationId, "getUsers")
        XCTAssertEqual(document.paths["/users"]?.post?.operationId, "createUser")
    }
    
    func testParseDocumentWithComponents() throws {
        let json = """
        {
            "openapi": "3.0.0",
            "info": { "title": "Test", "version": "1.0" },
            "paths": {},
            "components": {
                "schemas": {
                    "User": {
                        "type": "object",
                        "properties": {
                            "id": { "type": "integer" },
                            "name": { "type": "string" },
                            "email": { "type": "string" }
                        },
                        "required": ["id", "name"]
                    }
                }
            }
        }
        """
        
        let jsonURL = tempDirectory.appendingPathComponent("openapi.json")
        try json.write(to: jsonURL, atomically: true, encoding: .utf8)
        
        let parser = OpenAPIParser()
        let document = try parser.parse(fileURL: jsonURL)
        
        XCTAssertNotNil(document.components)
        XCTAssertNotNil(document.components?.schemas)
        XCTAssertNotNil(document.components?.schemas?["User"])
    }
    
    // MARK: - Model Generation Tests
    
    func testGenerateModelsNoDocument() {
        let parser = OpenAPIParser()
        
        XCTAssertThrowsError(try parser.generateModels()) { error in
            XCTAssertEqual(error as? OpenAPIParserError, .noDocumentParsed)
        }
    }
    
    func testGenerateAPIClient() throws {
        let json = """
        {
            "openapi": "3.0.0",
            "info": { "title": "Test API", "version": "1.0" },
            "paths": {}
        }
        """
        
        let jsonURL = tempDirectory.appendingPathComponent("openapi.json")
        try json.write(to: jsonURL, atomically: true, encoding: .utf8)
        
        let parser = OpenAPIParser()
        _ = try parser.parse(fileURL: jsonURL)
        let files = try parser.generateAPIClient()
        
        XCTAssertFalse(files.isEmpty)
        
        let fileNames = files.map { $0.fileName }
        XCTAssertTrue(fileNames.contains("APIClient.swift"))
        XCTAssertTrue(fileNames.contains("Endpoints.swift"))
    }
    
    // MARK: - Schema Type Tests
    
    func testSchemaTypeString() throws {
        let json = """
        {
            "openapi": "3.0.0",
            "info": { "title": "Test", "version": "1.0" },
            "paths": {},
            "components": {
                "schemas": {
                    "StringType": { "type": "string" }
                }
            }
        }
        """
        
        let jsonURL = tempDirectory.appendingPathComponent("openapi.json")
        try json.write(to: jsonURL, atomically: true, encoding: .utf8)
        
        let parser = OpenAPIParser()
        let document = try parser.parse(fileURL: jsonURL)
        
        if case .schema(let schema) = document.components?.schemas?["StringType"] {
            XCTAssertEqual(schema.type, .string)
        } else {
            XCTFail("Expected schema type")
        }
    }
    
    func testSchemaTypeInteger() throws {
        let json = """
        {
            "openapi": "3.0.0",
            "info": { "title": "Test", "version": "1.0" },
            "paths": {},
            "components": {
                "schemas": {
                    "IntType": { "type": "integer" }
                }
            }
        }
        """
        
        let jsonURL = tempDirectory.appendingPathComponent("openapi.json")
        try json.write(to: jsonURL, atomically: true, encoding: .utf8)
        
        let parser = OpenAPIParser()
        let document = try parser.parse(fileURL: jsonURL)
        
        if case .schema(let schema) = document.components?.schemas?["IntType"] {
            XCTAssertEqual(schema.type, .integer)
        } else {
            XCTFail("Expected schema type")
        }
    }
    
    func testSchemaTypeNumber() throws {
        let json = """
        {
            "openapi": "3.0.0",
            "info": { "title": "Test", "version": "1.0" },
            "paths": {},
            "components": {
                "schemas": {
                    "NumberType": { "type": "number" }
                }
            }
        }
        """
        
        let jsonURL = tempDirectory.appendingPathComponent("openapi.json")
        try json.write(to: jsonURL, atomically: true, encoding: .utf8)
        
        let parser = OpenAPIParser()
        let document = try parser.parse(fileURL: jsonURL)
        
        if case .schema(let schema) = document.components?.schemas?["NumberType"] {
            XCTAssertEqual(schema.type, .number)
        } else {
            XCTFail("Expected schema type")
        }
    }
    
    func testSchemaTypeBoolean() throws {
        let json = """
        {
            "openapi": "3.0.0",
            "info": { "title": "Test", "version": "1.0" },
            "paths": {},
            "components": {
                "schemas": {
                    "BoolType": { "type": "boolean" }
                }
            }
        }
        """
        
        let jsonURL = tempDirectory.appendingPathComponent("openapi.json")
        try json.write(to: jsonURL, atomically: true, encoding: .utf8)
        
        let parser = OpenAPIParser()
        let document = try parser.parse(fileURL: jsonURL)
        
        if case .schema(let schema) = document.components?.schemas?["BoolType"] {
            XCTAssertEqual(schema.type, .boolean)
        } else {
            XCTFail("Expected schema type")
        }
    }
    
    func testSchemaTypeArray() throws {
        let json = """
        {
            "openapi": "3.0.0",
            "info": { "title": "Test", "version": "1.0" },
            "paths": {},
            "components": {
                "schemas": {
                    "ArrayType": {
                        "type": "array",
                        "items": { "type": "string" }
                    }
                }
            }
        }
        """
        
        let jsonURL = tempDirectory.appendingPathComponent("openapi.json")
        try json.write(to: jsonURL, atomically: true, encoding: .utf8)
        
        let parser = OpenAPIParser()
        let document = try parser.parse(fileURL: jsonURL)
        
        if case .schema(let schema) = document.components?.schemas?["ArrayType"] {
            XCTAssertEqual(schema.type, .array)
            XCTAssertNotNil(schema.items)
        } else {
            XCTFail("Expected schema type")
        }
    }
    
    func testSchemaTypeObject() throws {
        let json = """
        {
            "openapi": "3.0.0",
            "info": { "title": "Test", "version": "1.0" },
            "paths": {},
            "components": {
                "schemas": {
                    "ObjectType": {
                        "type": "object",
                        "properties": {
                            "name": { "type": "string" }
                        }
                    }
                }
            }
        }
        """
        
        let jsonURL = tempDirectory.appendingPathComponent("openapi.json")
        try json.write(to: jsonURL, atomically: true, encoding: .utf8)
        
        let parser = OpenAPIParser()
        let document = try parser.parse(fileURL: jsonURL)
        
        if case .schema(let schema) = document.components?.schemas?["ObjectType"] {
            XCTAssertEqual(schema.type, .object)
            XCTAssertNotNil(schema.properties)
        } else {
            XCTFail("Expected schema type")
        }
    }
    
    // MARK: - Error Tests
    
    func testParserErrorDescriptions() {
        XCTAssertEqual(
            OpenAPIParserError.noDocumentParsed.errorDescription,
            "No OpenAPI document has been parsed"
        )
        XCTAssertEqual(
            OpenAPIParserError.invalidSchema("test").errorDescription,
            "Invalid schema: test"
        )
        XCTAssertEqual(
            OpenAPIParserError.unsupportedType("custom").errorDescription,
            "Unsupported type: custom"
        )
        XCTAssertEqual(
            OpenAPIParserError.yamlNotSupported.errorDescription,
            "YAML parsing requires external dependency"
        )
        XCTAssertEqual(
            OpenAPIParserError.referenceNotFound("#/ref").errorDescription,
            "Reference not found: #/ref"
        )
    }
    
    // MARK: - AnyCodable Tests
    
    func testAnyCodableInt() throws {
        let value = AnyCodable(42)
        XCTAssertEqual(value.value as? Int, 42)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        XCTAssertEqual(decoded.value as? Int, 42)
    }
    
    func testAnyCodableString() throws {
        let value = AnyCodable("hello")
        XCTAssertEqual(value.value as? String, "hello")
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        XCTAssertEqual(decoded.value as? String, "hello")
    }
    
    func testAnyCodableBool() throws {
        let value = AnyCodable(true)
        XCTAssertEqual(value.value as? Bool, true)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        XCTAssertEqual(decoded.value as? Bool, true)
    }
    
    func testAnyCodableDouble() throws {
        let value = AnyCodable(3.14)
        XCTAssertEqual(value.value as? Double, 3.14)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        XCTAssertEqual(decoded.value as? Double, 3.14)
    }
    
    func testAnyCodableArray() throws {
        let value = AnyCodable([1, 2, 3])
        XCTAssertNotNil(value.value as? [Any])
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(AnyCodable.self, from: data)
        let decodedArray = decoded.value as? [Any]
        XCTAssertEqual(decodedArray?.count, 3)
    }
}
