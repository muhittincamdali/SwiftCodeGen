import Foundation

// MARK: - ViewModel Configuration

/// Configuration options for ViewModel generation.
public struct ViewModelConfig: Codable, Sendable {
    
    /// The architecture pattern to use.
    public enum ArchitecturePattern: String, Codable, Sendable {
        case mvvm = "MVVM"
        case mvvmC = "MVVM-C"
        case viper = "VIPER"
        case clean = "Clean"
        case tca = "TCA"
    }
    
    /// The binding mechanism to use.
    public enum BindingMechanism: String, Codable, Sendable {
        case combine = "Combine"
        case asyncAwait = "AsyncAwait"
        case observation = "Observation"
        case closures = "Closures"
    }
    
    /// Whether to generate input/output pattern.
    public var useInputOutput: Bool
    
    /// The architecture pattern.
    public var architecturePattern: ArchitecturePattern
    
    /// The binding mechanism.
    public var bindingMechanism: BindingMechanism
    
    /// Whether to generate coordinator integration.
    public var generateCoordinator: Bool
    
    /// Whether to generate dependency injection.
    public var generateDI: Bool
    
    /// Whether to generate loading states.
    public var generateLoadingStates: Bool
    
    /// Whether to generate error handling.
    public var generateErrorHandling: Bool
    
    /// Whether to use @MainActor.
    public var useMainActor: Bool
    
    /// Custom imports to include.
    public var customImports: [String]
    
    /// Creates a new ViewModel configuration.
    public init(
        useInputOutput: Bool = true,
        architecturePattern: ArchitecturePattern = .mvvm,
        bindingMechanism: BindingMechanism = .combine,
        generateCoordinator: Bool = false,
        generateDI: Bool = true,
        generateLoadingStates: Bool = true,
        generateErrorHandling: Bool = true,
        useMainActor: Bool = true,
        customImports: [String] = []
    ) {
        self.useInputOutput = useInputOutput
        self.architecturePattern = architecturePattern
        self.bindingMechanism = bindingMechanism
        self.generateCoordinator = generateCoordinator
        self.generateDI = generateDI
        self.generateLoadingStates = generateLoadingStates
        self.generateErrorHandling = generateErrorHandling
        self.useMainActor = useMainActor
        self.customImports = customImports
    }
}

// MARK: - ViewModel Definition

/// Represents a ViewModel definition for code generation.
public struct ViewModelDefinition: Codable, Sendable {
    
    /// An action that the ViewModel can perform.
    public struct Action: Codable, Sendable {
        public let name: String
        public let parameters: [Parameter]
        public let isAsync: Bool
        public let returnType: String?
        public let description: String?
        
        public init(
            name: String,
            parameters: [Parameter] = [],
            isAsync: Bool = true,
            returnType: String? = nil,
            description: String? = nil
        ) {
            self.name = name
            self.parameters = parameters
            self.isAsync = isAsync
            self.returnType = returnType
            self.description = description
        }
    }
    
    /// A parameter for an action.
    public struct Parameter: Codable, Sendable {
        public let name: String
        public let type: String
        public let defaultValue: String?
        
        public init(name: String, type: String, defaultValue: String? = nil) {
            self.name = name
            self.type = type
            self.defaultValue = defaultValue
        }
    }
    
    /// A state property for the ViewModel.
    public struct StateProperty: Codable, Sendable {
        public let name: String
        public let type: String
        public let defaultValue: String?
        public let isPublished: Bool
        
        public init(
            name: String,
            type: String,
            defaultValue: String? = nil,
            isPublished: Bool = true
        ) {
            self.name = name
            self.type = type
            self.defaultValue = defaultValue
            self.isPublished = isPublished
        }
    }
    
    /// A dependency for the ViewModel.
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
    
    public let name: String
    public let actions: [Action]
    public let stateProperties: [StateProperty]
    public let dependencies: [Dependency]
    public let navigationEvents: [String]
    
    public init(
        name: String,
        actions: [Action] = [],
        stateProperties: [StateProperty] = [],
        dependencies: [Dependency] = [],
        navigationEvents: [String] = []
    ) {
        self.name = name
        self.actions = actions
        self.stateProperties = stateProperties
        self.dependencies = dependencies
        self.navigationEvents = navigationEvents
    }
}

// MARK: - ViewModel Generator

/// Generates ViewModel classes following various architecture patterns.
///
/// The `ViewModelGenerator` creates ViewModels with proper state management,
/// dependency injection, and reactive bindings based on the configured pattern.
///
/// ## Overview
///
/// Use this generator to create consistent ViewModels across your application:
///
/// ```swift
/// let generator = ViewModelGenerator(
///     viewModels: [loginViewModel, homeViewModel],
///     outputPath: "Sources/ViewModels",
///     config: .init(bindingMechanism: .combine)
/// )
/// let files = try generator.generate()
/// ```
///
/// ## Supported Patterns
///
/// - MVVM with Combine
/// - MVVM with async/await
/// - MVVM-C with Coordinators
/// - Clean Architecture ViewModels
public final class ViewModelGenerator: CodeGenerator {
    
    // MARK: - Properties
    
    public let generatorType = "viewmodel"
    public let inputPath: String
    public let outputPath: String
    
    private let viewModels: [ViewModelDefinition]
    private let vmConfig: ViewModelConfig
    private let codeGenConfig: CodeGenConfig
    
    // MARK: - Initialization
    
    /// Creates a new ViewModel generator.
    public init(
        viewModels: [ViewModelDefinition],
        outputPath: String,
        vmConfig: ViewModelConfig = ViewModelConfig(),
        codeGenConfig: CodeGenConfig = CodeGenConfig()
    ) {
        self.viewModels = viewModels
        self.inputPath = ""
        self.outputPath = outputPath
        self.vmConfig = vmConfig
        self.codeGenConfig = codeGenConfig
    }
    
    /// Creates a new ViewModel generator from JSON input.
    public init(inputPath: String, outputPath: String, config: CodeGenConfig) {
        self.inputPath = inputPath
        self.outputPath = outputPath
        self.codeGenConfig = config
        self.vmConfig = ViewModelConfig()
        self.viewModels = []
    }
    
    // MARK: - Generation
    
