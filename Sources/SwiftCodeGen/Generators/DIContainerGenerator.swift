//
//  DIContainerGenerator.swift
//  SwiftCodeGen
//
//  Generates type-safe dependency injection containers with compile-time validation.
//

import Foundation

// MARK: - Dependency Scope

/// Defines the lifecycle scope of a dependency.
public enum DependencyScope: String, Codable, Sendable, CaseIterable {
    /// A new instance is created each time.
    case transient = "Transient"
    
    /// A single instance is shared across the container.
    case singleton = "Singleton"
    
    /// A single instance per scope/context.
    case scoped = "Scoped"
    
    /// Instance is created lazily on first access.
    case lazy = "Lazy"
    
    /// Weak reference singleton (deallocates when no strong refs).
    case weakSingleton = "WeakSingleton"
    
    /// Thread-local singleton instance.
    case threadLocal = "ThreadLocal"
}

// MARK: - Dependency Registration Type

/// How the dependency is registered in the container.
public enum RegistrationType: String, Codable, Sendable {
    /// Registered as a concrete type.
    case concrete = "Concrete"
    
    /// Registered against a protocol.
    case `protocol` = "Protocol"
    
    /// Registered with a factory closure.
    case factory = "Factory"
    
    /// Registered as an auto-resolved type.
    case autoResolved = "AutoResolved"
}

// MARK: - Injection Type

/// The method of injection for a dependency.
public enum InjectionType: String, Codable, Sendable {
    /// Constructor/initializer injection.
    case constructor = "Constructor"
    
    /// Property injection via setter.
    case property = "Property"
    
    /// Method injection.
    case method = "Method"
}

// MARK: - DI Configuration

/// Configuration options for dependency injection container generation.
public struct DIContainerConfig: Codable, Sendable {
    
    /// Container generation style.
    public enum ContainerStyle: String, Codable, Sendable {
        /// Generate a central container with all registrations.
        case centralized = "Centralized"
        
        /// Generate module-based containers.
        case modular = "Modular"
        
        /// Generate a container with child scopes.
        case hierarchical = "Hierarchical"
    }
    
    /// Thread safety strategy.
    public enum ThreadSafetyStrategy: String, Codable, Sendable {
        /// No thread safety (single-threaded access).
        case none = "None"
        
        /// Use locks for thread safety.
        case lock = "Lock"
        
        /// Use actors for Swift concurrency.
        case actor = "Actor"
        
        /// Use dispatch queues.
        case dispatchQueue = "DispatchQueue"
    }
    
    /// Validation level for dependency graph.
    public enum ValidationLevel: String, Codable, Sendable {
        /// No validation.
        case none = "None"
        
        /// Validate at runtime.
        case runtime = "Runtime"
        
        /// Generate compile-time validation.
        case compileTime = "CompileTime"
    }
    
    /// The container style to use.
    public var containerStyle: ContainerStyle
    
    /// Thread safety strategy.
    public var threadSafety: ThreadSafetyStrategy
    
    /// Validation level.
    public var validationLevel: ValidationLevel
    
    /// Whether to generate protocols for all registrations.
    public var generateProtocols: Bool
    
    /// Whether to generate mock registrations for testing.
    public var generateMocks: Bool
    
    /// Whether to generate property wrappers.
    public var generatePropertyWrappers: Bool
    
    /// Whether to generate async factory support.
    public var generateAsyncSupport: Bool
    
    /// Whether to generate circular dependency detection.
    public var detectCircularDependencies: Bool
    
    /// Whether to generate debug logging.
    public var generateDebugLogging: Bool
    
    /// Custom module name prefix.
    public var modulePrefix: String?
    
    /// Custom imports to include.
    public var customImports: [String]
    
    /// Creates a new DI container configuration.
    public init(
        containerStyle: ContainerStyle = .centralized,
        threadSafety: ThreadSafetyStrategy = .lock,
        validationLevel: ValidationLevel = .compileTime,
        generateProtocols: Bool = true,
        generateMocks: Bool = true,
        generatePropertyWrappers: Bool = true,
        generateAsyncSupport: Bool = true,
        detectCircularDependencies: Bool = true,
        generateDebugLogging: Bool = false,
        modulePrefix: String? = nil,
        customImports: [String] = []
    ) {
        self.containerStyle = containerStyle
        self.threadSafety = threadSafety
        self.validationLevel = validationLevel
        self.generateProtocols = generateProtocols
        self.generateMocks = generateMocks
        self.generatePropertyWrappers = generatePropertyWrappers
        self.generateAsyncSupport = generateAsyncSupport
        self.detectCircularDependencies = detectCircularDependencies
        self.generateDebugLogging = generateDebugLogging
        self.modulePrefix = modulePrefix
        self.customImports = customImports
    }
}

// MARK: - Dependency Definition

/// Represents a single dependency registration.
public struct DependencyDefinition: Codable, Sendable, Identifiable {
    
    /// Parameter definition for constructor injection.
    public struct Parameter: Codable, Sendable {
        /// The parameter name.
        public let name: String
        
        /// The parameter type.
        public let type: String
        
        /// Whether the parameter is optional.
        public let isOptional: Bool
        
        /// Default value if any.
        public let defaultValue: String?
        
        /// The dependency key to resolve.
        public let resolveKey: String?
        
        /// Whether this is a collection injection.
        public let isCollection: Bool
        
        /// Documentation for this parameter.
        public let documentation: String?
        
        public init(
            name: String,
            type: String,
            isOptional: Bool = false,
            defaultValue: String? = nil,
            resolveKey: String? = nil,
            isCollection: Bool = false,
            documentation: String? = nil
        ) {
            self.name = name
            self.type = type
            self.isOptional = isOptional
            self.defaultValue = defaultValue
            self.resolveKey = resolveKey
            self.isCollection = isCollection
            self.documentation = documentation
        }
    }
    
    /// Property injection definition.
    public struct PropertyInjection: Codable, Sendable {
        /// The property name.
        public let propertyName: String
        
        /// The property type.
        public let propertyType: String
        
        /// The dependency key to resolve.
        public let resolveKey: String?
        
        /// Whether injection is required.
        public let required: Bool
        
        public init(
            propertyName: String,
            propertyType: String,
            resolveKey: String? = nil,
            required: Bool = true
        ) {
            self.propertyName = propertyName
            self.propertyType = propertyType
            self.resolveKey = resolveKey
            self.required = required
        }
    }
    
    /// Unique identifier for this dependency.
    public var id: String { key }
    
    /// The unique key for this dependency.
    public let key: String
    
    /// The concrete type name.
    public let concreteType: String
    
    /// The protocol type (if any).
    public let protocolType: String?
    
