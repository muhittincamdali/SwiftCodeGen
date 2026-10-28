<!-- i18n-source: README.md@aafb1ff03311ce9811cf816cb4006c4bb83dac5a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg" alt="SwiftCodeGen: Swift macros that make a class Sendable without @unchecked and stream its changes."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml/badge.svg" alt="CI 상태"></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg" alt="최신 버전: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg" alt="지원 플랫폼: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg" alt="언어 버전: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg" alt="라이선스: MIT"></picture></a>
</p>

<p align="center">
<a href="#빠른-시작"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-ko-light.svg" alt="시작하기"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-ko-light.svg" alt="문서"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-ko-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-ko-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-ko-light.svg" alt="예제"></picture></a>
</p>

> 이 문서는 영어 README의 번역본입니다. 내용이 다를 경우 영어 버전이 최신입니다.

<!-- brand:end -->

SwiftCodeGen은 엄격한 동시성(strict concurrency)에서 흔해지는 한 가지 문제에 집중한 작은 Swift 6 매크로 패키지입니다. 그 문제란 동기 코드가 여러 스레드에서 상태를 공유하는 클래스, 예를 들어 캐시, 세션, 다운로드 delegate, 카운터입니다. Swift 6에서는 이런 클래스가 `Sendable`일 때만 스레드 사이를 넘나들 수 있습니다. 흔한 해법은 직접 작성한 락을 `@unchecked Sendable` 뒤에 두는 것(컴파일러가 더 이상 검사하지 않습니다)이거나, 모든 호출을 `await`로 바꾸는 actor를 쓰는 것입니다. 대신 `@Synchronized`를 붙이세요. 저장된 모든 `var`가 하나의 락으로 보호되고, `count += 1`이 업데이트를 잃지 않으며, `withLock`으로 여러 단계를 묶을 수 있고, 컴파일러 검사를 켠 채로 클래스가 `Sendable`이 됩니다. `@Streamed`는 프로퍼티의 값을 `AsyncStream`으로 제공하여 원하는 수의 구독자가 받을 수 있게 합니다.

## 주요 기능

- **검사되는 `Sendable`, `@unchecked` 없음** — 매크로가 실제 `Sendable` 준수를 추가하므로, `Sendable`이 아닌 타입의 `let`은 여전히 컴파일 오류입니다.
- **잃어버리는 업데이트 없음** — getter, setter, 제자리 변경(`+=`, `append`, `dict[key] =`)이 모두 락 안에서 실행됩니다. 테스트에서 동시에 수행한 2,000번의 `+=`는 정확히 2,000이 됩니다.
- **여러 단계를 하나로** — `withLock { … }`은 코드 블록 동안 락을 유지하며, 블록 안에서는 일반 프로퍼티 문법을 쓸 수 있고 타입이 지정된 오류(`throws(Failure)`)도 그대로 전달합니다.
- **다시 작성할 필요 없음** — 기본값, `init`의 `self.x = x`, 암시적 `nil`, `weak`, `unowned`가 계속 동작합니다. `let`, 계산 프로퍼티, `static` 프로퍼티는 건드리지 않습니다.
- **변경 스트림** — `@Streamed var progress: Double`은 `progressUpdates`를 추가합니다. 먼저 현재 값이, 그다음에 모든 변경이 순서대로 전달되고, 구독자마다 값 하나를 버퍼링하며, 객체가 사라지면 스트림이 끝납니다.
- **예기치 못한 동작 대신 오류** — struct, actor, final이 아닌 클래스, `@MainActor`, `lazy`, 옵저버, 프로퍼티 래퍼는 이유와 함께 거부되며, 해결 방법이 분명하면 수정 방법도 제시합니다.

## 빠른 시작

**1. 패키지 추가**

Xcode에서 **File › Add Package Dependencies…**를 선택하고, 저장소 URL을 입력한 다음 **SwiftCodeGen** 라이브러리를 타깃에 추가하세요. 첫 빌드에서 매크로에 대해 **Trust & Enable**을 선택합니다.