    public func generate() throws -> [GeneratedFile] {
        var files: [GeneratedFile] = []
        
        let viewModelsToGenerate = viewModels.isEmpty ? try loadViewModels() : viewModels
        
        // Generate base protocols and types
        files.append(generateViewModelProtocol())
        files.append(generateViewModelState())
        
        if vmConfig.generateLoadingStates {
            files.append(generateLoadingState())
        }
        
        if vmConfig.generateErrorHandling {
            files.append(generateViewModelError())
        }
        
        if vmConfig.generateCoordinator {
            files.append(generateCoordinatorProtocol())
            files.append(generateNavigationEvent())
        }
        
        if vmConfig.useInputOutput {
            files.append(generateInputOutputProtocol())
        }
        
        // Generate each ViewModel
        for viewModel in viewModelsToGenerate {
            files.append(generateViewModel(for: viewModel))
            
            if vmConfig.useInputOutput {
                files.append(generateInputOutput(for: viewModel))
            }
            
            if vmConfig.generateCoordinator && !viewModel.navigationEvents.isEmpty {
                files.append(generateViewModelCoordinator(for: viewModel))
            }
        }
        
        return files
    }
    
    // MARK: - Loading
    
    private func loadViewModels() throws -> [ViewModelDefinition] {
        guard !inputPath.isEmpty else { return [] }
        
        let url = URL(fileURLWithPath: inputPath)
        let data = try Data(contentsOf: url)
        return try JSONDecoder().decode([ViewModelDefinition].self, from: data)
    }
    
    // MARK: - Base Protocol Generation
    
    private func generateViewModelProtocol() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        if vmConfig.bindingMechanism == .combine {
            lines.append("import Combine")
        }
        lines.append("")
        lines.append("// MARK: - ViewModel Protocol")
        lines.append("")
        lines.append("/// A protocol defining the base contract for all ViewModels.")
        lines.append("///")
        lines.append("/// ViewModels manage the presentation logic and state for views,")
        lines.append("/// providing a clean separation between UI and business logic.")
        
        if vmConfig.useMainActor {
            lines.append("@MainActor")
        }
        
        lines.append("public protocol ViewModel: AnyObject {")
        lines.append("")
        lines.append("\(indent)/// The state type for this ViewModel.")
        lines.append("\(indent)associatedtype State")
        lines.append("")
        lines.append("\(indent)/// The action type for this ViewModel.")
        lines.append("\(indent)associatedtype Action")
        lines.append("")
        lines.append("\(indent)/// The current state of the ViewModel.")
        lines.append("\(indent)var state: State { get }")
        lines.append("")
        
        if vmConfig.bindingMechanism == .combine {
            lines.append("\(indent)/// A publisher for state changes.")
            lines.append("\(indent)var statePublisher: AnyPublisher<State, Never> { get }")
            lines.append("")
        }
        
        lines.append("\(indent)/// Sends an action to the ViewModel.")
        lines.append("\(indent)/// - Parameter action: The action to perform.")
        lines.append("\(indent)func send(_ action: Action)")
        lines.append("")
        
        if vmConfig.generateLoadingStates {
            lines.append("\(indent)/// The current loading state.")
            lines.append("\(indent)var loadingState: LoadingState { get }")
            lines.append("")
        }
        
        if vmConfig.generateErrorHandling {
            lines.append("\(indent)/// The current error, if any.")
            lines.append("\(indent)var error: ViewModelError? { get }")
            lines.append("")
        }
        
        lines.append("}")
        lines.append("")
        
        // Observable ViewModel extension
        if vmConfig.bindingMechanism == .observation {
            lines.append("// MARK: - Observable ViewModel")
            lines.append("")
            lines.append("/// A ViewModel that uses the Observation framework.")
            lines.append("@available(iOS 17.0, macOS 14.0, tvOS 17.0, watchOS 10.0, *)")
            lines.append("@Observable")
            if vmConfig.useMainActor {
                lines.append("@MainActor")
            }
            lines.append("public class ObservableViewModel<State, Action> {")
            lines.append("")
            lines.append("\(indent)public var state: State")
            lines.append("")
            if vmConfig.generateLoadingStates {
                lines.append("\(indent)public var loadingState: LoadingState = .idle")
            }
            if vmConfig.generateErrorHandling {
                lines.append("\(indent)public var error: ViewModelError?")
            }
            lines.append("")
            lines.append("\(indent)public init(initialState: State) {")
            lines.append("\(indent)\(indent)self.state = initialState")
            lines.append("\(indent)}")
            lines.append("")
            lines.append("\(indent)public func send(_ action: Action) {")
            lines.append("\(indent)\(indent)// Override in subclass")
            lines.append("\(indent)}")
            lines.append("}")
            lines.append("")
        }
        