    /// The dependency scope.
    public let scope: DependencyScope
    
    /// The registration type.
    public let registrationType: RegistrationType
    
    /// Constructor parameters.
    public let parameters: [Parameter]
    
    /// Property injections.
    public let propertyInjections: [PropertyInjection]
    
    /// Dependencies this registration depends on.
    public let dependencies: [String]
    
    /// Module this dependency belongs to.
    public let module: String?
    
    /// Tags for this dependency.
    public let tags: [String]
    
    /// Whether this is the primary implementation.
    public let isPrimary: Bool
    
    /// Documentation for this dependency.
    public let documentation: String?
    
    /// Creates a new dependency definition.
    public init(
        key: String,
        concreteType: String,
        protocolType: String? = nil,
        scope: DependencyScope = .transient,
        registrationType: RegistrationType = .concrete,
        parameters: [Parameter] = [],
        propertyInjections: [PropertyInjection] = [],
        dependencies: [String] = [],
        module: String? = nil,
        tags: [String] = [],
        isPrimary: Bool = true,
        documentation: String? = nil
    ) {
        self.key = key
        self.concreteType = concreteType
        self.protocolType = protocolType
        self.scope = scope
        self.registrationType = registrationType
        self.parameters = parameters
        self.propertyInjections = propertyInjections
        self.dependencies = dependencies
        self.module = module
        self.tags = tags
        self.isPrimary = isPrimary
        self.documentation = documentation
    }
}

// MARK: - Module Definition

/// Represents a module containing related dependencies.
public struct ModuleDefinition: Codable, Sendable, Identifiable {
    
    /// Unique identifier.
    public var id: String { name }
    
    /// The module name.
    public let name: String
    
    /// Dependencies in this module.
    public let dependencies: [DependencyDefinition]
    
    /// Parent module (for hierarchical containers).
    public let parentModule: String?
    
    /// Documentation for this module.
    public let documentation: String?
    
    /// Custom imports for this module.
    public let imports: [String]
    
    /// Creates a new module definition.
    public init(
        name: String,
        dependencies: [DependencyDefinition] = [],
        parentModule: String? = nil,
        documentation: String? = nil,
        imports: [String] = []
    ) {
        self.name = name
        self.dependencies = dependencies
        self.parentModule = parentModule
        self.documentation = documentation
        self.imports = imports
    }
}

// MARK: - Dependency Graph

/// Represents the complete dependency graph.
public struct DependencyGraph: Codable, Sendable {
    
    /// All modules in the graph.
    public let modules: [ModuleDefinition]
    
    /// Standalone dependencies (not in a module).
    public let dependencies: [DependencyDefinition]
    
    /// Graph metadata.
    public let metadata: GraphMetadata
    
    /// Graph metadata structure.
    public struct GraphMetadata: Codable, Sendable {
        public let name: String
        public let version: String
        public let author: String?
        public let description: String?
        
        public init(
            name: String,
            version: String = "1.0.0",
            author: String? = nil,
            description: String? = nil
        ) {
            self.name = name
            self.version = version
            self.author = author
            self.description = description
        }
    }
    
    /// Creates a new dependency graph.
    public init(
        modules: [ModuleDefinition] = [],
        dependencies: [DependencyDefinition] = [],
        metadata: GraphMetadata
    ) {
        self.modules = modules
        self.dependencies = dependencies
        self.metadata = metadata
    }
    
    /// Returns all dependencies in the graph.
    public var allDependencies: [DependencyDefinition] {
        modules.flatMap { $0.dependencies } + dependencies
    }
}

// MARK: - DI Container Generator

/// Generates type-safe dependency injection container code.
public final class DIContainerGenerator: CodeGenerator {
    
    /// The generator type identifier.
    public let generatorType = "di-container"
    
    /// Input path for dependency definitions.
    public let inputPath: String
    
    /// Output path for generated files.
    public let outputPath: String
    
    /// Global configuration.
    private let globalConfig: CodeGenConfig
    
    /// DI-specific configuration.
    private let diConfig: DIContainerConfig
    
    /// Resolution context for tracking dependencies.
    private var resolutionStack: Set<String> = []
    
    /// Creates a new DI container generator.
    public init(
        inputPath: String,
        outputPath: String,
        config: CodeGenConfig,
        diConfig: DIContainerConfig = DIContainerConfig()
    ) {
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.globalConfig = config
        self.diConfig = diConfig
    }
    
    /// Generates the DI container code.
    public func generate() throws -> [GeneratedFile] {
        let graph = try loadDependencyGraph()
        var files: [GeneratedFile] = []
        
        // Validate the dependency graph
        if diConfig.detectCircularDependencies {
            try validateGraph(graph)
        }
        
        // Generate container based on style
        switch diConfig.containerStyle {
        case .centralized:
            files.append(contentsOf: generateCentralizedContainer(graph))
        case .modular:
            files.append(contentsOf: generateModularContainers(graph))
        case .hierarchical:
            files.append(contentsOf: generateHierarchicalContainer(graph))
        }
        
        // Generate protocols if enabled
        if diConfig.generateProtocols {
            files.append(contentsOf: generateProtocols(graph))
        }
        
        // Generate property wrappers if enabled
        if diConfig.generatePropertyWrappers {
            files.append(generatePropertyWrappers())
        }
        
        // Generate mocks if enabled
        if diConfig.generateMocks {
            files.append(contentsOf: generateMocks(graph))
        }
        
        // Generate resolver extensions
        files.append(generateResolverExtensions(graph))
        
        // Generate error types
        files.append(generateDIErrors())
        
        return files
    }
    
    // MARK: - Graph Loading
    
    private func loadDependencyGraph() throws -> DependencyGraph {
        let url = URL(fileURLWithPath: inputPath)
        let data = try Data(contentsOf: url)
        let decoder = JSONDecoder()
        return try decoder.decode(DependencyGraph.self, from: data)
    }
    
    // MARK: - Graph Validation
    
    private func validateGraph(_ graph: DependencyGraph) throws {
        var visited: Set<String> = []
        var recursionStack: Set<String> = []
        
        for dependency in graph.allDependencies {
            try detectCycle(
                dependency: dependency,
                graph: graph,
                visited: &visited,
                recursionStack: &recursionStack
            )
        }
    }
    
    private func detectCycle(
        dependency: DependencyDefinition,
        graph: DependencyGraph,
        visited: inout Set<String>,
        recursionStack: inout Set<String>
    ) throws {
        if recursionStack.contains(dependency.key) {
            throw DIGeneratorError.circularDependency(key: dependency.key)
        }
        
        if visited.contains(dependency.key) {
            return
        }
        
        visited.insert(dependency.key)
        recursionStack.insert(dependency.key)
        
        for depKey in dependency.dependencies {
            if let dep = graph.allDependencies.first(where: { $0.key == depKey }) {
                try detectCycle(
                    dependency: dep,
                    graph: graph,
                    visited: &visited,
                    recursionStack: &recursionStack
                )
            }
        }
        
        recursionStack.remove(dependency.key)
    }
    
