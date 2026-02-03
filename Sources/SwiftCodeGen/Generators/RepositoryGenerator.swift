import Foundation

// MARK: - Repository Pattern Configuration

/// Configuration options for repository generation.
public struct RepositoryConfig: Codable, Sendable {
    
    /// The naming convention for repository protocols.
    public enum ProtocolNaming: String, Codable, Sendable {
        case suffix = "Repository"
        case prefix = "I"
        case both = "IRepository"
    }
    
    /// The data source type for the repository.
    public enum DataSourceType: String, Codable, Sendable {
        case coreData = "CoreData"
        case realm = "Realm"
        case userDefaults = "UserDefaults"
        case fileSystem = "FileSystem"
        case keychain = "Keychain"
        case inMemory = "InMemory"
        case network = "Network"
        case combined = "Combined"
    }
    
    /// Whether to generate async/await methods.
    public var useAsync: Bool
    
    /// Whether to generate Combine publishers.
    public var useCombine: Bool
    
    /// The protocol naming convention.
    public var protocolNaming: ProtocolNaming
    
    /// The data source type.
    public var dataSourceType: DataSourceType
    
    /// Whether to generate CRUD operations.
    public var generateCRUD: Bool
    
    /// Whether to generate batch operations.
    public var generateBatchOperations: Bool
    
    /// Whether to generate query builders.
    public var generateQueryBuilder: Bool
    
    /// Whether to generate caching layer.
    public var generateCaching: Bool
    
    /// Whether to generate unit of work pattern.
    public var generateUnitOfWork: Bool
    
    /// Custom imports to include.
    public var customImports: [String]
    
    /// Creates a new repository configuration.
    public init(
        useAsync: Bool = true,
        useCombine: Bool = true,
        protocolNaming: ProtocolNaming = .suffix,
        dataSourceType: DataSourceType = .combined,
        generateCRUD: Bool = true,
        generateBatchOperations: Bool = true,
        generateQueryBuilder: Bool = true,
        generateCaching: Bool = false,
        generateUnitOfWork: Bool = false,
        customImports: [String] = []
    ) {
        self.useAsync = useAsync
        self.useCombine = useCombine
        self.protocolNaming = protocolNaming
        self.dataSourceType = dataSourceType
        self.generateCRUD = generateCRUD
        self.generateBatchOperations = generateBatchOperations
        self.generateQueryBuilder = generateQueryBuilder
        self.generateCaching = generateCaching
        self.generateUnitOfWork = generateUnitOfWork
        self.customImports = customImports
    }
}

// MARK: - Entity Definition

/// Represents an entity for repository generation.
public struct EntityDefinition: Codable, Sendable {
    
    /// A property of the entity.
    public struct Property: Codable, Sendable {
        public let name: String
        public let type: String
        public let isOptional: Bool
        public let isPrimaryKey: Bool
        public let isIndexed: Bool
        public let defaultValue: String?
        public let attributes: [String]
        
        public init(
            name: String,
            type: String,
            isOptional: Bool = false,
            isPrimaryKey: Bool = false,
            isIndexed: Bool = false,
            defaultValue: String? = nil,
            attributes: [String] = []
        ) {
            self.name = name
            self.type = type
            self.isOptional = isOptional
            self.isPrimaryKey = isPrimaryKey
            self.isIndexed = isIndexed
            self.defaultValue = defaultValue
            self.attributes = attributes
        }
    }
    
    /// A relationship to another entity.
    public struct Relationship: Codable, Sendable {
        public enum RelationType: String, Codable, Sendable {
            case oneToOne
            case oneToMany
            case manyToMany
        }
        
        public let name: String
        public let targetEntity: String
        public let relationType: RelationType
        public let inverseName: String?
        public let cascadeDelete: Bool
        
        public init(
            name: String,
            targetEntity: String,
            relationType: RelationType,
            inverseName: String? = nil,
            cascadeDelete: Bool = false
        ) {
            self.name = name
            self.targetEntity = targetEntity
            self.relationType = relationType
            self.inverseName = inverseName
            self.cascadeDelete = cascadeDelete
        }
    }
    
    public let name: String
    public let properties: [Property]
    public let relationships: [Relationship]
    public let conformances: [String]
    
    public init(
        name: String,
        properties: [Property],
        relationships: [Relationship] = [],
        conformances: [String] = []
    ) {
        self.name = name
        self.properties = properties
        self.relationships = relationships
        self.conformances = conformances
    }
    
    /// Returns the primary key property if exists.
    public var primaryKey: Property? {
        properties.first { $0.isPrimaryKey }
    }
    
    /// Returns indexed properties.
    public var indexedProperties: [Property] {
        properties.filter { $0.isIndexed }
    }
}

// MARK: - Repository Generator

/// Generates repository pattern implementations for data access layer.
///
/// The `RepositoryGenerator` creates protocol definitions, concrete implementations,
/// and supporting types for the repository pattern. It supports multiple data sources
/// and provides options for async/await, Combine, caching, and more.
///
/// ## Overview
///
/// Use this generator to create a clean data access layer following the repository pattern:
///
/// ```swift
/// let generator = RepositoryGenerator(
///     entities: [userEntity, productEntity],
///     outputPath: "Sources/Repositories",
///     config: .init(useAsync: true, useCombine: true)
/// )
/// let files = try generator.generate()
/// ```
///
/// ## Generated Components
///
/// - Repository protocols defining data access contracts
/// - Concrete repository implementations
/// - Query builder for complex queries
/// - Caching layer (optional)
/// - Unit of Work pattern (optional)
public final class RepositoryGenerator: CodeGenerator {
    
    // MARK: - Properties
    
    public let generatorType = "repository"
    public let inputPath: String
    public let outputPath: String
    
    private let entities: [EntityDefinition]
    private let repoConfig: RepositoryConfig
    private let codeGenConfig: CodeGenConfig
    
    // MARK: - Initialization
    
    /// Creates a new repository generator.
    /// - Parameters:
    ///   - entities: The entity definitions to generate repositories for.
    ///   - outputPath: The output directory path.
    ///   - repoConfig: Repository-specific configuration.
    ///   - codeGenConfig: General code generation configuration.
    public init(
        entities: [EntityDefinition],
        outputPath: String,
        repoConfig: RepositoryConfig = RepositoryConfig(),
        codeGenConfig: CodeGenConfig = CodeGenConfig()
    ) {
        self.entities = entities
        self.inputPath = ""
        self.outputPath = outputPath
        self.repoConfig = repoConfig
        self.codeGenConfig = codeGenConfig
    }
    
    /// Creates a new repository generator from JSON input.
    public init(inputPath: String, outputPath: String, config: CodeGenConfig) {
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.codeGenConfig = config
        self.repoConfig = RepositoryConfig()
        self.entities = []
    }
    
    // MARK: - Generation
    
    public func generate() throws -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        
        // Load entities from input path if needed
        let entitiesToGenerate = entities.isEmpty ? try loadEntities() : entities
        
        // Generate base protocols
        files.append(generateBaseRepository())
        files.append(generateRepositoryError())
        
        // Generate query builder if enabled
        if repoConfig.generateQueryBuilder {
            files.append(generateQueryBuilder())
            files.append(generateSortDescriptor())
            files.append(generatePredicate())
        }
        
        // Generate caching layer if enabled
        if repoConfig.generateCaching {
            files.append(generateCacheProtocol())
            files.append(generateInMemoryCache())
            files.append(generateCachePolicy())
        }
        
        // Generate unit of work if enabled
        if repoConfig.generateUnitOfWork {
            files.append(generateUnitOfWork())
            files.append(generateTransactionManager())
        }
        
        // Generate repository for each entity
        for entity in entitiesToGenerate {
            files.append(generateRepositoryProtocol(for: entity))
            files.append(generateRepositoryImplementation(for: entity))
            
            if repoConfig.generateCaching {
                files.append(generateCachedRepository(for: entity))
            }
        }
        
        // Generate data source implementations
        files.append(contentsOf: generateDataSources())
        
