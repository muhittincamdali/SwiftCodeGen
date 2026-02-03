import Foundation

// MARK: - Service Configuration

/// Configuration options for service layer generation.
public struct ServiceConfig: Codable, Sendable {
    
    /// The service layer pattern to use.
    public enum ServicePattern: String, Codable, Sendable {
        case basic = "Basic"
        case facade = "Facade"
        case decorator = "Decorator"
        case proxy = "Proxy"
        case adapter = "Adapter"
    }
    
    /// The error handling strategy.
    public enum ErrorStrategy: String, Codable, Sendable {
        case throwing = "Throwing"
        case result = "Result"
        case optional = "Optional"
        case combined = "Combined"
    }
    
    /// The caching strategy for services.
    public enum CachingStrategy: String, Codable, Sendable {
        case none = "None"
        case memory = "Memory"
        case disk = "Disk"
        case hybrid = "Hybrid"
    }
    
    /// Whether to generate protocol definitions.
    public var generateProtocols: Bool
    
    /// Whether to use async/await.
    public var useAsync: Bool
    
    /// Whether to use Combine publishers.
    public var useCombine: Bool
    
    /// The service pattern to use.
    public var servicePattern: ServicePattern
    
    /// The error handling strategy.
    public var errorStrategy: ErrorStrategy
    
    /// The caching strategy.
    public var cachingStrategy: CachingStrategy
    
    /// Whether to generate retry logic.
    public var generateRetryLogic: Bool
    
    /// Whether to generate logging.
    public var generateLogging: Bool
    
    /// Whether to generate metrics.
    public var generateMetrics: Bool
    
    /// Custom imports to include.
    public var customImports: [String]
    
    /// Creates a new service configuration.
    public init(
        generateProtocols: Bool = true,
        useAsync: Bool = true,
        useCombine: Bool = true,
        servicePattern: ServicePattern = .basic,
        errorStrategy: ErrorStrategy = .throwing,
        cachingStrategy: CachingStrategy = .memory,
        generateRetryLogic: Bool = true,
        generateLogging: Bool = true,
        generateMetrics: Bool = false,
        customImports: [String] = []
    ) {
        self.generateProtocols = generateProtocols
        self.useAsync = useAsync
        self.useCombine = useCombine
        self.servicePattern = servicePattern
        self.errorStrategy = errorStrategy
        self.cachingStrategy = cachingStrategy
        self.generateRetryLogic = generateRetryLogic
        self.generateLogging = generateLogging
        self.generateMetrics = generateMetrics
        self.customImports = customImports
    }
}

// MARK: - Service Definition

/// Represents a service definition for code generation.
public struct ServiceDefinition: Codable, Sendable {
    
    /// A method parameter.
    public struct Parameter: Codable, Sendable {
        public let name: String
        public let type: String
        public let isOptional: Bool
        public let defaultValue: String?
        public let description: String?
        
        public init(
            name: String,
            type: String,
            isOptional: Bool = false,
            defaultValue: String? = nil,
            description: String? = nil
        ) {
            self.name = name
            self.type = type
            self.isOptional = isOptional
            self.defaultValue = defaultValue
            self.description = description
        }
    }
    
    /// A service method definition.
    public struct Method: Codable, Sendable {
        public let name: String
        public let parameters: [Parameter]
        public let returnType: String
        public let isAsync: Bool
        public let throwsError: Bool
        public let description: String?
        public let cachePolicy: CachePolicy?
        public let retryPolicy: RetryPolicy?
        
        public init(
            name: String,
            parameters: [Parameter] = [],
            returnType: String = "Void",
            isAsync: Bool = true,
            throwsError: Bool = true,
            description: String? = nil,
            cachePolicy: CachePolicy? = nil,
            retryPolicy: RetryPolicy? = nil
        ) {
            self.name = name
            self.parameters = parameters
            self.returnType = returnType
            self.isAsync = isAsync
            self.throwsError = throwsError
            self.description = description
            self.cachePolicy = cachePolicy
            self.retryPolicy = retryPolicy
        }
    }
    
    /// Cache policy for a method.
    public struct CachePolicy: Codable, Sendable {
        public let enabled: Bool
        public let ttlSeconds: Int
        public let invalidateOn: [String]
        
        public init(enabled: Bool = true, ttlSeconds: Int = 300, invalidateOn: [String] = []) {
            self.enabled = enabled
            self.ttlSeconds = ttlSeconds
            self.invalidateOn = invalidateOn
        }
    }
    
