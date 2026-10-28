<!-- i18n-source: README.md@75c95a1af2692e0963799c764db0ab6495616095 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg" alt="SwiftCodeGen: Swift macros that make a class Sendable without @unchecked and stream its changes."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml/badge.svg" alt="CI-Status"></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg" alt="Aktuelle Version: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg" alt="Unterstützte Plattformen: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg" alt="Sprachversion: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg" alt="Lizenz: MIT"></picture></a>
</p>

<p align="center">
<a href="#schnellstart"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-de-light.svg" alt="Loslegen"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-de-light.svg" alt="Dokumentation"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-de-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-de-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-de-light.svg" alt="Beispiele"></picture></a>
</p>

> Dies ist eine Übersetzung der englischen README. Bei Abweichungen gilt die englische Fassung.

<!-- brand:end -->

SwiftCodeGen ist ein kleines Swift-6-Makropaket für ein Problem, das Strict Concurrency häufig macht: eine Klasse,
deren Zustand synchroner Code über mehrere Threads hinweg teilt – ein Cache, eine Session, ein Download-Delegate,
ein Zähler. Swift 6 lässt eine solche Klasse nur dann Threadgrenzen überschreiten, wenn sie `Sendable` ist. Die
üblichen Auswege sind ein von Hand geschriebener Lock hinter `@unchecked Sendable`, den der Compiler nicht mehr
prüft, oder ein Actor, der jeden Aufruf zu einem `await` macht. Setze stattdessen `@Synchronized` ein: Jede
gespeicherte `var` wird von einem einzigen Lock geschützt, `count += 1` kann keine Änderung verlieren, `withLock`
fasst mehrere Schritte zusammen, und die Klasse wird `Sendable`, während die Compiler-Prüfung aktiv bleibt.
`@Streamed` ergänzt einen `AsyncStream` mit den Werten einer Property für beliebig viele Abonnenten.

## Highlights

- **Geprüftes `Sendable`, kein `@unchecked`** — das Makro fügt eine echte `Sendable`-Konformität hinzu, sodass ein
  `let` mit einem nicht-`Sendable`-Typ weiterhin ein Kompilierfehler ist.
- **Keine verlorenen Änderungen** — Getter, Setter und direkte Änderungen (`+=`, `append`, `dict[key] =`) laufen
  unter dem Lock; 2.000 nebenläufige `+=` in den Tests ergeben genau 2.000.
- **Mehrere Schritte als einer** — `withLock { … }` hält den Lock für einen Codeblock, in dem die normale
  Property-Syntax gilt, und reicht typisierte Fehler (`throws(Failure)`) durch.
- **Nichts umzuschreiben** — Standardwerte, `self.x = x` in `init`, implizites `nil`, `weak` und `unowned`
  funktionieren weiter; `let`-, berechnete und `static`-Properties bleiben unberührt.
- **Ströme von Änderungen** — `@Streamed var progress: Double` ergänzt `progressUpdates`: zuerst der aktuelle Wert,
  dann jede Änderung in der richtigen Reihenfolge, ein gepufferter Wert pro Abonnent; der Stream endet, wenn das
  Objekt freigegeben wird.
- **Fehler statt Überraschungen** — Structs, Actors, Klassen ohne `final`, `@MainActor`, `lazy`, Observer und
  Property Wrapper werden mit einer Begründung abgelehnt, und mit einem Fix, wo er eindeutig ist.

## Schnellstart

**1. Paket hinzufügen**

Wähle in Xcode **File › Add Package Dependencies…**, gib die Repository-URL ein und füge die Bibliothek
**SwiftCodeGen** zu deinem Target hinzu. Wähle beim ersten Build für die Makros **Trust & Enable**.

```text
https://github.com/muhittincamdali/SwiftCodeGen.git
```

**2. Modul importieren**

```swift
import SwiftCodeGen
```

**3. `@Synchronized` an eine final-Klasse hängen**

Ein Cache, den jeder Thread ohne `await` verwenden kann
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

`ImageCache` ist jetzt `Sendable`: Übergib sie an einen `Task.detached`, eine Task Group oder einen Callback auf
einer beliebigen Queue und rufe sie ohne `await` auf.

## Installation

### Swift Package Manager

Füge es in deiner `Package.swift` zu den `dependencies` hinzu:

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

