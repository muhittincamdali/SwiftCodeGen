<!-- i18n-source: README.md@aafb1ff03311ce9811cf816cb4006c4bb83dac5a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg" alt="SwiftCodeGen: Swift macros that make a class Sendable without @unchecked and stream its changes."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml/badge.svg" alt="CI ステータス"></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg" alt="最新バージョン: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg" alt="対応プラットフォーム: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg" alt="言語バージョン: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg" alt="ライセンス: MIT"></picture></a>
</p>

<p align="center">
<a href="#クイックスタート"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-ja-light.svg" alt="はじめる"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-ja-light.svg" alt="ドキュメント"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-ja-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-ja-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-ja-light.svg" alt="サンプル"></picture></a>
</p>

> このドキュメントは英語版 README の翻訳です。内容が異なる場合は英語版が最新です。

<!-- brand:end -->

SwiftCodeGen は、厳格な並行性（strict concurrency）のもとでよく起こる 1 つの問題に絞った、小さな Swift 6 マクロパッケージです。対象は、同期コードが複数のスレッドで状態を共有するクラス（キャッシュ、セッション、ダウンロードの delegate、カウンターなど）です。Swift 6 では、そのようなクラスをスレッド間で受け渡せるのは `Sendable` に準拠している場合だけです。よくある対処は、手書きのロックを `@unchecked Sendable` の裏に置く方法（コンパイラはもう検査しません）か、すべての呼び出しを `await` に変える actor を使う方法です。代わりに `@Synchronized` を付けてください。保存されたすべての `var` が 1 つのロックで保護され、`count += 1` が更新を失うことはなく、`withLock` で複数のステップをまとめられ、コンパイラの検査を有効にしたままクラスが `Sendable` になります。`@Streamed` は、プロパティの値を `AsyncStream` として、任意の数のサブスクライバーに届けます。

## 主な特長

- **検査される `Sendable`、`@unchecked` は不要** — マクロは本物の `Sendable` 準拠を追加するため、`Sendable` でない型の `let` は引き続きコンパイルエラーになります。
- **更新が失われない** — getter、setter、その場での変更（`+=`、`append`、`dict[key] =`）はすべてロックの下で実行されます。テストでは、2,000 回の並行 `+=` がちょうど 2,000 になります。
- **複数のステップを 1 つに** — `withLock { … }` はコードのブロックの間ロックを保持し、ブロック内では通常のプロパティ構文を使えます。型付きエラー（`throws(Failure)`）もそのまま伝わります。
- **書き直しは不要** — デフォルト値、`init` 内の `self.x = x`、暗黙の `nil`、`weak`、`unowned` はそのまま動作します。`let`、計算プロパティ、`static` プロパティには手を加えません。
- **変更のストリーム** — `@Streamed var progress: Double` は `progressUpdates` を追加します。最初に現在の値、その後は変更が順番に届き、サブスクライバーごとに 1 つの値をバッファし、オブジェクトが解放されると終了します。
- **予期せぬ動作ではなくエラーに** — struct、actor、final でないクラス、`@MainActor`、`lazy`、オブザーバー、プロパティラッパーは、理由つきで拒否されます。修正方法が明確な場合は、その修正も示されます。

## クイックスタート

**1. パッケージを追加する**

Xcode で **File › Add Package Dependencies…** を選び、リポジトリの URL を入力して、**SwiftCodeGen** ライブラリをターゲットに追加します。最初のビルドでは、マクロに対して **Trust & Enable** を選んでください。

```text
https://github.com/muhittincamdali/SwiftCodeGen.git
```

**2. モジュールをインポートする**

```swift
import SwiftCodeGen
```

**3. final クラスに `@Synchronized` を付ける**

どのスレッドからでも `await` なしで使えるキャッシュです（[ReadmeSamples.swift](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift)）。

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

`ImageCache` は `Sendable` になりました。`Task.detached`、タスクグループ、任意のキューのコールバックに渡せ、`await` なしで呼び出せます。

## インストール

### Swift Package Manager

`Package.swift` の `dependencies` に追加します。

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