```text
https://github.com/muhittincamdali/SwiftCodeGen.git
```

**2. 모듈 가져오기**

```swift
import SwiftCodeGen
```

**3. final 클래스에 `@Synchronized` 붙이기**

어떤 스레드에서든 `await` 없이 사용할 수 있는 캐시입니다([ReadmeSamples.swift](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift)).

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

`ImageCache`는 이제 `Sendable`입니다. `Task.detached`, 태스크 그룹, 어떤 큐의 콜백에든 전달할 수 있고, `await` 없이 호출할 수 있습니다.

## 설치

### Swift Package Manager

`Package.swift`의 `dependencies`에 추가하세요.

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

이 패키지는 컴파일러가 매크로를 확장하는 데 쓰는 [swift-syntax](https://github.com/swiftlang/swift-syntax)(602~604)에 의존하지만, 그중 어떤 것도 앱에 링크되지 않습니다. `xcodebuild`를 쓰는 커맨드 라인 빌드에는 `-skipMacroValidation`이 필요하며, Xcode에서 한 번 신뢰하는 방법도 있습니다.

## 사용법

아래 샘플은 [`ReadmeSamples.swift`](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift)에서 복사한 것입니다. 예제 앱은 이 파일을 MainActor 기본 격리(default isolation)로 빌드하고, 테스트 스위트도 이 파일을 실행합니다.

### 여러 프로퍼티를 함께 변경하기

프로퍼티에 접근할 때마다 락이 걸린 한 단계로 처리됩니다. 함께 일어나야 하는 단계는 `withLock`에 넣으세요. 그러면 다른 어떤 스레드도 `progress`와 `status`가 서로 어긋난 상태를 보지 못합니다.

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

락은 재귀적이므로, `withLock` 안의 프로퍼티 접근은 같은 스레드에서 락을 다시 획득합니다. 두 스레드에서 두 객체의 락을 서로 반대 순서로 획득하지 마세요. 다른 모든 락 쌍과 마찬가지로 데드락이 발생합니다.

### `for await`로 변경 따라가기

`@Streamed`는 `UploadTracker`에 `progressUpdates`와 `statusUpdates` 프로퍼티를 추가했습니다. 읽을 때마다 현재 값으로 시작하는 새 스트림이 반환됩니다.

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

값은 락을 잡은 상태에서 전송되므로, 모든 구독자가 변경을 발생한 순서대로 받습니다. `Equatable` 타입에서는 프로퍼티가 이미 가진 값을 다시 대입해도 아무것도 전송되지 않습니다. MainActor 기본 격리를 쓰는 앱 타깃에서는 위의 `UploadStatus`처럼 이런 타입을 `nonisolated`로 선언하세요. 그렇지 않으면 준수가 메인 actor에 속하게 되어 대입할 때마다 값이 전송됩니다. 뒤처진 구독자는 가장 최신 값만 유지합니다. 스트림은 객체가 해제되면 끝나며, 스트림이 객체를 살려 두지는 않습니다.

### 이니셜라이저와 약한 참조

프로퍼티는 이니셜라이저에서도 계속 동작하고, 옵셔널은 `nil`로 시작하며, `weak`는 약한 참조로 남습니다.

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

### 매크로가 작성하는 코드

Xcode에서 **Editor › Expand Macro**를 사용하면 어떤 클래스의 코드든 볼 수 있습니다. `var hits = 0`의 경우는 다음과 같습니다.

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

여기에 더해 클래스마다 한 번씩 `private let _lock = SwiftCodeGen.SynchronizedLock()`, `withLock` 메서드, `extension ImageCache: Sendable {}`가 추가됩니다. 저장소가 `nonisolated(unsafe)`인 이유는 컴파일러가 아니라 락이 이를 보호하기 때문이며, 클래스의 나머지 멤버는 모두 계속 검사됩니다.

### 매크로가 거부하는 것

| 선언 | 오류와 제안하는 수정 방법 |
| --- | --- |
| `struct`, `enum` | 값 타입은 저장 프로퍼티가 `Sendable`이면 `Sendable`입니다. |
| `actor` | actor는 이미 상태를 보호합니다. |
| `final`이 없는 `class` | 서브클래스가 락으로 보호되지 않는 상태를 추가할 수 있습니다. 수정: `final`을 추가하세요. |
| 클래스 또는 프로퍼티의 `@MainActor` | 락이 actor 격리를 대신합니다. 수정: 제거하세요. |
| `lazy var` | 수정: `lazy`를 제거하세요. |
| `willSet` / `didSet` | 코드를 해당 프로퍼티를 설정하는 메서드로 옮기세요. |
| 프로퍼티 래퍼 | 저장소가 보호되지 않습니다. |
| `var a = 0, b = 1`, `var (a, b) = …` | 프로퍼티마다 한 줄씩 따로 선언하세요. |
| `let`, `static`, 계산 프로퍼티, `weak` 프로퍼티, 타입이 없는 프로퍼티에 붙인 `@Streamed` | 각각 고유한 메시지가 표시됩니다. |

프로퍼티를 일부러 제외하려면 `nonisolated(unsafe)`로 표시하세요.

## 데모

[`Examples/SyncDemo`](Examples/SyncDemo)의 예제 앱은 iPhone이나 Mac에서 두 매크로를 모두 실행합니다. 아래 스크린샷은 Mac 빌드에서 [`scripts/capture-mac-screens.sh`](scripts/capture-mac-screens.sh)로 촬영한 것이며, [`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh)는 같은 화면을 iPhone 시뮬레이터에서 촬영합니다.

| 공유 카운터 | 업로드 진행률 |
| --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-counter-dark.png"><img src="docs/images/demo-counter-light.png" width="320" alt="공유 카운터: 여덟 개의 태스크가 각각 20,000번씩 1을 더합니다. 락이 걸린 한 단계로는 160,000이 되고, 락이 걸린 두 단계로는 업데이트를 잃습니다"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-upload-dark.png"><img src="docs/images/demo-upload-light.png" width="320" alt="업로드 진행률: 한 구독자는 21개의 값을 받은 뒤 100퍼센트를 표시하고, 다른 구독자는 대기 중, 업로드 중, 완료를 각각 한 번씩 표시합니다"></picture> |

## 문서

- [SwiftCodeGen 레퍼런스](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/)
- [시작하기](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/gettingstarted)
- [변경 사항 스트리밍](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/streamingchanges)
- [도구 고르기](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/choosingatool)

## 가이드

- [시작하기](Sources/SwiftCodeGen/SwiftCodeGen.docc/GettingStarted.md) — 매크로가 무엇을 바꾸는지, `withLock`, MainActor 기본 격리, 거부되는 선언.
- [변경 사항 스트리밍](Sources/SwiftCodeGen/SwiftCodeGen.docc/StreamingChanges.md) — 구독자가 받는 것, 스트림이 끝나는 시점, 단독으로 쓰는 `StreamBroadcast`.
- [도구 고르기](Sources/SwiftCodeGen/SwiftCodeGen.docc/ChoosingATool.md) — actor, `Mutex` 또는 다른 패키지가 더 나은 선택인 경우.

## 다른 도구를 써야 할 때

SwiftCodeGen은 범용 코드 생성기가 아닙니다. 잘 알려진 도구들이 하는 일에는 그 도구를 사용하세요.

| 필요한 것 | 사용할 것 |
| --- | --- |
| 작업이 `async`인 상태(네트워크, 디스크) | `actor`: 메서드가 일시 중단될 수 있으며, 락은 `await`를 가로질러 잡고 있으면 안 됩니다. |
| iOS 18+에서 보호할 값이 한두 개 | Synchronization 모듈의 `Mutex`. |
| SwiftUI가 관찰하는 UI 상태 | 메인 actor의 `@Observable`. |
| 프로토콜의 목(mock)과 스파이(spy) | [Mockable](https://github.com/Kolos65/Mockable), [swift-spyable](https://github.com/Matejkob/swift-spyable) |
| 여러 타입에 걸쳐 템플릿으로 생성하는 코드 | [Sourcery](https://github.com/krzysztofzablocki/Sourcery) |
| OpenAPI 문서에서 만드는 클라이언트와 서버 | [swift-openapi-generator](https://github.com/apple/swift-openapi-generator) |
| 이미지, 색상, 문자열의 타입이 지정된 이름 | Xcode가 생성하는 에셋 및 String Catalog 심볼. 폰트, plist 및 기타 파일에는 [SwiftGen](https://github.com/SwiftGen/SwiftGen) |
| 재시도, 타임아웃, single-flight 요청 | [SwiftConcurrency](https://github.com/muhittincamdali/SwiftConcurrency) |

## 요구 사항

| 플랫폼 | 최소 버전 |
| --- | --- |
| iOS | 16 |
| macOS | 13 |
| tvOS | 16 |
| watchOS | 9 |
| visionOS | 1 |
| 툴체인 | Swift 6.2 · Xcode 26+ |

## 아키텍처

| 타깃 | 내용 |
| --- | --- |
| `SwiftCodeGen` | 매크로 선언, `SynchronizedLock`(재귀 락), `StreamBroadcast`(다중 구독자 `AsyncStream`) |
| `SwiftCodeGenMacros` | 컴파일러 플러그인: `SynchronizedMacro`(member, member-attribute, extension 역할), `SynchronizedPropertyMacro`(접근자와 저장소), `StreamedMacro`(검사), `PropertyAnalysis`, 진단 |
| `SwiftCodeGenTests` | macOS와 iOS 시뮬레이터에서의 런타임 테스트: 동시성, 스트림, README 샘플 |
| `SwiftCodeGenMainActorTests` | 새 앱처럼 MainActor 기본 격리를 쓰는 타깃에서의 매크로 |
| `SwiftCodeGenMacrosTests` | 정확한 확장 결과와 모든 진단 및 해당 fix-it(macOS) |

- **프로퍼티마다가 아니라 객체마다 락 하나.** 재귀 락 하나 덕분에 `withLock`이 여러 프로퍼티를 함께 다룰 수 있고, 그 안의 코드가 일반 프로퍼티 문법을 쓸 수 있습니다.
- **body 매크로가 아니라 init 접근자.** 저장소를 `@storageRestrictions(initializes:)`로 초기화하므로, 이니셜라이저와 기본값이 모든 Swift 6.2 컴파일러에서 작성한 그대로 동작합니다.
- **락 안에서의 `_modify`.** 제자리 변경은 락을 잡은 상태에서 저장소를 yield합니다. 이것이 `+=`와 `append`를 원자적으로 만듭니다. `weak` 또는 `unowned` 프로퍼티에는 `get`과 `set`만 생성됩니다.

## 로드맵

- 스트림 프로퍼티의 이름을 지정하는 옵션(`@Streamed(as: "progressStream")`).
- public 클래스를 위한, 선택적으로 켜는 public `withLock`(`@Synchronized(.publicLock)`). 현재는 모듈 밖의 코드가 락을 잡을 수 없도록 internal입니다.
- CI에서의 Linux 지원: 이 패키지는 Foundation의 `NSRecursiveLock`과 `NSLock`만 사용하지만, 테스트는 Apple 플랫폼에서만 합니다.

## 기여하기

기여를 환영합니다. pull request를 열기 전에 [기여 가이드](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CONTRIBUTING.md)와 [행동 강령](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CODE_OF_CONDUCT.md)을 읽어 주세요. 보안 문제는 [보안 정책](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/SECURITY.md)에 따라 비공개로 제보해 주세요.

## 라이선스

MIT 라이선스로 배포됩니다. 자세한 내용은 [LICENSE](LICENSE)를 참고하세요.