Das Paket hängt von [swift-syntax](https://github.com/swiftlang/swift-syntax) (602 bis 604) ab, womit der Compiler
die Makros expandiert; nichts davon wird in deine App gelinkt. Kommandozeilen-Builds mit `xcodebuild` brauchen
`-skipMacroValidation` oder eine einmalige Vertrauensfreigabe in Xcode.

## Verwendung

Die folgenden Beispiele sind aus
[`ReadmeSamples.swift`](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift) kopiert. Die Beispiel-App baut diese Datei
mit MainActor als Standard-Isolation (default isolation), und die Test-Suite führt sie aus.

### Mehrere Properties zusammen ändern

Jeder Property-Zugriff ist ein gesperrter Schritt. Schritte, die zusammengehören, kommen in `withLock`, damit kein
anderer Thread `progress` und `status` im Widerspruch sieht:

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

Der Lock ist rekursiv, daher nehmen die Property-Zugriffe innerhalb von `withLock` ihn im selben Thread erneut.
Nimm die Locks zweier Objekte nicht auf zwei Threads in entgegengesetzter Reihenfolge; das führt wie bei jedem Paar
von Locks zu einem Deadlock.

### Änderungen mit `for await` verfolgen

`@Streamed` hat `UploadTracker` die Properties `progressUpdates` und `statusUpdates` gegeben. Jedes Lesen liefert
einen neuen Stream, der mit dem aktuellen Wert beginnt:

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

Werte werden gesendet, während der Lock gehalten wird, sodass jeder Abonnent die Änderungen in der Reihenfolge sieht,
in der sie passiert sind. Bei einem `Equatable`-Typ sendet die Zuweisung des Werts, den eine Property bereits hat,
nichts; in einem App-Target mit MainActor als Standard-Isolation deklarierst du einen solchen Typ als
`nonisolated`, wie `UploadStatus` oben, sonst gehört seine Konformität zum Main Actor und jede Zuweisung wird
gesendet. Ein Abonnent, der zurückfällt, behält nur den neuesten Wert. Streams enden, wenn das Objekt freigegeben
wird, und ein Stream hält sein Objekt nicht am Leben.

### Initializer und weak-Referenzen

Properties funktionieren weiterhin in Initializern, Optionals beginnen als `nil`, und `weak` bleibt weak:

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

### Was das Makro schreibt

Mit **Editor › Expand Macro** in Xcode siehst du den Code für jede Klasse. Für `var hits = 0` ist es:

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

Dazu kommen einmal pro Klasse `private let _lock = SwiftCodeGen.SynchronizedLock()`, die Methode `withLock` und
`extension ImageCache: Sendable {}`. Der Speicher ist `nonisolated(unsafe)`, weil der Lock ihn schützt und nicht der
Compiler; jedes andere Mitglied der Klasse wird weiterhin geprüft.

### Was das Makro ablehnt

| Deklaration | Fehler und der angebotene Fix |
| --- | --- |
| `struct`, `enum` | Werttypen sind `Sendable`, wenn ihre gespeicherten Properties es sind. |
| `actor` | Ein Actor schützt seinen Zustand bereits. |
| `class` ohne `final` | Eine Subklasse könnte Zustand hinzufügen, den der Lock nicht schützt. Fix: `final` ergänzen. |
| `@MainActor` an der Klasse oder an einer Property | Der Lock ersetzt die Actor-Isolation. Fix: entfernen. |
| `lazy var` | Fix: `lazy` entfernen. |
| `willSet` / `didSet` | Den Code in eine Methode verschieben, die die Property setzt. |
| Ein Property Wrapper | Sein Speicher wäre nicht geschützt. |
| `var a = 0, b = 1`, `var (a, b) = …` | Jede Property in einer eigenen Zeile deklarieren. |
| `@Streamed` an einer `let`-, `static`-, berechneten, `weak`- oder untypisierten Property | Jeweils mit eigener Meldung. |

Um eine Property absichtlich auszunehmen, markiere sie mit `nonisolated(unsafe)`.

## Demo

Die Beispiel-App in [`Examples/SyncDemo`](Examples/SyncDemo) führt beide Makros auf einem iPhone oder einem Mac aus.
Die folgenden Screenshots stammen aus ihrem Mac-Build und wurden mit
[`scripts/capture-mac-screens.sh`](scripts/capture-mac-screens.sh) aufgenommen;
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) nimmt dieselben Bildschirme in einem
iPhone-Simulator auf.

| Gemeinsamer Zähler | Upload-Fortschritt |
| --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-counter-dark.png"><img src="docs/images/demo-counter-light.png" width="320" alt="Gemeinsamer Zähler: Acht Tasks addieren jeweils 20.000-mal eins; ein gesperrter Schritt zählt 160.000, zwei gesperrte Schritte verlieren Änderungen"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-upload-dark.png"><img src="docs/images/demo-upload-light.png" width="320" alt="Upload-Fortschritt: Ein Abonnent zeigt nach 21 Werten 100 Prozent, der andere zeigt Wartet, Lädt hoch und Fertig je einmal"></picture> |

## Dokumentation

- [SwiftCodeGen-Referenz](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/)
- [Erste Schritte](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/gettingstarted)
- [Änderungen streamen](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/streamingchanges)
- [Das passende Werkzeug wählen](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/choosingatool)

## Anleitungen

- [Erste Schritte](Sources/SwiftCodeGen/SwiftCodeGen.docc/GettingStarted.md) — was das Makro ändert, `withLock`,
  MainActor als Standard-Isolation und die Deklarationen, die es ablehnt.
