<!-- i18n-source: README.md@aafb1ff03311ce9811cf816cb4006c4bb83dac5a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg" alt="SwiftCodeGen: Swift macros that make a class Sendable without @unchecked and stream its changes."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml/badge.svg" alt="CI 状态"></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg" alt="最新版本: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg" alt="支持的平台: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg" alt="语言版本: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg" alt="许可证: MIT"></picture></a>
</p>

<p align="center">
<a href="#快速开始"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-zh-CN-light.svg" alt="开始使用"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-zh-CN-light.svg" alt="文档"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-zh-CN-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-zh-CN-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-zh-CN-light.svg" alt="示例"></picture></a>
</p>

> 本文是英文 README 的译文。如两者内容不一致，以英文版为准。

<!-- brand:end -->

SwiftCodeGen 是一个小巧的 Swift 6 宏软件包，专门解决严格并发（strict concurrency）下很常见的一个问题：某个类的状态由同步代码在多个线程间共享，例如缓存、会话、下载 delegate 或计数器。Swift 6 只允许这样的类在线程间传递，前提是它符合 `Sendable`。常见的做法要么是手写一把锁，再用 `@unchecked Sendable` 包起来，这样编译器就不再检查；要么改用 actor，但这会让每次调用都变成 `await`。不妨改用 `@Synchronized`：每个存储的 `var` 都由同一把锁保护，`count += 1` 不会丢失更新，`withLock` 可以把多个步骤合为一体，而类在编译器检查保持开启的情况下成为 `Sendable`。`@Streamed` 则为属性的值提供 `AsyncStream`，可供任意数量的订阅者使用。

## 亮点

- **经过检查的 `Sendable`，无需 `@unchecked`** — 宏会添加真正的 `Sendable` 一致性，因此非 `Sendable` 类型的 `let` 仍然是编译错误。
- **不丢失更新** — getter、setter 和原地修改（`+=`、`append`、`dict[key] =`）都在锁内执行；测试中 2,000 次并发的 `+=` 恰好得到 2,000。
- **多个步骤合为一步** — `withLock { … }` 在一段代码内持有锁，块内可使用普通的属性语法，并会透传类型化错误（`throws(Failure)`）。
- **无需改写代码** — 默认值、`init` 中的 `self.x = x`、隐式的 `nil`、`weak` 和 `unowned` 都照常工作；`let`、计算属性和 `static` 属性不受影响。
- **变化流** — `@Streamed var progress: Double` 会添加 `progressUpdates`：先给出当前值，然后按顺序给出每一次变化；每个订阅者缓冲一个值，对象销毁时流结束。
- **用报错代替意外** — struct、actor、非 final 的类、`@MainActor`、`lazy`、属性观察器和属性包装器都会被拒绝并给出原因；在修复方式明确时还会给出修复建议。

## 快速开始

**1. 添加软件包**

在 Xcode 中选择 **File › Add Package Dependencies…**，输入仓库地址，并把 **SwiftCodeGen** 库添加到你的 target。首次构建时，请为宏选择 **Trust & Enable**。

```text
https://github.com/muhittincamdali/SwiftCodeGen.git
```

**2. 导入模块**

```swift
import SwiftCodeGen
```

**3. 把 `@Synchronized` 添加到 final 类上**

一个任何线程都可以不用 `await` 就使用的缓存（[ReadmeSamples.swift](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift)）：

```swift
@Synchronized
final class ImageCache {
    var images: [URL: Data] = [:]
    var hits = 0
    var misses = 0

    func image(for url: URL) -> Data? {
        // Reading the cache and counting the hit or miss happen as one step.
        withLock {
            if let data = images[url] {
                hits += 1
                return data
            }
            misses += 1
            return nil
        }
    }

    func store(_ data: Data, for url: URL) {
        images[url] = data
    }
}
```

`ImageCache` 现在是 `Sendable` 了：可以把它传给 `Task.detached`、task group 或任意队列上的回调，并且无需 `await` 就能调用。

## 安装

### Swift Package Manager

把它添加到 `Package.swift` 的 `dependencies` 中：

```swift
dependencies: [
    .package(url: "https://github.com/muhittincamdali/SwiftCodeGen.git", branch: "main")
],
targets: [
    .target(name: "YourApp", dependencies: [
        .product(name: "SwiftCodeGen", package: "SwiftCodeGen")
    ])
]
```

