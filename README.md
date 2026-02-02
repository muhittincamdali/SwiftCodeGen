# SwiftCodeGen

[![Swift](https://img.shields.io/badge/Swift-5.9+-orange.svg)](https://swift.org)
[![Platforms](https://img.shields.io/badge/Platforms-macOS%20%7C%20iOS%2015+-blue.svg)](https://developer.apple.com)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![SPM](https://img.shields.io/badge/SPM-Compatible-brightgreen.svg)](Package.swift)

**All-in-one Swift code generation toolkit.** Generate mocks, asset catalogs, localizations, DI containers, and data models from a single CLI or library integration.

---

## Table of Contents

- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Generators](#generators)
  - [Mock Generator](#mock-generator)
  - [Asset Generator](#asset-generator)
  - [Localization Generator](#localization-generator)
  - [DI Container Generator](#di-container-generator)
  - [Model Generator](#model-generator)
- [Configuration](#configuration)
- [CLI Usage](#cli-usage)
- [Library Integration](#library-integration)
- [Template Engine](#template-engine)
- [Architecture](#architecture)
- [Requirements](#requirements)
- [Contributing](#contributing)
- [License](#license)

---

## Features

| Feature | Description |
|---------|-------------|
| 🎭 **Mock Generation** | Auto-generate mock implementations from Swift protocols |
| 🎨 **Asset Catalogs** | Type-safe asset catalog accessors with compile-time checks |
| 🌍 **Localizations** | Generate strongly-typed string accessors from `.xcstrings` |
| 💉 **DI Containers** | Build dependency injection registration code automatically |
| 📦 **Model Generation** | Convert JSON schemas into Swift `Codable` models |
| ⚡ **Template Engine** | Flexible Mustache-like templates for custom generation |
| 🔧 **CLI + Library** | Use from command line or embed in your build pipeline |

---

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftCodeGen.git", from: "1.0.0")
]
```

### As a CLI Tool

```bash
git clone https://github.com/muhittincamdali/SwiftCodeGen.git
cd SwiftCodeGen
swift build -c release
cp .build/release/swiftcodegen /usr/local/bin/
```

### Mint

```bash
mint install muhittincamdali/SwiftCodeGen
```

---

## Quick Start

### 1. Create a Configuration File

```yaml
# swiftcodegen.yml
generators:
  - type: mock
    input: Sources/Protocols/
    output: Sources/Generated/Mocks/
  - type: assets
    input: Resources/Assets.xcassets
    output: Sources/Generated/Assets.swift
  - type: localization
    input: Resources/Localizable.xcstrings
    output: Sources/Generated/Strings.swift
```

### 2. Run the Generator

```bash
swiftcodegen generate --config swiftcodegen.yml
```

### 3. Check the Output

```
✅ Generated 12 mock files
✅ Generated Assets.swift (48 assets)
✅ Generated Strings.swift (156 keys)
```

---

## Generators

### Mock Generator

Parses Swift protocol declarations and generates full mock implementations with call tracking, stubbing, and verification.

```swift
// Input: Your protocol
protocol UserService {
    func fetchUser(id: String) async throws -> User
    func updateProfile(name: String, email: String) async throws
    var currentUser: User? { get }
}

// Output: Generated mock
class MockUserService: UserService {
    var fetchUserCallCount = 0
    var fetchUserReceivedId: String?
    var fetchUserReturnValue: User!

    func fetchUser(id: String) async throws -> User {
        fetchUserCallCount += 1
        fetchUserReceivedId = id
        return fetchUserReturnValue
    }

    var updateProfileCallCount = 0
    func updateProfile(name: String, email: String) async throws {
        updateProfileCallCount += 1
    }

    var currentUserValue: User?
    var currentUser: User? { currentUserValue }
}
```

### Asset Generator

Reads `.xcassets` catalogs and produces type-safe Swift accessors:

```swift
// Generated from Assets.xcassets
enum Asset {
    enum Colors {
        static let primary = Color("primary")
        static let secondary = Color("secondary")
        static let background = Color("background")
    }
    enum Images {
        static let logo = Image("logo")
        static let avatar = Image("avatar")
        static let placeholder = Image("placeholder")
    }
}
```

### Localization Generator

Processes `.xcstrings` files into strongly-typed accessors:

```swift
// Generated from Localizable.xcstrings
enum L10n {
    static let welcomeTitle = NSLocalizedString("welcome_title", comment: "")
    static func greeting(_ name: String) -> String {
        String(format: NSLocalizedString("greeting", comment: ""), name)
    }
    enum Settings {
        static let title = NSLocalizedString("settings_title", comment: "")
        static let logout = NSLocalizedString("settings_logout", comment: "")
    }
}
```

### DI Container Generator

Scans registrations and generates container setup code:

```swift
// Generated container
extension Container {
    func registerAll() {
        register(UserService.self) { UserServiceImpl() }
        register(AuthManager.self) { AuthManagerImpl(userService: self.resolve()) }
        register(ProfileViewModel.self) { ProfileViewModel(auth: self.resolve()) }
    }
}
```

### Model Generator

Converts JSON schemas or sample JSON into Swift structs:

```swift
// Input JSON:
// { "id": 1, "name": "John", "email": "john@example.com", "active": true }

// Generated:
struct User: Codable, Equatable, Sendable {
    let id: Int
    let name: String
    let email: String
    let active: Bool
}
```

---

## Configuration

Create `swiftcodegen.yml` in your project root:

```yaml
# Global settings
output_directory: Sources/Generated
indent: spaces
indent_width: 4
header_comment: "// Auto-generated — do not edit manually"

# Generator configurations
generators:
  - type: mock
    input: Sources/Protocols/
    output: Sources/Generated/Mocks/
    options:
      access_level: internal
      include_call_tracking: true
      include_stub_helpers: true

  - type: assets
    input: Resources/Assets.xcassets
    output: Sources/Generated/Assets.swift
    options:
      use_swiftui: true
      generate_previews: false

  - type: localization
    input: Resources/Localizable.xcstrings
    output: Sources/Generated/Strings.swift
    options:
      nested_enums: true
      generate_functions: true

  - type: model
    input: Schemas/
    output: Sources/Models/
    options:
      conformances: [Codable, Equatable, Sendable]
      optional_by_default: false
```

---

## CLI Usage

```bash
# Generate everything from config
swiftcodegen generate --config swiftcodegen.yml

# Generate only mocks
swiftcodegen generate --type mock --input Sources/Protocols/ --output Generated/

# Generate models from JSON
swiftcodegen model --input schema.json --output Models/User.swift

# Dry run (preview without writing)
swiftcodegen generate --config swiftcodegen.yml --dry-run

# Verbose output
swiftcodegen generate --config swiftcodegen.yml --verbose
```

---

## Library Integration

Use SwiftCodeGen as a library in your own build tools:

```swift
import SwiftCodeGen

let config = CodeGenConfig(
    outputDirectory: "Sources/Generated",
    indentWidth: 4
)

// Generate mocks programmatically
let parser = SwiftParser()
let protocols = try parser.parseProtocols(at: "Sources/Protocols/")

let mockGenerator = MockGenerator(config: config)
let mockFiles = try mockGenerator.generate(from: protocols)

let writer = FileWriter()
try writer.write(mockFiles, to: "Sources/Generated/Mocks/")
```

---

## Template Engine

SwiftCodeGen includes a lightweight template engine for custom generation:

```swift
let engine = TemplateEngine()

let template = """
class Mock{{name}}: {{name}} {
    {{#methods}}
    var {{name}}CallCount = 0
    func {{name}}({{params}}) {{returnClause}} {
        {{name}}CallCount += 1
    }
    {{/methods}}
}
"""

let output = engine.render(template, context: protocolContext)
```

---

## Architecture

```
SwiftCodeGen/
├── CLI/                    # Command-line interface (ArgumentParser)
├── Generators/             # Code generation engines
│   ├── MockGenerator       # Protocol → Mock class
│   ├── AssetGenerator      # .xcassets → Swift enums
│   ├── LocalizationGenerator # .xcstrings → Swift accessors
│   ├── DIContainerGenerator  # DI registrations
│   └── ModelGenerator      # JSON → Swift structs
├── Parsers/                # Source code & resource parsing
│   ├── SwiftParser         # Swift protocol/type parsing
│   └── AssetCatalogParser  # .xcassets parsing
├── Templates/              # Template engine & built-in templates
├── Configuration/          # Config file parsing
└── Utilities/              # File I/O helpers
```

---

## Requirements

| Requirement | Version |
|-------------|---------|
| Swift | 5.9+ |
| macOS | 13.0+ |
| iOS | 15.0+ |
| Xcode | 15.0+ |

---

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/new-generator`)
3. Write tests for new functionality
4. Ensure all tests pass (`swift test`)
5. Commit your changes (`git commit -m 'feat: add new generator'`)
6. Push to the branch (`git push origin feature/new-generator`)
7. Open a Pull Request

---

## Roadmap

- [ ] Xcode Build Plugin support
- [ ] SwiftUI preview generation
- [ ] CoreData model generation
- [ ] OpenAPI / Swagger codegen
- [ ] Watch for file changes (live mode)
- [ ] VSCode extension

---

## License

This project is licensed under the MIT License — see the [LICENSE](LICENSE) file for details.

---

Made with ❤️ for the Swift community.