- [Änderungen streamen](Sources/SwiftCodeGen/SwiftCodeGen.docc/StreamingChanges.md) — was ein Abonnent erhält, wann
  ein Stream endet und `StreamBroadcast` für sich allein.
- [Das passende Werkzeug wählen](Sources/SwiftCodeGen/SwiftCodeGen.docc/ChoosingATool.md) — wann ein Actor, `Mutex`
  oder ein anderes Paket die bessere Wahl ist.

## Wann etwas anderes besser passt

SwiftCodeGen ist kein allgemeiner Code-Generator. Für die Aufgaben der bekannten Werkzeuge nimm diese:

| Du brauchst | Nimm |
| --- | --- |
| Zustand, dessen Arbeit `async` ist (Netzwerk, Datenträger) | Einen `actor`: Seine Methoden können pausieren, ein Lock darf nicht über ein `await` hinweg gehalten werden. |
| Ein oder zwei geschützte Werte ab iOS 18 | `Mutex` aus dem Modul Synchronization. |
| UI-Zustand, den SwiftUI beobachtet | `@Observable` auf dem Main Actor. |
| Mocks und Spies von Protokollen | [Mockable](https://github.com/Kolos65/Mockable), [swift-spyable](https://github.com/Matejkob/swift-spyable) |
| Aus Templates generierter Code für viele Typen | [Sourcery](https://github.com/krzysztofzablocki/Sourcery) |
| Clients und Server aus einem OpenAPI-Dokument | [swift-openapi-generator](https://github.com/apple/swift-openapi-generator) |
| Typisierte Namen für Bilder, Farben und Strings | Die von Xcode generierten Asset- und String-Catalog-Symbole; [SwiftGen](https://github.com/SwiftGen/SwiftGen) für Schriften, Plists und andere Dateien |
| Wiederholungsversuche, Timeouts, Single-Flight-Anfragen | [SwiftConcurrency](https://github.com/muhittincamdali/SwiftConcurrency) |

## Voraussetzungen

| Plattform | Mindestversion |
| --- | --- |
| iOS | 16 |
| macOS | 13 |
| tvOS | 16 |
| watchOS | 9 |
| visionOS | 1 |
| Toolchain | Swift 6.2 · Xcode 26+ |

## Architektur

| Target | Inhalt |
| --- | --- |
| `SwiftCodeGen` | Die Makrodeklarationen, `SynchronizedLock` (ein rekursiver Lock) und `StreamBroadcast` (ein `AsyncStream` für mehrere Abonnenten) |
| `SwiftCodeGenMacros` | Das Compiler-Plugin: `SynchronizedMacro` (Rollen member, member-attribute und extension), `SynchronizedPropertyMacro` (Accessoren und Speicher), `StreamedMacro` (Prüfungen), `PropertyAnalysis` und die Diagnosen |
| `SwiftCodeGenTests` | Laufzeittests unter macOS und im iOS-Simulator: Nebenläufigkeit, Streams, README-Beispiele |
| `SwiftCodeGenMainActorTests` | Die Makros in einem Target mit MainActor als Standard-Isolation, wie in einer neuen App |
| `SwiftCodeGenMacrosTests` | Exakte Expansionen und jede Diagnose mit ihrem Fix-it (macOS) |

- **Ein Lock pro Objekt, nicht pro Property.** Ein einzelner rekursiver Lock ist es, der `withLock` mehrere
  Properties abdecken lässt und dem Code darin die normale Property-Syntax erlaubt.
- **Init-Accessoren, keine Body-Makros.** Der Speicher wird über `@storageRestrictions(initializes:)` initialisiert,
  sodass Initializer und Standardwerte mit jedem Swift-6.2-Compiler so funktionieren, wie sie geschrieben sind.
- **`_modify` unter dem Lock.** Direkte Änderungen geben den Speicher per `yield` frei, während der Lock gehalten
  wird; das macht `+=` und `append` atomar. Eine `weak`- oder `unowned`-Property bekommt nur `get` und `set`.

## Roadmap

- Eine Option, um die Stream-Property zu benennen (`@Streamed(as: "progressStream")`).
- Ein öffentliches `withLock` für öffentliche Klassen als Opt-in (`@Synchronized(.publicLock)`); heute ist es
  `internal`, damit Code außerhalb des Moduls den Lock nicht halten kann.
- Linux in der CI: Das Paket verwendet nur `NSRecursiveLock` und `NSLock` aus Foundation, wird aber nur auf
  Apple-Plattformen getestet.

## Mitwirken

Beiträge sind willkommen. Lies vor einem Pull Request den [Leitfaden für Beiträge](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CONTRIBUTING.md) und den [Verhaltenskodex](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CODE_OF_CONDUCT.md). Sicherheitsprobleme meldest du vertraulich, wie in der [Sicherheitsrichtlinie](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/SECURITY.md) beschrieben.

## Lizenz

Veröffentlicht unter der MIT-Lizenz. Siehe [LICENSE](LICENSE).