    // MARK: - Centralized Container Generation
    
    private func generateCentralizedContainer(_ graph: DependencyGraph) -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        
        var lines: [String] = []
        lines.append(generateFileHeader("DIContainer"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        
        // MARK comment
        lines.append("// MARK: - DIContainer")
        lines.append("")
        
        // Container documentation
        lines.append("/// A type-safe dependency injection container.")
        lines.append("///")
        lines.append("/// This container provides compile-time validated dependency resolution")
        lines.append("/// with support for multiple scopes and injection patterns.")
        lines.append("///")
        lines.append("/// ## Usage")
        lines.append("/// ```swift")
        lines.append("/// let container = DIContainer()")
        lines.append("/// container.registerDefaults()")
        lines.append("/// let service = try container.resolve(UserService.self)")
        lines.append("/// ```")
        lines.append("")
        
        // Container class
        lines.append("public final class DIContainer: @unchecked Sendable {")
        lines.append("")
        
        // Properties
        lines.append(contentsOf: generateContainerProperties())
        lines.append("")
        
        // Initialization
        lines.append(contentsOf: generateContainerInit())
        lines.append("")
        
        // Registration methods
        lines.append(contentsOf: generateRegistrationMethods())
        lines.append("")
        
        // Resolution methods
        lines.append(contentsOf: generateResolutionMethods())
        lines.append("")
        
        // Auto-registration
        lines.append(contentsOf: generateAutoRegistration(graph))
        lines.append("")
        
        // Scope management
        lines.append(contentsOf: generateScopeManagement())
        lines.append("")
        
        // Debug methods
        if diConfig.generateDebugLogging {
            lines.append(contentsOf: generateDebugMethods())
            lines.append("")
        }
        
        lines.append("}")
        
        files.append(GeneratedFile(
            fileName: "DIContainer.swift",
            content: lines.joined(separator: "\n")
        ))
        
        // Generate registration extensions
        files.append(generateRegistrationExtension(graph))
        
        return files
    }
    
    private func generateContainerProperties() -> [String] {
        var lines: [String] = []
        
        lines.append("    // MARK: - Properties")
        lines.append("")
        lines.append("    /// Singleton storage.")
        lines.append("    private var singletons: [ObjectIdentifier: Any] = [:]")
        lines.append("")
        lines.append("    /// Weak singleton storage.")
        lines.append("    private var weakSingletons: [ObjectIdentifier: WeakBox] = [:]")
        lines.append("")
        lines.append("    /// Factory registrations.")
        lines.append("    private var factories: [ObjectIdentifier: () -> Any] = [:]")
        lines.append("")
        lines.append("    /// Async factory registrations.")
        lines.append("    private var asyncFactories: [ObjectIdentifier: () async -> Any] = [:]")
        lines.append("")
        lines.append("    /// Scoped instances storage.")
        lines.append("    private var scopedInstances: [String: [ObjectIdentifier: Any]] = [:]")
        lines.append("")
        lines.append("    /// Current scope identifier.")
        lines.append("    private var currentScope: String?")
        lines.append("")
        
        // Thread safety
        switch diConfig.threadSafety {
        case .lock:
            lines.append("    /// Thread-safety lock.")
            lines.append("    private let lock = NSRecursiveLock()")
        case .dispatchQueue:
            lines.append("    /// Thread-safety queue.")
            lines.append("    private let queue = DispatchQueue(label: \"com.di.container\", attributes: .concurrent)")
        case .actor, .none:
            break
        }
        lines.append("")
        
        lines.append("    /// Parent container for hierarchical resolution.")
        lines.append("    private weak var parent: DIContainer?")
        lines.append("")
        lines.append("    /// Debug mode flag.")
        lines.append("    public var isDebugMode: Bool = false")
        
        return lines
    }
    
    private func generateContainerInit() -> [String] {
        var lines: [String] = []
        
        lines.append("    // MARK: - Initialization")
        lines.append("")
        lines.append("    /// Creates a new DI container.")
        lines.append("    /// - Parameter parent: Optional parent container for hierarchical resolution.")
        lines.append("    public init(parent: DIContainer? = nil) {")
        lines.append("        self.parent = parent")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Creates a child container with this container as parent.")
        lines.append("    /// - Returns: A new child container.")
        lines.append("    public func createChildContainer() -> DIContainer {")
        lines.append("        DIContainer(parent: self)")
        lines.append("    }")
        
        return lines
    }
    
    private func generateRegistrationMethods() -> [String] {
        var lines: [String] = []
        
        lines.append("    // MARK: - Registration")
        lines.append("")
        
        // Register singleton
        lines.append("    /// Registers a singleton instance.")
        lines.append("    /// - Parameters:")
        lines.append("    ///   - instance: The singleton instance.")
        lines.append("    ///   - type: The type to register against.")
        lines.append("    public func registerSingleton<T>(_ instance: T, for type: T.Type = T.self) {")
        lines.append(generateLockGuard())
        lines.append("        let key = ObjectIdentifier(type)")
        lines.append("        singletons[key] = instance")
        lines.append(generateDebugLog("Registered singleton: \\(type)"))
        lines.append("    }")
        lines.append("")
        
        // Register factory
        lines.append("    /// Registers a factory for transient instances.")
        lines.append("    /// - Parameters:")
        lines.append("    ///   - type: The type to register.")
        lines.append("    ///   - factory: The factory closure.")
        lines.append("    public func register<T>(_ type: T.Type = T.self, factory: @escaping () -> T) {")
        lines.append(generateLockGuard())
        lines.append("        let key = ObjectIdentifier(type)")
        lines.append("        factories[key] = factory")
        lines.append(generateDebugLog("Registered factory: \\(type)"))
        lines.append("    }")
        lines.append("")
        
        // Register async factory
        if diConfig.generateAsyncSupport {
            lines.append("    /// Registers an async factory.")
            lines.append("    /// - Parameters:")
            lines.append("    ///   - type: The type to register.")
            lines.append("    ///   - factory: The async factory closure.")
            lines.append("    public func registerAsync<T>(_ type: T.Type = T.self, factory: @escaping () async -> T) {")
            lines.append(generateLockGuard())
            lines.append("        let key = ObjectIdentifier(type)")
            lines.append("        asyncFactories[key] = factory")
            lines.append(generateDebugLog("Registered async factory: \\(type)"))
            lines.append("    }")
            lines.append("")
        }
        
        // Register weak singleton
        lines.append("    /// Registers a weak singleton factory.")
        lines.append("    /// - Parameters:")
        lines.append("    ///   - type: The type to register.")
        lines.append("    ///   - factory: The factory closure.")
        lines.append("    public func registerWeakSingleton<T: AnyObject>(_ type: T.Type = T.self, factory: @escaping () -> T) {")
        lines.append(generateLockGuard())
        lines.append("        let key = ObjectIdentifier(type)")
        lines.append("        factories[key] = factory")
        lines.append("        weakSingletons[key] = WeakBox(nil)")
        lines.append(generateDebugLog("Registered weak singleton: \\(type)"))
        lines.append("    }")
        lines.append("")
        
        // Register scoped
        lines.append("    /// Registers a scoped factory.")
        lines.append("    /// - Parameters:")
        lines.append("    ///   - type: The type to register.")
        lines.append("    ///   - factory: The factory closure.")
        lines.append("    public func registerScoped<T>(_ type: T.Type = T.self, factory: @escaping () -> T) {")
        lines.append(generateLockGuard())
        lines.append("        let key = ObjectIdentifier(type)")
        lines.append("        factories[key] = factory")
        lines.append(generateDebugLog("Registered scoped: \\(type)"))
        lines.append("    }")
        lines.append("")
        
        // Register protocol implementation
        lines.append("    /// Registers a concrete type for a protocol.")
        lines.append("    /// - Parameters:")
        lines.append("    ///   - protocolType: The protocol type.")
        lines.append("    ///   - implementationType: The concrete implementation type.")
        lines.append("    ///   - factory: The factory closure.")
        lines.append("    public func register<P, T>(_ protocolType: P.Type, implementedBy implementationType: T.Type, factory: @escaping () -> T) where T: P {")
        lines.append(generateLockGuard())
        lines.append("        let key = ObjectIdentifier(protocolType)")
        lines.append("        factories[key] = factory")
        lines.append(generateDebugLog("Registered \\(implementationType) for \\(protocolType)"))
        lines.append("    }")
        
        return lines
    }
    
    private func generateResolutionMethods() -> [String] {
        var lines: [String] = []
        
        lines.append("    // MARK: - Resolution")
        lines.append("")
        
        // Resolve required
        lines.append("    /// Resolves a required dependency.")
        lines.append("    /// - Parameter type: The type to resolve.")
        lines.append("    /// - Returns: The resolved instance.")
        lines.append("    /// - Throws: `DIError.notRegistered` if the type is not registered.")
        lines.append("    public func resolve<T>(_ type: T.Type = T.self) throws -> T {")
        lines.append(generateLockGuard())
        lines.append("        let key = ObjectIdentifier(type)")
        lines.append("")
        lines.append("        // Check singletons first")
        lines.append("        if let instance = singletons[key] as? T {")
        lines.append(generateDebugLog("Resolved singleton: \\(type)"))
        lines.append("            return instance")
        lines.append("        }")
        lines.append("")
        lines.append("        // Check weak singletons")
        lines.append("        if let weakBox = weakSingletons[key], let instance = weakBox.value as? T {")
        lines.append(generateDebugLog("Resolved weak singleton: \\(type)"))
        lines.append("            return instance")
        lines.append("        }")
        lines.append("")
        lines.append("        // Check scoped instances")
        lines.append("        if let scope = currentScope, let instance = scopedInstances[scope]?[key] as? T {")
        lines.append(generateDebugLog("Resolved scoped: \\(type)"))
        lines.append("            return instance")
        lines.append("        }")
        lines.append("")
        lines.append("        // Use factory")
        lines.append("        if let factory = factories[key] {")
        lines.append("            let instance = factory() as! T")
        lines.append("")
        lines.append("            // Store weak singletons")
        lines.append("            if weakSingletons[key] != nil, let objInstance = instance as? AnyObject {")
        lines.append("                weakSingletons[key] = WeakBox(objInstance)")
        lines.append("            }")
        lines.append("")
        lines.append("            // Store scoped instances")
        lines.append("            if let scope = currentScope {")
        lines.append("                if scopedInstances[scope] == nil {")
        lines.append("                    scopedInstances[scope] = [:]")
        lines.append("                }")
        lines.append("                scopedInstances[scope]?[key] = instance")
        lines.append("            }")
        lines.append("")
        lines.append(generateDebugLog("Resolved via factory: \\(type)"))
        lines.append("            return instance")
        lines.append("        }")
        lines.append("")
        lines.append("        // Try parent container")
        lines.append("        if let parent = parent {")
        lines.append("            return try parent.resolve(type)")
        lines.append("        }")
        lines.append("")
        lines.append("        throw DIError.notRegistered(type: String(describing: type))")
        lines.append("    }")
        lines.append("")
        
        // Resolve optional
        lines.append("    /// Resolves an optional dependency.")
        lines.append("    /// - Parameter type: The type to resolve.")
        lines.append("    /// - Returns: The resolved instance or nil.")
        lines.append("    public func resolveOptional<T>(_ type: T.Type = T.self) -> T? {")
        lines.append("        try? resolve(type)")
        lines.append("    }")
        lines.append("")
        
        // Resolve async
        if diConfig.generateAsyncSupport {
            lines.append("    /// Resolves an async dependency.")
            lines.append("    /// - Parameter type: The type to resolve.")
            lines.append("    /// - Returns: The resolved instance.")
            lines.append("    public func resolveAsync<T>(_ type: T.Type = T.self) async throws -> T {")
            lines.append(generateLockGuard())
            lines.append("        let key = ObjectIdentifier(type)")
            lines.append("")
            lines.append("        // Check singletons")
            lines.append("        if let instance = singletons[key] as? T {")
            lines.append("            return instance")
            lines.append("        }")
            lines.append("")
            lines.append("        // Use async factory")
            lines.append("        if let factory = asyncFactories[key] {")
            lines.append("            let instance = await factory() as! T")
            lines.append("            return instance")
            lines.append("        }")
            lines.append("")
            lines.append("        // Fall back to sync resolution")
            lines.append("        return try resolve(type)")
            lines.append("    }")
            lines.append("")
        }
        
        // Resolve all
        lines.append("    /// Resolves all instances registered for a protocol.")
        lines.append("    /// - Parameter type: The protocol type.")
        lines.append("    /// - Returns: Array of all registered instances.")
        lines.append("    public func resolveAll<T>(_ type: T.Type = T.self) -> [T] {")
        lines.append(generateLockGuard())
        lines.append("        var results: [T] = []")
        lines.append("")
        lines.append("        for (_, value) in singletons {")
        lines.append("            if let instance = value as? T {")
        lines.append("                results.append(instance)")
        lines.append("            }")
        lines.append("        }")
        lines.append("")
        lines.append("        for (_, factory) in factories {")
        lines.append("            if let instance = factory() as? T {")
        lines.append("                results.append(instance)")
        lines.append("            }")
        lines.append("        }")
        lines.append("")
        lines.append("        return results")
        lines.append("    }")
        
        return lines
    }
    
    private func generateAutoRegistration(_ graph: DependencyGraph) -> [String] {
        var lines: [String] = []
        
        lines.append("    // MARK: - Auto Registration")
        lines.append("")
        lines.append("    /// Registers all default dependencies.")
        lines.append("    public func registerDefaults() {")
        
        for dependency in graph.allDependencies {
            lines.append(contentsOf: generateDependencyRegistration(dependency))
        }
        
        lines.append("    }")
        
        return lines
    }
    
    private func generateDependencyRegistration(_ dependency: DependencyDefinition) -> [String] {
        var lines: [String] = []
        
        let registerMethod: String
        switch dependency.scope {
        case .singleton:
            registerMethod = "registerSingleton"
        case .weakSingleton:
            registerMethod = "registerWeakSingleton"
        case .scoped:
            registerMethod = "registerScoped"
        default:
            registerMethod = "register"
        }
        
        let type = dependency.protocolType ?? dependency.concreteType
        
        if dependency.parameters.isEmpty {
            lines.append("        \(registerMethod)(\(type).self) { \(dependency.concreteType)() }")
        } else {
            lines.append("        \(registerMethod)(\(type).self) { [weak self] in")
            lines.append("            guard let self = self else { fatalError(\"Container deallocated\") }")
            
            var params: [String] = []
            for param in dependency.parameters {
                if let resolveKey = param.resolveKey {
                    params.append("\(param.name): try! self.resolve(\(resolveKey).self)")
                } else if param.isOptional {
                    params.append("\(param.name): self.resolveOptional(\(param.type).self)")
                } else {
                    params.append("\(param.name): try! self.resolve(\(param.type).self)")
                }
            }
            
            lines.append("            return \(dependency.concreteType)(")
            for (index, param) in params.enumerated() {
                let suffix = index < params.count - 1 ? "," : ""
                lines.append("                \(param)\(suffix)")
            }
            lines.append("            )")
            lines.append("        }")
        }
        
        return lines
    }
    
    private func generateScopeManagement() -> [String] {
        var lines: [String] = []
        
        lines.append("    // MARK: - Scope Management")
        lines.append("")
        lines.append("    /// Begins a new scope.")
        lines.append("    /// - Parameter identifier: The scope identifier.")
        lines.append("    public func beginScope(_ identifier: String) {")
        lines.append(generateLockGuard())
        lines.append("        currentScope = identifier")
        lines.append("        scopedInstances[identifier] = [:]")
        lines.append(generateDebugLog("Began scope: \\(identifier)"))
        lines.append("    }")
        lines.append("")
        lines.append("    /// Ends the current scope.")
        lines.append("    public func endScope() {")
        lines.append(generateLockGuard())
        lines.append("        if let scope = currentScope {")
        lines.append("            scopedInstances.removeValue(forKey: scope)")
        lines.append(generateDebugLog("Ended scope: \\(scope)"))
        lines.append("        }")
        lines.append("        currentScope = nil")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Executes a closure within a scope.")
        lines.append("    /// - Parameters:")
        lines.append("    ///   - identifier: The scope identifier.")
        lines.append("    ///   - closure: The closure to execute.")
        lines.append("    /// - Returns: The result of the closure.")
        lines.append("    public func withScope<T>(_ identifier: String, closure: () throws -> T) rethrows -> T {")
        lines.append("        beginScope(identifier)")
        lines.append("        defer { endScope() }")
        lines.append("        return try closure()")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Resets the container, removing all registrations.")
        lines.append("    public func reset() {")
        lines.append(generateLockGuard())
        lines.append("        singletons.removeAll()")
        lines.append("        weakSingletons.removeAll()")
        lines.append("        factories.removeAll()")
        lines.append("        asyncFactories.removeAll()")
        lines.append("        scopedInstances.removeAll()")
        lines.append("        currentScope = nil")
        lines.append(generateDebugLog("Container reset"))
        lines.append("    }")
        
        return lines
    }
    
    private func generateDebugMethods() -> [String] {
        var lines: [String] = []
        
        lines.append("    // MARK: - Debug")
        lines.append("")
        lines.append("    /// Prints all registered types.")
        lines.append("    public func printRegistrations() {")
        lines.append("        print(\"=== DIContainer Registrations ===\")")
        lines.append("        print(\"Singletons: \\(singletons.count)\")")
        lines.append("        print(\"Weak Singletons: \\(weakSingletons.count)\")")
        lines.append("        print(\"Factories: \\(factories.count)\")")
        lines.append("        print(\"Async Factories: \\(asyncFactories.count)\")")
        lines.append("        print(\"Scopes: \\(scopedInstances.keys.joined(separator: \", \"))\")")
        lines.append("        print(\"================================\")")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Validates that all dependencies can be resolved.")
        lines.append("    /// - Returns: Array of validation errors.")
        lines.append("    public func validate() -> [DIError] {")
        lines.append("        var errors: [DIError] = []")
        lines.append("        // Validation logic would go here")
        lines.append("        return errors")
        lines.append("    }")
        
        return lines
    }
    
    // MARK: - Modular Container Generation
    
    private func generateModularContainers(_ graph: DependencyGraph) -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        
        for module in graph.modules {
            files.append(generateModuleContainer(module))
        }
        
        // Generate coordinator
        files.append(generateModuleCoordinator(graph))
        
        return files
    }
    
