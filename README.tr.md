<!-- i18n-source: README.md@aafb1ff03311ce9811cf816cb4006c4bb83dac5a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg" alt="SwiftCodeGen: Swift macros that make a class Sendable without @unchecked and stream its changes."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml/badge.svg" alt="CI durumu"></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg" alt="Son sürüm: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg" alt="Desteklenen platformlar: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg" alt="Dil sürümü: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg" alt="Lisans: MIT"></picture></a>
</p>

<p align="center">
<a href="#hızlı-başlangıç"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-tr-light.svg" alt="Başlayın"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-tr-light.svg" alt="Dokümantasyon"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-tr-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-tr-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-tr-light.svg" alt="Örnekler"></picture></a>
</p>

> Bu belge İngilizce README'nin çevirisidir. İkisi arasında fark varsa güncel olan İngilizce sürümdür.

<!-- brand:end -->

SwiftCodeGen, katı eşzamanlılığın (strict concurrency) yaygınlaştırdığı tek bir soruna odaklanan küçük bir Swift 6
makro paketidir: durumu senkron kodun iş parçacıkları arasında paylaştığı bir sınıf — bir önbellek, bir oturum,
bir indirme delegesi, bir sayaç. Swift 6 böyle bir sınıfın iş parçacıkları arasında geçmesine yalnızca `Sendable`
olduğunda izin verir. Olağan çözümler ya elle yazılmış bir kilidi `@unchecked Sendable` arkasına saklamaktır
(derleyici artık denetlemez) ya da her çağrıyı `await`'e çeviren bir actor kullanmaktır. Bunun yerine
`@Synchronized` ekleyin: saklanan her `var` tek bir kilitle korunur, `count += 1` hiçbir güncellemeyi kaybetmez,
`withLock` birkaç adımı bir arada toplar ve sınıf, derleyici denetimi açıkken `Sendable` olur. `@Streamed` ise bir
özelliğin değerlerini, istenen sayıda abone için bir `AsyncStream` olarak sunar.

## Öne çıkanlar

- **Denetlenen `Sendable`, `@unchecked` yok** — makro gerçek bir `Sendable` uyumu ekler; bu yüzden `Sendable`
  olmayan bir türde `let` tanımlamak yine derleme hatasıdır.
- **Kayıp güncelleme yok** — getter'lar, setter'lar ve yerinde değişiklikler (`+=`, `append`, `dict[key] =`)
  kilit altında çalışır; testlerde eşzamanlı 2.000 `+=` tam olarak 2.000 eder.
- **Birkaç adım tek adım gibi** — `withLock { … }` bir kod bloğu boyunca kilidi tutar, içinde sıradan özellik
  sözdizimi kullanılır ve tipli hatalar (`throws(Failure)`) olduğu gibi geçer.
- **Yeniden yazmaya gerek yok** — varsayılan değerler, `init` içindeki `self.x = x`, örtük `nil`, `weak` ve
  `unowned` çalışmaya devam eder; `let`, hesaplanan ve `static` özelliklere dokunulmaz.
- **Değişim akışları** — `@Streamed var progress: Double` bir `progressUpdates` özelliği ekler: önce geçerli değer,
  ardından her değişiklik sırasıyla gelir; her abone için tek bir değer tamponlanır ve nesne yok olunca akış biter.
- **Sürpriz yerine hata** — struct'lar, actor'lar, `final` olmayan sınıflar, `@MainActor`, `lazy`, gözlemciler ve
  property wrapper'lar bir gerekçeyle reddedilir; çözüm belirginse çözüm de önerilir.

## Hızlı başlangıç

**1. Paketi ekleyin**

Xcode'da **File › Add Package Dependencies…** menüsünü seçin, depo adresini girin ve **SwiftCodeGen** kütüphanesini
hedefinize ekleyin. İlk derlemede makrolar için **Trust & Enable** seçeneğini seçin.

