# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- SwiftData model generation
- Macro-based code generation

## [1.2.0] - 2026-02-06

### Added
- **Mock Generation**
  - Protocol mock generation
  - Spy generation with call tracking
  - Stub generation with default values
  - Fake implementation generation

- **Asset Generation**
  - Type-safe asset catalogs
  - Color palette generation
  - Image asset enums
  - Symbol names generation

- **Localization**
  - Localizable.strings parser
  - Type-safe localization keys
  - Pluralization support
  - String interpolation handling

- **Dependency Injection**
  - Container generation
  - Protocol witness generation
  - Factory pattern templates
  - Environment-based configuration

- **Model Generation**
  - Codable models from JSON
  - CoreData model generation
  - Realm model generation
  - GraphQL type generation

### Changed
- Improved CLI performance
- Better error messages with suggestions

### Fixed
- Nested type handling in mocks
- Unicode support in localization

## [1.1.0] - 2026-01-15

### Added
- SwiftUI view scaffolding
- Test file generation
- MVVM template generation

## [1.0.0] - 2026-01-01

### Added
- Initial release with core generators
- CLI tool with configuration support

[Unreleased]: https://github.com/muhittincamdali/SwiftCodeGen/compare/v1.2.0...HEAD
[1.2.0]: https://github.com/muhittincamdali/SwiftCodeGen/compare/v1.1.0...v1.2.0
[1.1.0]: https://github.com/muhittincamdali/SwiftCodeGen/compare/v1.0.0...v1.1.0
[1.0.0]: https://github.com/muhittincamdali/SwiftCodeGen/releases/tag/v1.0.0