    /// Retry policy for a method.
    public struct RetryPolicy: Codable, Sendable {
        public let maxRetries: Int
        public let delaySeconds: Double
        public let exponentialBackoff: Bool
        
        public init(maxRetries: Int = 3, delaySeconds: Double = 1.0, exponentialBackoff: Bool = true) {
            self.maxRetries = maxRetries
            self.delaySeconds = delaySeconds
            self.exponentialBackoff = exponentialBackoff
        }
    }
    
    /// A dependency required by the service.
    public struct Dependency: Codable, Sendable {
        public let name: String
        public let type: String
        public let isOptional: Bool
        
        public init(name: String, type: String, isOptional: Bool = false) {
            self.name = name
            self.type = type
            self.isOptional = isOptional
        }
    }
    
    /// The name of the service.
    public let name: String
    
    /// The methods provided by the service.
    public let methods: [Method]
    
    /// The dependencies required by the service.
    public let dependencies: [Dependency]
    
    /// Description of the service.
    public let description: String?
    
    /// Creates a new service definition.
    public init(
        name: String,
        methods: [Method] = [],
        dependencies: [Dependency] = [],
        description: String? = nil
    ) {
        self.name = name
        self.methods = methods
        self.dependencies = dependencies
        self.description = description
    }
}

// MARK: - Service Generator

/// Generates service layer code from definitions.
public final class ServiceGenerator: CodeGenerator {
    
    /// The type identifier for this generator.
    public let generatorType = "service"
    
    /// The input path for source files.
    public let inputPath: String
    
    /// The output path for generated files.
    public let outputPath: String
    
    /// The global configuration.
    private let globalConfig: CodeGenConfig
    
    /// The service-specific configuration.
    private let serviceConfig: ServiceConfig
    
    /// Creates a new service generator.
    public init(
        inputPath: String,
        outputPath: String,
        config: CodeGenConfig,
        serviceConfig: ServiceConfig = ServiceConfig()
    ) {
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.globalConfig = config
        self.serviceConfig = serviceConfig
    }
    
    /// Generates service code from the input definitions.
    public func generate() throws -> [GeneratedFile] {
        let definitions = try loadServiceDefinitions()
        var files: [GeneratedFile] = []
        
        for definition in definitions {
            if serviceConfig.generateProtocols {
                files.append(generateProtocol(for: definition))
            }
            
            files.append(generateImplementation(for: definition))
            
            if serviceConfig.cachingStrategy != .none {
                files.append(generateCacheWrapper(for: definition))
            }
            
            if serviceConfig.servicePattern == .decorator {
                files.append(generateDecorator(for: definition))
            }
            
            if serviceConfig.generateLogging {
                files.append(generateLoggingDecorator(for: definition))
            }
        }
        
        if !definitions.isEmpty {
            files.append(generateServiceContainer(for: definitions))
            files.append(generateServiceErrors())
        }
        
        return files
    }
    
    // MARK: - Loading
    
    private func loadServiceDefinitions() throws -> [ServiceDefinition] {
        let url = URL(fileURLWithPath: inputPath)
        
        if url.pathExtension == "json" {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            return try decoder.decode([ServiceDefinition].self, from: data)
        }
        
        var definitions: [ServiceDefinition] = []
        let fileManager = FileManager.default
        
        if let enumerator = fileManager.enumerator(atPath: inputPath) {
            while let file = enumerator.nextObject() as? String {
                if file.hasSuffix(".service.json") {
                    let fileURL = URL(fileURLWithPath: inputPath).appendingPathComponent(file)
                    let data = try Data(contentsOf: fileURL)
                    let decoder = JSONDecoder()
                    let definition = try decoder.decode(ServiceDefinition.self, from: data)
                    definitions.append(definition)
                }
            }
        }
        
        return definitions
    }
    
    // MARK: - Protocol Generation
    
    private func generateProtocol(for definition: ServiceDefinition) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: "\(definition.name)Protocol"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        
        if let description = definition.description {
            lines.append("/// \(description)")
        }
        lines.append("public protocol \(definition.name)Protocol: Sendable {")
        lines.append("")
        
        for method in definition.methods {
            lines.append(contentsOf: generateProtocolMethod(method))
            lines.append("")
        }
        
        lines.append("}")
        