```text
https://github.com/muhittincamdali/SwiftCodeGen.git
```

**2. Modülü içe aktarın**

```swift
import SwiftCodeGen
```

**3. `@Synchronized`'ı bir final sınıfa ekleyin**

Herhangi bir iş parçacığının `await` olmadan kullanabileceği bir önbellek
([ReadmeSamples.swift](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift)):

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

`ImageCache` artık `Sendable`'dır: onu bir `Task.detached`'a, bir task group'a ya da herhangi bir kuyruktaki bir
callback'e verebilir ve `await` olmadan çağırabilirsiniz.

## Kurulum

### Swift Package Manager

`Package.swift` dosyanızdaki `dependencies` listesine ekleyin:

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

Paket, makroları genişletmek için derleyicinin kullandığı [swift-syntax](https://github.com/swiftlang/swift-syntax)
(602 – 604) paketine bağlıdır; bunun hiçbir parçası uygulamanıza bağlanmaz. `xcodebuild` ile komut satırından
yapılan derlemeler `-skipMacroValidation` gerektirir; alternatif olarak Xcode'da bir kez güven verilmelidir.

## Kullanım

Aşağıdaki örnekler, örnek uygulamanın MainActor varsayılan yalıtımıyla (default isolation) derlediği ve test
paketinin çalıştırdığı
[`ReadmeSamples.swift`](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift) dosyasından kopyalanmıştır.

### Birkaç özelliği birlikte değiştirme

Her özellik erişimi kilitli tek bir adımdır. Birlikte olması gereken adımları `withLock` içine alın; böylece başka
hiçbir iş parçacığı `progress` ile `status` değerlerinin birbiriyle çeliştiğini görmez:

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

Kilit özyinelemelidir (recursive); bu yüzden `withLock` içindeki özellik erişimleri aynı iş parçacığında kilidi
yeniden alır. İki nesnenin kilitlerini iki iş parçacığında zıt sırayla almayın; bu, her kilit çiftinde olduğu gibi
kilitlenmeye (deadlock) yol açar.

### Değişiklikleri `for await` ile izleme

`@Streamed`, `UploadTracker`'a `progressUpdates` ve `statusUpdates` özelliklerini kazandırdı. Her okuma, geçerli
değerle başlayan yeni bir akış döndürür:

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

Değerler kilit tutulurken gönderilir; böylece her abone değişiklikleri gerçekleştikleri sırayla görür. `Equatable`
bir tür için bir özelliğe zaten sahip olduğu değeri atamak hiçbir şey göndermez. MainActor varsayılan yalıtımına
sahip bir uygulama hedefinde böyle bir türü `nonisolated` olarak tanımlayın (yukarıdaki `UploadStatus` gibi);
aksi halde uyumu ana actor'a ait olur ve her atama gönderilir. Geride kalan bir abone yalnızca en yeni değeri
tutar. Nesne serbest bırakıldığında akışlar sona erer ve bir akış nesnesini hayatta tutmaz.

### Başlatıcılar ve weak referanslar

Özellikler başlatıcılarda (initializer) çalışmaya devam eder, opsiyoneller `nil` ile başlar ve `weak` zayıf kalır:

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

### Makro ne yazıyor

Herhangi bir sınıfın kodunu görmek için Xcode'da **Editor › Expand Macro** komutunu kullanın. `var hits = 0` için
çıktı şudur:

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

Buna ek olarak sınıf başına bir kez `private let _lock = SwiftCodeGen.SynchronizedLock()`, `withLock` metodu ve
`extension ImageCache: Sendable {}` eklenir. Depolama `nonisolated(unsafe)` olarak işaretlenir, çünkü onu derleyici
değil kilit korur; sınıfın diğer tüm üyeleri hâlâ denetlenir.

### Makro neyi reddeder

| Bildirim | Hata ve önerdiği çözüm |
| --- | --- |
| `struct`, `enum` | Değer türleri, saklanan özellikleri `Sendable` olduğunda `Sendable`'dır. |
| `actor` | Bir actor durumunu zaten korur. |
| `final` olmayan `class` | Bir alt sınıf, kilidin korumadığı durum ekleyebilir. Çözüm: `final` ekleyin. |
| Sınıfta veya bir özellikte `@MainActor` | Kilit, actor yalıtımının yerini alır. Çözüm: kaldırın. |
| `lazy var` | Çözüm: `lazy`'yi kaldırın. |
| `willSet` / `didSet` | Kodu, özelliği ayarlayan bir metoda taşıyın. |
| Bir property wrapper | Depolaması korunmazdı. |
| `var a = 0, b = 1`, `var (a, b) = …` | Her özelliği kendi satırında tanımlayın. |
| Bir `let`, `static`, hesaplanan, `weak` veya tipsiz özellikte `@Streamed` | Her biri kendi mesajını verir. |

Bir özelliği bilerek kapsam dışı bırakmak için `nonisolated(unsafe)` ile işaretleyin.

## Demo

[`Examples/SyncDemo`](Examples/SyncDemo) içindeki örnek uygulama her iki makroyu da bir iPhone'da veya Mac'te
çalıştırır. Aşağıdaki ekran görüntüleri, Mac sürümünden
[`scripts/capture-mac-screens.sh`](scripts/capture-mac-screens.sh) ile alınmıştır;
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) aynı ekranları bir iPhone simülatöründe
alır.

