<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-FA7343?style=for-the-badge&logo=swift&logoColor=white" alt="Swift 6.0"/>
  <img src="https://img.shields.io/badge/Platform-iOS%20|%20macOS%20|%20visionOS-007AFF?style=for-the-badge&logo=apple&logoColor=white" alt="Platform"/>
  <img src="https://img.shields.io/badge/Standard-Unified%20Core-5856D6?style=for-the-badge" alt="Standard"/>
</p>

---

> **🛡️ PART OF THE 2026 UNIFIED CORE**
> This repository is a verified component of 'The Endless March' initiative. Purified for Swift 6, zero-dependency, and engineered for maximum hardware saturation.
> 
> *Flagship Engines:* [SwiftNetwork](https://github.com/muhittincamdali/SwiftNetwork) | [SwiftAI](https://github.com/muhittincamdali/SwiftAI) | [LiquidGlassKit](https://github.com/muhittincamdali/LiquidGlassKit)

---

<h1 align="center">SwiftCodeGen</h1>

<p align="center">
  <strong>⚙️ All-in-one Swift code generator - mocks, assets, localization & DI</strong>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.0-orange.svg" alt="Swift"/>
  <img src="https://img.shields.io/badge/license-MIT-green.svg" alt="License"/>
</p>

---

## Features

| Generator | Description |
|-----------|-------------|
| 🎨 **Assets** | Type-safe image & color references |
| 🌍 **Strings** | Type-safe localization |
| 🧪 **Mocks** | Protocol mock generation |
| 💉 **DI** | Dependency container generation |
| 📦 **Models** | Codable model generation |

## Quick Start

```bash
# Install
brew install swiftcodegen

# Generate assets
swiftcodegen assets --input Assets.xcassets --output Sources/Assets.swift

# Generate strings
swiftcodegen strings --input Localizable.strings --output Sources/Strings.swift

# Generate mocks
swiftcodegen mocks --input Sources/ --output Tests/Mocks/
```

## Assets Generation

```swift
// Generated
enum Assets {
    enum Images {
        static let logo = UIImage(named: "logo")!
        static let background = UIImage(named: "background")!
    }
    enum Colors {
        static let primary = UIColor(named: "primary")!
        static let secondary = UIColor(named: "secondary")!
    }
}

// Usage
imageView.image = Assets.Images.logo
view.backgroundColor = Assets.Colors.primary
```

## Strings Generation

```swift
// Generated
enum L10n {
    static let welcomeTitle = NSLocalizedString("welcome_title", comment: "")
    static func itemsCount(_ count: Int) -> String {
        String(format: NSLocalizedString("items_count", comment: ""), count)
    }
}

// Usage
titleLabel.text = L10n.welcomeTitle
subtitleLabel.text = L10n.itemsCount(5)
```

## Mocks Generation

```swift
// Source protocol
protocol UserRepository {
    func getUser(id: String) async throws -> User
}

// Generated mock
class MockUserRepository: UserRepository {
    var getUserResult: Result<User, Error> = .failure(MockError())
    var getUserCallCount = 0
    var getUserArguments: [String] = []
    
    func getUser(id: String) async throws -> User {
        getUserCallCount += 1
        getUserArguments.append(id)
        return try getUserResult.get()
    }
}
```

## Configuration

```yaml
# swiftcodegen

## 🚀 Killer Feature: OpenAPI 3 to Swift 6 Generator
Don't write boilerplate network code. Feed your `swagger.json` to the engine, and it will instantly generate a 100% Swift 6 compliant, Actor-isolated `SwiftNetwork` client..yml
assets:
  input: Resources/Assets.xcassets
  output: Sources/Generated/Assets.swift

strings:
  input: Resources/Localizable.strings
  output: Sources/Generated/Strings.swift

mocks:
  input: Sources/Protocols/
  output: Tests/Generated/Mocks/
  protocols:
    - "*Repository"
    - "*Service"
```

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

MIT License

---

## 📈 Star History

<a href="https://star-history.com/#muhittincamdali/SwiftCodeGen&Date">
 <picture>
   <source media="(prefers-color-scheme: dark)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/SwiftCodeGen&type=Date&theme=dark" />
   <source media="(prefers-color-scheme: light)" srcset="https://api.star-history.com/svg?repos=muhittincamdali/SwiftCodeGen&type=Date" />
   <img alt="Star History Chart" src="https://api.star-history.com/svg?repos=muhittincamdali/SwiftCodeGen&type=Date" />
 </picture>
</a>