        return GeneratedFile(
            fileName: "\(definition.name)Protocol.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    private func generateProtocolMethod(_ method: ServiceDefinition.Method) -> [String] {
        var lines: [String] = []
        
        if let description = method.description {
            lines.append("    /// \(description)")
            for param in method.parameters {
                if let paramDesc = param.description {
                    lines.append("    /// - Parameter \(param.name): \(paramDesc)")
                }
            }
            if method.returnType != "Void" {
                lines.append("    /// - Returns: \(method.returnType)")
            }
        }
        
        let params = method.parameters.map { param -> String in
            let type = param.isOptional ? "\(param.type)?" : param.type
            if let defaultValue = param.defaultValue {
                return "\(param.name): \(type) = \(defaultValue)"
            }
            return "\(param.name): \(type)"
        }.joined(separator: ", ")
        
        var signature = "    func \(method.name)(\(params))"
        
        if method.isAsync {
            signature += " async"
        }
        
        if method.throwsError {
            signature += " throws"
        }
        
        if method.returnType != "Void" {
            signature += " -> \(method.returnType)"
        }
        
        lines.append(signature)
        
        return lines
    }
    
    // MARK: - Implementation Generation
    
    private func generateImplementation(for definition: ServiceDefinition) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: definition.name))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        lines.append("// MARK: - \(definition.name)")
        lines.append("")
        
        if let description = definition.description {
            lines.append("/// \(description)")
        }
        lines.append("public final class \(definition.name): \(definition.name)Protocol {")
        lines.append("")
        
        lines.append(contentsOf: generateProperties(for: definition))
        lines.append("")
        lines.append(contentsOf: generateInitializer(for: definition))
        lines.append("")
        
        for method in definition.methods {
            lines.append(contentsOf: generateMethod(method, for: definition))
            lines.append("")
        }
        
        lines.append("}")
        
        return GeneratedFile(
            fileName: "\(definition.name).swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    private func generateProperties(for definition: ServiceDefinition) -> [String] {
        var lines: [String] = []
        
        lines.append("    // MARK: - Properties")
        lines.append("")
        
        for dependency in definition.dependencies {
            let type = dependency.isOptional ? "\(dependency.type)?" : dependency.type
            lines.append("    /// The \(dependency.name) dependency.")
            lines.append("    private let \(dependency.name): \(type)")
        }
        
        if serviceConfig.generateLogging {
            lines.append("")
            lines.append("    /// The logger instance.")
            lines.append("    private let logger: Logger")
        }
        
        if serviceConfig.cachingStrategy != .none {
            lines.append("")
            lines.append("    /// The cache instance.")
            lines.append("    private let cache: ServiceCache")
        }
        
        return lines
    }
    
    private func generateInitializer(for definition: ServiceDefinition) -> [String] {
        var lines: [String] = []
        
        lines.append("    // MARK: - Initialization")
        lines.append("")
        
        var params: [String] = []
        for dependency in definition.dependencies {
            let type = dependency.isOptional ? "\(dependency.type)?" : dependency.type
            params.append("\(dependency.name): \(type)")
        }
        
        if serviceConfig.generateLogging {
            params.append("logger: Logger = .init(subsystem: \"Services\", category: \"\(definition.name)\")")
        }
        
        if serviceConfig.cachingStrategy != .none {
            params.append("cache: ServiceCache = .shared")
        }
        
        lines.append("    /// Creates a new \(definition.name) instance.")
        lines.append("    public init(")
        for (index, param) in params.enumerated() {
            let suffix = index < params.count - 1 ? "," : ""
            lines.append("        \(param)\(suffix)")
        }
        lines.append("    ) {")
        
        for dependency in definition.dependencies {
            lines.append("        self.\(dependency.name) = \(dependency.name)")
        }
        
        if serviceConfig.generateLogging {
            lines.append("        self.logger = logger")
        }
        
        if serviceConfig.cachingStrategy != .none {
            lines.append("        self.cache = cache")
        }
        
        lines.append("    }")
        
        return lines
    }
    
    private func generateMethod(_ method: ServiceDefinition.Method, for definition: ServiceDefinition) -> [String] {
        var lines: [String] = []
        
        lines.append("    // MARK: - \(method.name.capitalized)")
        lines.append("")
        
        if let description = method.description {
            lines.append("    /// \(description)")
            for param in method.parameters {
                if let paramDesc = param.description {
                    lines.append("    /// - Parameter \(param.name): \(paramDesc)")
                }
            }
            if method.returnType != "Void" {
                lines.append("    /// - Returns: \(method.returnType)")
            }
        }
        
        let params = method.parameters.map { param -> String in
            let type = param.isOptional ? "\(param.type)?" : param.type
            return "\(param.name): \(type)"
        }.joined(separator: ", ")
        
        var signature = "    public func \(method.name)(\(params))"
        
        if method.isAsync {
            signature += " async"
        }
        
        if method.throwsError {
            signature += " throws"
        }
        
        if method.returnType != "Void" {
            signature += " -> \(method.returnType)"
        }
        
        signature += " {"
        lines.append(signature)
        
        if serviceConfig.generateLogging {
            lines.append("        logger.debug(\"Starting \(method.name)\")")
        }
        
        if let cachePolicy = method.cachePolicy, cachePolicy.enabled {
            lines.append(contentsOf: generateCacheCheck(for: method))
        }
        
        if let retryPolicy = method.retryPolicy {
            lines.append(contentsOf: generateRetryLogic(for: method, policy: retryPolicy))
        } else {
            lines.append(contentsOf: generateMethodBody(for: method))
        }
        
        if serviceConfig.generateLogging {
            lines.append("        logger.debug(\"Completed \(method.name)\")")
        }
        
        if method.returnType != "Void" {
            lines.append("        return result")
        }
        
        lines.append("    }")
        
        return lines
    }
    
    private func generateCacheCheck(for method: ServiceDefinition.Method) -> [String] {
        var lines: [String] = []
        
        let cacheKeyParams = method.parameters.map { "\\(\($0.name))" }.joined(separator: "-")
        lines.append("        let cacheKey = \"\(method.name)-\(cacheKeyParams)\"")
        lines.append("")
        lines.append("        if let cached: \(method.returnType) = cache.get(forKey: cacheKey) {")
        lines.append("            logger.debug(\"Cache hit for \(method.name)\")")
        lines.append("            return cached")
        lines.append("        }")
        lines.append("")
        
        return lines
    }
    
    private func generateRetryLogic(for method: ServiceDefinition.Method, policy: ServiceDefinition.RetryPolicy) -> [String] {
        var lines: [String] = []
        
        lines.append("        var lastError: Error?")
        lines.append("        var delay: TimeInterval = \(policy.delaySeconds)")
        lines.append("")
        lines.append("        for attempt in 1...\(policy.maxRetries) {")
        lines.append("            do {")
        lines.append(contentsOf: generateMethodBody(for: method).map { "        \($0)" })
        lines.append("                break")
        lines.append("            } catch {")
        lines.append("                lastError = error")
        lines.append("                logger.warning(\"Attempt \\(attempt) failed: \\(error)\")")
        lines.append("")
        lines.append("                if attempt < \(policy.maxRetries) {")
        lines.append("                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))")
        if policy.exponentialBackoff {
            lines.append("                    delay *= 2")
        }
        lines.append("                }")
        lines.append("            }")
        lines.append("        }")
        lines.append("")
        lines.append("        if let error = lastError {")
        lines.append("            throw ServiceError.retryExhausted(underlying: error)")
        lines.append("        }")
        
        return lines
    }
    
    private func generateMethodBody(for method: ServiceDefinition.Method) -> [String] {
        var lines: [String] = []
        
        if method.returnType != "Void" {
            lines.append("        let result: \(method.returnType)")
            lines.append("        // TODO: Implement \(method.name) logic")
            lines.append("        result = try await performOperation()")
        } else {
            lines.append("        // TODO: Implement \(method.name) logic")
        }
        
        return lines
    }
    
    // MARK: - Cache Wrapper Generation
    
    private func generateCacheWrapper(for definition: ServiceDefinition) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: "Cached\(definition.name)"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        lines.append("// MARK: - Cached\(definition.name)")
        lines.append("")
        lines.append("/// A caching wrapper for \(definition.name).")
        lines.append("public final class Cached\(definition.name): \(definition.name)Protocol {")
        lines.append("")
        lines.append("    // MARK: - Properties")
        lines.append("")
        lines.append("    /// The wrapped service.")
        lines.append("    private let wrapped: \(definition.name)Protocol")
        lines.append("")
        lines.append("    /// The cache instance.")
        lines.append("    private let cache: ServiceCache")
        lines.append("")
        lines.append("    /// The default TTL for cached items.")
        lines.append("    private let defaultTTL: TimeInterval")
        lines.append("")
        lines.append("    // MARK: - Initialization")
        lines.append("")
        lines.append("    /// Creates a new caching wrapper.")
        lines.append("    public init(")
        lines.append("        wrapped: \(definition.name)Protocol,")
        lines.append("        cache: ServiceCache = .shared,")
        lines.append("        defaultTTL: TimeInterval = 300")
        lines.append("    ) {")
        lines.append("        self.wrapped = wrapped")
        lines.append("        self.cache = cache")
        lines.append("        self.defaultTTL = defaultTTL")
        lines.append("    }")
        lines.append("")
        
        for method in definition.methods {
            lines.append(contentsOf: generateCachedMethod(method))
            lines.append("")
        }
        
        lines.append("    // MARK: - Cache Management")
        lines.append("")
        lines.append("    /// Invalidates all cached data for this service.")
        lines.append("    public func invalidateCache() {")
        lines.append("        cache.removeAll(prefix: \"\(definition.name)\")")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Invalidates cached data for a specific method.")
        lines.append("    public func invalidateCache(for method: String) {")
        lines.append("        cache.removeAll(prefix: \"\(definition.name).\\(method)\")")
        lines.append("    }")
        lines.append("")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "Cached\(definition.name).swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    private func generateCachedMethod(_ method: ServiceDefinition.Method) -> [String] {
        var lines: [String] = []
        
        let params = method.parameters.map { param -> String in
            let type = param.isOptional ? "\(param.type)?" : param.type
            return "\(param.name): \(type)"
        }.joined(separator: ", ")
        
        var signature = "    public func \(method.name)(\(params))"
        
        if method.isAsync {
            signature += " async"
        }
        
        if method.throwsError {
            signature += " throws"
        }
        
        if method.returnType != "Void" {
            signature += " -> \(method.returnType)"
        }
        
        signature += " {"
        lines.append(signature)
        
        if method.returnType != "Void" {
            let cacheKeyParams = method.parameters.map { "\\(\($0.name))" }.joined(separator: "-")
            lines.append("        let cacheKey = \"\(method.name)-\(cacheKeyParams)\"")
            lines.append("")
            lines.append("        if let cached: \(method.returnType) = cache.get(forKey: cacheKey) {")
            lines.append("            return cached")
            lines.append("        }")
            lines.append("")
            
            let paramNames = method.parameters.map { "\($0.name): \($0.name)" }.joined(separator: ", ")
            var call = "        let result = "
            if method.isAsync {
                call += "await "
            }
            if method.throwsError {
                call += "try "
            }
            call += "wrapped.\(method.name)(\(paramNames))"
            lines.append(call)
            
            lines.append("        cache.set(result, forKey: cacheKey, ttl: defaultTTL)")
            lines.append("        return result")
        } else {
            let paramNames = method.parameters.map { "\($0.name): \($0.name)" }.joined(separator: ", ")
            var call = "        "
            if method.isAsync {
                call += "await "
            }
            if method.throwsError {
                call += "try "
            }
            call += "wrapped.\(method.name)(\(paramNames))"
            lines.append(call)
        }
        
        lines.append("    }")
        
        return lines
    }
    
    // MARK: - Decorator Generation
    
    private func generateDecorator(for definition: ServiceDefinition) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: "\(definition.name)Decorator"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        lines.append("// MARK: - \(definition.name)Decorator")
        lines.append("")
        lines.append("/// Base decorator for \(definition.name).")
        lines.append("open class \(definition.name)Decorator: \(definition.name)Protocol {")
        lines.append("")
        lines.append("    // MARK: - Properties")
        lines.append("")
        lines.append("    /// The wrapped service instance.")
        lines.append("    public let wrapped: \(definition.name)Protocol")
        lines.append("")
        lines.append("    // MARK: - Initialization")
        lines.append("")
        lines.append("    /// Creates a new decorator wrapping the given service.")
        lines.append("    public init(wrapped: \(definition.name)Protocol) {")
        lines.append("        self.wrapped = wrapped")
        lines.append("    }")
        lines.append("")
        
        for method in definition.methods {
            lines.append(contentsOf: generateDecoratorMethod(method))
            lines.append("")
        }
        
        lines.append("}")
        
        return GeneratedFile(
            fileName: "\(definition.name)Decorator.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    private func generateDecoratorMethod(_ method: ServiceDefinition.Method) -> [String] {
        var lines: [String] = []
        
        let params = method.parameters.map { param -> String in
            let type = param.isOptional ? "\(param.type)?" : param.type
            return "\(param.name): \(type)"
        }.joined(separator: ", ")
        
        var signature = "    open func \(method.name)(\(params))"
        
        if method.isAsync {
            signature += " async"
        }
        
        if method.throwsError {
            signature += " throws"
        }
        
        if method.returnType != "Void" {
            signature += " -> \(method.returnType)"
        }
        
        signature += " {"
        lines.append(signature)
        
        let paramNames = method.parameters.map { "\($0.name): \($0.name)" }.joined(separator: ", ")
        var call = "        "
        if method.returnType != "Void" {
            call += "return "
        }
        if method.isAsync {
            call += "await "
        }
        if method.throwsError {
            call += "try "
        }
        call += "wrapped.\(method.name)(\(paramNames))"
        lines.append(call)
        
        lines.append("    }")
        
        return lines
    }
    
    // MARK: - Logging Decorator Generation
    
    private func generateLoggingDecorator(for definition: ServiceDefinition) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: "Logging\(definition.name)"))
        lines.append("")
        lines.append(generateImports())
        lines.append("import os.log")
        lines.append("")
        lines.append("// MARK: - Logging\(definition.name)")
        lines.append("")
        lines.append("/// A logging decorator for \(definition.name).")
        lines.append("public final class Logging\(definition.name): \(definition.name)Decorator {")
        lines.append("")
        lines.append("    // MARK: - Properties")
        lines.append("")
        lines.append("    /// The logger instance.")
        lines.append("    private let logger: Logger")
        lines.append("")
        lines.append("    // MARK: - Initialization")
        lines.append("")
        lines.append("    /// Creates a new logging decorator.")
        lines.append("    public init(")
        lines.append("        wrapped: \(definition.name)Protocol,")
        lines.append("        logger: Logger = Logger(subsystem: \"Services\", category: \"\(definition.name)\")")
        lines.append("    ) {")
        lines.append("        self.logger = logger")
        lines.append("        super.init(wrapped: wrapped)")
        lines.append("    }")
        lines.append("")
        
        for method in definition.methods {
            lines.append(contentsOf: generateLoggingMethod(method))
            lines.append("")
        }
        
        lines.append("}")
        
        return GeneratedFile(
            fileName: "Logging\(definition.name).swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    private func generateLoggingMethod(_ method: ServiceDefinition.Method) -> [String] {
        var lines: [String] = []
        
        let params = method.parameters.map { param -> String in
            let type = param.isOptional ? "\(param.type)?" : param.type
            return "\(param.name): \(type)"
        }.joined(separator: ", ")
        
        var signature = "    public override func \(method.name)(\(params))"
        
        if method.isAsync {
            signature += " async"
        }
        
        if method.throwsError {
            signature += " throws"
        }
        
        if method.returnType != "Void" {
            signature += " -> \(method.returnType)"
        }
        
        signature += " {"
        lines.append(signature)
        
        let paramLog = method.parameters.map { "\\(\($0.name))" }.joined(separator: ", ")
        lines.append("        logger.info(\"[\(method.name)] Starting with params: \(paramLog)\")")
        lines.append("        let startTime = CFAbsoluteTimeGetCurrent()")
        lines.append("")
        
        if method.throwsError {
            lines.append("        do {")
            let paramNames = method.parameters.map { "\($0.name): \($0.name)" }.joined(separator: ", ")
            var call = "            "
            if method.returnType != "Void" {
                call += "let result = "
            }
            if method.isAsync {
                call += "await "
            }
            call += "try wrapped.\(method.name)(\(paramNames))"
            lines.append(call)
            lines.append("            let duration = CFAbsoluteTimeGetCurrent() - startTime")
            lines.append("            logger.info(\"[\(method.name)] Completed in \\(duration)s\")")
            if method.returnType != "Void" {
                lines.append("            return result")
            }
            lines.append("        } catch {")
            lines.append("            let duration = CFAbsoluteTimeGetCurrent() - startTime")
            lines.append("            logger.error(\"[\(method.name)] Failed after \\(duration)s: \\(error)\")")
            lines.append("            throw error")
            lines.append("        }")
        } else {
            let paramNames = method.parameters.map { "\($0.name): \($0.name)" }.joined(separator: ", ")
            var call = "        "
            if method.returnType != "Void" {
                call += "let result = "
            }
            if method.isAsync {
                call += "await "
            }
            call += "wrapped.\(method.name)(\(paramNames))"
            lines.append(call)
            lines.append("        let duration = CFAbsoluteTimeGetCurrent() - startTime")
            lines.append("        logger.info(\"[\(method.name)] Completed in \\(duration)s\")")
            if method.returnType != "Void" {
                lines.append("        return result")
            }
        }
        
        lines.append("    }")
        
        return lines
    }
    
    // MARK: - Service Container Generation
    
    private func generateServiceContainer(for definitions: [ServiceDefinition]) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: "ServiceContainer"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        lines.append("// MARK: - ServiceContainer")
        lines.append("")
        lines.append("/// Central container for service registration and resolution.")
        lines.append("public final class ServiceContainer: @unchecked Sendable {")
        lines.append("")
        lines.append("    // MARK: - Singleton")
        lines.append("")
        lines.append("    /// The shared service container instance.")
        lines.append("    public static let shared = ServiceContainer()")
        lines.append("")
        lines.append("    // MARK: - Properties")
        lines.append("")
        lines.append("    /// Thread-safe storage for registered services.")
        lines.append("    private var services: [ObjectIdentifier: Any] = [:]")
        lines.append("")
        lines.append("    /// Lock for thread-safe access.")
        lines.append("    private let lock = NSLock()")
        lines.append("")
        lines.append("    // MARK: - Initialization")
        lines.append("")
        lines.append("    /// Creates a new service container.")
        lines.append("    public init() {}")
        lines.append("")
        lines.append("    // MARK: - Registration")
        lines.append("")
        lines.append("    /// Registers a service instance.")
        lines.append("    public func register<T>(_ service: T, for type: T.Type = T.self) {")
        lines.append("        lock.lock()")
        lines.append("        defer { lock.unlock() }")
        lines.append("        services[ObjectIdentifier(type)] = service")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Registers a service factory.")
        lines.append("    public func register<T>(factory: @escaping () -> T, for type: T.Type = T.self) {")
        lines.append("        lock.lock()")
        lines.append("        defer { lock.unlock() }")
        lines.append("        services[ObjectIdentifier(type)] = factory")
        lines.append("    }")
        lines.append("")
        lines.append("    // MARK: - Resolution")
        lines.append("")
        lines.append("    /// Resolves a service instance.")
        lines.append("    public func resolve<T>(_ type: T.Type = T.self) -> T? {")
        lines.append("        lock.lock()")
        lines.append("        defer { lock.unlock() }")
        lines.append("")
        lines.append("        let key = ObjectIdentifier(type)")
        lines.append("")
        lines.append("        if let service = services[key] as? T {")
        lines.append("            return service")
        lines.append("        }")
        lines.append("")
        lines.append("        if let factory = services[key] as? () -> T {")
        lines.append("            return factory()")
        lines.append("        }")
        lines.append("")
        lines.append("        return nil")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Resolves a service instance, throwing if not found.")
        lines.append("    public func require<T>(_ type: T.Type = T.self) throws -> T {")
        lines.append("        guard let service: T = resolve(type) else {")
        lines.append("            throw ServiceError.notRegistered(type: String(describing: type))")
        lines.append("        }")
        lines.append("        return service")
        lines.append("    }")
        lines.append("")
        lines.append("    // MARK: - Convenience Accessors")
        lines.append("")
        
        for definition in definitions {
            lines.append("    /// Resolves the \(definition.name) service.")
            lines.append("    public var \(definition.name.lowercasedFirst): \(definition.name)Protocol? {")
            lines.append("        resolve(\(definition.name)Protocol.self)")
            lines.append("    }")
            lines.append("")
        }
        
        lines.append("    // MARK: - Management")
        lines.append("")
        lines.append("    /// Removes all registered services.")
        lines.append("    public func reset() {")
        lines.append("        lock.lock()")
        lines.append("        defer { lock.unlock() }")
        lines.append("        services.removeAll()")
        lines.append("    }")
        lines.append("")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - String Extension")
        lines.append("")
        lines.append("private extension String {")
        lines.append("    var lowercasedFirst: String {")
        lines.append("        guard let first = first else { return self }")
        lines.append("        return first.lowercased() + dropFirst()")
        lines.append("    }")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "ServiceContainer.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    // MARK: - Error Generation
    
    private func generateServiceErrors() -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader(for: "ServiceError"))
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - ServiceError")
        lines.append("")
        lines.append("/// Errors that can occur during service operations.")
        lines.append("public enum ServiceError: LocalizedError, Sendable {")
        lines.append("")
        lines.append("    /// The service was not registered in the container.")
        lines.append("    case notRegistered(type: String)")
        lines.append("")
        lines.append("    /// A network request failed.")
        lines.append("    case networkFailure(underlying: Error)")
        lines.append("")
        lines.append("    /// Data validation failed.")
        lines.append("    case validationFailed(reason: String)")
        lines.append("")
        lines.append("    /// The operation was cancelled.")
        lines.append("    case cancelled")
        lines.append("")
        lines.append("    /// Retry attempts were exhausted.")
        lines.append("    case retryExhausted(underlying: Error)")
        lines.append("")
        lines.append("    /// A cache operation failed.")
        lines.append("    case cacheFailed(reason: String)")
        lines.append("")
        lines.append("    /// An unknown error occurred.")
        lines.append("    case unknown(message: String)")
        lines.append("")
        lines.append("    // MARK: - LocalizedError")
        lines.append("")
        lines.append("    public var errorDescription: String? {")
        lines.append("        switch self {")
        lines.append("        case .notRegistered(let type):")
        lines.append("            return \"Service not registered: \\(type)\"")
        lines.append("        case .networkFailure(let error):")
        lines.append("            return \"Network failure: \\(error.localizedDescription)\"")
        lines.append("        case .validationFailed(let reason):")
        lines.append("            return \"Validation failed: \\(reason)\"")
        lines.append("        case .cancelled:")
        lines.append("            return \"Operation was cancelled\"")
        lines.append("        case .retryExhausted(let error):")
        lines.append("            return \"Retry exhausted: \\(error.localizedDescription)\"")
        lines.append("        case .cacheFailed(let reason):")
        lines.append("            return \"Cache operation failed: \\(reason)\"")
        lines.append("        case .unknown(let message):")
        lines.append("            return message")
        lines.append("        }")
        lines.append("    }")
        lines.append("")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - ServiceCache")
        lines.append("")
        lines.append("/// A simple in-memory cache for service results.")
        lines.append("public final class ServiceCache: @unchecked Sendable {")
        lines.append("")
        lines.append("    // MARK: - Singleton")
        lines.append("")
        lines.append("    /// The shared cache instance.")
        lines.append("    public static let shared = ServiceCache()")
        lines.append("")
        lines.append("    // MARK: - Types")
        lines.append("")
        lines.append("    private struct CacheEntry {")
        lines.append("        let value: Any")
        lines.append("        let expiresAt: Date")
        lines.append("    }")
        lines.append("")
        lines.append("    // MARK: - Properties")
        lines.append("")
        lines.append("    private var storage: [String: CacheEntry] = [:]")
        lines.append("    private let lock = NSLock()")
        lines.append("")
        lines.append("    // MARK: - Initialization")
        lines.append("")
        lines.append("    public init() {}")
        lines.append("")
        lines.append("    // MARK: - Operations")
        lines.append("")
        lines.append("    /// Gets a cached value.")
        lines.append("    public func get<T>(forKey key: String) -> T? {")
        lines.append("        lock.lock()")
        lines.append("        defer { lock.unlock() }")
        lines.append("")
        lines.append("        guard let entry = storage[key] else { return nil }")
        lines.append("")
        lines.append("        if entry.expiresAt < Date() {")
        lines.append("            storage.removeValue(forKey: key)")
        lines.append("            return nil")
        lines.append("        }")
        lines.append("")
        lines.append("        return entry.value as? T")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Sets a cached value.")
        lines.append("    public func set<T>(_ value: T, forKey key: String, ttl: TimeInterval) {")
        lines.append("        lock.lock()")
        lines.append("        defer { lock.unlock() }")
        lines.append("")
        lines.append("        let entry = CacheEntry(value: value, expiresAt: Date().addingTimeInterval(ttl))")
        lines.append("        storage[key] = entry")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Removes all entries with the given prefix.")
        lines.append("    public func removeAll(prefix: String) {")
        lines.append("        lock.lock()")
        lines.append("        defer { lock.unlock() }")
        lines.append("")
        lines.append("        storage = storage.filter { !$0.key.hasPrefix(prefix) }")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Removes all cached entries.")
        lines.append("    public func clear() {")
        lines.append("        lock.lock()")
        lines.append("        defer { lock.unlock() }")
        lines.append("        storage.removeAll()")
        lines.append("    }")
        lines.append("")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "ServiceError.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    // MARK: - Helpers
    
    private func generateFileHeader(for fileName: String) -> String {
        """
        //
        //  \(fileName).swift
        //  SwiftCodeGen
        //
        //  Auto-generated file. Do not modify.
        //
        """
    }
    
    private func generateImports() -> String {
        var imports = ["import Foundation"]
        
        if serviceConfig.useCombine {
            imports.append("import Combine")
        }
        
        if serviceConfig.generateLogging {
            imports.append("import os.log")
        }
        
        imports.append(contentsOf: serviceConfig.customImports.map { "import \($0)" })
        
        return imports.joined(separator: "\n")
    }
}
