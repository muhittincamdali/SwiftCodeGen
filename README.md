<p align="center">
  <img src="Assets/logo.png" alt="SwiftCodeGen" width="200"/>
</p>

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
# swiftcodegen.yml
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
