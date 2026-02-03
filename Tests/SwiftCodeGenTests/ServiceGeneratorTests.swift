import XCTest
@testable import SwiftCodeGen

final class ServiceGeneratorTests: XCTestCase {
    
    // MARK: - Properties
    
    var tempDirectory: URL!
    var inputDirectory: URL!
    var outputDirectory: URL!
    
    // MARK: - Setup
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        tempDirectory = FileManager.default.temporaryDirectory
            .appendingPathComponent(UUID().uuidString)
        
        inputDirectory = tempDirectory.appendingPathComponent("input")
        outputDirectory = tempDirectory.appendingPathComponent("output")
        
        try FileManager.default.createDirectory(
            at: inputDirectory,
            withIntermediateDirectories: true
        )
        try FileManager.default.createDirectory(
            at: outputDirectory,
            withIntermediateDirectories: true
        )
    }
    
    override func tearDownWithError() throws {
        try? FileManager.default.removeItem(at: tempDirectory)
        try super.tearDownWithError()
    }
    
    // MARK: - ServiceConfig Tests
    
    func testServiceConfigDefaultValues() {
        let config = ServiceConfig()
        
        XCTAssertTrue(config.generateProtocols)
        XCTAssertTrue(config.useAsync)
        XCTAssertTrue(config.useCombine)
        XCTAssertEqual(config.servicePattern, .basic)
        XCTAssertEqual(config.errorStrategy, .throwing)
        XCTAssertEqual(config.cachingStrategy, .memory)
        XCTAssertTrue(config.generateRetryLogic)
        XCTAssertTrue(config.generateLogging)
        XCTAssertFalse(config.generateMetrics)
        XCTAssertTrue(config.customImports.isEmpty)
    }
    
    func testServiceConfigCustomValues() {
        let config = ServiceConfig(
            generateProtocols: false,
            useAsync: false,
            useCombine: false,
            servicePattern: .decorator,
            errorStrategy: .result,
            cachingStrategy: .disk,
            generateRetryLogic: false,
            generateLogging: false,
            generateMetrics: true,
            customImports: ["UIKit", "CoreData"]
        )
        
        XCTAssertFalse(config.generateProtocols)
        XCTAssertFalse(config.useAsync)
        XCTAssertFalse(config.useCombine)
        XCTAssertEqual(config.servicePattern, .decorator)
        XCTAssertEqual(config.errorStrategy, .result)
        XCTAssertEqual(config.cachingStrategy, .disk)
        XCTAssertFalse(config.generateRetryLogic)
        XCTAssertFalse(config.generateLogging)
        XCTAssertTrue(config.generateMetrics)
        XCTAssertEqual(config.customImports, ["UIKit", "CoreData"])
    }
    
    func testServiceConfigEncodingDecoding() throws {
        let original = ServiceConfig(
            generateProtocols: true,
            useAsync: true,
            useCombine: false,
            servicePattern: .facade,
            errorStrategy: .combined,
            cachingStrategy: .hybrid
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(original)
        
        let decoder = JSONDecoder()
        let decoded = try decoder.decode(ServiceConfig.self, from: data)
        
        XCTAssertEqual(original.generateProtocols, decoded.generateProtocols)
        XCTAssertEqual(original.useAsync, decoded.useAsync)
        XCTAssertEqual(original.useCombine, decoded.useCombine)
        XCTAssertEqual(original.servicePattern, decoded.servicePattern)
        XCTAssertEqual(original.errorStrategy, decoded.errorStrategy)
        XCTAssertEqual(original.cachingStrategy, decoded.cachingStrategy)
    }
    
    // MARK: - ServiceDefinition Tests
    
    func testServiceDefinitionCreation() {
        let method = ServiceDefinition.Method(
            name: "fetchUser",
            parameters: [
                ServiceDefinition.Parameter(name: "id", type: "String")
            ],
            returnType: "User",
            isAsync: true,
            throwsError: true,
            description: "Fetches a user by ID"
        )
        
        let dependency = ServiceDefinition.Dependency(
            name: "networkClient",
            type: "NetworkClient"
        )
        
        let definition = ServiceDefinition(
            name: "UserService",
            methods: [method],
            dependencies: [dependency],
            description: "Service for user operations"
        )
        
        XCTAssertEqual(definition.name, "UserService")
        XCTAssertEqual(definition.methods.count, 1)
        XCTAssertEqual(definition.methods.first?.name, "fetchUser")
        XCTAssertEqual(definition.dependencies.count, 1)
        XCTAssertEqual(definition.dependencies.first?.name, "networkClient")
        XCTAssertEqual(definition.description, "Service for user operations")
    }
    
    func testServiceDefinitionParameter() {
        let param = ServiceDefinition.Parameter(
            name: "userId",
            type: "String",
            isOptional: true,
            defaultValue: "nil",
            description: "The user identifier"
        )
        
        XCTAssertEqual(param.name, "userId")
        XCTAssertEqual(param.type, "String")
        XCTAssertTrue(param.isOptional)
        XCTAssertEqual(param.defaultValue, "nil")
        XCTAssertEqual(param.description, "The user identifier")
    }
    
    func testServiceDefinitionCachePolicy() {
        let policy = ServiceDefinition.CachePolicy(
            enabled: true,
            ttlSeconds: 600,
            invalidateOn: ["userUpdated", "userDeleted"]
        )
        
        XCTAssertTrue(policy.enabled)
        XCTAssertEqual(policy.ttlSeconds, 600)
        XCTAssertEqual(policy.invalidateOn, ["userUpdated", "userDeleted"])
    }
    
    func testServiceDefinitionRetryPolicy() {
        let policy = ServiceDefinition.RetryPolicy(
            maxRetries: 5,
            delaySeconds: 2.0,
            exponentialBackoff: false
        )
        
        XCTAssertEqual(policy.maxRetries, 5)
        XCTAssertEqual(policy.delaySeconds, 2.0)
        XCTAssertFalse(policy.exponentialBackoff)
    }
    
    // MARK: - Generator Tests
    
    func testServiceGeneratorType() {
        let config = CodeGenConfig.default
        let generator = ServiceGenerator(
            inputPath: inputDirectory.path,
            outputPath: outputDirectory.path,
            config: config
        )
        
        XCTAssertEqual(generator.generatorType, "service")
        XCTAssertEqual(generator.inputPath, inputDirectory.path)
        XCTAssertEqual(generator.outputPath, outputDirectory.path)
    }
    
    func testServiceGeneratorEmptyInput() throws {
        let config = CodeGenConfig.default
        let generator = ServiceGenerator(
            inputPath: inputDirectory.path,
            outputPath: outputDirectory.path,
            config: config
        )
        
        let files = try generator.generate()
        XCTAssertTrue(files.isEmpty)
    }
    
    func testServiceGeneratorWithDefinition() throws {
        let definitions: [ServiceDefinition] = [
            ServiceDefinition(
                name: "TestService",
                methods: [
                    ServiceDefinition.Method(
                        name: "doSomething",
                        returnType: "String"
                    )
                ],
                dependencies: []
            )
        ]
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(definitions)
        let jsonURL = inputDirectory.appendingPathComponent("services.json")
        try data.write(to: jsonURL)
        
        let config = CodeGenConfig.default
        let serviceConfig = ServiceConfig(
            generateProtocols: true,
            cachingStrategy: .memory,
            generateLogging: true
        )
        
        let generator = ServiceGenerator(
            inputPath: jsonURL.path,
            outputPath: outputDirectory.path,
            config: config,
            serviceConfig: serviceConfig
        )
        
        let files = try generator.generate()
        
        XCTAssertFalse(files.isEmpty)
        
        let fileNames = files.map { $0.fileName }
        XCTAssertTrue(fileNames.contains("TestServiceProtocol.swift"))
        XCTAssertTrue(fileNames.contains("TestService.swift"))
        XCTAssertTrue(fileNames.contains("ServiceContainer.swift"))
        XCTAssertTrue(fileNames.contains("ServiceError.swift"))
    }
    
    // MARK: - Pattern Tests
    
    func testServicePatternBasic() {
        let config = ServiceConfig(servicePattern: .basic)
        XCTAssertEqual(config.servicePattern, .basic)
    }
    
    func testServicePatternFacade() {
        let config = ServiceConfig(servicePattern: .facade)
        XCTAssertEqual(config.servicePattern, .facade)
    }
    
    func testServicePatternDecorator() {
        let config = ServiceConfig(servicePattern: .decorator)
        XCTAssertEqual(config.servicePattern, .decorator)
    }
    
    func testServicePatternProxy() {
        let config = ServiceConfig(servicePattern: .proxy)
        XCTAssertEqual(config.servicePattern, .proxy)
    }
    
    func testServicePatternAdapter() {
        let config = ServiceConfig(servicePattern: .adapter)
        XCTAssertEqual(config.servicePattern, .adapter)
    }
    
    // MARK: - Error Strategy Tests
    
    func testErrorStrategyThrowing() {
        let config = ServiceConfig(errorStrategy: .throwing)
        XCTAssertEqual(config.errorStrategy, .throwing)
    }
    
    func testErrorStrategyResult() {
        let config = ServiceConfig(errorStrategy: .result)
        XCTAssertEqual(config.errorStrategy, .result)
    }
    
    func testErrorStrategyOptional() {
        let config = ServiceConfig(errorStrategy: .optional)
        XCTAssertEqual(config.errorStrategy, .optional)
    }
    
    func testErrorStrategyCombined() {
        let config = ServiceConfig(errorStrategy: .combined)
        XCTAssertEqual(config.errorStrategy, .combined)
    }
    
    // MARK: - Caching Strategy Tests
    
    func testCachingStrategyNone() {
        let config = ServiceConfig(cachingStrategy: .none)
        XCTAssertEqual(config.cachingStrategy, .none)
    }
    
    func testCachingStrategyMemory() {
        let config = ServiceConfig(cachingStrategy: .memory)
        XCTAssertEqual(config.cachingStrategy, .memory)
    }
    
    func testCachingStrategyDisk() {
        let config = ServiceConfig(cachingStrategy: .disk)
        XCTAssertEqual(config.cachingStrategy, .disk)
    }
    
    func testCachingStrategyHybrid() {
        let config = ServiceConfig(cachingStrategy: .hybrid)
        XCTAssertEqual(config.cachingStrategy, .hybrid)
    }
}
