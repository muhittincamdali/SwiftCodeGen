# SwiftCodeGen API Documentation

## CLI Usage

```bash
# Generate all
swiftcodegen generate

# Generate specific
swiftcodegen generate --mock
swiftcodegen generate --assets
swiftcodegen generate --localization

# With custom config
swiftcodegen generate --config ./custom.yml
```

## Generators

### Mock Generator

Generates mocks from protocols.

**Input:**
```swift
protocol UserService {
    func fetchUser(id: String) async throws -> User
    func updateUser(_ user: User) async throws
    var currentUser: User? { get }
}
```

**Output:**
```swift
final class MockUserService: UserService {
    // Call tracking
    var fetchUserCallCount = 0
    var fetchUserReceivedId: String?
    var fetchUserResult: Result<User, Error> = .failure(MockError.notConfigured)
    
    func fetchUser(id: String) async throws -> User {
        fetchUserCallCount += 1
        fetchUserReceivedId = id
        return try fetchUserResult.get()
    }
    
    // ... more generated code
}
```

### Asset Generator

Generates type-safe asset accessors.

**Input:** `Assets.xcassets`

**Output:**
```swift
enum Asset {
    enum Colors {
        static let primary = Color("Primary")
        static let secondary = Color("Secondary")
    }
    
    enum Images {
        static let logo = Image("Logo")
        static let background = Image("Background")
    }
}
```

### Localization Generator

Generates type-safe localization keys.

**Input:** `Localizable.strings`
```
"welcome_message" = "Welcome, %@!";
"items_count" = "%d items";
```

**Output:**
```swift
enum L10n {
    static func welcomeMessage(_ p1: String) -> String {
        String(format: NSLocalizedString("welcome_message", comment: ""), p1)
    }
    
    static func itemsCount(_ p1: Int) -> String {
        String(format: NSLocalizedString("items_count", comment: ""), p1)
    }
}
```

### DI Container Generator

Generates dependency injection containers.

**Input:**
```swift
@Injectable
final class UserRepository {
    init(api: API, cache: Cache) { }
}
```

**Output:**
```swift
extension Container {
    var userRepository: UserRepository {
        UserRepository(api: api, cache: cache)
    }
}
```

## Configuration

```yaml
# swiftcodegen.yml
version: "1.0"

mock:
  input: "./Sources/Services"
  output: "./Tests/Mocks"
  prefix: "Mock"
  
assets:
  input: "./Resources/Assets.xcassets"
  output: "./Sources/Generated/Assets.swift"
  
localization:
  input: "./Resources/*.lproj"
  output: "./Sources/Generated/L10n.swift"
  
di:
  input: "./Sources"
  output: "./Sources/Generated/Container.swift"
```

## Programmatic API

```swift
import SwiftCodeGen

let config = Config(path: "./swiftcodegen.yml")
let generator = SwiftCodeGen(config: config)

try generator.generate(types: [.mock, .assets])
```