| Ortak sayaç | Yükleme ilerlemesi |
| --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-counter-dark.png"><img src="docs/images/demo-counter-light.png" width="320" alt="Ortak sayaç: sekiz görev her biri 20.000 kez bir ekler; kilitli tek adım 160.000'e ulaşır, iki kilitli adım güncelleme kaybeder"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-upload-dark.png"><img src="docs/images/demo-upload-light.png" width="320" alt="Yükleme ilerlemesi: bir abone 21 değerden sonra yüzde 100'ü gösterir, diğeri beklemede, yükleniyor ve tamamlandı durumlarını birer kez gösterir"></picture> |

## Dokümantasyon

- [SwiftCodeGen başvuru belgeleri](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/)
- [Başlarken](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/gettingstarted)
- [Değişiklikleri akışa alma](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/streamingchanges)
- [Doğru aracı seçme](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/choosingatool)

## Rehberler

- [Başlarken](Sources/SwiftCodeGen/SwiftCodeGen.docc/GettingStarted.md) — makronun neyi değiştirdiği, `withLock`,
  MainActor varsayılan yalıtımı ve reddettiği bildirimler.
- [Değişiklikleri akışa alma](Sources/SwiftCodeGen/SwiftCodeGen.docc/StreamingChanges.md) — bir abonenin ne aldığı,
  bir akışın ne zaman bittiği ve tek başına `StreamBroadcast`.
- [Doğru aracı seçme](Sources/SwiftCodeGen/SwiftCodeGen.docc/ChoosingATool.md) — bir actor'ın, `Mutex`'in veya başka
  bir paketin ne zaman daha iyi seçim olduğu.

## Başka bir araç ne zaman?

SwiftCodeGen genel amaçlı bir kod üreticisi değildir. Tanınmış araçların yaptığı işler için onları kullanın:

