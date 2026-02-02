import ArgumentParser
import Foundation

@main
struct SwiftCodeGenCLI: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "swiftcodegen",
        abstract: "All-in-one Swift code generation toolkit",
        version: "1.0.0",
        subcommands: [Generate.self, Model.self, Mock.self],
        defaultSubcommand: Generate.self
    )
}

// MARK: - Generate Command

struct Generate: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Run code generation from configuration file"
    )

    @Option(name: .shortAndLong, help: "Path to the configuration file")
    var config: String = "swiftcodegen.yml"

    @Option(name: .shortAndLong, help: "Only run a specific generator type")
    var type: String?

    @Option(name: .long, help: "Override input path")
    var input: String?

    @Option(name: .long, help: "Override output path")
    var output: String?

    @Flag(name: .long, help: "Preview changes without writing files")
    var dryRun = false

    @Flag(name: .shortAndLong, help: "Enable verbose logging")
    var verbose = false

    mutating func run() throws {
        let configURL = URL(fileURLWithPath: config)
        guard FileManager.default.fileExists(atPath: configURL.path) else {
            throw ValidationError("Configuration file not found at: \(config)")
        }

        if verbose {
            print("📖 Loading configuration from \(config)")
        }

        let parsedConfig = try CodeGenConfig.load(from: configURL)
        let generators = buildGenerators(from: parsedConfig)

        for generator in generators {
            if let filterType = type, generator.generatorType != filterType {
                continue
            }

            if verbose {
                print("⚙️  Running \(generator.generatorType) generator...")
            }

            let results = try generator.generate()

            if dryRun {
                print("📋 [DRY RUN] Would generate \(results.count) files")
                for result in results {
                    print("   → \(result.fileName)")
                }
            } else {
                let writer = FileWriter()
                let outputPath = output ?? generator.outputPath
                try writer.write(results, to: outputPath)
                print("✅ Generated \(results.count) files → \(outputPath)")
            }
        }
    }

    private func buildGenerators(from config: CodeGenConfig) -> [any CodeGenerator] {
        var generators: [any CodeGenerator] = []

        for entry in config.generators {
            let inputPath = input ?? entry.inputPath
            let outputPath = output ?? entry.outputPath

            switch entry.type {
            case "mock":
                generators.append(MockGenerator(inputPath: inputPath, outputPath: outputPath, config: config))
            case "assets":
                generators.append(AssetGenerator(inputPath: inputPath, outputPath: outputPath, config: config))
            case "localization":
                generators.append(LocalizationGenerator(inputPath: inputPath, outputPath: outputPath, config: config))
            case "di":
                generators.append(DIContainerGenerator(inputPath: inputPath, outputPath: outputPath, config: config))
            case "model":
                generators.append(ModelGenerator(inputPath: inputPath, outputPath: outputPath, config: config))
            default:
                print("⚠️  Unknown generator type: \(entry.type)")
            }
        }

        return generators
    }
}

// MARK: - Model Command

struct Model: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate Swift models from JSON files"
    )

    @Option(name: .shortAndLong, help: "Input JSON file or directory")
    var input: String

    @Option(name: .shortAndLong, help: "Output Swift file or directory")
    var output: String

    @Flag(name: .long, help: "Make all properties optional")
    var optionalProperties = false

    mutating func run() throws {
        let config = CodeGenConfig.default
        let generator = ModelGenerator(inputPath: input, outputPath: output, config: config)
        let results = try generator.generate()
        let writer = FileWriter()
        try writer.write(results, to: output)
        print("✅ Generated \(results.count) model files → \(output)")
    }
}

// MARK: - Mock Command

struct Mock: ParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate mock implementations from Swift protocols"
    )

    @Option(name: .shortAndLong, help: "Input Swift source directory")
    var input: String

    @Option(name: .shortAndLong, help: "Output directory for generated mocks")
    var output: String

    @Option(name: .long, help: "Access level for generated types")
    var accessLevel: String = "internal"

    mutating func run() throws {
        let config = CodeGenConfig.default
        let generator = MockGenerator(inputPath: input, outputPath: output, config: config)
        let results = try generator.generate()
        let writer = FileWriter()
        try writer.write(results, to: output)
        print("✅ Generated \(results.count) mock files → \(output)")
    }
}