该软件包依赖 [swift-syntax](https://github.com/swiftlang/swift-syntax)（602 至 604），编译器用它来展开宏；它的任何部分都不会链接进你的 App。使用 `xcodebuild` 的命令行构建需要加上 `-skipMacroValidation`，或者在 Xcode 中一次性授予信任。

## 使用方法

下面的示例复制自 [`ReadmeSamples.swift`](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift)；示例 App 使用 MainActor 默认隔离（default isolation）构建它，测试套件也会运行它。

### 同时修改多个属性

每次属性访问都是一个加锁的步骤。需要一起完成的步骤放进 `withLock`，这样其他线程就不会看到 `progress` 和 `status` 互相不一致：

```swift
// `nonisolated`: with MainActor default isolation, the Equatable conformance would otherwise be
// isolated to the main actor, and the stream could not skip repeated values off the main actor.
nonisolated enum UploadStatus: Sendable, Equatable {
    case waiting
    case uploading
    case finished
}

/// Progress that a background upload writes and any number of views read.
@Synchronized
final class UploadTracker {
    let totalChunks: Int
    @Streamed var progress: Double = 0
    @Streamed var status: UploadStatus = .waiting
    private var sentChunks = 0

    init(totalChunks: Int) {
        precondition(totalChunks > 0, "An upload has at least one chunk")
        self.totalChunks = totalChunks
    }

    func chunkSent() {
        // The three properties change together; a reader never sees them disagree.
        withLock {
            sentChunks = min(sentChunks + 1, totalChunks)
            progress = Double(sentChunks) / Double(totalChunks)
            status = sentChunks < totalChunks ? .uploading : .finished
        }
    }
}
```

这把锁是递归锁，所以 `withLock` 内部的属性访问会在同一线程上再次获取它。不要在两个线程上以相反的顺序获取两个对象的锁；与任何一对锁一样，这会导致死锁。

### 用 `for await` 跟踪变化

`@Streamed` 为 `UploadTracker` 提供了 `progressUpdates` 和 `statusUpdates` 两个属性。每次读取都会返回一个以当前值开头的新流：

```swift
/// Waits until the upload has finished and returns the statuses it went through.
func waitForUpload(_ tracker: UploadTracker) async -> [UploadStatus] {
    var seen: [UploadStatus] = []
    for await status in tracker.statusUpdates {
        seen.append(status)
        if status == .finished { break }
    }
    return seen
}
```

值是在持有锁的情况下发送的，所以每个订阅者看到的变化顺序与实际发生的顺序一致。对于 `Equatable` 类型，把属性已有的值再赋给它不会发送任何内容；在使用 MainActor 默认隔离的 App target 中，请像上面的 `UploadStatus` 那样把这样的类型声明为 `nonisolated`，否则它的一致性属于主 actor，每次赋值都会被发送。跟不上的订阅者只保留最新的值。对象被释放时流随之结束，而流本身不会让对象保持存活。

### 初始化器与弱引用

属性在初始化器中照常工作，可选类型从 `nil` 开始，`weak` 仍然是弱引用：

```swift
@Synchronized
final class Session {
    let id: UUID
    var token: String
    var expiresAt: Date?
    weak var observer: SessionObserver?

    init(token: String) {
        id = UUID()
        self.token = token
    }
}
```

### 宏生成了什么

在 Xcode 中使用 **Editor › Expand Macro** 可以查看任意类的展开代码。对于 `var hits = 0`，结果如下：

```swift
var hits {
    @storageRestrictions(initializes: _hits)
    init(initialValue) {
        _hits = initialValue
    }
    get {
        _lock.lock()
        defer {
            _lock.unlock()
        }
        return _hits
    }
    set {
        _lock.lock()
        defer {
            _lock.unlock()
        }
        _hits = newValue
    }
    _modify {
        _lock.lock()
        defer {
            _lock.unlock()
        }
        yield &_hits
    }
}

nonisolated(unsafe) private var _hits = 0
```

此外，每个类还会生成一次 `private let _lock = SwiftCodeGen.SynchronizedLock()`、`withLock` 方法和 `extension ImageCache: Sendable {}`。存储属性之所以是 `nonisolated(unsafe)`，是因为由锁而不是编译器来保护它；类的其他所有成员仍然会被检查。

### 宏会拒绝什么

| 声明 | 错误及其给出的修复建议 |
| --- | --- |
| `struct`、`enum` | 值类型的存储属性都是 `Sendable` 时，它本身就是 `Sendable`。 |
| `actor` | actor 本身已经保护了它的状态。 |
| 没有 `final` 的 `class` | 子类可能添加锁无法保护的状态。修复：添加 `final`。 |
| 类或属性上的 `@MainActor` | 锁取代了 actor 隔离。修复：移除它。 |
| `lazy var` | 修复：移除 `lazy`。 |
| `willSet` / `didSet` | 把代码移到设置该属性的方法中。 |
| 属性包装器 | 它的存储不会受到保护。 |
| `var a = 0, b = 1`、`var (a, b) = …` | 每个属性单独声明一行。 |
| 位于 `let`、`static`、计算属性、`weak` 属性或未标注类型的属性上的 `@Streamed` | 每种情况都有各自的提示信息。 |

如果要有意把某个属性排除在外，请将其标记为 `nonisolated(unsafe)`。

## 演示

[`Examples/SyncDemo`](Examples/SyncDemo) 中的示例 App 可在 iPhone 或 Mac 上运行这两个宏。下面的截图由 [`scripts/capture-mac-screens.sh`](scripts/capture-mac-screens.sh) 从它的 Mac 版本中截取；[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) 则在 iPhone 模拟器上截取相同的画面。

| 共享计数器 | 上传进度 |
| --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-counter-dark.png"><img src="docs/images/demo-counter-light.png" width="320" alt="共享计数器：八个任务各自加一 20,000 次；一个加锁步骤计数为 160,000，两个加锁步骤则会丢失更新"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-upload-dark.png"><img src="docs/images/demo-upload-light.png" width="320" alt="上传进度：一个订阅者在收到 21 个值后显示 100%，另一个订阅者依次各显示一次“等待中”“上传中”“已完成”"></picture> |

## 文档

- [SwiftCodeGen 参考文档](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/)
- [入门](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/gettingstarted)
- [流式获取变化](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/streamingchanges)
- [如何选择工具](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/choosingatool)

## 指南

- [入门](Sources/SwiftCodeGen/SwiftCodeGen.docc/GettingStarted.md) — 宏做了哪些改动、`withLock`、MainActor 默认隔离，以及它会拒绝的声明。
- [流式获取变化](Sources/SwiftCodeGen/SwiftCodeGen.docc/StreamingChanges.md) — 订阅者会收到什么、流何时结束，以及单独使用 `StreamBroadcast`。
- [如何选择工具](Sources/SwiftCodeGen/SwiftCodeGen.docc/ChoosingATool.md) — 什么时候 actor、`Mutex` 或其他软件包是更好的选择。

## 何时改用其他工具

SwiftCodeGen 不是通用的代码生成器。对于那些知名工具擅长的工作，请使用它们：

| 你需要 | 使用 |
| --- | --- |
| 工作内容是 `async` 的状态（网络、磁盘） | `actor`：它的方法可以挂起，而锁不能跨 `await` 持有。 |
| iOS 18+ 上一两个受保护的值 | Synchronization 模块中的 `Mutex`。 |
| SwiftUI 观察的界面状态 | 主 actor 上的 `@Observable`。 |
| 协议的 mock 和 spy | [Mockable](https://github.com/Kolos65/Mockable)、[swift-spyable](https://github.com/Matejkob/swift-spyable) |
| 从模板为许多类型生成代码 | [Sourcery](https://github.com/krzysztofzablocki/Sourcery) |
| 根据 OpenAPI 文档生成客户端和服务端 | [swift-openapi-generator](https://github.com/apple/swift-openapi-generator) |
| 图片、颜色和字符串的类型化名称 | Xcode 生成的资源和 String Catalog 符号；字体、plist 和其他文件使用 [SwiftGen](https://github.com/SwiftGen/SwiftGen) |
| 重试、超时、single-flight 请求 | [SwiftConcurrency](https://github.com/muhittincamdali/SwiftConcurrency) |

## 系统要求

| 平台 | 最低版本 |
| --- | --- |
| iOS | 16 |
| macOS | 13 |
| tvOS | 16 |
| watchOS | 9 |
| visionOS | 1 |
| 工具链 | Swift 6.2 · Xcode 26+ |

## 架构

| Target | 内容 |
| --- | --- |
| `SwiftCodeGen` | 宏声明、`SynchronizedLock`（递归锁）和 `StreamBroadcast`（多订阅者 `AsyncStream`） |
| `SwiftCodeGenMacros` | 编译器插件：`SynchronizedMacro`（member、member-attribute 和 extension 角色）、`SynchronizedPropertyMacro`（访问器与存储）、`StreamedMacro`（检查）、`PropertyAnalysis` 以及各类诊断 |
| `SwiftCodeGenTests` | 在 macOS 和 iOS 模拟器上的运行时测试：并发、流、README 示例 |
| `SwiftCodeGenMainActorTests` | 在使用 MainActor 默认隔离的 target 中测试这些宏，就像一个新建的 App |
| `SwiftCodeGenMacrosTests` | 精确的展开结果，以及每条诊断及其 fix-it（macOS） |

- **每个对象一把锁，而不是每个属性一把。** 正是一把递归锁让 `withLock` 能够覆盖多个属性，并让其中的代码使用普通的属性语法。
- **使用 init accessor，而不是 body 宏。** 存储通过 `@storageRestrictions(initializes:)` 初始化，因此在每一个 Swift 6.2 编译器上，初始化器和默认值都能按所写的方式工作。
- **在锁内执行 `_modify`。** 原地修改在持有锁的同时 yield 存储，这正是 `+=` 和 `append` 成为原子操作的原因。`weak` 或 `unowned` 属性只有 `get` 和 `set`。

## 路线图

- 提供为流属性命名的选项（`@Streamed(as: "progressStream")`）。
- 为 public 类提供可选的 public `withLock`（`@Synchronized(.publicLock)`）；目前它是 internal 的，这样模块之外的代码就无法持有这把锁。
- 在 CI 中支持 Linux：该软件包只使用 Foundation 的 `NSRecursiveLock` 和 `NSLock`，但目前只在 Apple 平台上测试过。

## 参与贡献

欢迎参与贡献。提交 pull request 之前，请先阅读[贡献指南](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CONTRIBUTING.md)和[行为准则](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CODE_OF_CONDUCT.md)。如发现安全问题，请按照[安全策略](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/SECURITY.md)私下报告。

## 许可证

基于 MIT 许可证发布。详见 [LICENSE](LICENSE)。
