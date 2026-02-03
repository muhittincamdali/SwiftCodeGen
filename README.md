<div align="center">

# ⚙️ SwiftCodeGen

**All-in-one Swift code generator - mocks, assets, localization & DI**

[![Swift](https://img.shields.io/badge/Swift-5.9+-F05138?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org)
[![SPM](https://img.shields.io/badge/SPM-Compatible-FA7343?style=for-the-badge&logo=swift&logoColor=white)](https://swift.org/package-manager/)
[![License](https://img.shields.io/badge/License-MIT-green?style=for-the-badge)](LICENSE)

</div>

---

## ✨ Features

- 🎭 **Mock Generation** — Auto-generate mocks from protocols
- 🖼️ **Asset Catalogs** — Type-safe asset access
- 🌍 **Localization** — Compile-time checked strings
- 💉 **DI Container** — Generate dependency graphs
- 🔧 **CLI Tool** — Easy CI/CD integration

---

## 🚀 Quick Start

```bash
# Generate mocks
swift run swiftcodegen mock Sources/

# Generate assets
swift run swiftcodegen assets Assets.xcassets

# Generate strings
swift run swiftcodegen strings Localizable.strings
```

```swift
// Generated code
let image = Asset.Icons.checkmark
let text = L10n.welcome("John")
```

---

## 📄 License

MIT • [@muhittincamdali](https://github.com/muhittincamdali)