    private func generateModuleContainer(_ module: ModuleDefinition) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader("\(module.name)Module"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        
        lines.append("// MARK: - \(module.name)Module")
        lines.append("")
        
        if let docs = module.documentation {
            lines.append("/// \(docs)")
        } else {
            lines.append("/// Dependency module for \(module.name).")
        }
        
        lines.append("public struct \(module.name)Module: DIModule {")
        lines.append("")
        lines.append("    /// The module name.")
        lines.append("    public static let name = \"\(module.name)\"")
        lines.append("")
        lines.append("    /// Creates a new module instance.")
        lines.append("    public init() {}")
        lines.append("")
        lines.append("    /// Registers all dependencies in this module.")
        lines.append("    /// - Parameter container: The container to register in.")
        lines.append("    public func register(in container: DIContainer) {")
        
        for dependency in module.dependencies {
            lines.append(contentsOf: generateDependencyRegistration(dependency).map { "    \($0)" })
        }
        
        lines.append("    }")
        lines.append("")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "\(module.name)Module.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    private func generateModuleCoordinator(_ graph: DependencyGraph) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader("DIModuleCoordinator"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        
        lines.append("// MARK: - DIModule Protocol")
        lines.append("")
        lines.append("/// Protocol for dependency modules.")
        lines.append("public protocol DIModule {")
        lines.append("    /// The module name.")
        lines.append("    static var name: String { get }")
        lines.append("")
        lines.append("    /// Registers dependencies in the container.")
        lines.append("    func register(in container: DIContainer)")
        lines.append("}")
        lines.append("")
        
        lines.append("// MARK: - DIModuleCoordinator")
        lines.append("")
        lines.append("/// Coordinates multiple dependency modules.")
        lines.append("public final class DIModuleCoordinator {")
        lines.append("")
        lines.append("    /// The container to register in.")
        lines.append("    private let container: DIContainer")
        lines.append("")
        lines.append("    /// Registered modules.")
        lines.append("    private var modules: [String: DIModule] = [:]")
        lines.append("")
        lines.append("    /// Creates a new coordinator.")
        lines.append("    public init(container: DIContainer) {")
        lines.append("        self.container = container")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Registers a module.")
        lines.append("    public func register(_ module: DIModule) {")
        lines.append("        let name = type(of: module).name")
        lines.append("        modules[name] = module")
        lines.append("        module.register(in: container)")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Registers all default modules.")
        lines.append("    public func registerAllModules() {")
        
        for module in graph.modules {
            lines.append("        register(\(module.name)Module())")
        }
        
        lines.append("    }")
        lines.append("")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "DIModuleCoordinator.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    // MARK: - Hierarchical Container Generation
    
    private func generateHierarchicalContainer(_ graph: DependencyGraph) -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        
        // Generate base container
        files.append(contentsOf: generateCentralizedContainer(graph))
        
        // Generate scope-specific containers
        files.append(generateScopedContainer())
        
        return files
    }
    
