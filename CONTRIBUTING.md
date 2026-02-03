# Contributing to SwiftCodeGen

Thank you for your interest in contributing! 🛠️

## Adding New Generators

### 1. Create Generator Module

```swift
// Sources/SwiftCodeGen/Generators/MyGenerator.swift

public struct MyGenerator: Generator {
    public let name = "myfeature"
    public let description = "Generates my feature code"
    
    public func generate(config: Config) throws -> [GeneratedFile] {
        // Parse input
        // Generate code
        // Return files
    }
}
```

### 2. Register Generator

```swift
// Sources/SwiftCodeGen/CLI/Commands.swift
static let generators: [Generator] = [
    MockGenerator(),
    AssetGenerator(),
    MyGenerator(), // Add here
]
```

### 3. Add Tests

```swift
final class MyGeneratorTests: XCTestCase {
    func testBasicGeneration() throws {
        let generator = MyGenerator()
        let files = try generator.generate(config: .test)
        
        XCTAssertEqual(files.count, 1)
        XCTAssertTrue(files[0].content.contains("expected"))
    }
}
```

### 4. Document in README

Add usage examples and configuration options.

## Code Style

Generated code should:
- Follow Swift API Design Guidelines
- Include proper documentation
- Be formatted consistently
- Handle edge cases gracefully

## Pull Request Checklist

- [ ] Generator works correctly
- [ ] Unit tests pass
- [ ] Documentation updated
- [ ] CHANGELOG entry added
- [ ] CLI help text updated

Thank you for contributing! 🙏