        return GeneratedFile(fileName: "ViewModel.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateViewModelState() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - ViewModel State")
        lines.append("")
        lines.append("/// A protocol for ViewModel state types.")
        lines.append("///")
        lines.append("/// States should be value types (structs) that represent the")
        lines.append("/// complete UI state at any given moment.")
        lines.append("public protocol ViewModelState: Equatable, Sendable {")
        lines.append("")
        lines.append("\(indent)/// Creates an initial/default state.")
        lines.append("\(indent)static var initial: Self { get }")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - Reducible State")
        lines.append("")
        lines.append("/// A state that can be reduced with actions.")
        lines.append("public protocol ReducibleState: ViewModelState {")
        lines.append("")
        lines.append("\(indent)/// The action type that can modify this state.")
        lines.append("\(indent)associatedtype Action")
        lines.append("")
        lines.append("\(indent)/// Reduces the state with an action.")
        lines.append("\(indent)/// - Parameter action: The action to apply.")
        lines.append("\(indent)/// - Returns: A new state after applying the action.")
        lines.append("\(indent)func reduce(action: Action) -> Self")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - State Container")
        lines.append("")
        lines.append("/// A container that holds and publishes state changes.")
        if vmConfig.useMainActor {
            lines.append("@MainActor")
        }
        lines.append("public final class StateContainer<State: ViewModelState>: ObservableObject {")
        lines.append("")
        lines.append("\(indent)/// The current state value.")
        lines.append("\(indent)@Published public private(set) var value: State")
        lines.append("")
        lines.append("\(indent)/// Creates a new state container.")
        lines.append("\(indent)public init(initialState: State = .initial) {")
        lines.append("\(indent)\(indent)self.value = initialState")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Updates the state.")
        lines.append("\(indent)public func update(_ newState: State) {")
        lines.append("\(indent)\(indent)value = newState")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Updates the state with a transformation.")
        lines.append("\(indent)public func update(_ transform: (inout State) -> Void) {")
        lines.append("\(indent)\(indent)var newState = value")
        lines.append("\(indent)\(indent)transform(&newState)")
        lines.append("\(indent)\(indent)value = newState")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "ViewModelState.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateLoadingState() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Loading State")
        lines.append("")
        lines.append("/// Represents the loading state of an operation.")
        lines.append("public enum LoadingState: Equatable, Sendable {")
        lines.append("")
        lines.append("\(indent)/// No operation is in progress.")
        lines.append("\(indent)case idle")
        lines.append("")
        lines.append("\(indent)/// An operation is in progress.")
        lines.append("\(indent)case loading")
        lines.append("")
        lines.append("\(indent)/// An operation is in progress with a message.")
        lines.append("\(indent)case loadingWithMessage(String)")
        lines.append("")
        lines.append("\(indent)/// An operation is in progress with progress value.")
        lines.append("\(indent)case loadingWithProgress(Double)")
        lines.append("")
        lines.append("\(indent)/// The operation completed successfully.")
        lines.append("\(indent)case success")
        lines.append("")
        lines.append("\(indent)/// The operation completed with a success message.")
        lines.append("\(indent)case successWithMessage(String)")
        lines.append("")
        lines.append("\(indent)/// The operation failed.")
        lines.append("\(indent)case failed")
        lines.append("")
        lines.append("\(indent)/// The operation failed with a message.")
        lines.append("\(indent)case failedWithMessage(String)")
        lines.append("")
        lines.append("\(indent)/// Whether the state represents loading.")
        lines.append("\(indent)public var isLoading: Bool {")
        lines.append("\(indent)\(indent)switch self {")
        lines.append("\(indent)\(indent)case .loading, .loadingWithMessage, .loadingWithProgress:")
        lines.append("\(indent)\(indent)\(indent)return true")
        lines.append("\(indent)\(indent)default:")
        lines.append("\(indent)\(indent)\(indent)return false")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Whether the state represents success.")
        lines.append("\(indent)public var isSuccess: Bool {")
        lines.append("\(indent)\(indent)switch self {")
        lines.append("\(indent)\(indent)case .success, .successWithMessage:")
        lines.append("\(indent)\(indent)\(indent)return true")
        lines.append("\(indent)\(indent)default:")
        lines.append("\(indent)\(indent)\(indent)return false")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Whether the state represents failure.")
        lines.append("\(indent)public var isFailed: Bool {")
        lines.append("\(indent)\(indent)switch self {")
        lines.append("\(indent)\(indent)case .failed, .failedWithMessage:")
        lines.append("\(indent)\(indent)\(indent)return true")
        lines.append("\(indent)\(indent)default:")
        lines.append("\(indent)\(indent)\(indent)return false")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// The progress value, if available.")
        lines.append("\(indent)public var progress: Double? {")
        lines.append("\(indent)\(indent)if case .loadingWithProgress(let value) = self {")
        lines.append("\(indent)\(indent)\(indent)return value")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)\(indent)return nil")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// The message, if available.")
        lines.append("\(indent)public var message: String? {")
        lines.append("\(indent)\(indent)switch self {")
        lines.append("\(indent)\(indent)case .loadingWithMessage(let msg),")
        lines.append("\(indent)\(indent)\(indent) .successWithMessage(let msg),")
        lines.append("\(indent)\(indent)\(indent) .failedWithMessage(let msg):")
        lines.append("\(indent)\(indent)\(indent)return msg")
        lines.append("\(indent)\(indent)default:")
        lines.append("\(indent)\(indent)\(indent)return nil")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - Async Loading State")
        lines.append("")
        lines.append("/// A generic loading state with success and failure types.")
        lines.append("public enum AsyncLoadingState<Success, Failure: Error>: Sendable where Success: Sendable {")
        lines.append("")
        lines.append("\(indent)/// Initial state, no operation started.")
        lines.append("\(indent)case idle")
        lines.append("")
        lines.append("\(indent)/// Operation is in progress.")
        lines.append("\(indent)case loading")
        lines.append("")
        lines.append("\(indent)/// Operation succeeded with a result.")
        lines.append("\(indent)case loaded(Success)")
        lines.append("")
        lines.append("\(indent)/// Operation failed with an error.")
        lines.append("\(indent)case failed(Failure)")
        lines.append("")
        lines.append("\(indent)/// The loaded value, if available.")
        lines.append("\(indent)public var value: Success? {")
        lines.append("\(indent)\(indent)if case .loaded(let value) = self {")
        lines.append("\(indent)\(indent)\(indent)return value")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)\(indent)return nil")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// The error, if available.")
        lines.append("\(indent)public var error: Failure? {")
        lines.append("\(indent)\(indent)if case .failed(let error) = self {")
        lines.append("\(indent)\(indent)\(indent)return error")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)\(indent)return nil")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Whether the state is loading.")
        lines.append("\(indent)public var isLoading: Bool {")
        lines.append("\(indent)\(indent)if case .loading = self { return true }")
        lines.append("\(indent)\(indent)return false")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "LoadingState.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateViewModelError() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - ViewModel Error")
        lines.append("")
        lines.append("/// Errors that can occur in ViewModels.")
        lines.append("public enum ViewModelError: LocalizedError, Equatable, Sendable {")
        lines.append("")
        lines.append("\(indent)/// A validation error occurred.")
        lines.append("\(indent)case validation(field: String, message: String)")
        lines.append("")
        lines.append("\(indent)/// A network error occurred.")
        lines.append("\(indent)case network(message: String)")
        lines.append("")
        lines.append("\(indent)/// An authentication error occurred.")
        lines.append("\(indent)case authentication(message: String)")
        lines.append("")
        lines.append("\(indent)/// An authorization error occurred.")
        lines.append("\(indent)case authorization(message: String)")
        lines.append("")
        lines.append("\(indent)/// The requested resource was not found.")
        lines.append("\(indent)case notFound(resource: String)")
        lines.append("")
        lines.append("\(indent)/// The operation was cancelled.")
        lines.append("\(indent)case cancelled")
        lines.append("")
        lines.append("\(indent)/// The operation timed out.")
        lines.append("\(indent)case timeout")
        lines.append("")
        lines.append("\(indent)/// A generic error with a message.")
        lines.append("\(indent)case generic(message: String)")
        lines.append("")
        lines.append("\(indent)/// An unknown error occurred.")
        lines.append("\(indent)case unknown")
        lines.append("")
        lines.append("\(indent)// MARK: - LocalizedError")
        lines.append("")
        lines.append("\(indent)public var errorDescription: String? {")
        lines.append("\(indent)\(indent)switch self {")
        lines.append("\(indent)\(indent)case .validation(let field, let message):")
        lines.append("\(indent)\(indent)\(indent)return \"\\(field): \\(message)\"")
        lines.append("\(indent)\(indent)case .network(let message):")
        lines.append("\(indent)\(indent)\(indent)return \"Network error: \\(message)\"")
        lines.append("\(indent)\(indent)case .authentication(let message):")
        lines.append("\(indent)\(indent)\(indent)return \"Authentication error: \\(message)\"")
        lines.append("\(indent)\(indent)case .authorization(let message):")
        lines.append("\(indent)\(indent)\(indent)return \"Authorization error: \\(message)\"")
        lines.append("\(indent)\(indent)case .notFound(let resource):")
        lines.append("\(indent)\(indent)\(indent)return \"\\(resource) not found\"")
        lines.append("\(indent)\(indent)case .cancelled:")
        lines.append("\(indent)\(indent)\(indent)return \"Operation cancelled\"")
        lines.append("\(indent)\(indent)case .timeout:")
        lines.append("\(indent)\(indent)\(indent)return \"Operation timed out\"")
        lines.append("\(indent)\(indent)case .generic(let message):")
        lines.append("\(indent)\(indent)\(indent)return message")
        lines.append("\(indent)\(indent)case .unknown:")
        lines.append("\(indent)\(indent)\(indent)return \"An unknown error occurred\"")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// The recovery suggestion for the error.")
        lines.append("\(indent)public var recoverySuggestion: String? {")
        lines.append("\(indent)\(indent)switch self {")
        lines.append("\(indent)\(indent)case .validation:")
        lines.append("\(indent)\(indent)\(indent)return \"Please correct the input and try again.\"")
        lines.append("\(indent)\(indent)case .network:")
        lines.append("\(indent)\(indent)\(indent)return \"Please check your internet connection and try again.\"")
        lines.append("\(indent)\(indent)case .authentication:")
        lines.append("\(indent)\(indent)\(indent)return \"Please sign in again.\"")
        lines.append("\(indent)\(indent)case .authorization:")
        lines.append("\(indent)\(indent)\(indent)return \"You don't have permission to perform this action.\"")
        lines.append("\(indent)\(indent)case .notFound:")
        lines.append("\(indent)\(indent)\(indent)return \"The requested resource could not be found.\"")
        lines.append("\(indent)\(indent)case .cancelled:")
        lines.append("\(indent)\(indent)\(indent)return nil")
        lines.append("\(indent)\(indent)case .timeout:")
        lines.append("\(indent)\(indent)\(indent)return \"Please try again.\"")
        lines.append("\(indent)\(indent)case .generic, .unknown:")
        lines.append("\(indent)\(indent)\(indent)return \"Please try again later.\"")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Creates a ViewModelError from any error.")
        lines.append("\(indent)public static func from(_ error: Error) -> ViewModelError {")
        lines.append("\(indent)\(indent)if let vmError = error as? ViewModelError {")
        lines.append("\(indent)\(indent)\(indent)return vmError")
        lines.append("\(indent)\(indent)}")
        lines.append("")
        lines.append("\(indent)\(indent)let nsError = error as NSError")
        lines.append("")
        lines.append("\(indent)\(indent)if nsError.domain == NSURLErrorDomain {")
        lines.append("\(indent)\(indent)\(indent)if nsError.code == NSURLErrorCancelled {")
        lines.append("\(indent)\(indent)\(indent)\(indent)return .cancelled")
        lines.append("\(indent)\(indent)\(indent)}")
        lines.append("\(indent)\(indent)\(indent)if nsError.code == NSURLErrorTimedOut {")
        lines.append("\(indent)\(indent)\(indent)\(indent)return .timeout")
        lines.append("\(indent)\(indent)\(indent)}")
        lines.append("\(indent)\(indent)\(indent)return .network(message: error.localizedDescription)")
        lines.append("\(indent)\(indent)}")
        lines.append("")
        lines.append("\(indent)\(indent)return .generic(message: error.localizedDescription)")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - Error Alertable")
        lines.append("")
        lines.append("/// A protocol for presenting errors as alerts.")
        lines.append("public protocol ErrorAlertable {")
        lines.append("\(indent)var alertTitle: String { get }")
        lines.append("\(indent)var alertMessage: String { get }")
        lines.append("\(indent)var alertActions: [AlertAction] { get }")
        lines.append("}")
        lines.append("")
        lines.append("/// An action for an alert.")
        lines.append("public struct AlertAction: Identifiable, Sendable {")
        lines.append("\(indent)public let id = UUID()")
        lines.append("\(indent)public let title: String")
        lines.append("\(indent)public let style: Style")
        lines.append("\(indent)public let handler: @Sendable () -> Void")
        lines.append("")
        lines.append("\(indent)public enum Style: Sendable {")
        lines.append("\(indent)\(indent)case `default`")
        lines.append("\(indent)\(indent)case cancel")
        lines.append("\(indent)\(indent)case destructive")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public init(title: String, style: Style = .default, handler: @escaping @Sendable () -> Void = {}) {")
        lines.append("\(indent)\(indent)self.title = title")
        lines.append("\(indent)\(indent)self.style = style")
        lines.append("\(indent)\(indent)self.handler = handler")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        lines.append("extension ViewModelError: ErrorAlertable {")
        lines.append("\(indent)public var alertTitle: String {")
        lines.append("\(indent)\(indent)switch self {")
        lines.append("\(indent)\(indent)case .validation:")
        lines.append("\(indent)\(indent)\(indent)return \"Validation Error\"")
        lines.append("\(indent)\(indent)case .network:")
        lines.append("\(indent)\(indent)\(indent)return \"Network Error\"")
        lines.append("\(indent)\(indent)case .authentication:")
        lines.append("\(indent)\(indent)\(indent)return \"Authentication Error\"")
        lines.append("\(indent)\(indent)case .authorization:")
        lines.append("\(indent)\(indent)\(indent)return \"Access Denied\"")
        lines.append("\(indent)\(indent)case .notFound:")
        lines.append("\(indent)\(indent)\(indent)return \"Not Found\"")
        lines.append("\(indent)\(indent)case .cancelled:")
        lines.append("\(indent)\(indent)\(indent)return \"Cancelled\"")
        lines.append("\(indent)\(indent)case .timeout:")
        lines.append("\(indent)\(indent)\(indent)return \"Timeout\"")
        lines.append("\(indent)\(indent)case .generic, .unknown:")
        lines.append("\(indent)\(indent)\(indent)return \"Error\"")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public var alertMessage: String {")
        lines.append("\(indent)\(indent)errorDescription ?? \"An error occurred\"")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)public var alertActions: [AlertAction] {")
        lines.append("\(indent)\(indent)[AlertAction(title: \"OK\", style: .default)]")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "ViewModelError.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateCoordinatorProtocol() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        if vmConfig.bindingMechanism == .combine {
            lines.append("import Combine")
        }
        lines.append("")
        lines.append("// MARK: - Coordinator Protocol")
        lines.append("")
        lines.append("/// A protocol for coordinators that handle navigation.")
        if vmConfig.useMainActor {
            lines.append("@MainActor")
        }
        lines.append("public protocol Coordinator: AnyObject {")
        lines.append("")
        lines.append("\(indent)/// The child coordinators.")
        lines.append("\(indent)var childCoordinators: [any Coordinator] { get set }")
        lines.append("")
        lines.append("\(indent)/// Starts the coordinator.")
        lines.append("\(indent)func start()")
        lines.append("")
        lines.append("\(indent)/// Stops the coordinator and cleans up.")
        lines.append("\(indent)func stop()")
        lines.append("}")
        lines.append("")
        lines.append("extension Coordinator {")
        lines.append("")
        lines.append("\(indent)/// Adds a child coordinator.")
        lines.append("\(indent)public func addChild(_ coordinator: any Coordinator) {")
        lines.append("\(indent)\(indent)childCoordinators.append(coordinator)")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Removes a child coordinator.")
        lines.append("\(indent)public func removeChild(_ coordinator: any Coordinator) {")
        lines.append("\(indent)\(indent)childCoordinators.removeAll { $0 === coordinator }")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)/// Removes all child coordinators.")
        lines.append("\(indent)public func removeAllChildren() {")
        lines.append("\(indent)\(indent)childCoordinators.forEach { $0.stop() }")
        lines.append("\(indent)\(indent)childCoordinators.removeAll()")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - Routing Protocol")
        lines.append("")
        lines.append("/// A protocol for routers that handle navigation destinations.")
        lines.append("public protocol Router {")
        lines.append("")
        lines.append("\(indent)/// The route type for this router.")
        lines.append("\(indent)associatedtype Route")
        lines.append("")
        lines.append("\(indent)/// Navigates to a route.")
        lines.append("\(indent)func navigate(to route: Route)")
        lines.append("")
        lines.append("\(indent)/// Goes back to the previous screen.")
        lines.append("\(indent)func goBack()")
        lines.append("")
        lines.append("\(indent)/// Goes back to the root screen.")
        lines.append("\(indent)func goToRoot()")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - Flow Coordinator")
        lines.append("")
        lines.append("/// A coordinator that manages a specific flow in the app.")
        if vmConfig.useMainActor {
            lines.append("@MainActor")
        }
        lines.append("open class FlowCoordinator<Route>: Coordinator {")
        lines.append("")
        lines.append("\(indent)// MARK: - Properties")
        lines.append("")
        lines.append("\(indent)public var childCoordinators: [any Coordinator] = []")
        
        if vmConfig.bindingMechanism == .combine {
            lines.append("\(indent)public let navigationSubject = PassthroughSubject<Route, Never>()")
            lines.append("\(indent)public var cancellables = Set<AnyCancellable>()")
        }
        
        lines.append("")
        lines.append("\(indent)// MARK: - Initialization")
        lines.append("")
        lines.append("\(indent)public init() {}")
        lines.append("")
        lines.append("\(indent)// MARK: - Coordinator")
        lines.append("")
        lines.append("\(indent)open func start() {")
        lines.append("\(indent)\(indent)// Override in subclass")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)open func stop() {")
        lines.append("\(indent)\(indent)removeAllChildren()")
        if vmConfig.bindingMechanism == .combine {
            lines.append("\(indent)\(indent)cancellables.removeAll()")
        }
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Navigation")
        lines.append("")
        lines.append("\(indent)open func navigate(to route: Route) {")
        if vmConfig.bindingMechanism == .combine {
            lines.append("\(indent)\(indent)navigationSubject.send(route)")
        }
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "Coordinator.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateNavigationEvent() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        lines.append("")
        lines.append("// MARK: - Navigation Event")
        lines.append("")
        lines.append("/// A protocol for navigation events emitted by ViewModels.")
        lines.append("public protocol NavigationEvent: Sendable {}")
        lines.append("")
        lines.append("// MARK: - Common Navigation Events")
        lines.append("")
        lines.append("/// Common navigation events used across the app.")
        lines.append("public enum CommonNavigationEvent: NavigationEvent {")
        lines.append("")
        lines.append("\(indent)/// Dismiss the current screen.")
        lines.append("\(indent)case dismiss")
        lines.append("")
        lines.append("\(indent)/// Go back to the previous screen.")
        lines.append("\(indent)case goBack")
        lines.append("")
        lines.append("\(indent)/// Go to the root of the navigation stack.")
        lines.append("\(indent)case goToRoot")
        lines.append("")
        lines.append("\(indent)/// Present an alert.")
        lines.append("\(indent)case showAlert(title: String, message: String)")
        lines.append("")
        lines.append("\(indent)/// Present a confirmation dialog.")
        lines.append("\(indent)case showConfirmation(title: String, message: String, confirm: String, cancel: String)")
        lines.append("")
        lines.append("\(indent)/// Open a URL.")
        lines.append("\(indent)case openURL(URL)")
        lines.append("")
        lines.append("\(indent)/// Share content.")
        lines.append("\(indent)case share(items: [Any])")
        lines.append("}")
        lines.append("")
        lines.append("// MARK: - Navigation Handler")
        lines.append("")
        lines.append("/// A handler for navigation events.")
        if vmConfig.useMainActor {
            lines.append("@MainActor")
        }
        lines.append("public protocol NavigationHandler {")
        lines.append("")
        lines.append("\(indent)/// The event type this handler can process.")
        lines.append("\(indent)associatedtype Event: NavigationEvent")
        lines.append("")
        lines.append("\(indent)/// Handles a navigation event.")
        lines.append("\(indent)func handle(_ event: Event)")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "NavigationEvent.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateInputOutputProtocol() -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        if vmConfig.bindingMechanism == .combine {
            lines.append("import Combine")
        }
        lines.append("")
        lines.append("// MARK: - Input/Output Protocol")
        lines.append("")
        lines.append("/// A protocol for ViewModels using the input/output pattern.")
        lines.append("///")
        lines.append("/// This pattern provides a clear contract between the View and ViewModel:")
        lines.append("/// - Input: Actions/events from the View")
        lines.append("/// - Output: State/results from the ViewModel")
        if vmConfig.useMainActor {
            lines.append("@MainActor")
        }
        lines.append("public protocol InputOutputViewModel {")
        lines.append("")
        lines.append("\(indent)/// The input type representing view events.")
        lines.append("\(indent)associatedtype Input")
        lines.append("")
        lines.append("\(indent)/// The output type representing ViewModel state.")
        lines.append("\(indent)associatedtype Output")
        lines.append("")
        lines.append("\(indent)/// Transforms inputs to outputs.")
        if vmConfig.bindingMechanism == .combine {
            lines.append("\(indent)func transform(input: Input) -> Output")
        } else {
            lines.append("\(indent)func transform(input: Input) async -> Output")
        }
        lines.append("}")
        lines.append("")
        
        if vmConfig.bindingMechanism == .combine {
            lines.append("// MARK: - Combine Input Types")
            lines.append("")
            lines.append("/// A container for Combine-based inputs.")
            lines.append("public struct CombineInput<Event> {")
            lines.append("")
            lines.append("\(indent)/// Publisher for view lifecycle events.")
            lines.append("\(indent)public let viewDidLoad: AnyPublisher<Void, Never>")
            lines.append("")
            lines.append("\(indent)/// Publisher for view appear events.")
            lines.append("\(indent)public let viewWillAppear: AnyPublisher<Void, Never>")
            lines.append("")
            lines.append("\(indent)/// Publisher for view disappear events.")
            lines.append("\(indent)public let viewWillDisappear: AnyPublisher<Void, Never>")
            lines.append("")
            lines.append("\(indent)/// Publisher for custom events.")
            lines.append("\(indent)public let events: AnyPublisher<Event, Never>")
            lines.append("")
            lines.append("\(indent)public init(")
            lines.append("\(indent)\(indent)viewDidLoad: AnyPublisher<Void, Never> = Empty().eraseToAnyPublisher(),")
            lines.append("\(indent)\(indent)viewWillAppear: AnyPublisher<Void, Never> = Empty().eraseToAnyPublisher(),")
            lines.append("\(indent)\(indent)viewWillDisappear: AnyPublisher<Void, Never> = Empty().eraseToAnyPublisher(),")
            lines.append("\(indent)\(indent)events: AnyPublisher<Event, Never> = Empty().eraseToAnyPublisher()")
            lines.append("\(indent)) {")
            lines.append("\(indent)\(indent)self.viewDidLoad = viewDidLoad")
            lines.append("\(indent)\(indent)self.viewWillAppear = viewWillAppear")
            lines.append("\(indent)\(indent)self.viewWillDisappear = viewWillDisappear")
            lines.append("\(indent)\(indent)self.events = events")
            lines.append("\(indent)}")
            lines.append("}")
            lines.append("")
            lines.append("// MARK: - Combine Output Types")
            lines.append("")
            lines.append("/// A container for Combine-based outputs.")
            lines.append("public struct CombineOutput<State, Effect> {")
            lines.append("")
            lines.append("\(indent)/// Publisher for state changes.")
            lines.append("\(indent)public let state: AnyPublisher<State, Never>")
            lines.append("")
            lines.append("\(indent)/// Publisher for loading state.")
            lines.append("\(indent)public let isLoading: AnyPublisher<Bool, Never>")
            lines.append("")
            lines.append("\(indent)/// Publisher for errors.")
            lines.append("\(indent)public let error: AnyPublisher<ViewModelError?, Never>")
            lines.append("")
            lines.append("\(indent)/// Publisher for side effects.")
            lines.append("\(indent)public let effects: AnyPublisher<Effect, Never>")
            lines.append("")
            lines.append("\(indent)public init(")
            lines.append("\(indent)\(indent)state: AnyPublisher<State, Never>,")
            lines.append("\(indent)\(indent)isLoading: AnyPublisher<Bool, Never> = Just(false).eraseToAnyPublisher(),")
            lines.append("\(indent)\(indent)error: AnyPublisher<ViewModelError?, Never> = Just(nil).eraseToAnyPublisher(),")
            lines.append("\(indent)\(indent)effects: AnyPublisher<Effect, Never> = Empty().eraseToAnyPublisher()")
            lines.append("\(indent)) {")
            lines.append("\(indent)\(indent)self.state = state")
            lines.append("\(indent)\(indent)self.isLoading = isLoading")
            lines.append("\(indent)\(indent)self.error = error")
            lines.append("\(indent)\(indent)self.effects = effects")
            lines.append("\(indent)}")
            lines.append("}")
            lines.append("")
        }
        
        return GeneratedFile(fileName: "InputOutputViewModel.swift", content: lines.joined(separator: "\n"))
    }
    
    // MARK: - ViewModel Generation
    
    private func generateViewModel(for viewModel: ViewModelDefinition) -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        let className = "\(viewModel.name)ViewModel"
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        if vmConfig.bindingMechanism == .combine {
            lines.append("import Combine")
        }
        for customImport in vmConfig.customImports {
            lines.append("import \(customImport)")
        }
        lines.append("")
        lines.append("// MARK: - \(viewModel.name) ViewModel")
        lines.append("")
        
        // State struct
        lines.append("/// State for \(viewModel.name) screen.")
        lines.append("public struct \(viewModel.name)State: ViewModelState {")
        lines.append("")
        for prop in viewModel.stateProperties {
            if let defaultValue = prop.defaultValue {
                lines.append("\(indent)public var \(prop.name): \(prop.type) = \(defaultValue)")
            } else {
                lines.append("\(indent)public var \(prop.name): \(prop.type)")
            }
        }
        if vmConfig.generateLoadingStates {
            lines.append("\(indent)public var loadingState: LoadingState = .idle")
        }
        if vmConfig.generateErrorHandling {
            lines.append("\(indent)public var error: ViewModelError?")
        }
        lines.append("")
        lines.append("\(indent)public static var initial: \(viewModel.name)State {")
        lines.append("\(indent)\(indent)\(viewModel.name)State(")
        let propInits = viewModel.stateProperties.map { prop -> String in
            if let defaultValue = prop.defaultValue {
                return "\(prop.name): \(defaultValue)"
            } else if prop.type.hasSuffix("?") {
                return "\(prop.name): nil"
            } else if prop.type == "String" {
                return "\(prop.name): \"\""
            } else if prop.type == "Int" || prop.type == "Double" {
                return "\(prop.name): 0"
            } else if prop.type == "Bool" {
                return "\(prop.name): false"
            } else if prop.type.hasPrefix("[") {
                return "\(prop.name): []"
            } else {
                return "\(prop.name): .init()"
            }
        }
        lines.append("\(indent)\(indent)\(indent)\(propInits.joined(separator: ",\n\(indent)\(indent)\(indent)"))")
        lines.append("\(indent)\(indent))")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        // Action enum
        lines.append("/// Actions for \(viewModel.name) screen.")
        lines.append("public enum \(viewModel.name)Action: Sendable {")
        for action in viewModel.actions {
            if action.parameters.isEmpty {
                lines.append("\(indent)case \(action.name)")
            } else {
                let params = action.parameters.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
                lines.append("\(indent)case \(action.name)(\(params))")
            }
        }
        lines.append("\(indent)case setError(ViewModelError?)")
        lines.append("\(indent)case clearError")
        lines.append("}")
        lines.append("")
        
        // ViewModel class
        lines.append("/// ViewModel for \(viewModel.name) screen.")
        if vmConfig.useMainActor {
            lines.append("@MainActor")
        }
        lines.append("public final class \(className): ObservableObject {")
        lines.append("")
        lines.append("\(indent)// MARK: - Published Properties")
        lines.append("")
        lines.append("\(indent)@Published public private(set) var state: \(viewModel.name)State = .initial")
        
        if vmConfig.generateLoadingStates {
            lines.append("\(indent)@Published public private(set) var loadingState: LoadingState = .idle")
        }
        if vmConfig.generateErrorHandling {
            lines.append("\(indent)@Published public var error: ViewModelError?")
        }
        
        lines.append("")
        lines.append("\(indent)// MARK: - Dependencies")
        lines.append("")
        for dep in viewModel.dependencies {
            if dep.isOptional {
                lines.append("\(indent)private var \(dep.name): \(dep.type)?")
            } else {
                lines.append("\(indent)private let \(dep.name): \(dep.type)")
            }
        }
        
        if vmConfig.bindingMechanism == .combine {
            lines.append("")
            lines.append("\(indent)// MARK: - Combine")
            lines.append("")
            lines.append("\(indent)private var cancellables = Set<AnyCancellable>()")
            
            if vmConfig.generateCoordinator && !viewModel.navigationEvents.isEmpty {
                lines.append("\(indent)private let navigationSubject = PassthroughSubject<\(viewModel.name)NavigationEvent, Never>()")
                lines.append("")
                lines.append("\(indent)public var navigationPublisher: AnyPublisher<\(viewModel.name)NavigationEvent, Never> {")
                lines.append("\(indent)\(indent)navigationSubject.eraseToAnyPublisher()")
                lines.append("\(indent)}")
            }
        }
        
        lines.append("")
        lines.append("\(indent)// MARK: - Initialization")
        lines.append("")
        
        let depParams = viewModel.dependencies.map { dep -> String in
            if dep.isOptional {
                return "\(dep.name): \(dep.type)? = nil"
            } else {
                return "\(dep.name): \(dep.type)"
            }
        }
        if depParams.isEmpty {
            lines.append("\(indent)public init() {}")
        } else {
            lines.append("\(indent)public init(")
            lines.append("\(indent)\(indent)\(depParams.joined(separator: ",\n\(indent)\(indent)"))")
            lines.append("\(indent)) {")
            for dep in viewModel.dependencies {
                lines.append("\(indent)\(indent)self.\(dep.name) = \(dep.name)")
            }
            lines.append("\(indent)}")
        }
        
        lines.append("")
        lines.append("\(indent)// MARK: - Actions")
        lines.append("")
        lines.append("\(indent)/// Sends an action to the ViewModel.")
        lines.append("\(indent)public func send(_ action: \(viewModel.name)Action) {")
        lines.append("\(indent)\(indent)switch action {")
        
        for action in viewModel.actions {
            if action.parameters.isEmpty {
                lines.append("\(indent)\(indent)case .\(action.name):")
                if action.isAsync {
                    lines.append("\(indent)\(indent)\(indent)Task { await handle\(action.name.capitalized)() }")
                } else {
                    lines.append("\(indent)\(indent)\(indent)handle\(action.name.capitalized)()")
                }
            } else {
                let paramNames = action.parameters.map { "let \($0.name)" }.joined(separator: ", ")
                lines.append("\(indent)\(indent)case .\(action.name)(\(paramNames)):")
                let paramArgs = action.parameters.map { $0.name }.joined(separator: ", ")
                if action.isAsync {
                    lines.append("\(indent)\(indent)\(indent)Task { await handle\(action.name.capitalized)(\(paramArgs)) }")
                } else {
                    lines.append("\(indent)\(indent)\(indent)handle\(action.name.capitalized)(\(paramArgs))")
                }
            }
        }
        
        lines.append("\(indent)\(indent)case .setError(let error):")
        lines.append("\(indent)\(indent)\(indent)self.error = error")
        lines.append("\(indent)\(indent)case .clearError:")
        lines.append("\(indent)\(indent)\(indent)self.error = nil")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        
        // Generate action handlers
        lines.append("\(indent)// MARK: - Action Handlers")
        lines.append("")
        
        for action in viewModel.actions {
            if let description = action.description {
                lines.append("\(indent)/// \(description)")
            }
            
            let paramDefs = action.parameters.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
            
            if action.isAsync {
                lines.append("\(indent)private func handle\(action.name.capitalized)(\(paramDefs)) async {")
                if vmConfig.generateLoadingStates {
                    lines.append("\(indent)\(indent)loadingState = .loading")
                }
                lines.append("\(indent)\(indent)do {")
                lines.append("\(indent)\(indent)\(indent)// TODO: Implement \(action.name) logic")
                if vmConfig.generateLoadingStates {
                    lines.append("\(indent)\(indent)\(indent)loadingState = .success")
                }
                lines.append("\(indent)\(indent)} catch {")
                if vmConfig.generateErrorHandling {
                    lines.append("\(indent)\(indent)\(indent)self.error = ViewModelError.from(error)")
                }
                if vmConfig.generateLoadingStates {
                    lines.append("\(indent)\(indent)\(indent)loadingState = .failed")
                }
                lines.append("\(indent)\(indent)}")
                lines.append("\(indent)}")
            } else {
                lines.append("\(indent)private func handle\(action.name.capitalized)(\(paramDefs)) {")
                lines.append("\(indent)\(indent)// TODO: Implement \(action.name) logic")
                lines.append("\(indent)}")
            }
            lines.append("")
        }
        
        // Generate navigation methods if coordinator is enabled
        if vmConfig.generateCoordinator && !viewModel.navigationEvents.isEmpty {
            lines.append("\(indent)// MARK: - Navigation")
            lines.append("")
            
            for event in viewModel.navigationEvents {
                lines.append("\(indent)/// Triggers navigation to \(event).")
                lines.append("\(indent)public func navigateTo\(event)() {")
                if vmConfig.bindingMechanism == .combine {
                    lines.append("\(indent)\(indent)navigationSubject.send(.\(event.lowercased()))")
                }
                lines.append("\(indent)}")
                lines.append("")
            }
        }
        
        // State update helper
        lines.append("\(indent)// MARK: - State Updates")
        lines.append("")
        lines.append("\(indent)/// Updates the state with a transformation.")
        lines.append("\(indent)private func updateState(_ transform: (inout \(viewModel.name)State) -> Void) {")
        lines.append("\(indent)\(indent)var newState = state")
        lines.append("\(indent)\(indent)transform(&newState)")
        lines.append("\(indent)\(indent)state = newState")
        lines.append("\(indent)}")
        
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "\(className).swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateInputOutput(for viewModel: ViewModelDefinition) -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        if vmConfig.bindingMechanism == .combine {
            lines.append("import Combine")
        }
        lines.append("")
        lines.append("// MARK: - \(viewModel.name) Input/Output")
        lines.append("")
        
        // Input type
        lines.append("/// Input events for \(viewModel.name) screen.")
        lines.append("public enum \(viewModel.name)Input {")
        lines.append("\(indent)case viewDidLoad")
        lines.append("\(indent)case viewWillAppear")
        lines.append("\(indent)case viewWillDisappear")
        for action in viewModel.actions {
            if action.parameters.isEmpty {
                lines.append("\(indent)case \(action.name)")
            } else {
                let params = action.parameters.map { "\($0.name): \($0.type)" }.joined(separator: ", ")
                lines.append("\(indent)case \(action.name)(\(params))")
            }
        }
        lines.append("}")
        lines.append("")
        
        // Output type
        lines.append("/// Output state for \(viewModel.name) screen.")
        lines.append("public struct \(viewModel.name)Output {")
        
        if vmConfig.bindingMechanism == .combine {
            lines.append("\(indent)public let state: AnyPublisher<\(viewModel.name)State, Never>")
            lines.append("\(indent)public let isLoading: AnyPublisher<Bool, Never>")
            lines.append("\(indent)public let error: AnyPublisher<ViewModelError?, Never>")
            
            if vmConfig.generateCoordinator && !viewModel.navigationEvents.isEmpty {
                lines.append("\(indent)public let navigation: AnyPublisher<\(viewModel.name)NavigationEvent, Never>")
            }
        } else {
            lines.append("\(indent)public let state: \(viewModel.name)State")
            lines.append("\(indent)public let isLoading: Bool")
            lines.append("\(indent)public let error: ViewModelError?")
        }
        
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "\(viewModel.name)InputOutput.swift", content: lines.joined(separator: "\n"))
    }
    
    private func generateViewModelCoordinator(for viewModel: ViewModelDefinition) -> GeneratedFile {
        let indent = String(repeating: " ", count: codeGenConfig.indentWidth)
        
        var lines: [String] = []
        lines.append(codeGenConfig.headerComment)
        lines.append("")
        lines.append("import Foundation")
        if vmConfig.bindingMechanism == .combine {
            lines.append("import Combine")
        }
        lines.append("")
        lines.append("// MARK: - \(viewModel.name) Navigation Events")
        lines.append("")
        lines.append("/// Navigation events for \(viewModel.name) screen.")
        lines.append("public enum \(viewModel.name)NavigationEvent: NavigationEvent {")
        for event in viewModel.navigationEvents {
            lines.append("\(indent)case \(event.lowercased())")
        }
        lines.append("\(indent)case dismiss")
        lines.append("\(indent)case goBack")
        lines.append("}")
        lines.append("")
        
        // Coordinator
        lines.append("// MARK: - \(viewModel.name) Coordinator")
        lines.append("")
        lines.append("/// Coordinator for \(viewModel.name) flow.")
        if vmConfig.useMainActor {
            lines.append("@MainActor")
        }
        lines.append("public final class \(viewModel.name)Coordinator: FlowCoordinator<\(viewModel.name)NavigationEvent> {")
        lines.append("")
        lines.append("\(indent)// MARK: - Properties")
        lines.append("")
        lines.append("\(indent)private weak var viewModel: \(viewModel.name)ViewModel?")
        lines.append("")
        lines.append("\(indent)// MARK: - Initialization")
        lines.append("")
        lines.append("\(indent)public init(viewModel: \(viewModel.name)ViewModel) {")
        lines.append("\(indent)\(indent)self.viewModel = viewModel")
        lines.append("\(indent)\(indent)super.init()")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)// MARK: - Coordinator")
        lines.append("")
        lines.append("\(indent)public override func start() {")
        lines.append("\(indent)\(indent)setupBindings()")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)private func setupBindings() {")
        
        if vmConfig.bindingMechanism == .combine {
            lines.append("\(indent)\(indent)viewModel?.navigationPublisher")
            lines.append("\(indent)\(indent)\(indent).sink { [weak self] event in")
            lines.append("\(indent)\(indent)\(indent)\(indent)self?.handle(event)")
            lines.append("\(indent)\(indent)\(indent)}")
            lines.append("\(indent)\(indent)\(indent).store(in: &cancellables)")
        }
        
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)private func handle(_ event: \(viewModel.name)NavigationEvent) {")
        lines.append("\(indent)\(indent)switch event {")
        
        for event in viewModel.navigationEvents {
            lines.append("\(indent)\(indent)case .\(event.lowercased()):")
            lines.append("\(indent)\(indent)\(indent)navigateTo\(event)()")
        }
        
        lines.append("\(indent)\(indent)case .dismiss:")
        lines.append("\(indent)\(indent)\(indent)dismiss()")
        lines.append("\(indent)\(indent)case .goBack:")
        lines.append("\(indent)\(indent)\(indent)goBack()")
        lines.append("\(indent)\(indent)}")
        lines.append("\(indent)}")
        lines.append("")
        
        // Navigation methods
        for event in viewModel.navigationEvents {
            lines.append("\(indent)private func navigateTo\(event)() {")
            lines.append("\(indent)\(indent)// TODO: Implement navigation to \(event)")
            lines.append("\(indent)}")
            lines.append("")
        }
        
        lines.append("\(indent)private func dismiss() {")
        lines.append("\(indent)\(indent)// TODO: Implement dismiss")
        lines.append("\(indent)}")
        lines.append("")
        lines.append("\(indent)private func goBack() {")
        lines.append("\(indent)\(indent)// TODO: Implement go back")
        lines.append("\(indent)}")
        lines.append("}")
        lines.append("")
        
        return GeneratedFile(fileName: "\(viewModel.name)Coordinator.swift", content: lines.joined(separator: "\n"))
    }
}