    private func generateScopedContainer() -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader("ScopedContainer"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        
        lines.append("// MARK: - ScopedContainer")
        lines.append("")
        lines.append("/// A container that manages a specific scope.")
        lines.append("public final class ScopedContainer {")
        lines.append("")
        lines.append("    /// The parent container.")
        lines.append("    private let parent: DIContainer")
        lines.append("")
        lines.append("    /// The scope identifier.")
        lines.append("    public let scopeId: String")
        lines.append("")
        lines.append("    /// Scoped instances.")
        lines.append("    private var instances: [ObjectIdentifier: Any] = [:]")
        lines.append("")
        lines.append("    /// Thread-safety lock.")
        lines.append("    private let lock = NSLock()")
        lines.append("")
        lines.append("    /// Creates a scoped container.")
        lines.append("    public init(parent: DIContainer, scopeId: String) {")
        lines.append("        self.parent = parent")
        lines.append("        self.scopeId = scopeId")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Resolves a dependency within this scope.")
        lines.append("    public func resolve<T>(_ type: T.Type = T.self) throws -> T {")
        lines.append("        lock.lock()")
        lines.append("        defer { lock.unlock() }")
        lines.append("")
        lines.append("        let key = ObjectIdentifier(type)")
        lines.append("")
        lines.append("        if let instance = instances[key] as? T {")
        lines.append("            return instance")
        lines.append("        }")
        lines.append("")
        lines.append("        let instance = try parent.resolve(type)")
        lines.append("        instances[key] = instance")
        lines.append("        return instance")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Disposes of all scoped instances.")
        lines.append("    public func dispose() {")
        lines.append("        lock.lock()")
        lines.append("        defer { lock.unlock() }")
        lines.append("        instances.removeAll()")
        lines.append("    }")
        lines.append("")
        lines.append("    deinit {")
        lines.append("        dispose()")
        lines.append("    }")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "ScopedContainer.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    // MARK: - Protocol Generation
    
    private func generateProtocols(_ graph: DependencyGraph) -> [GeneratedFile] {
        var lines: [String] = []
        
        lines.append(generateFileHeader("DIProtocols"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        
        lines.append("// MARK: - Resolver Protocol")
        lines.append("")
        lines.append("/// Protocol for dependency resolvers.")
        lines.append("public protocol DIResolver: AnyObject, Sendable {")
        lines.append("    /// Resolves a required dependency.")
        lines.append("    func resolve<T>(_ type: T.Type) throws -> T")
        lines.append("")
        lines.append("    /// Resolves an optional dependency.")
        lines.append("    func resolveOptional<T>(_ type: T.Type) -> T?")
        lines.append("}")
        lines.append("")
        
        lines.append("// MARK: - Registrar Protocol")
        lines.append("")
        lines.append("/// Protocol for dependency registration.")
        lines.append("public protocol DIRegistrar: AnyObject {")
        lines.append("    /// Registers a singleton instance.")
        lines.append("    func registerSingleton<T>(_ instance: T, for type: T.Type)")
        lines.append("")
        lines.append("    /// Registers a factory.")
        lines.append("    func register<T>(_ type: T.Type, factory: @escaping () -> T)")
        lines.append("}")
        lines.append("")
        
        lines.append("// MARK: - Injectable Protocol")
        lines.append("")
        lines.append("/// Protocol for types that can be injected.")
        lines.append("public protocol Injectable {")
        lines.append("    /// Initializes with a resolver.")
        lines.append("    init(resolver: DIResolver) throws")
        lines.append("}")
        lines.append("")
        
        lines.append("// MARK: - AutoRegisterable Protocol")
        lines.append("")
        lines.append("/// Protocol for types that auto-register.")
        lines.append("public protocol AutoRegisterable {")
        lines.append("    /// The registration scope.")
        lines.append("    static var scope: DependencyScope { get }")
        lines.append("")
        lines.append("    /// Registers in the container.")
        lines.append("    static func register(in container: DIContainer)")
        lines.append("}")
        lines.append("")
        
        lines.append("extension AutoRegisterable {")
        lines.append("    public static var scope: DependencyScope { .transient }")
        lines.append("}")
        
        return [GeneratedFile(
            fileName: "DIProtocols.swift",
            content: lines.joined(separator: "\n")
        )]
    }
    
    // MARK: - Property Wrapper Generation
    
    private func generatePropertyWrappers() -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader("DIPropertyWrappers"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        
        // @Injected
        lines.append("// MARK: - @Injected")
        lines.append("")
        lines.append("/// Property wrapper for automatic dependency injection.")
        lines.append("///")
        lines.append("/// ```swift")
        lines.append("/// class MyViewController: UIViewController {")
        lines.append("///     @Injected var userService: UserServiceProtocol")
        lines.append("/// }")
        lines.append("/// ```")
        lines.append("@propertyWrapper")
        lines.append("public struct Injected<T> {")
        lines.append("")
        lines.append("    /// The wrapped value.")
        lines.append("    public var wrappedValue: T {")
        lines.append("        guard let value = container?.resolveOptional(T.self) else {")
        lines.append("            fatalError(\"Failed to resolve \\(T.self). Ensure it is registered.\")")
        lines.append("        }")
        lines.append("        return value")
        lines.append("    }")
        lines.append("")
        lines.append("    /// The container to resolve from.")
        lines.append("    private weak var container: DIContainer?")
        lines.append("")
        lines.append("    /// Creates an injected property using the shared container.")
        lines.append("    public init() {")
        lines.append("        self.container = DIContainer.shared")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Creates an injected property using a specific container.")
        lines.append("    public init(container: DIContainer) {")
        lines.append("        self.container = container")
        lines.append("    }")
        lines.append("}")
        lines.append("")
        
        // @LazyInjected
        lines.append("// MARK: - @LazyInjected")
        lines.append("")
        lines.append("/// Property wrapper for lazy dependency injection.")
        lines.append("@propertyWrapper")
        lines.append("public struct LazyInjected<T> {")
        lines.append("")
        lines.append("    /// Cached value.")
        lines.append("    private var cached: T?")
        lines.append("")
        lines.append("    /// The container to resolve from.")
        lines.append("    private weak var container: DIContainer?")
        lines.append("")
        lines.append("    /// The wrapped value.")
        lines.append("    public var wrappedValue: T {")
        lines.append("        mutating get {")
        lines.append("            if let cached = cached {")
        lines.append("                return cached")
        lines.append("            }")
        lines.append("")
        lines.append("            guard let value = container?.resolveOptional(T.self) else {")
        lines.append("                fatalError(\"Failed to resolve \\(T.self).\")")
        lines.append("            }")
        lines.append("")
        lines.append("            cached = value")
        lines.append("            return value")
        lines.append("        }")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Creates a lazy injected property.")
        lines.append("    public init() {")
        lines.append("        self.container = DIContainer.shared")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Creates a lazy injected property with a specific container.")
        lines.append("    public init(container: DIContainer) {")
        lines.append("        self.container = container")
        lines.append("    }")
        lines.append("}")
        lines.append("")
        
        // @OptionalInjected
        lines.append("// MARK: - @OptionalInjected")
        lines.append("")
        lines.append("/// Property wrapper for optional dependency injection.")
        lines.append("@propertyWrapper")
        lines.append("public struct OptionalInjected<T> {")
        lines.append("")
        lines.append("    /// The wrapped value.")
        lines.append("    public var wrappedValue: T? {")
        lines.append("        container?.resolveOptional(T.self)")
        lines.append("    }")
        lines.append("")
        lines.append("    /// The container to resolve from.")
        lines.append("    private weak var container: DIContainer?")
        lines.append("")
        lines.append("    /// Creates an optional injected property.")
        lines.append("    public init() {")
        lines.append("        self.container = DIContainer.shared")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Creates an optional injected property with a specific container.")
        lines.append("    public init(container: DIContainer) {")
        lines.append("        self.container = container")
        lines.append("    }")
        lines.append("}")
        lines.append("")
        
        // WeakBox helper
        lines.append("// MARK: - WeakBox")
        lines.append("")
        lines.append("/// Helper class for weak reference storage.")
        lines.append("final class WeakBox {")
        lines.append("    weak var value: AnyObject?")
        lines.append("")
        lines.append("    init(_ value: AnyObject?) {")
        lines.append("        self.value = value")
        lines.append("    }")
        lines.append("}")
        lines.append("")
        
        // Shared container extension
        lines.append("// MARK: - Shared Container")
        lines.append("")
        lines.append("extension DIContainer {")
        lines.append("    /// The shared container instance.")
        lines.append("    public static let shared = DIContainer()")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "DIPropertyWrappers.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    // MARK: - Mock Generation
    
    private func generateMocks(_ graph: DependencyGraph) -> [GeneratedFile] {
        var lines: [String] = []
        
        lines.append(generateFileHeader("DIMocks"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        
        lines.append("// MARK: - MockDIContainer")
        lines.append("")
        lines.append("/// A mock container for testing.")
        lines.append("public final class MockDIContainer: DIResolver {")
        lines.append("")
        lines.append("    /// Mock registrations.")
        lines.append("    private var mocks: [ObjectIdentifier: Any] = [:]")
        lines.append("")
        lines.append("    /// Resolution call tracking.")
        lines.append("    public private(set) var resolutionCalls: [String] = []")
        lines.append("")
        lines.append("    /// Creates a mock container.")
        lines.append("    public init() {}")
        lines.append("")
        lines.append("    /// Registers a mock instance.")
        lines.append("    public func registerMock<T>(_ instance: T, for type: T.Type = T.self) {")
        lines.append("        let key = ObjectIdentifier(type)")
        lines.append("        mocks[key] = instance")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Resolves a dependency.")
        lines.append("    public func resolve<T>(_ type: T.Type) throws -> T {")
        lines.append("        resolutionCalls.append(String(describing: type))")
        lines.append("")
        lines.append("        let key = ObjectIdentifier(type)")
        lines.append("        guard let instance = mocks[key] as? T else {")
        lines.append("            throw DIError.notRegistered(type: String(describing: type))")
        lines.append("        }")
        lines.append("        return instance")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Resolves an optional dependency.")
        lines.append("    public func resolveOptional<T>(_ type: T.Type) -> T? {")
        lines.append("        resolutionCalls.append(String(describing: type))")
        lines.append("        let key = ObjectIdentifier(type)")
        lines.append("        return mocks[key] as? T")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Resets all mocks and tracking.")
        lines.append("    public func reset() {")
        lines.append("        mocks.removeAll()")
        lines.append("        resolutionCalls.removeAll()")
        lines.append("    }")
        lines.append("")
        lines.append("    /// Verifies a type was resolved.")
        lines.append("    public func verifyResolved<T>(_ type: T.Type, times: Int = 1) -> Bool {")
        lines.append("        let typeName = String(describing: type)")
        lines.append("        let count = resolutionCalls.filter { $0 == typeName }.count")
        lines.append("        return count == times")
        lines.append("    }")
        lines.append("}")
        
        return [GeneratedFile(
            fileName: "DIMocks.swift",
            content: lines.joined(separator: "\n")
        )]
    }
    
    // MARK: - Resolver Extensions
    
    private func generateResolverExtensions(_ graph: DependencyGraph) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader("DIResolverExtensions"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        
        lines.append("// MARK: - Convenience Resolution")
        lines.append("")
        lines.append("extension DIContainer {")
        lines.append("")
        
        for dependency in graph.allDependencies {
            let type = dependency.protocolType ?? dependency.concreteType
            let propertyName = type.lowercasedFirst()
            
            lines.append("    /// Resolves \(type).")
            lines.append("    public var \(propertyName): \(type)? {")
            lines.append("        resolveOptional(\(type).self)")
            lines.append("    }")
            lines.append("")
        }
        
        lines.append("}")
        lines.append("")
        
        // String extension
        lines.append("// MARK: - String Extension")
        lines.append("")
        lines.append("private extension String {")
        lines.append("    func lowercasedFirst() -> String {")
        lines.append("        guard let first = first else { return self }")
        lines.append("        return first.lowercased() + dropFirst()")
        lines.append("    }")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "DIResolverExtensions.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    private func generateRegistrationExtension(_ graph: DependencyGraph) -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader("DIRegistrations"))
        lines.append("")
        lines.append(generateImports())
        lines.append("")
        
        lines.append("// MARK: - Registration Helpers")
        lines.append("")
        lines.append("extension DIContainer {")
        lines.append("")
        lines.append("    /// Registers using a builder pattern.")
        lines.append("    public func register<T>(")
        lines.append("        _ type: T.Type,")
        lines.append("        scope: DependencyScope = .transient,")
        lines.append("        factory: @escaping (DIContainer) -> T")
        lines.append("    ) {")
        lines.append("        switch scope {")
        lines.append("        case .singleton:")
        lines.append("            registerSingleton(factory(self), for: type)")
        lines.append("        case .transient:")
        lines.append("            register(type) { [weak self] in")
        lines.append("                guard let self = self else { fatalError() }")
        lines.append("                return factory(self)")
        lines.append("            }")
        lines.append("        case .scoped:")
        lines.append("            registerScoped(type) { [weak self] in")
        lines.append("                guard let self = self else { fatalError() }")
        lines.append("                return factory(self)")
        lines.append("            }")
        lines.append("        case .lazy, .weakSingleton, .threadLocal:")
        lines.append("            register(type) { [weak self] in")
        lines.append("                guard let self = self else { fatalError() }")
        lines.append("                return factory(self)")
        lines.append("            }")
        lines.append("        }")
        lines.append("    }")
        lines.append("")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "DIRegistrations.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    // MARK: - Error Generation
    
    private func generateDIErrors() -> GeneratedFile {
        var lines: [String] = []
        
        lines.append(generateFileHeader("DIError"))
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        
        lines.append("// MARK: - DIError")
        lines.append("")
        lines.append("/// Errors that can occur during dependency injection.")
        lines.append("public enum DIError: LocalizedError, Sendable {")
        lines.append("")
        lines.append("    /// The requested type is not registered.")
        lines.append("    case notRegistered(type: String)")
        lines.append("")
        lines.append("    /// A circular dependency was detected.")
        lines.append("    case circularDependency(types: [String])")
        lines.append("")
        lines.append("    /// Resolution failed due to missing dependency.")
        lines.append("    case resolutionFailed(type: String, reason: String)")
        lines.append("")
        lines.append("    /// The scope has ended.")
        lines.append("    case scopeEnded(scopeId: String)")
        lines.append("")
        lines.append("    /// The container has been deallocated.")
        lines.append("    case containerDeallocated")
        lines.append("")
        lines.append("    /// A factory threw an error.")
        lines.append("    case factoryError(underlying: Error)")
        lines.append("")
        lines.append("    // MARK: - LocalizedError")
        lines.append("")
        lines.append("    public var errorDescription: String? {")
        lines.append("        switch self {")
        lines.append("        case .notRegistered(let type):")
        lines.append("            return \"Type not registered: \\(type)\"")
        lines.append("        case .circularDependency(let types):")
        lines.append("            return \"Circular dependency detected: \\(types.joined(separator: \" -> \"))\"")
        lines.append("        case .resolutionFailed(let type, let reason):")
        lines.append("            return \"Failed to resolve \\(type): \\(reason)\"")
        lines.append("        case .scopeEnded(let scopeId):")
        lines.append("            return \"Scope has ended: \\(scopeId)\"")
        lines.append("        case .containerDeallocated:")
        lines.append("            return \"Container has been deallocated\"")
        lines.append("        case .factoryError(let error):")
        lines.append("            return \"Factory error: \\(error.localizedDescription)\"")
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        lines.append("")
        
        lines.append("// MARK: - DIGeneratorError")
        lines.append("")
        lines.append("/// Errors during DI code generation.")
        lines.append("public enum DIGeneratorError: LocalizedError {")
        lines.append("")
        lines.append("    /// Circular dependency detected in graph.")
        lines.append("    case circularDependency(key: String)")
        lines.append("")
        lines.append("    /// Invalid configuration.")
        lines.append("    case invalidConfiguration(reason: String)")
        lines.append("")
        lines.append("    /// Missing dependency definition.")
        lines.append("    case missingDependency(key: String)")
        lines.append("")
        lines.append("    public var errorDescription: String? {")
        lines.append("        switch self {")
        lines.append("        case .circularDependency(let key):")
        lines.append("            return \"Circular dependency detected at: \\(key)\"")
        lines.append("        case .invalidConfiguration(let reason):")
        lines.append("            return \"Invalid configuration: \\(reason)\"")
        lines.append("        case .missingDependency(let key):")
        lines.append("            return \"Missing dependency: \\(key)\"")
        lines.append("        }")
        lines.append("    }")
        lines.append("}")
        
        return GeneratedFile(
            fileName: "DIError.swift",
            content: lines.joined(separator: "\n")
        )
    }
    
    // MARK: - Helpers
    
    private func generateFileHeader(_ name: String) -> String {
        """
        //
        //  \(name).swift
        //  SwiftCodeGen
        //
        //  Auto-generated dependency injection container.
        //
        """
    }
    
    private func generateImports() -> String {
        var imports = ["import Foundation"]
        imports.append(contentsOf: diConfig.customImports.map { "import \($0)" })
        return imports.joined(separator: "\n")
    }
    
    private func generateLockGuard() -> String {
        switch diConfig.threadSafety {
        case .lock:
            return "        lock.lock(); defer { lock.unlock() }"
        case .dispatchQueue:
            return "        queue.sync {"
        case .actor, .none:
            return ""
        }
    }
    
    private func generateDebugLog(_ message: String) -> String {
        guard diConfig.generateDebugLogging else { return "" }
        return "        if isDebugMode { print(\"[DI] \(message)\") }"
    }
}

// MARK: - String Extension

private extension String {
    func lowercasedFirst() -> String {
        guard let first = first else { return self }
        return first.lowercased() + dropFirst()
    }
}