        return files
    }
    
    // MARK: - Entity Loading
    
    private func loadEntities() throws -> [EntityDefinition] {
        guard !inputPath.isEmpty else { return [] }
        
        let url = URL(fileURLWithPath: inputPath)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([EntityDefinition].self, from: data)
    }
    
    // MARK: - Base Repository Generation
    
    private func generateBaseRepository() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        if repoConfig.useCombine {
            lines.append("import Combine")
        }
        for customImport in repoConfig.customImports {
            lines.append("import \(customImport)")
        }
        lines.append("")
        
        // Base repository protocol
        lines.append("// MARK: - Base Repository Protocol")
        lines.append("")
        lines.append("/// A protocol defining the base contract for all repositories.")
        lines.append("///")
        lines.append("/// Repositories provide a clean abstraction for data access,")
        lines.append("/// hiding the details of how data is stored and retrieved.")
        lines.append("public protocol Repository {")
        lines.append("")
        lines.append("\(indent)/// The type of entity managed by this repository.")
        lines.append("\(indent)associatedtype Entity: Identifiable")
        lines.append("")
        lines.append("\(indent)/// The type used for entity identifiers.")
        lines.append("\(indent)associatedtype ID: Hashable")
        lines.append("")
        
        // CRUD operations
        if repoConfig.generateCRUD {
            lines.append("\(indent)// MARK: - CRUD Operations")
            lines.append("")
            
            if repoConfig.useAsync {
                lines.append("\(indent)/// Retrieves an entity by its identifier.")
                lines.append("\(indent)/// - Parameter id: The unique identifier of the entity.")
                lines.append("\(indent)/// - Returns: The entity if found, nil otherwise.")
                lines.append("\(indent)func get(by id: ID) async throws -> Entity?")
                lines.append("")
                lines.append("\(indent)/// Retrieves all entities.")
                lines.append("\(indent)/// - Returns: An array of all entities.")
                lines.append("\(indent)func getAll() async throws -> [Entity]")
                lines.append("")
                lines.append("\(indent)/// Saves an entity to the repository.")
                lines.append("\(indent)/// - Parameter entity: The entity to save.")
                lines.append("\(indent)/// - Returns: The saved entity.")
                lines.append("\(indent)@discardableResult")
                lines.append("\(indent)func save(_ entity: Entity) async throws -> Entity")
                lines.append("")
                lines.append("\(indent)/// Updates an existing entity.")
                lines.append("\(indent)/// - Parameter entity: The entity with updated values.")
                lines.append("\(indent)/// - Returns: The updated entity.")
                lines.append("\(indent)@discardableResult")
                lines.append("\(indent)func update(_ entity: Entity) async throws -> Entity")
                lines.append("")
                lines.append("\(indent)/// Deletes an entity by its identifier.")
                lines.append("\(indent)/// - Parameter id: The identifier of the entity to delete.")
                lines.append("\(indent)func delete(by id: ID) async throws")
                lines.append("")
                lines.append("\(indent)/// Checks if an entity exists with the given identifier.")
                lines.append("\(indent)/// - Parameter id: The identifier to check.")
                lines.append("\(indent)/// - Returns: True if the entity exists.")
                lines.append("\(indent)func exists(by id: ID) async throws -> Bool")
                lines.append("")
                lines.append("\(indent)/// Returns the count of all entities.")
                lines.append("\(indent)/// - Returns: The total count.")
                lines.append("\(indent)func count() async throws -> Int")
            }
            
            lines.append("")
        }
        
        // Batch operations
        if repoConfig.generateBatchOperations {
            lines.append("\(indent)// MARK: - Batch Operations")
            lines.append("")
            
            if repoConfig.useAsync {
                lines.append("\(indent)/// Retrieves entities by their identifiers.")
                lines.append("\(indent)/// - Parameter ids: The identifiers to fetch.")
                lines.append("\(indent)/// - Returns: An array of found entities.")
                lines.append("\(indent)func get(by ids: [ID]) async throws -> [Entity]")
                lines.append("")
                lines.append("\(indent)/// Saves multiple entities.")
                lines.append("\(indent)/// - Parameter entities: The entities to save.")
                lines.append("\(indent)/// - Returns: The saved entities.")
                lines.append("\(indent)@discardableResult")
                lines.append("\(indent)func saveAll(_ entities: [Entity]) async throws -> [Entity]")
                lines.append("")
                lines.append("\(indent)/// Deletes multiple entities by their identifiers.")
                lines.append("\(indent)/// - Parameter ids: The identifiers of entities to delete.")
                lines.append("\(indent)func deleteAll(by ids: [ID]) async throws")
                lines.append("")
                lines.append("\(indent)/// Deletes all entities in the repository.")
                lines.append("\(indent)func deleteAll() async throws")
            }
            
            lines.append("")
        }
        
        lines.append("}")
        lines.append("")
        
        // Observable repository extension
        if repoConfig.useCombine {
            lines.append("// MARK: - Observable Repository")
            lines.append("")
            lines.append("/// A repository that provides reactive streams for data changes.")
            lines.append("public protocol ObservableRepository: Repository {")
            lines.append("")
            lines.append("\(indent)/// A publisher that emits when the repository content changes.")
            lines.append("\(indent)var changesPublisher: AnyPublisher<RepositoryChange<Entity>, Never> { get }")
            lines.append("")
            lines.append("\(indent)/// Observes a specific entity by its identifier.")
            lines.append("\(indent)/// - Parameter id: The identifier of the entity to observe.")
            lines.append("\(indent)/// - Returns: A publisher that emits the entity on changes.")
            lines.append("\(indent)func observe(by id: ID) -> AnyPublisher<Entity?, Never>")
            lines.append("")
            lines.append("\(indent)/// Observes all entities in the repository.")
            lines.append("\(indent)/// - Returns: A publisher that emits all entities on changes.")
            lines.append("\(indent)func observeAll() -> AnyPublisher<[Entity], Never>")
            lines.append("")
            lines.append("}")
            lines.append("")
            
            // Repository change enum
            lines.append("/// Represents a change in the repository.")
            lines.append("public enum RepositoryChange<Entity> {")
            lines.append("\(indent)case inserted(Entity)")
            lines.append("\(indent)case updated(Entity)")
            lines.append("\(indent)case deleted(Entity)")
            lines.append("\(indent)case reloaded([Entity])")
            lines.append("}")
            lines.append("")
        }
        
        // Specification pattern
        lines.append("// MARK: - Specification Pattern")
        lines.append("")
        lines.append("/// A specification that defines criteria for querying entities.")
        lines.append("public protocol Specification {")
        lines.append("\(indent)associatedtype Entity")
        lines.append("")
        lines.append("\(indent)/// Determines if an entity satisfies this specification.")
        lines.append("\(indent)/// - Parameter entity: The entity to check.")
        lines.append("\(indent)/// - Returns: True if the entity satisfies the specification.")
        lines.append("\(indent)func isSatisfied(by entity: Entity) -> Bool")
        lines.append("")
        lines.append("\(indent)/// Converts the specification to a predicate.")
        lines.append("\(indent)/// - Returns: An NSPredicate representation.")
        lines.append("\(indent)func toPredicate() -> NSPredicate?")
        lines.append("}")
        lines.append("")
        
        // Default implementation
        lines.append("extension Specification {")
        lines.append("\(indent)public func toPredicate() -> NSPredicate? { nil }")
        lines.append("}")
        lines.append("")
        
        // Composite specification
        lines.append("/// A composite specification combining multiple specifications.")
        lines.append("public struct CompositeSpecification<Entity>: Specification {")
        lines.append("")
        lines.append("\(indent)private let predicate: (Entity) -> Bool")
        lines.append("\(indent)private let nsPredicate: NSPredicate?")
        lines.append("")
        lines.append("\(indent)public init(")
        lines.append("\(indent)\(indent)predicate: @escaping (Entity) -> Bool,")
        lines.append("\(indent)\(indent)nsPredicate: NSPredicate? = nil")
        lines.append("\(indent)) {")
        lines.append("\(indent)\(indent)self.predicate = predicate")
        lines.append("\(indent)\(indent)self.nsPredicate = nsPredicate")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func isSatisfied(by entity: Entity) -> Bool {")
        lines.append("\(indent)\(indent)predicate(entity)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func toPredicate() -> NSPredicate? {")
        lines.append("\(indent)\(indent)nsPredicate")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        // Specification operators
        lines.append("// MARK: - Specification Operators")
        lines.append("")
        lines.append("extension Specification {")
        lines.append("")
        lines.append("\(indent)/// Creates a specification that requires both specifications to be satisfied.")
        lines.append("\(indent)public func and<S: Specification>(_ other: S) -> CompositeSpecification<Entity> where S.Entity == Entity {")
        lines.append("\(indent)\(indent)let combinedPredicate: NSPredicate?")
        lines.append("\(indent)\(indent)if let p1 = toPredicate(), let p2 = other.toPredicate() {")
        lines.append("\(indent)\(indent)\(indent)combinedPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [p1, p2])")
        lines.append("\(indent)\(indent)} else {")
        lines.append("\(indent)\(indent)\(indent)combinedPredicate = toPredicate() ?? other.toPredicate()")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)\(indent)return CompositeSpecification(")
        lines.append("\(indent)\(indent)\(indent)predicate: { self.isSatisfied(by: $0) && other.isSatisfied(by: $0) },")
        lines.append("\(indent)\(indent)\(indent)nsPredicate: combinedPredicate")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Creates a specification that requires either specification to be satisfied.")
        lines.append("\(indent)public func or<S: Specification>(_ other: S) -> CompositeSpecification<Entity> where S.Entity == Entity {")
        lines.append("\(indent)\(indent)let combinedPredicate: NSPredicate?")
        lines.append("\(indent)\(indent)if let p1 = toPredicate(), let p2 = other.toPredicate() {")
        lines.append("\(indent)\(indent)\(indent)combinedPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: [p1, p2])")
        lines.append("\(indent)\(indent)} else {")
        lines.append("\(indent)\(indent)\(indent)combinedPredicate = nil")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)\(indent)return CompositeSpecification(")
        lines.append("\(indent)\(indent)\(indent)predicate: { self.isSatisfied(by: $0) || other.isSatisfied(by: $0) },")
        lines.append("\(indent)\(indent)\(indent)nsPredicate: combinedPredicate")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Creates a specification that negates this specification.")
        lines.append("\(indent)public func not() -> CompositeSpecification<Entity> {")
        lines.append("\(indent)\(indent)let negatedPredicate = toPredicate().map { NSCompoundPredicate(notPredicateWithSubpredicate: $0) }")
        lines.append("\(indent)\(indent)return CompositeSpecification(")
        lines.append("\(indent)\(indent)\(indent)predicate: { !self.isSatisfied(by: $0) },")
        lines.append("\(indent)\(indent)\(indent)nsPredicate: negatedPredicate")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "Repository.swift", content: lines.joined(separator: "\n"))
    }
    
    // MARK: - Error Generation
    
    private func generateRepositoryError() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Repository Errors")
        lines.append("")
        lines.append("/// Errors that can occur during repository operations.")
        lines.append("public enum RepositoryError: LocalizedError, Equatable {")
        lines.append("")
        lines.append("\(indent)/// The requested entity was not found.")
        lines.append("\(indent)case notFound(id: String)")
        lines.append("")
        lines.append("\(indent)/// An entity with the given identifier already exists.")
        lines.append("\(indent)case duplicateEntry(id: String)")
        lines.append("")
        lines.append("\(indent)/// The operation violated a constraint.")
        lines.append("\(indent)case constraintViolation(message: String)")
        lines.append("")
        lines.append("\(indent)/// A validation error occurred.")
        lines.append("\(indent)case validationFailed(field: String, message: String)")
        lines.append("")
        lines.append("\(indent)/// The data could not be serialized.")
        lines.append("\(indent)case serializationFailed(message: String)")
        lines.append("")
        lines.append("\(indent)/// The data could not be deserialized.")
        lines.append("\(indent)case deserializationFailed(message: String)")
        lines.append("")
        lines.append("\(indent)/// A database error occurred.")
        lines.append("\(indent)case databaseError(underlying: Error)")
        lines.append("")
        lines.append("\(indent)/// A network error occurred.")
        lines.append("\(indent)case networkError(underlying: Error)")
        lines.append("")
        lines.append("\(indent)/// The operation timed out.")
        lines.append("\(indent)case timeout(operation: String)")
        lines.append("")
        lines.append("\(indent)/// Access was denied.")
        lines.append("\(indent)case accessDenied(reason: String)")
        lines.append("")
        lines.append("\(indent)/// The repository is in an invalid state.")
        lines.append("\(indent)case invalidState(message: String)")
        lines.append("")
        lines.append("\(indent)/// A transaction error occurred.")
        lines.append("\(indent)case transactionFailed(message: String)")
        lines.append("")
        lines.append("\(indent)/// The operation was cancelled.")
        lines.append("\(indent)case cancelled")
        lines.append("")
        lines.append("\(indent)/// An unknown error occurred.")
        lines.append("\(indent)case unknown(underlying: Error?)")
        lines.append("")
        lines.append("\(indent)// MARK: - LocalizedError")
        lines.append("")
        lines.append("\(indent)public var errorDescription: String? {")
        lines.append("\(indent)\(indent)switch self {")
        lines.append("\(indent)\(indent)case .notFound(let id):")
        lines.append("\(indent)\(indent)\(indent)return \"Entity with id '\\(id)' was not found.\"")
        lines.append("\(indent)\(indent)case .duplicateEntry(let id):")
        lines.append("\(indent)\(indent)\(indent)return \"An entity with id '\\(id)' already exists.\"")
        lines.append("\(indent)\(indent)case .constraintViolation(let message):")
        lines.append("\(indent)\(indent)\(indent)return \"Constraint violation: \\(message)\"")
        lines.append("\(indent)\(indent)case .validationFailed(let field, let message):")
        lines.append("\(indent)\(indent)\(indent)return \"Validation failed for '\\(field)': \\(message)\"")
        lines.append("\(indent)\(indent)case .serializationFailed(let message):")
        lines.append("\(indent)\(indent)\(indent)return \"Serialization failed: \\(message)\"")
        lines.append("\(indent)\(indent)case .deserializationFailed(let message):")
        lines.append("\(indent)\(indent)\(indent)return \"Deserialization failed: \\(message)\"")
        lines.append("\(indent)\(indent)case .databaseError(let error):")
        lines.append("\(indent)\(indent)\(indent)return \"Database error: \\(error.localizedDescription)\"")
        lines.append("\(indent)\(indent)case .networkError(let error):")
        lines.append("\(indent)\(indent)\(indent)return \"Network error: \\(error.localizedDescription)\"")
        lines.append("\(indent)\(indent)case .timeout(let operation):")
        lines.append("\(indent)\(indent)\(indent)return \"Operation '\\(operation)' timed out.\"")
        lines.append("\(indent)\(indent)case .accessDenied(let reason):")
        lines.append("\(indent)\(indent)\(indent)return \"Access denied: \\(reason)\"")
        lines.append("\(indent)\(indent)case .invalidState(let message):")
        lines.append("\(indent)\(indent)\(indent)return \"Invalid state: \\(message)\"")
        lines.append("\(indent)\(indent)case .transactionFailed(let message):")
        lines.append("\(indent)\(indent)\(indent)return \"Transaction failed: \\(message)\"")
        lines.append("\(indent)\(indent)case .cancelled:")
        lines.append("\(indent)\(indent)\(indent)return \"Operation was cancelled.\"")
        lines.append("\(indent)\(indent)case .unknown(let error):")
        lines.append("\(indent)\(indent)\(indent)if let error = error {")
        lines.append("\(indent)\(indent)\(indent)\(indent)return \"Unknown error: \\(error.localizedDescription)\"")
        lines.append("\(indent)\(indent)\(indent)}")
        lines.append("\(indent)\(indent)\(indent)return \"An unknown error occurred.\"")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Equatable")
        lines.append("")
        lines.append("\(indent)public static func == (lhs: RepositoryError, rhs: RepositoryError) -> Bool {")
        lines.append("\(indent)\(indent)switch (lhs, rhs) {")
        lines.append("\(indent)\(indent)case (.notFound(let id1), .notFound(let id2)):")
        lines.append("\(indent)\(indent)\(indent)return id1 == id2")
        lines.append("\(indent)\(indent)case (.duplicateEntry(let id1), .duplicateEntry(let id2)):")
        lines.append("\(indent)\(indent)\(indent)return id1 == id2")
        lines.append("\(indent)\(indent)case (.constraintViolation(let m1), .constraintViolation(let m2)):")
        lines.append("\(indent)\(indent)\(indent)return m1 == m2")
        lines.append("\(indent)\(indent)case (.validationFailed(let f1, let m1), .validationFailed(let f2, let m2)):")
        lines.append("\(indent)\(indent)\(indent)return f1 == f2 && m1 == m2")
        lines.append("\(indent)\(indent)case (.timeout(let o1), .timeout(let o2)):")
        lines.append("\(indent)\(indent)\(indent)return o1 == o2")
        lines.append("\(indent)\(indent)case (.accessDenied(let r1), .accessDenied(let r2)):")
        lines.append("\(indent)\(indent)\(indent)return r1 == r2")
        lines.append("\(indent)\(indent)case (.cancelled, .cancelled):")
        lines.append("\(indent)\(indent)\(indent)return true")
        lines.append("\(indent)\(indent)default:")
        lines.append("\(indent)\(indent)\(indent)return false")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "RepositoryError.swift", content: lines.joined(separator: "\n"))
    }
    
    // MARK: - Query Builder Generation
    
    private func generateQueryBuilder() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Query Builder")
        lines.append("")
        lines.append("/// A fluent query builder for constructing complex queries.")
        lines.append("///")
        lines.append("/// Use the query builder to create type-safe queries with filtering,")
        lines.append("/// sorting, and pagination support.")
        lines.append("///")
        lines.append("/// ```swift")
        lines.append("/// let query = QueryBuilder<User>()")
        lines.append("///     .filter(\\.isActive, equals: true)")
        lines.append("///     .filter(\\.age, greaterThan: 18)")
        lines.append("///     .sort(\\.name, ascending: true)")
        lines.append("///     .limit(20)")
        lines.append("///     .offset(0)")
        lines.append("/// ```")
        lines.append("public final class QueryBuilder<Entity> {")
        lines.append("")
        lines.append("\(indent)// MARK: - Properties")
        lines.append("")
        lines.append("\(indent)private var filters: [QueryFilter] = []")
        lines.append("\(indent)private var sortDescriptors: [QuerySortDescriptor] = []")
        lines.append("\(indent)private var limitValue: Int?")
        lines.append("\(indent)private var offsetValue: Int?")
        lines.append("\(indent)private var distinctValue: Bool = false")
        lines.append("\(indent)private var includedRelationships: [String] = []")
        lines.append("")
        lines.append("\(indent)// MARK: - Initialization")
        lines.append("")
        lines.append("\(indent)/// Creates a new query builder.")
        lines.append("\(indent)public init() {}")
        lines.append("")
        lines.append("\(indent)// MARK: - Filtering")
        lines.append("")
        lines.append("\(indent)/// Adds an equality filter.")
        lines.append("\(indent)/// - Parameters:")
        lines.append("\(indent)///   - keyPath: The key path to filter on.")
        lines.append("\(indent)///   - value: The value to compare against.")
        lines.append("\(indent)/// - Returns: The query builder for chaining.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filter<Value: Equatable>(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, Value>,")
        lines.append("\(indent)\(indent)equals value: Value")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: .equals,")
        lines.append("\(indent)\(indent)\(indent)value: value")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds an inequality filter.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filter<Value: Equatable>(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, Value>,")
        lines.append("\(indent)\(indent)notEquals value: Value")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: .notEquals,")
        lines.append("\(indent)\(indent)\(indent)value: value")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds a greater than filter.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filter<Value: Comparable>(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, Value>,")
        lines.append("\(indent)\(indent)greaterThan value: Value")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: .greaterThan,")
        lines.append("\(indent)\(indent)\(indent)value: value")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds a greater than or equal filter.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filter<Value: Comparable>(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, Value>,")
        lines.append("\(indent)\(indent)greaterThanOrEquals value: Value")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: .greaterThanOrEquals,")
        lines.append("\(indent)\(indent)\(indent)value: value")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds a less than filter.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filter<Value: Comparable>(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, Value>,")
        lines.append("\(indent)\(indent)lessThan value: Value")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: .lessThan,")
        lines.append("\(indent)\(indent)\(indent)value: value")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds a less than or equal filter.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filter<Value: Comparable>(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, Value>,")
        lines.append("\(indent)\(indent)lessThanOrEquals value: Value")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: .lessThanOrEquals,")
        lines.append("\(indent)\(indent)\(indent)value: value")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds a contains filter for strings.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filter(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, String>,")
        lines.append("\(indent)\(indent)contains value: String,")
        lines.append("\(indent)\(indent)caseInsensitive: Bool = true")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: caseInsensitive ? .containsCaseInsensitive : .contains,")
        lines.append("\(indent)\(indent)\(indent)value: value")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds a prefix filter for strings.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filter(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, String>,")
        lines.append("\(indent)\(indent)startsWith value: String,")
        lines.append("\(indent)\(indent)caseInsensitive: Bool = true")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: caseInsensitive ? .startsWithCaseInsensitive : .startsWith,")
        lines.append("\(indent)\(indent)\(indent)value: value")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds a suffix filter for strings.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filter(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, String>,")
        lines.append("\(indent)\(indent)endsWith value: String,")
        lines.append("\(indent)\(indent)caseInsensitive: Bool = true")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: caseInsensitive ? .endsWithCaseInsensitive : .endsWith,")
        lines.append("\(indent)\(indent)\(indent)value: value")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds an \"in\" filter for checking membership.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filter<Value: Equatable>(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, Value>,")
        lines.append("\(indent)\(indent)in values: [Value]")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: .in,")
        lines.append("\(indent)\(indent)\(indent)value: values")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds a \"not in\" filter.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filter<Value: Equatable>(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, Value>,")
        lines.append("\(indent)\(indent)notIn values: [Value]")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: .notIn,")
        lines.append("\(indent)\(indent)\(indent)value: values")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds a null check filter.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filterIsNil<Value>(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, Value?>")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: .isNil,")
        lines.append("\(indent)\(indent)\(indent)value: nil as Any?")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds a not null check filter.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filterIsNotNil<Value>(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, Value?>")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: .isNotNil,")
        lines.append("\(indent)\(indent)\(indent)value: nil as Any?")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Adds a between filter for ranges.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func filter<Value: Comparable>(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, Value>,")
        lines.append("\(indent)\(indent)between lower: Value,")
        lines.append("\(indent)\(indent)and upper: Value")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let filter = QueryFilter(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)operation: .between,")
        lines.append("\(indent)\(indent)\(indent)value: [lower, upper]")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)filters.append(filter)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Sorting")
        lines.append("")
        lines.append("\(indent)/// Adds a sort descriptor.")
        lines.append("\(indent)/// - Parameters:")
        lines.append("\(indent)///   - keyPath: The key path to sort by.")
        lines.append("\(indent)///   - ascending: Whether to sort ascending (default: true).")
        lines.append("\(indent)/// - Returns: The query builder for chaining.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func sort<Value: Comparable>(")
        lines.append("\(indent)\(indent)_ keyPath: KeyPath<Entity, Value>,")
        lines.append("\(indent)\(indent)ascending: Bool = true")
        lines.append("\(indent)) -> Self {")
        lines.append("\(indent)\(indent)let descriptor = QuerySortDescriptor(")
        lines.append("\(indent)\(indent)\(indent)keyPath: keyPathString(keyPath),")
        lines.append("\(indent)\(indent)\(indent)ascending: ascending")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)\(indent)sortDescriptors.append(descriptor)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Pagination")
        lines.append("")
        lines.append("\(indent)/// Sets the maximum number of results to return.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func limit(_ value: Int) -> Self {")
        lines.append("\(indent)\(indent)limitValue = value")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Sets the number of results to skip.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func offset(_ value: Int) -> Self {")
        lines.append("\(indent)\(indent)offsetValue = value")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Sets pagination using page number and page size.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func page(_ page: Int, size: Int) -> Self {")
        lines.append("\(indent)\(indent)limitValue = size")
        lines.append("\(indent)\(indent)offsetValue = page * size")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Options")
        lines.append("")
        lines.append("\(indent)/// Marks the query as distinct.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func distinct() -> Self {")
        lines.append("\(indent)\(indent)distinctValue = true")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Includes a relationship for eager loading.")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func include(_ relationship: String) -> Self {")
        lines.append("\(indent)\(indent)includedRelationships.append(relationship)")
        lines.append("\(indent)\(indent)return self")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Build")
        lines.append("")
        lines.append("\(indent)/// Builds the query specification.")
        lines.append("\(indent)public func build() -> QuerySpecification<Entity> {")
        lines.append("\(indent)\(indent)QuerySpecification(")
        lines.append("\(indent)\(indent)\(indent)filters: filters,")
        lines.append("\(indent)\(indent)\(indent)sortDescriptors: sortDescriptors,")
        lines.append("\(indent)\(indent)\(indent)limit: limitValue,")
        lines.append("\(indent)\(indent)\(indent)offset: offsetValue,")
        lines.append("\(indent)\(indent)\(indent)distinct: distinctValue,")
        lines.append("\(indent)\(indent)\(indent)includedRelationships: includedRelationships")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Helpers")
        lines.append("")
        lines.append("\(indent)private func keyPathString<Value>(_ keyPath: KeyPath<Entity, Value>) -> String {")
        lines.append("\(indent)\(indent)String(describing: keyPath)")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - Query Specification")
        lines.append("")
        lines.append("/// A compiled query specification ready for execution.")
        lines.append("public struct QuerySpecification<Entity> {")
        lines.append("\(indent)public let filters: [QueryFilter]")
        lines.append("\(indent)public let sortDescriptors: [QuerySortDescriptor]")
        lines.append("\(indent)public let limit: Int?")
        lines.append("\(indent)public let offset: Int?")
        lines.append("\(indent)public let distinct: Bool")
        lines.append("\(indent)public let includedRelationships: [String]")
        lines.append("")
        lines.append("\(indent)/// Converts to NSPredicate.")
        lines.append("\(indent)public func toPredicate() -> NSPredicate? {")
        lines.append("\(indent)\(indent)guard !filters.isEmpty else { return nil }")
        lines.append("\(indent)\(indent)let predicates = filters.compactMap { $0.toPredicate() }")
        lines.append("\(indent)\(indent)return NSCompoundPredicate(andPredicateWithSubpredicates: predicates)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Converts to NSSortDescriptors.")
        lines.append("\(indent)public func toSortDescriptors() -> [NSSortDescriptor] {")
        lines.append("\(indent)\(indent)sortDescriptors.map { $0.toNSSortDescriptor() }")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "QueryBuilder.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateSortDescriptor() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Query Sort Descriptor")
        lines.append("")
        lines.append("/// A descriptor for sorting query results.")
        lines.append("public struct QuerySortDescriptor: Sendable {")
        lines.append("")
        lines.append("\(indent)/// The key path to sort by.")
        lines.append("\(indent)public let keyPath: String")
        lines.append("")
        lines.append("\(indent)/// Whether to sort in ascending order.")
        lines.append("\(indent)public let ascending: Bool")
        lines.append("")
        lines.append("\(indent)/// Creates a new sort descriptor.")
        lines.append("\(indent)public init(keyPath: String, ascending: Bool = true) {")
        lines.append("\(indent)\(indent)self.keyPath = keyPath")
        lines.append("\(indent)\(indent)self.ascending = ascending")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Converts to NSSortDescriptor.")
        lines.append("\(indent)public func toNSSortDescriptor() -> NSSortDescriptor {")
        lines.append("\(indent)\(indent)NSSortDescriptor(key: keyPath, ascending: ascending)")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "QuerySortDescriptor.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generatePredicate() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Query Filter")
        lines.append("")
        lines.append("/// A filter for query operations.")
        lines.append("public struct QueryFilter: Sendable {")
        lines.append("")
        lines.append("\(indent)/// The filter operation type.")
        lines.append("\(indent)public enum Operation: String, Sendable {")
        lines.append("\(indent)\(indent)case equals = \"==\"")
        lines.append("\(indent)\(indent)case notEquals = \"!=\"")
        lines.append("\(indent)\(indent)case greaterThan = \">\"")
        lines.append("\(indent)\(indent)case greaterThanOrEquals = \">=\"")
        lines.append("\(indent)\(indent)case lessThan = \"<\"")
        lines.append("\(indent)\(indent)case lessThanOrEquals = \"<=\"")
        lines.append("\(indent)\(indent)case contains = \"CONTAINS\"")
        lines.append("\(indent)\(indent)case containsCaseInsensitive = \"CONTAINS[c]\"")
        lines.append("\(indent)\(indent)case startsWith = \"BEGINSWITH\"")
        lines.append("\(indent)\(indent)case startsWithCaseInsensitive = \"BEGINSWITH[c]\"")
        lines.append("\(indent)\(indent)case endsWith = \"ENDSWITH\"")
        lines.append("\(indent)\(indent)case endsWithCaseInsensitive = \"ENDSWITH[c]\"")
        lines.append("\(indent)\(indent)case `in` = \"IN\"")
        lines.append("\(indent)\(indent)case notIn = \"NOT IN\"")
        lines.append("\(indent)\(indent)case isNil = \"== nil\"")
        lines.append("\(indent)\(indent)case isNotNil = \"!= nil\"")
        lines.append("\(indent)\(indent)case between = \"BETWEEN\"")
        lines.append("\(indent)\(indent)case like = \"LIKE\"")
        lines.append("\(indent)\(indent)case matches = \"MATCHES\"")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// The key path to filter on.")
        lines.append("\(indent)public let keyPath: String")
        lines.append("")
        lines.append("\(indent)/// The filter operation.")
        lines.append("\(indent)public let operation: Operation")
        lines.append("")
        lines.append("\(indent)/// The value to compare against.")
        lines.append("\(indent)public let value: Any?")
        lines.append("")
        lines.append("\(indent)/// Creates a new query filter.")
        lines.append("\(indent)public init(keyPath: String, operation: Operation, value: Any?) {")
        lines.append("\(indent)\(indent)self.keyPath = keyPath")
        lines.append("\(indent)\(indent)self.operation = operation")
        lines.append("\(indent)\(indent)self.value = value")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Converts to NSPredicate.")
        lines.append("\(indent)public func toPredicate() -> NSPredicate? {")
        lines.append("\(indent)\(indent)switch operation {")
        lines.append("\(indent)\(indent)case .equals:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K == %@\", keyPath, value as? CVarArg ?? NSNull())")
        lines.append("\(indent)\(indent)case .notEquals:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K != %@\", keyPath, value as? CVarArg ?? NSNull())")
        lines.append("\(indent)\(indent)case .greaterThan:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K > %@\", keyPath, value as? CVarArg ?? NSNull())")
        lines.append("\(indent)\(indent)case .greaterThanOrEquals:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K >= %@\", keyPath, value as? CVarArg ?? NSNull())")
        lines.append("\(indent)\(indent)case .lessThan:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K < %@\", keyPath, value as? CVarArg ?? NSNull())")
        lines.append("\(indent)\(indent)case .lessThanOrEquals:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K <= %@\", keyPath, value as? CVarArg ?? NSNull())")
        lines.append("\(indent)\(indent)case .contains:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K CONTAINS %@\", keyPath, value as? CVarArg ?? \"\")")
        lines.append("\(indent)\(indent)case .containsCaseInsensitive:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K CONTAINS[c] %@\", keyPath, value as? CVarArg ?? \"\")")
        lines.append("\(indent)\(indent)case .startsWith:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K BEGINSWITH %@\", keyPath, value as? CVarArg ?? \"\")")
        lines.append("\(indent)\(indent)case .startsWithCaseInsensitive:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K BEGINSWITH[c] %@\", keyPath, value as? CVarArg ?? \"\")")
        lines.append("\(indent)\(indent)case .endsWith:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K ENDSWITH %@\", keyPath, value as? CVarArg ?? \"\")")
        lines.append("\(indent)\(indent)case .endsWithCaseInsensitive:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K ENDSWITH[c] %@\", keyPath, value as? CVarArg ?? \"\")")
        lines.append("\(indent)\(indent)case .in:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K IN %@\", keyPath, value as? [Any] ?? [])")
        lines.append("\(indent)\(indent)case .notIn:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"NOT (%K IN %@)\", keyPath, value as? [Any] ?? [])")
        lines.append("\(indent)\(indent)case .isNil:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K == nil\", keyPath)")
        lines.append("\(indent)\(indent)case .isNotNil:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K != nil\", keyPath)")
        lines.append("\(indent)\(indent)case .between:")
        lines.append("\(indent)\(indent)\(indent)guard let bounds = value as? [Any], bounds.count == 2 else { return nil }")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K BETWEEN %@\", keyPath, bounds)")
        lines.append("\(indent)\(indent)case .like:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K LIKE %@\", keyPath, value as? CVarArg ?? \"\")")
        lines.append("\(indent)\(indent)case .matches:")
        lines.append("\(indent)\(indent)\(indent)return NSPredicate(format: \"%K MATCHES %@\", keyPath, value as? CVarArg ?? \"\")")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "QueryFilter.swift", content: lines.joined(separator: "\n"))
    }
    
    // MARK: - Caching Generation
    
    private func generateCacheProtocol() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Cache Protocol")
        lines.append("")
        lines.append("/// A protocol defining cache operations for repository caching.")
        lines.append("public protocol CacheProtocol {")
        lines.append("")
        lines.append("\(indent)/// The type of cached entity.")
        lines.append("\(indent)associatedtype Entity")
        lines.append("")
        lines.append("\(indent)/// The type used for cache keys.")
        lines.append("\(indent)associatedtype Key: Hashable")
        lines.append("")
        lines.append("\(indent)/// Retrieves an entity from the cache.")
        lines.append("\(indent)func get(for key: Key) -> Entity?")
        lines.append("")
        lines.append("\(indent)/// Stores an entity in the cache.")
        lines.append("\(indent)func set(_ entity: Entity, for key: Key)")
        lines.append("")
        lines.append("\(indent)/// Removes an entity from the cache.")
        lines.append("\(indent)func remove(for key: Key)")
        lines.append("")
        lines.append("\(indent)/// Clears all cached entities.")
        lines.append("\(indent)func clear()")
        lines.append("")
        lines.append("\(indent)/// Checks if an entity exists in the cache.")
        lines.append("\(indent)func contains(key: Key) -> Bool")
        lines.append("")
        lines.append("\(indent)/// Returns the number of cached entities.")
        lines.append("\(indent)var count: Int { get }")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "CacheProtocol.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateInMemoryCache() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - In-Memory Cache")
        lines.append("")
        lines.append("/// An in-memory cache implementation with optional TTL support.")
        lines.append("public final class InMemoryCache<Key: Hashable, Entity>: CacheProtocol, @unchecked Sendable {")
        lines.append("")
        lines.append("\(indent)// MARK: - Types")
        lines.append("")
        lines.append("\(indent)private struct CacheEntry {")
        lines.append("\(indent)\(indent)let entity: Entity")
        lines.append("\(indent)\(indent)let expirationDate: Date?")
        lines.append("")
        lines.append("\(indent)\(indent)var isExpired: Bool {")
        lines.append("\(indent)\(indent)\(indent)guard let expiration = expirationDate else { return false }")
        lines.append("\(indent)\(indent)\(indent)return Date() > expiration")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Properties")
        lines.append("")
        lines.append("\(indent)private var cache: [Key: CacheEntry] = [:]")
        lines.append("\(indent)private let lock = NSLock()")
        lines.append("\(indent)private let maxSize: Int?")
        lines.append("\(indent)private let defaultTTL: TimeInterval?")
        lines.append("")
        lines.append("\(indent)public var count: Int {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("\(indent)\(indent)return cache.count")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Initialization")
        lines.append("")
        lines.append("\(indent)/// Creates a new in-memory cache.")
        lines.append("\(indent)/// - Parameters:")
        lines.append("\(indent)///   - maxSize: Optional maximum number of entries.")
        lines.append("\(indent)///   - defaultTTL: Optional default time-to-live for entries.")
        lines.append("\(indent)public init(maxSize: Int? = nil, defaultTTL: TimeInterval? = nil) {")
        lines.append("\(indent)\(indent)self.maxSize = maxSize")
        lines.append("\(indent)\(indent)self.defaultTTL = defaultTTL")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - CacheProtocol")
        lines.append("")
        lines.append("\(indent)public func get(for key: Key) -> Entity? {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("")
        lines.append("\(indent)\(indent)guard let entry = cache[key] else { return nil }")
        lines.append("")
        lines.append("\(indent)\(indent)if entry.isExpired {")
        lines.append("\(indent)\(indent)\(indent)cache.removeValue(forKey: key)")
        lines.append("\(indent)\(indent)\(indent)return nil")
        lines.append("\(indent)\(indent)}")
        lines.append("")
        lines.append("\(indent)\(indent)return entry.entity")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func set(_ entity: Entity, for key: Key) {")
        lines.append("\(indent)\(indent)set(entity, for: key, ttl: defaultTTL)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Stores an entity with a specific TTL.")
        lines.append("\(indent)public func set(_ entity: Entity, for key: Key, ttl: TimeInterval?) {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("")
        lines.append("\(indent)\(indent)// Evict if at capacity")
        lines.append("\(indent)\(indent)if let maxSize = maxSize, cache.count >= maxSize {")
        lines.append("\(indent)\(indent)\(indent)evictOldest()")
        lines.append("\(indent)\(indent)}")
        lines.append("")
        lines.append("\(indent)\(indent)let expirationDate = ttl.map { Date().addingTimeInterval($0) }")
        lines.append("\(indent)\(indent)cache[key] = CacheEntry(entity: entity, expirationDate: expirationDate)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func remove(for key: Key) {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("\(indent)\(indent)cache.removeValue(forKey: key)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func clear() {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("\(indent)\(indent)cache.removeAll()")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func contains(key: Key) -> Bool {")
        lines.append("\(indent)\(indent)get(for: key) != nil")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Maintenance")
        lines.append("")
        lines.append("\(indent)/// Removes expired entries from the cache.")
        lines.append("\(indent)public func removeExpired() {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("")
        lines.append("\(indent)\(indent)cache = cache.filter { !$0.value.isExpired }")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)private func evictOldest() {")
        lines.append("\(indent)\(indent)// Simple FIFO eviction - remove first key")
        lines.append("\(indent)\(indent)if let firstKey = cache.keys.first {")
        lines.append("\(indent)\(indent)\(indent)cache.removeValue(forKey: firstKey)")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "InMemoryCache.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateCachePolicy() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Cache Policy")
        lines.append("")
        lines.append("/// Defines the caching policy for repository operations.")
        lines.append("public enum CachePolicy: Sendable {")
        lines.append("")
        lines.append("\(indent)/// Always fetch from cache if available.")
        lines.append("\(indent)case cacheFirst")
        lines.append("")
        lines.append("\(indent)/// Always fetch from the source, then update cache.")
        lines.append("\(indent)case networkFirst")
        lines.append("")
        lines.append("\(indent)/// Only use cache, never fetch from source.")
        lines.append("\(indent)case cacheOnly")
        lines.append("")
        lines.append("\(indent)/// Only fetch from source, don't use cache.")
        lines.append("\(indent)case networkOnly")
        lines.append("")
        lines.append("\(indent)/// Fetch from cache, but refresh in background.")
        lines.append("\(indent)case staleWhileRevalidate")
        lines.append("")
        lines.append("\(indent)/// Use cache if not older than the given interval.")
        lines.append("\(indent)case cacheWithMaxAge(TimeInterval)")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "CachePolicy.swift", content: lines.joined(separator: "\n"))
    }
    
    // MARK: - Unit of Work Generation
    
    private func generateUnitOfWork() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Unit of Work")
        lines.append("")
        lines.append("/// A protocol for managing transactions across multiple repositories.")
        lines.append("///")
        lines.append("/// The Unit of Work pattern maintains a list of objects affected by a")
        lines.append("/// business transaction and coordinates the writing out of changes.")
        lines.append("public protocol UnitOfWork {")
        lines.append("")
        lines.append("\(indent)/// Begins a new transaction.")
        lines.append("\(indent)func begin() async throws")
        lines.append("")
        lines.append("\(indent)/// Commits all pending changes.")
        lines.append("\(indent)func commit() async throws")
        lines.append("")
        lines.append("\(indent)/// Rolls back all pending changes.")
        lines.append("\(indent)func rollback() async throws")
        lines.append("")
        lines.append("\(indent)/// Registers an entity for insertion.")
        lines.append("\(indent)func registerNew<T>(_ entity: T)")
        lines.append("")
        lines.append("\(indent)/// Registers an entity for update.")
        lines.append("\(indent)func registerDirty<T>(_ entity: T)")
        lines.append("")
        lines.append("\(indent)/// Registers an entity for deletion.")
        lines.append("\(indent)func registerDeleted<T>(_ entity: T)")
        lines.append("")
        lines.append("\(indent)/// Registers an entity as clean (unchanged).")
        lines.append("\(indent)func registerClean<T>(_ entity: T)")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "UnitOfWork.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateTransactionManager() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Transaction Manager")
        lines.append("")
        lines.append("/// Manages database transactions with automatic rollback on failure.")
        lines.append("public final class TransactionManager: @unchecked Sendable {")
        lines.append("")
        lines.append("\(indent)// MARK: - Types")
        lines.append("")
        lines.append("\(indent)/// Transaction isolation levels.")
        lines.append("\(indent)public enum IsolationLevel: Sendable {")
        lines.append("\(indent)\(indent)case readUncommitted")
        lines.append("\(indent)\(indent)case readCommitted")
        lines.append("\(indent)\(indent)case repeatableRead")
        lines.append("\(indent)\(indent)case serializable")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Transaction state.")
        lines.append("\(indent)public enum State: Sendable {")
        lines.append("\(indent)\(indent)case idle")
        lines.append("\(indent)\(indent)case active")
        lines.append("\(indent)\(indent)case committed")
        lines.append("\(indent)\(indent)case rolledBack")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Properties")
        lines.append("")
        lines.append("\(indent)private let lock = NSLock()")
        lines.append("\(indent)private var state: State = .idle")
        lines.append("\(indent)private var savepoints: [String] = []")
        lines.append("")
        lines.append("\(indent)public var isActive: Bool {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("\(indent)\(indent)return state == .active")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Initialization")
        lines.append("")
        lines.append("\(indent)public init() {}")
        lines.append("")
        lines.append("\(indent)// MARK: - Transaction Control")
        lines.append("")
        lines.append("\(indent)/// Executes a block within a transaction.")
        lines.append("\(indent)/// - Parameters:")
        lines.append("\(indent)///   - isolation: The isolation level for the transaction.")
        lines.append("\(indent)///   - block: The block to execute within the transaction.")
        lines.append("\(indent)/// - Returns: The result of the block.")
        lines.append("\(indent)public func transaction<T>(")
        lines.append("\(indent)\(indent)isolation: IsolationLevel = .readCommitted,")
        lines.append("\(indent)\(indent)_ block: () async throws -> T")
        lines.append("\(indent)) async throws -> T {")
        lines.append("\(indent)\(indent)try begin(isolation: isolation)")
        lines.append("")
        lines.append("\(indent)\(indent)do {")
        lines.append("\(indent)\(indent)\(indent)let result = try await block()")
        lines.append("\(indent)\(indent)\(indent)try commit()")
        lines.append("\(indent)\(indent)\(indent)return result")
        lines.append("\(indent)\(indent)} catch {")
        lines.append("\(indent)\(indent)\(indent)try? rollback()")
        lines.append("\(indent)\(indent)\(indent)throw error")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Begins a new transaction.")
        lines.append("\(indent)public func begin(isolation: IsolationLevel = .readCommitted) throws {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("")
        lines.append("\(indent)\(indent)guard state == .idle else {")
        lines.append("\(indent)\(indent)\(indent)throw RepositoryError.transactionFailed(message: \"Transaction already active\")")
        lines.append("\(indent)\(indent)}")
        lines.append("")
        lines.append("\(indent)\(indent)state = .active")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Commits the current transaction.")
        lines.append("\(indent)public func commit() throws {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("")
        lines.append("\(indent)\(indent)guard state == .active else {")
        lines.append("\(indent)\(indent)\(indent)throw RepositoryError.transactionFailed(message: \"No active transaction to commit\")")
        lines.append("\(indent)\(indent)}")
        lines.append("")
        lines.append("\(indent)\(indent)state = .committed")
        lines.append("\(indent)\(indent)savepoints.removeAll()")
        lines.append("\(indent)\(indent)state = .idle")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Rolls back the current transaction.")
        lines.append("\(indent)public func rollback() throws {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("")
        lines.append("\(indent)\(indent)guard state == .active else {")
        lines.append("\(indent)\(indent)\(indent)throw RepositoryError.transactionFailed(message: \"No active transaction to rollback\")")
        lines.append("\(indent)\(indent)}")
        lines.append("")
        lines.append("\(indent)\(indent)state = .rolledBack")
        lines.append("\(indent)\(indent)savepoints.removeAll()")
        lines.append("\(indent)\(indent)state = .idle")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Savepoints")
        lines.append("")
        lines.append("\(indent)/// Creates a savepoint within the current transaction.")
        lines.append("\(indent)public func savepoint(_ name: String) throws {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("")
        lines.append("\(indent)\(indent)guard state == .active else {")
        lines.append("\(indent)\(indent)\(indent)throw RepositoryError.transactionFailed(message: \"No active transaction for savepoint\")")
        lines.append("\(indent)\(indent)}")
        lines.append("")
        lines.append("\(indent)\(indent)savepoints.append(name)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Rolls back to a savepoint.")
        lines.append("\(indent)public func rollbackToSavepoint(_ name: String) throws {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("")
        lines.append("\(indent)\(indent)guard let index = savepoints.firstIndex(of: name) else {")
        lines.append("\(indent)\(indent)\(indent)throw RepositoryError.transactionFailed(message: \"Savepoint '\\(name)' not found\")")
        lines.append("\(indent)\(indent)}")
        lines.append("")
        lines.append("\(indent)\(indent)savepoints.removeSubrange(index...)")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "TransactionManager.swift", content: lines.joined(separator: "\n"))
    }
    
    // MARK: - Entity-Specific Generation
    
    private func generateRepositoryProtocol(for entity: EntityDefinition) -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        let protocolName = repositoryProtocolName(for: entity.name)
        let idType = entity.primaryKey?.type ?? "String"
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        if repoConfig.useCombine {
            lines.append("import Combine")
        }
        lines.append("")
        lines.append("// MARK: - \(entity.name) Repository Protocol")
        lines.append("")
        lines.append("/// Repository protocol for \(entity.name) entities.")
        lines.append("public protocol \(protocolName): Repository where Entity == \(entity.name), ID == \(idType) {")
        lines.append("")
        
        // Custom query methods based on indexed properties
        for property in entity.indexedProperties {
            lines.append("\(indent)/// Finds entities by \(property.name).")
            lines.append("\(indent)func find(by\(property.name.capitalized): \(property.type)) async throws -> [\(entity.name)]")
            lines.append("")
        }
        
        // Relationship accessors
        for relationship in entity.relationships {
            let returnType = relationship.relationType == .oneToOne ? relationship.targetEntity : "[\(relationship.targetEntity)]"
            lines.append("\(indent)/// Gets the \(relationship.name) for an entity.")
            lines.append("\(indent)func get\(relationship.name.capitalized)(for entity: \(entity.name)) async throws -> \(returnType)?")
            lines.append("")
        }
        
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "\(protocolName).swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateRepositoryImplementation(for entity: EntityDefinition) -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        let protocolName = repositoryProtocolName(for: entity.name)
        let implName = "\(entity.name)RepositoryImpl"
        let idType = entity.primaryKey?.type ?? "String"
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        if repoConfig.useCombine {
            lines.append("import Combine")
        }
        lines.append("")
        lines.append("// MARK: - \(entity.name) Repository Implementation")
        lines.append("")
        lines.append("/// Concrete implementation of \(protocolName).")
        lines.append("public final class \(implName): \(protocolName), @unchecked Sendable {")
        lines.append("")
        lines.append("\(indent)// MARK: - Properties")
        lines.append("")
        lines.append("\(indent)private var storage: [\(idType): \(entity.name)] = [:]")
        lines.append("\(indent)private let lock = NSLock()")
        
        if repoConfig.useCombine {
            lines.append("\(indent)private let changesSubject = PassthroughSubject<RepositoryChange<\(entity.name)>, Never>()")
            lines.append("")
            lines.append("\(indent)public var changesPublisher: AnyPublisher<RepositoryChange<\(entity.name)>, Never> {")
            lines.append("\(indent)\(indent)changesSubject.eraseToAnyPublisher()")
            lines.append("\(indent)}")
        }
        
        lines.append("")
        lines.append("\(indent)// MARK: - Initialization")
        lines.append("")
        lines.append("\(indent)public init() {}")
        lines.append("")
        lines.append("\(indent)// MARK: - CRUD Operations")
        lines.append("")
        
        if repoConfig.useAsync {
            // Get by ID
            lines.append("\(indent)public func get(by id: \(idType)) async throws -> \(entity.name)? {")
            lines.append("\(indent)\(indent)lock.lock()")
            lines.append("\(indent)\(indent)defer { lock.unlock() }")
            lines.append("\(indent)\(indent)return storage[id]")
            lines.append("\(indent)}")
            lines.append("")
            
            // Get all
            lines.append("\(indent)public func getAll() async throws -> [\(entity.name)] {")
            lines.append("\(indent)\(indent)lock.lock()")
            lines.append("\(indent)\(indent)defer { lock.unlock() }")
            lines.append("\(indent)\(indent)return Array(storage.values)")
            lines.append("\(indent)}")
            lines.append("")
            
            // Save
            lines.append("\(indent)@discardableResult")
            lines.append("\(indent)public func save(_ entity: \(entity.name)) async throws -> \(entity.name) {")
            lines.append("\(indent)\(indent)lock.lock()")
            lines.append("\(indent)\(indent)defer { lock.unlock() }")
            lines.append("\(indent)\(indent)storage[entity.id] = entity")
            if repoConfig.useCombine {
                lines.append("\(indent)\(indent)changesSubject.send(.inserted(entity))")
            }
            lines.append("\(indent)\(indent)return entity")
            lines.append("\(indent)}")
            lines.append("")
            
            // Update
            lines.append("\(indent)@discardableResult")
            lines.append("\(indent)public func update(_ entity: \(entity.name)) async throws -> \(entity.name) {")
            lines.append("\(indent)\(indent)lock.lock()")
            lines.append("\(indent)\(indent)defer { lock.unlock() }")
            lines.append("\(indent)\(indent)guard storage[entity.id] != nil else {")
            lines.append("\(indent)\(indent)\(indent)throw RepositoryError.notFound(id: String(describing: entity.id))")
            lines.append("\(indent)\(indent)}")
            lines.append("\(indent)\(indent)storage[entity.id] = entity")
            if repoConfig.useCombine {
                lines.append("\(indent)\(indent)changesSubject.send(.updated(entity))")
            }
            lines.append("\(indent)\(indent)return entity")
            lines.append("\(indent)}")
            lines.append("")
            
            // Delete
            lines.append("\(indent)public func delete(by id: \(idType)) async throws {")
            lines.append("\(indent)\(indent)lock.lock()")
            lines.append("\(indent)\(indent)defer { lock.unlock() }")
            lines.append("\(indent)\(indent)guard let entity = storage.removeValue(forKey: id) else {")
            lines.append("\(indent)\(indent)\(indent)throw RepositoryError.notFound(id: String(describing: id))")
            lines.append("\(indent)\(indent)}")
            if repoConfig.useCombine {
                lines.append("\(indent)\(indent)changesSubject.send(.deleted(entity))")
            } else {
                lines.append("\(indent)\(indent)_ = entity")
            }
            lines.append("\(indent)}")
            lines.append("")
            
            // Exists
            lines.append("\(indent)public func exists(by id: \(idType)) async throws -> Bool {")
            lines.append("\(indent)\(indent)lock.lock()")
            lines.append("\(indent)\(indent)defer { lock.unlock() }")
            lines.append("\(indent)\(indent)return storage[id] != nil")
            lines.append("\(indent)}")
            lines.append("")
            
            // Count
            lines.append("\(indent)public func count() async throws -> Int {")
            lines.append("\(indent)\(indent)lock.lock()")
            lines.append("\(indent)\(indent)defer { lock.unlock() }")
            lines.append("\(indent)\(indent)return storage.count")
            lines.append("\(indent)}")
            lines.append("")
        }
        
        if repoConfig.generateBatchOperations {
            lines.append("\(indent)// MARK: - Batch Operations")
            lines.append("")
            
            // Get by IDs
            lines.append("\(indent)public func get(by ids: [\(idType)]) async throws -> [\(entity.name)] {")
            lines.append("\(indent)\(indent)lock.lock()")
            lines.append("\(indent)\(indent)defer { lock.unlock() }")
            lines.append("\(indent)\(indent)return ids.compactMap { storage[$0] }")
            lines.append("\(indent)}")
            lines.append("")
            
            // Save all
            lines.append("\(indent)@discardableResult")
            lines.append("\(indent)public func saveAll(_ entities: [\(entity.name)]) async throws -> [\(entity.name)] {")
            lines.append("\(indent)\(indent)lock.lock()")
            lines.append("\(indent)\(indent)defer { lock.unlock() }")
            lines.append("\(indent)\(indent)for entity in entities {")
            lines.append("\(indent)\(indent)\(indent)storage[entity.id] = entity")
            if repoConfig.useCombine {
                lines.append("\(indent)\(indent)\(indent)changesSubject.send(.inserted(entity))")
            }
            lines.append("\(indent)\(indent)}")
            lines.append("\(indent)\(indent)return entities")
            lines.append("\(indent)}")
            lines.append("")
            
            // Delete all by IDs
            lines.append("\(indent)public func deleteAll(by ids: [\(idType)]) async throws {")
            lines.append("\(indent)\(indent)lock.lock()")
            lines.append("\(indent)\(indent)defer { lock.unlock() }")
            lines.append("\(indent)\(indent)for id in ids {")
            lines.append("\(indent)\(indent)\(indent)if let entity = storage.removeValue(forKey: id) {")
            if repoConfig.useCombine {
                lines.append("\(indent)\(indent)\(indent)\(indent)changesSubject.send(.deleted(entity))")
            } else {
                lines.append("\(indent)\(indent)\(indent)\(indent)_ = entity")
            }
            lines.append("\(indent)\(indent)\(indent)}")
            lines.append("\(indent)\(indent)}")
            lines.append("\(indent)}")
            lines.append("")
            
            // Delete all
            lines.append("\(indent)public func deleteAll() async throws {")
            lines.append("\(indent)\(indent)lock.lock()")
            lines.append("\(indent)\(indent)defer { lock.unlock() }")
            if repoConfig.useCombine {
                lines.append("\(indent)\(indent)let allEntities = Array(storage.values)")
            }
            lines.append("\(indent)\(indent)storage.removeAll()")
            if repoConfig.useCombine {
                lines.append("\(indent)\(indent)changesSubject.send(.reloaded(allEntities))")
            }
            lines.append("\(indent)}")
            lines.append("")
        }
        
        // Custom query methods
        for property in entity.indexedProperties {
            lines.append("\(indent)public func find(by\(property.name.capitalized): \(property.type)) async throws -> [\(entity.name)] {")
            lines.append("\(indent)\(indent)lock.lock()")
            lines.append("\(indent)\(indent)defer { lock.unlock() }")
            lines.append("\(indent)\(indent)return storage.values.filter { $0.\(property.name) == by\(property.name.capitalized) }")
            lines.append("\(indent)}")
            lines.append("")
        }
        
        // Relationship accessors
        for relationship in entity.relationships {
            let returnType = relationship.relationType == .oneToOne ? relationship.targetEntity : "[\(relationship.targetEntity)]"
            lines.append("\(indent)public func get\(relationship.name.capitalized)(for entity: \(entity.name)) async throws -> \(returnType)? {")
            lines.append("\(indent)\(indent)// Implementation depends on data source")
            lines.append("\(indent)\(indent)return nil")
            lines.append("\(indent)}")
            lines.append("")
        }
        
        if repoConfig.useCombine {
            lines.append("\(indent)// MARK: - Observation")
            lines.append("")
            
            lines.append("\(indent)public func observe(by id: \(idType)) -> AnyPublisher<\(entity.name)?, Never> {")
            lines.append("\(indent)\(indent)changesPublisher")
            lines.append("\(indent)\(indent)\(indent).compactMap { [weak self] change -> \(entity.name)?? in")
            lines.append("\(indent)\(indent)\(indent)\(indent)switch change {")
            lines.append("\(indent)\(indent)\(indent)\(indent)case .inserted(let entity), .updated(let entity):")
            lines.append("\(indent)\(indent)\(indent)\(indent)\(indent)return entity.id == id ? entity : nil")
            lines.append("\(indent)\(indent)\(indent)\(indent)case .deleted(let entity):")
            lines.append("\(indent)\(indent)\(indent)\(indent)\(indent)return entity.id == id ? nil : nil")
            lines.append("\(indent)\(indent)\(indent)\(indent)case .reloaded:")
            lines.append("\(indent)\(indent)\(indent)\(indent)\(indent)return self?.storage[id]")
            lines.append("\(indent)\(indent)\(indent)\(indent)}")
            lines.append("\(indent)\(indent)\(indent)}")
            lines.append("\(indent)\(indent)\(indent).eraseToAnyPublisher()")
            lines.append("\(indent)}")
            lines.append("")
            
            lines.append("\(indent)public func observeAll() -> AnyPublisher<[\(entity.name)], Never> {")
            lines.append("\(indent)\(indent)changesPublisher")
            lines.append("\(indent)\(indent)\(indent).map { [weak self] _ in")
            lines.append("\(indent)\(indent)\(indent)\(indent)Array(self?.storage.values ?? [])")
            lines.append("\(indent)\(indent)\(indent)}")
            lines.append("\(indent)\(indent)\(indent).eraseToAnyPublisher()")
            lines.append("\(indent)}")
            lines.append("")
        }
        
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "\(implName).swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateCachedRepository(for entity: EntityDefinition) -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        let protocolName = repositoryProtocolName(for: entity.name)
        let className = "Cached\(entity.name)Repository"
        let idType = entity.primaryKey?.type ?? "String"
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        if repoConfig.useCombine {
            lines.append("import Combine")
        }
        lines.append("")
        lines.append("// MARK: - Cached \(entity.name) Repository")
        lines.append("")
        lines.append("/// A caching wrapper for \(entity.name) repository.")
        lines.append("public final class \(className)<Wrapped: \(protocolName)>: \(protocolName), @unchecked Sendable {")
        lines.append("")
        lines.append("\(indent)// MARK: - Properties")
        lines.append("")
        lines.append("\(indent)private let wrapped: Wrapped")
        lines.append("\(indent)private let cache: InMemoryCache<\(idType), \(entity.name)>")
        lines.append("\(indent)private let policy: CachePolicy")
        lines.append("")
        if repoConfig.useCombine {
            lines.append("\(indent)public var changesPublisher: AnyPublisher<RepositoryChange<\(entity.name)>, Never> {")
            lines.append("\(indent)\(indent)wrapped.changesPublisher")
            lines.append("\(indent)}")
            lines.append("")
        }
        lines.append("\(indent)// MARK: - Initialization")
        lines.append("")
        lines.append("\(indent)public init(")
        lines.append("\(indent)\(indent)wrapped: Wrapped,")
        lines.append("\(indent)\(indent)cache: InMemoryCache<\(idType), \(entity.name)> = InMemoryCache(),")
        lines.append("\(indent)\(indent)policy: CachePolicy = .cacheFirst")
        lines.append("\(indent)) {")
        lines.append("\(indent)\(indent)self.wrapped = wrapped")
        lines.append("\(indent)\(indent)self.cache = cache")
        lines.append("\(indent)\(indent)self.policy = policy")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - CRUD Operations")
        lines.append("")
        lines.append("\(indent)public func get(by id: \(idType)) async throws -> \(entity.name)? {")
        lines.append("\(indent)\(indent)switch policy {")
        lines.append("\(indent)\(indent)case .cacheFirst, .staleWhileRevalidate:")
        lines.append("\(indent)\(indent)\(indent)if let cached = cache.get(for: id) {")
        lines.append("\(indent)\(indent)\(indent)\(indent)return cached")
        lines.append("\(indent)\(indent)\(indent)}")
        lines.append("\(indent)\(indent)\(indent)let entity = try await wrapped.get(by: id)")
        lines.append("\(indent)\(indent)\(indent)if let entity = entity {")
        lines.append("\(indent)\(indent)\(indent)\(indent)cache.set(entity, for: id)")
        lines.append("\(indent)\(indent)\(indent)}")
        lines.append("\(indent)\(indent)\(indent)return entity")
        lines.append("\(indent)\(indent)case .cacheOnly:")
        lines.append("\(indent)\(indent)\(indent)return cache.get(for: id)")
        lines.append("\(indent)\(indent)case .networkFirst, .networkOnly:")
        lines.append("\(indent)\(indent)\(indent)let entity = try await wrapped.get(by: id)")
        lines.append("\(indent)\(indent)\(indent)if let entity = entity {")
        lines.append("\(indent)\(indent)\(indent)\(indent)cache.set(entity, for: id)")
        lines.append("\(indent)\(indent)\(indent)}")
        lines.append("\(indent)\(indent)\(indent)return entity")
        lines.append("\(indent)\(indent)case .cacheWithMaxAge:")
        lines.append("\(indent)\(indent)\(indent)if let cached = cache.get(for: id) {")
        lines.append("\(indent)\(indent)\(indent)\(indent)return cached")
        lines.append("\(indent)\(indent)\(indent)}")
        lines.append("\(indent)\(indent)\(indent)let entity = try await wrapped.get(by: id)")
        lines.append("\(indent)\(indent)\(indent)if let entity = entity {")
        lines.append("\(indent)\(indent)\(indent)\(indent)cache.set(entity, for: id)")
        lines.append("\(indent)\(indent)\(indent)}")
        lines.append("\(indent)\(indent)\(indent)return entity")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func getAll() async throws -> [\(entity.name)] {")
        lines.append("\(indent)\(indent)try await wrapped.getAll()")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func save(_ entity: \(entity.name)) async throws -> \(entity.name) {")
        lines.append("\(indent)\(indent)let saved = try await wrapped.save(entity)")
        lines.append("\(indent)\(indent)cache.set(saved, for: saved.id)")
        lines.append("\(indent)\(indent)return saved")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func update(_ entity: \(entity.name)) async throws -> \(entity.name) {")
        lines.append("\(indent)\(indent)let updated = try await wrapped.update(entity)")
        lines.append("\(indent)\(indent)cache.set(updated, for: updated.id)")
        lines.append("\(indent)\(indent)return updated")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func delete(by id: \(idType)) async throws {")
        lines.append("\(indent)\(indent)try await wrapped.delete(by: id)")
        lines.append("\(indent)\(indent)cache.remove(for: id)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func exists(by id: \(idType)) async throws -> Bool {")
        lines.append("\(indent)\(indent)if cache.contains(key: id) { return true }")
        lines.append("\(indent)\(indent)return try await wrapped.exists(by: id)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func count() async throws -> Int {")
        lines.append("\(indent)\(indent)try await wrapped.count()")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Batch Operations")
        lines.append("")
        lines.append("\(indent)public func get(by ids: [\(idType)]) async throws -> [\(entity.name)] {")
        lines.append("\(indent)\(indent)try await wrapped.get(by: ids)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)@discardableResult")
        lines.append("\(indent)public func saveAll(_ entities: [\(entity.name)]) async throws -> [\(entity.name)] {")
        lines.append("\(indent)\(indent)let saved = try await wrapped.saveAll(entities)")
        lines.append("\(indent)\(indent)for entity in saved {")
        lines.append("\(indent)\(indent)\(indent)cache.set(entity, for: entity.id)")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)\(indent)return saved")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func deleteAll(by ids: [\(idType)]) async throws {")
        lines.append("\(indent)\(indent)try await wrapped.deleteAll(by: ids)")
        lines.append("\(indent)\(indent)for id in ids {")
        lines.append("\(indent)\(indent)\(indent)cache.remove(for: id)")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func deleteAll() async throws {")
        lines.append("\(indent)\(indent)try await wrapped.deleteAll()")
        lines.append("\(indent)\(indent)cache.clear()")
        lines.append("\(indent)}")
        lines.append("")
        
        // Custom query methods
        for property in entity.indexedProperties {
            lines.append("\(indent)public func find(by\(property.name.capitalized): \(property.type)) async throws -> [\(entity.name)] {")
            lines.append("\(indent)\(indent)try await wrapped.find(by\(property.name.capitalized): by\(property.name.capitalized))")
            lines.append("\(indent)}")
            lines.append("")
        }
        
        // Relationship accessors
        for relationship in entity.relationships {
            let returnType = relationship.relationType == .oneToOne ? relationship.targetEntity : "[\(relationship.targetEntity)]"
            lines.append("\(indent)public func get\(relationship.name.capitalized)(for entity: \(entity.name)) async throws -> \(returnType)? {")
            lines.append("\(indent)\(indent)try await wrapped.get\(relationship.name.capitalized)(for: entity)")
            lines.append("\(indent)}")
            lines.append("")
        }
        
        if repoConfig.useCombine {
            lines.append("\(indent)// MARK: - Observation")
            lines.append("")
            lines.append("\(indent)public func observe(by id: \(idType)) -> AnyPublisher<\(entity.name)?, Never> {")
            lines.append("\(indent)\(indent)wrapped.observe(by: id)")
            lines.append("\(indent)}")
            lines.append("")
            lines.append("\(indent)public func observeAll() -> AnyPublisher<[\(entity.name)], Never> {")
            lines.append("\(indent)\(indent)wrapped.observeAll()")
            lines.append("\(indent)}")
            lines.append("")
        }
        
        lines.append("\(indent)// MARK: - Cache Control")
        lines.append("")
        lines.append("\(indent)/// Invalidates the entire cache.")
        lines.append("\(indent)public func invalidateCache() {")
        lines.append("\(indent)\(indent)cache.clear()")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Invalidates a specific entry.")
        lines.append("\(indent)public func invalidate(id: \(idType)) {")
        lines.append("\(indent)\(indent)cache.remove(for: id)")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "\(className).swift", content: lines.joined(separator: "\n"))
    }
    
    // MARK: - Data Source Generation
    
    private func generateDataSources() -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        
        // Generate based on configured data source type
        switch repoConfig.dataSourceType {
        case .inMemory, .combined:
            files.append(generateInMemoryDataSource())
        case .userDefaults:
            files.append(generateUserDefaultsDataSource())
        case .fileSystem:
            files.append(generateFileSystemDataSource())
        default:
            files.append(generateInMemoryDataSource())
        }
        
        return files
    }
    
    private func generateInMemoryDataSource() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - In-Memory Data Source")
        lines.append("")
        lines.append("/// An in-memory data source for development and testing.")
        lines.append("public final class InMemoryDataSource<Key: Hashable, Value>: @unchecked Sendable {")
        lines.append("")
        lines.append("\(indent)// MARK: - Properties")
        lines.append("")
        lines.append("\(indent)private var storage: [Key: Value] = [:]")
        lines.append("\(indent)private let lock = NSLock()")
        lines.append("")
        lines.append("\(indent)// MARK: - Initialization")
        lines.append("")
        lines.append("\(indent)public init() {}")
        lines.append("")
        lines.append("\(indent)public init(initialData: [Key: Value]) {")
        lines.append("\(indent)\(indent)self.storage = initialData")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Operations")
        lines.append("")
        lines.append("\(indent)public func get(key: Key) -> Value? {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("\(indent)\(indent)return storage[key]")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func set(_ value: Value, for key: Key) {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("\(indent)\(indent)storage[key] = value")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func remove(key: Key) -> Value? {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("\(indent)\(indent)return storage.removeValue(forKey: key)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func getAll() -> [Value] {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("\(indent)\(indent)return Array(storage.values)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func clear() {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("\(indent)\(indent)storage.removeAll()")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public var count: Int {")
        lines.append("\(indent)\(indent)lock.lock()")
        lines.append("\(indent)\(indent)defer { lock.unlock() }")
        lines.append("\(indent)\(indent)return storage.count")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "InMemoryDataSource.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateUserDefaultsDataSource() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - UserDefaults Data Source")
        lines.append("")
        lines.append("/// A UserDefaults-based data source for simple persistence.")
        lines.append("public final class UserDefaultsDataSource<Value: Codable>: @unchecked Sendable {")
        lines.append("")
        lines.append("\(indent)// MARK: - Properties")
        lines.append("")
        lines.append("\(indent)private let defaults: UserDefaults")
        lines.append("\(indent)private let keyPrefix: String")
        lines.append("\(indent)private let encoder = JSONEncoder()")
        lines.append("\(indent)private let decoder = JSONDecoder()")
        lines.append("")
        lines.append("\(indent)// MARK: - Initialization")
        lines.append("")
        lines.append("\(indent)public init(")
        lines.append("\(indent)\(indent)defaults: UserDefaults = .standard,")
        lines.append("\(indent)\(indent)keyPrefix: String = \"\"")
        lines.append("\(indent)) {")
        lines.append("\(indent)\(indent)self.defaults = defaults")
        lines.append("\(indent)\(indent)self.keyPrefix = keyPrefix")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Operations")
        lines.append("")
        lines.append("\(indent)public func get(key: String) -> Value? {")
        lines.append("\(indent)\(indent)guard let data = defaults.data(forKey: prefixedKey(key)) else {")
        lines.append("\(indent)\(indent)\(indent)return nil")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)\(indent)return try? decoder.decode(Value.self, from: data)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func set(_ value: Value, for key: String) throws {")
        lines.append("\(indent)\(indent)let data = try encoder.encode(value)")
        lines.append("\(indent)\(indent)defaults.set(data, forKey: prefixedKey(key))")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func remove(key: String) {")
        lines.append("\(indent)\(indent)defaults.removeObject(forKey: prefixedKey(key))")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Helpers")
        lines.append("")
        lines.append("\(indent)private func prefixedKey(_ key: String) -> String {")
        lines.append("\(indent)\(indent)keyPrefix.isEmpty ? key : \"\\(keyPrefix).\\(key)\"")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "UserDefaultsDataSource.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateFileSystemDataSource() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - File System Data Source")
        lines.append("")
        lines.append("/// A file system-based data source for JSON persistence.")
        lines.append("public final class FileSystemDataSource<Value: Codable>: @unchecked Sendable {")
        lines.append("")
        lines.append("\(indent)// MARK: - Properties")
        lines.append("")
        lines.append("\(indent)private let baseURL: URL")
        lines.append("\(indent)private let fileManager = FileManager.default")
        lines.append("\(indent)private let encoder = JSONEncoder()")
        lines.append("\(indent)private let decoder = JSONDecoder()")
        lines.append("")
        lines.append("\(indent)// MARK: - Initialization")
        lines.append("")
        lines.append("\(indent)public init(baseURL: URL) throws {")
        lines.append("\(indent)\(indent)self.baseURL = baseURL")
        lines.append("\(indent)\(indent)try fileManager.createDirectory(at: baseURL, withIntermediateDirectories: true)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public convenience init(directory: String) throws {")
        lines.append("\(indent)\(indent)let documentsURL = fileManager.urls(for: .documentDirectory, in: .userDomainMask)[0]")
        lines.append("\(indent)\(indent)try self.init(baseURL: documentsURL.appendingPathComponent(directory))")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Operations")
        lines.append("")
        lines.append("\(indent)public func get(key: String) throws -> Value? {")
        lines.append("\(indent)\(indent)let fileURL = baseURL.appendingPathComponent(\"\\(key).json\")")
        lines.append("\(indent)\(indent)guard fileManager.fileExists(atPath: fileURL.path) else { return nil }")
        lines.append("\(indent)\(indent)let data = try Data(contentsOf: fileURL)")
        lines.append("\(indent)\(indent)return try decoder.decode(Value.self, from: data)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func set(_ value: Value, for key: String) throws {")
        lines.append("\(indent)\(indent)let fileURL = baseURL.appendingPathComponent(\"\\(key).json\")")
        lines.append("\(indent)\(indent)let data = try encoder.encode(value)")
        lines.append("\(indent)\(indent)try data.write(to: fileURL)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func remove(key: String) throws {")
        lines.append("\(indent)\(indent)let fileURL = baseURL.appendingPathComponent(\"\\(key).json\")")
        lines.append("\(indent)\(indent)if fileManager.fileExists(atPath: fileURL.path) {")
        lines.append("\(indent)\(indent)\(indent)try fileManager.removeItem(at: fileURL)")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func getAll() throws -> [Value] {")
        lines.append("\(indent)\(indent)let contents = try fileManager.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: nil)")
        lines.append("\(indent)\(indent)return try contents")
        lines.append("\(indent)\(indent)\(indent).filter { $0.pathExtension == \"json\" }")
        lines.append("\(indent)\(indent)\(indent).compactMap { url -> Value? in")
        lines.append("\(indent)\(indent)\(indent)\(indent)let data = try? Data(contentsOf: url)")
        lines.append("\(indent)\(indent)\(indent)\(indent)return data.flatMap { try? decoder.decode(Value.self, from: $0) }")
        lines.append("\(indent)\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public func clear() throws {")
        lines.append("\(indent)\(indent)let contents = try fileManager.contentsOfDirectory(at: baseURL, includingPropertiesForKeys: nil)")
        lines.append("\(indent)\(indent)for url in contents where url.pathExtension == \"json\" {")
        lines.append("\(indent)\(indent)\(indent)try fileManager.removeItem(at: url)")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "FileSystemDataSource.swift", content: lines.joined(separator: "\n"))
    }
    
    // MARK: - Helpers
    
    private func repositoryProtocolName(for entityName: String) -> String {
        switch repoConfig.protocolNaming {
        case .suffix:
            return "\(entityName)Repository"
        case .prefix:
            return "I\(entityName)"
        case .both:
            return "I\(entityName)Repository"
        }
    }
}
