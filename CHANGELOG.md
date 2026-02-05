# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- Watch for file changes and regenerate automatically
- Xcode Build Phase integration script
- Configuration file support (`.swiftcodegen.yml`)

## [1.0.0] - 2024-01-15

### Added

#### Asset Generation
- Type-safe image references from `.xcassets`
- Type-safe color references
- Symbol image support (SF Symbols)
- Asset validation at compile time

#### String Generation
- Type-safe localization from `.strings` files
- Pluralization support
- String interpolation with typed parameters
- Multi-language validation

#### Mock Generation
- Automatic protocol mock generation
- Call tracking and verification
- Stub configuration for return values
- Async method mock support

#### DI Container Generation
- Dependency registration code generation
- Scope management (singleton, transient, scoped)
- Circular dependency detection
- Thread-safe container generation

#### Model Generation
- Codable model generation from JSON
- Custom coding keys support
- Optional property handling
- Nested model generation

#### CLI
- `swiftcodegen assets` command
- `swiftcodegen strings` command
- `swiftcodegen mocks` command
- `swiftcodegen di` command
- `swiftcodegen models` command
- Configurable input/output paths
- Verbose and dry-run modes

### Features
- Zero runtime dependencies
- Swift 6.0 strict concurrency compliance
- Homebrew installation support
- Swift Package Manager plugin

[Unreleased]: https://github.com/muhittincamdali/SwiftCodeGen/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/muhittincamdali/SwiftCodeGen/releases/tag/v1.0.0