| İhtiyacınız | Kullanın |
| --- | --- |
| İşi `async` olan durum (ağ, disk) | Bir `actor`: metotları askıya alınabilir; kilit bir `await` boyunca tutulmamalıdır. |
| iOS 18+ üzerinde bir ya da iki korunan değer | Synchronization modülündeki `Mutex`. |
| SwiftUI'ın gözlemlediği arayüz durumu | Ana actor üzerinde `@Observable`. |
| Protokollerin mock ve spy'ları | [Mockable](https://github.com/Kolos65/Mockable), [swift-spyable](https://github.com/Matejkob/swift-spyable) |
| Birçok türde şablonlardan üretilen kod | [Sourcery](https://github.com/krzysztofzablocki/Sourcery) |
| Bir OpenAPI belgesinden istemciler ve sunucular | [swift-openapi-generator](https://github.com/apple/swift-openapi-generator) |
| Görseller, renkler ve metinler için tipli adlar | Xcode'un ürettiği varlık ve String Catalog sembolleri; yazı tipleri, plist'ler ve diğer dosyalar için [SwiftGen](https://github.com/SwiftGen/SwiftGen) |
| Yeniden deneme, zaman aşımı, tek uçuşlu (single-flight) istekler | [SwiftConcurrency](https://github.com/muhittincamdali/SwiftConcurrency) |

## Gereksinimler

| Platform | En düşük sürüm |
| --- | --- |
| iOS | 16 |
| macOS | 13 |
| tvOS | 16 |
| watchOS | 9 |
| visionOS | 1 |
| Araç zinciri | Swift 6.2 · Xcode 26+ |

## Mimari

| Hedef | İçerik |
| --- | --- |
| `SwiftCodeGen` | Makro bildirimleri, `SynchronizedLock` (özyinelemeli bir kilit) ve `StreamBroadcast` (çok aboneli `AsyncStream`) |
| `SwiftCodeGenMacros` | Derleyici eklentisi: `SynchronizedMacro` (member, member-attribute ve extension rolleri), `SynchronizedPropertyMacro` (erişimciler ve depolama), `StreamedMacro` (denetimler), `PropertyAnalysis` ve tanılamalar |
| `SwiftCodeGenTests` | macOS'ta ve iOS simülatöründe çalışma zamanı testleri: eşzamanlılık, akışlar, README örnekleri |
| `SwiftCodeGenMainActorTests` | Yeni bir uygulama gibi, MainActor varsayılan yalıtımına sahip bir hedefte makrolar |
| `SwiftCodeGenMacrosTests` | Tam genişletmeler ve her tanılama, fix-it'iyle birlikte (macOS) |

- **Özellik başına değil, nesne başına tek kilit.** Tek bir özyinelemeli kilit, `withLock`'un birkaç özelliği
  kapsamasını ve içindeki kodun sıradan özellik sözdizimi kullanmasını sağlar.
- **Body makroları değil, init accessor'ları.** Depolama `@storageRestrictions(initializes:)` ile başlatılır; bu
  sayede başlatıcılar ve varsayılan değerler, Swift 6.2'nin her derleyicisinde yazıldığı gibi çalışır.
- **Kilit altında `_modify`.** Yerinde değişiklikler, kilit tutulurken depolamayı `yield` eder; `+=` ve `append`
  işlemlerini atomik yapan budur. `weak` veya `unowned` bir özellik yalnızca `get` ve `set` alır.

## Yol haritası

- Akış özelliğini adlandırma seçeneği (`@Streamed(as: "progressStream")`).
- Herkese açık (public) sınıflar için, isteğe bağlı olarak herkese açık bir `withLock` (`@Synchronized(.publicLock)`);
  bugün `internal`'dır, böylece modül dışındaki kod kilidi tutamaz.
- CI'da Linux: paket yalnızca Foundation'ın `NSRecursiveLock` ve `NSLock` türlerini kullanır, ancak yalnızca Apple
  platformlarında test edilir.

## Katkıda bulunma

Katkılarınızı bekliyoruz. Pull request açmadan önce [katkı rehberini](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CONTRIBUTING.md) ve [davranış kurallarını](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CODE_OF_CONDUCT.md) okuyun. Güvenlik açıklarını [güvenlik politikasında](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/SECURITY.md) anlatıldığı gibi gizli olarak bildirin.

## Lisans

MIT lisansıyla yayımlanmıştır. Ayrıntılar için [LICENSE](LICENSE) dosyasına bakın.