このパッケージは [swift-syntax](https://github.com/swiftlang/swift-syntax)（602 から 604）に依存しています。コンパイラがマクロを展開するために使うもので、アプリにはリンクされません。`xcodebuild` を使ったコマンドラインのビルドでは `-skipMacroValidation` が必要です。Xcode で一度だけ信頼を許可する方法もあります。

## 使い方

以下のサンプルは [`ReadmeSamples.swift`](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift) からコピーしたものです。サンプルアプリは MainActor のデフォルト分離（default isolation）でこのファイルをビルドし、テストスイートも実行します。

### 複数のプロパティをまとめて変更する

プロパティへのアクセスは、それぞれロックされた 1 ステップです。一緒に行うべきステップは `withLock` に入れてください。そうすれば、他のスレッドから `progress` と `status` が食い違って見えることはありません。

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

ロックは再帰的なので、`withLock` 内のプロパティアクセスは同じスレッドで再びロックを取得します。2 つのオブジェクトのロックを、2 つのスレッドで逆の順序で取得しないでください。他のあらゆるロックの組み合わせと同様に、デッドロックになります。

### `for await` で変更を追う

`@Streamed` によって、`UploadTracker` に `progressUpdates` と `statusUpdates` が追加されました。読み取るたびに、現在の値から始まる新しいストリームが返されます。

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

値はロックを保持している間に送られるため、すべてのサブスクライバーが変更を発生した順に受け取ります。`Equatable` な型では、プロパティがすでに持っている値を代入しても何も送られません。MainActor のデフォルト分離を使うアプリターゲットでは、上の `UploadStatus` のようにそうした型を `nonisolated` にしてください。そうしないと準拠がメインアクターに属し、代入のたびに値が送られます。遅れているサブスクライバーには最新の値だけが残ります。ストリームはオブジェクトが解放されると終了し、ストリームがオブジェクトを存続させることはありません。

### イニシャライザと弱参照

プロパティはイニシャライザ内でもそのまま動作し、オプショナルは `nil` から始まり、`weak` は弱いままです。

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

### マクロが書き出すコード

Xcode の **Editor › Expand Macro** を使うと、任意のクラスについてコードを確認できます。`var hits = 0` の場合は次のようになります。

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

これに加えて、クラスごとに 1 度だけ `private let _lock = SwiftCodeGen.SynchronizedLock()`、`withLock` メソッド、`extension ImageCache: Sendable {}` が追加されます。ストレージが `nonisolated(unsafe)` なのは、コンパイラではなくロックがそれを守るためです。クラスの他のメンバーはこれまでどおり検査されます。

### マクロが拒否するもの

| 宣言 | エラーと、示される修正 |
| --- | --- |
| `struct`、`enum` | 値型は、保存プロパティが `Sendable` であれば `Sendable` です。 |
| `actor` | actor はすでに状態を保護しています。 |
| `final` でない `class` | サブクラスがロックで守られない状態を追加する可能性があります。修正: `final` を付けます。 |
| クラスまたはプロパティの `@MainActor` | ロックが actor による分離の代わりになります。修正: 取り除きます。 |
| `lazy var` | 修正: `lazy` を取り除きます。 |
| `willSet` / `didSet` | コードを、そのプロパティを設定するメソッドに移します。 |
| プロパティラッパー | ストレージが保護されなくなります。 |
| `var a = 0, b = 1`、`var (a, b) = …` | プロパティは 1 行に 1 つずつ宣言します。 |
| `let`、`static`、計算プロパティ、`weak`、または型のないプロパティへの `@Streamed` | それぞれ専用のメッセージが表示されます。 |

特定のプロパティをあえて対象外にするには、`nonisolated(unsafe)` を付けます。

## デモ

[`Examples/SyncDemo`](Examples/SyncDemo) のサンプルアプリは、iPhone または Mac で両方のマクロを実行します。以下のスクリーンショットは、その Mac 版から [`scripts/capture-mac-screens.sh`](scripts/capture-mac-screens.sh) で撮影したものです。[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) を使うと、同じ画面を iPhone シミュレータで撮影できます。

| 共有カウンター | アップロードの進捗 |
| --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-counter-dark.png"><img src="docs/images/demo-counter-light.png" width="320" alt="共有カウンター: 8 つのタスクがそれぞれ 20,000 回ずつ 1 を加算します。ロックされた 1 ステップでは 160,000 になり、ロックされた 2 ステップでは更新が失われます"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-upload-dark.png"><img src="docs/images/demo-upload-light.png" width="320" alt="アップロードの進捗: 一方のサブスクライバーは 21 個の値の後に 100% を表示し、もう一方は「待機中」「アップロード中」「完了」を 1 回ずつ表示します"></picture> |

## ドキュメント

- [SwiftCodeGen リファレンス](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/)
- [はじめに](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/gettingstarted)
- [変更のストリーミング](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/streamingchanges)
- [ツールの選び方](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/choosingatool)

## ガイド

- [はじめに](Sources/SwiftCodeGen/SwiftCodeGen.docc/GettingStarted.md) — マクロが何を変えるか、`withLock`、MainActor のデフォルト分離、拒否される宣言。
- [変更のストリーミング](Sources/SwiftCodeGen/SwiftCodeGen.docc/StreamingChanges.md) — サブスクライバーが受け取るもの、ストリームが終了するタイミング、単体で使う `StreamBroadcast`。
- [ツールの選び方](Sources/SwiftCodeGen/SwiftCodeGen.docc/ChoosingATool.md) — actor、`Mutex`、他のパッケージのほうが適している場合。

## 他のツールを使うべき場合

SwiftCodeGen は汎用のコードジェネレーターではありません。定評のあるツールが得意とする作業には、そちらを使ってください。

| やりたいこと | 使うもの |
| --- | --- |
| 処理が `async`（ネットワーク、ディスク）である状態 | `actor`。メソッドは中断できますが、ロックは `await` をまたいで保持してはいけません。 |
| iOS 18+ で、保護する値が 1、2 個 | Synchronization モジュールの `Mutex`。 |
| SwiftUI が監視する UI の状態 | メインアクター上の `@Observable`。 |
| プロトコルのモックとスパイ | [Mockable](https://github.com/Kolos65/Mockable)、[swift-spyable](https://github.com/Matejkob/swift-spyable) |
| 多数の型にまたがるテンプレートからのコード生成 | [Sourcery](https://github.com/krzysztofzablocki/Sourcery) |
| OpenAPI ドキュメントからのクライアントとサーバー | [swift-openapi-generator](https://github.com/apple/swift-openapi-generator) |
| 画像、色、文字列の型付きの名前 | Xcode が生成するアセットと String Catalog のシンボル。フォント、plist、その他のファイルには [SwiftGen](https://github.com/SwiftGen/SwiftGen) |
| リトライ、タイムアウト、single-flight リクエスト | [SwiftConcurrency](https://github.com/muhittincamdali/SwiftConcurrency) |

## 動作要件

| プラットフォーム | 最小バージョン |
| --- | --- |
| iOS | 16 |
| macOS | 13 |
| tvOS | 16 |
| watchOS | 9 |
| visionOS | 1 |
| ツールチェーン | Swift 6.2 · Xcode 26+ |

## アーキテクチャ

| ターゲット | 内容 |
| --- | --- |
| `SwiftCodeGen` | マクロの宣言、`SynchronizedLock`（再帰ロック）、`StreamBroadcast`（複数サブスクライバー対応の `AsyncStream`） |
| `SwiftCodeGenMacros` | コンパイラプラグイン: `SynchronizedMacro`（member、member-attribute、extension の各ロール）、`SynchronizedPropertyMacro`（アクセサとストレージ）、`StreamedMacro`（検査）、`PropertyAnalysis`、診断 |
| `SwiftCodeGenTests` | macOS と iOS シミュレータでのランタイムテスト: 並行性、ストリーム、README のサンプル |
| `SwiftCodeGenMainActorTests` | 新規アプリと同じ、MainActor のデフォルト分離を使うターゲットでのマクロ |
| `SwiftCodeGenMacrosTests` | 正確な展開結果と、すべての診断およびその fix-it（macOS） |

- **プロパティごとではなく、オブジェクトごとに 1 つのロック。** 1 つの再帰ロックがあるから、`withLock` で複数のプロパティをまとめて扱え、その中のコードで通常のプロパティ構文を使えます。
- **body マクロではなく init アクセサ。** ストレージは `@storageRestrictions(initializes:)` で初期化されるため、イニシャライザやデフォルト値は、どの Swift 6.2 コンパイラでも書いたとおりに動作します。
- **ロックの下での `_modify`。** その場での変更は、ロックを保持したままストレージを yield します。これが `+=` や `append` をアトミックにしています。`weak` や `unowned` のプロパティには `get` と `set` だけが生成されます。

## ロードマップ

- ストリームのプロパティに名前を付けるオプション（`@Streamed(as: "progressStream")`）。
- public なクラス向けに、オプトインで使える public な `withLock`（`@Synchronized(.publicLock)`）。現在は internal で、モジュール外のコードがロックを保持できないようになっています。
- CI での Linux 対応: このパッケージが使うのは Foundation の `NSRecursiveLock` と `NSLock` だけですが、テストは Apple プラットフォームでのみ行っています。

## コントリビューション

コントリビューションを歓迎します。pull request を作成する前に[コントリビューションガイド](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CONTRIBUTING.md)と[行動規範](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CODE_OF_CONDUCT.md)をお読みください。セキュリティ上の問題は[セキュリティポリシー](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/SECURITY.md)に従って非公開で報告してください。

## ライセンス

MIT ライセンスで公開しています。詳細は [LICENSE](LICENSE) を参照してください。
