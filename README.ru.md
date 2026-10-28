<!-- i18n-source: README.md@aafb1ff03311ce9811cf816cb4006c4bb83dac5a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg" alt="SwiftCodeGen: Swift macros that make a class Sendable without @unchecked and stream its changes."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml/badge.svg" alt="Статус CI"></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg" alt="Последняя версия: v1.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg" alt="Поддерживаемые платформы: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg" alt="Версия языка: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg" alt="Лицензия: MIT"></picture></a>
</p>

<p align="center">
<a href="#быстрый-старт"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-ru-light.svg" alt="Начать"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-ru-light.svg" alt="Документация"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-ru-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-ru-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-ru-light.svg" alt="Примеры"></picture></a>
</p>

> Это перевод README на английском языке. Если они расходятся, актуальна английская версия.

<!-- brand:end -->

SwiftCodeGen — небольшой пакет макросов Swift 6 для одной задачи, которую строгая конкурентность (strict
concurrency) делает частой: класс, состоянием которого синхронный код делится между потоками, например кеш, сессия,
delegate загрузки или счётчик. Swift 6 разрешает такому классу пересекать границы потоков, только если он
`Sendable`, а привычные решения — это написанная вручную блокировка за `@unchecked Sendable`, которую компилятор
перестаёт проверять, либо actor, превращающий каждый вызов в `await`. Вместо этого добавьте `@Synchronized`: каждая
сохраняемая `var` защищена одной блокировкой, `count += 1` не может потерять обновление, `withLock` объединяет
несколько шагов, а класс становится `Sendable` при включённой проверке компилятора. `@Streamed` добавляет
`AsyncStream` со значениями свойства для любого числа подписчиков.

## Основные возможности

- **Проверяемый `Sendable`, без `@unchecked`** — макрос добавляет настоящее соответствие `Sendable`, поэтому `let`
  с типом, не являющимся `Sendable`, по-прежнему вызывает ошибку компиляции.
- **Никаких потерянных обновлений** — геттеры, сеттеры и изменения на месте (`+=`, `append`, `dict[key] =`)
  выполняются под блокировкой; 2 000 параллельных `+=` в тестах дают ровно 2 000.
- **Несколько шагов как один** — `withLock { … }` удерживает блокировку на время блока кода с обычным синтаксисом
  свойств внутри и пропускает типизированные ошибки (`throws(Failure)`).
- **Ничего не нужно переписывать** — значения по умолчанию, `self.x = x` в `init`, неявный `nil`, `weak` и
  `unowned` продолжают работать; свойства `let`, вычисляемые и `static` остаются нетронутыми.
- **Потоки изменений** — `@Streamed var progress: Double` добавляет `progressUpdates`: сначала текущее значение,
  затем каждое изменение по порядку, по одному буферизованному значению на подписчика; поток завершается, когда
  объект освобождается.
- **Ошибки вместо сюрпризов** — структуры, actor, не-`final` классы, `@MainActor`, `lazy`, наблюдатели и property
  wrapper отклоняются с объяснением причины и, где исправление очевидно, с готовым исправлением.

## Быстрый старт

**1. Добавьте пакет**

В Xcode выберите **File › Add Package Dependencies…**, введите URL репозитория и добавьте библиотеку
**SwiftCodeGen** в свой target. При первой сборке выберите для макросов **Trust & Enable**.

```text
https://github.com/muhittincamdali/SwiftCodeGen.git
```

**2. Импортируйте модуль**

```swift
import SwiftCodeGen
```

**3. Добавьте `@Synchronized` к final-классу**

Кеш, которым любой поток может пользоваться без `await`
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

`ImageCache` теперь `Sendable`: передавайте его в `Task.detached`, в task group или в callback на любой очереди и
вызывайте без `await`.

## Установка

### Swift Package Manager

Добавьте пакет в `dependencies` в вашем `Package.swift`:

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

Пакет зависит от [swift-syntax](https://github.com/swiftlang/swift-syntax) (с 602 по 604), который компилятор
использует для раскрытия макросов; в ваше приложение он не линкуется. Для сборок из командной строки через
`xcodebuild` нужен флаг `-skipMacroValidation` либо однократное подтверждение доверия в Xcode.

## Использование

Примеры ниже скопированы из
[`ReadmeSamples.swift`](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift): демонстрационное приложение собирает этот
файл с изоляцией MainActor по умолчанию (default isolation), и тесты тоже его запускают.

### Изменение нескольких свойств вместе

Каждое обращение к свойству — отдельный шаг под блокировкой. Шаги, которые должны выполняться вместе, помещайте в
`withLock`, чтобы ни один другой поток не увидел рассогласованные `progress` и `status`:

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

Блокировка рекурсивная, поэтому обращения к свойствам внутри `withLock` берут её повторно в том же потоке. Не
захватывайте блокировки двух объектов в противоположном порядке в двух потоках: это приводит к взаимной блокировке
(deadlock), как и с любой парой блокировок.

### Отслеживание изменений через `for await`

`@Streamed` дал `UploadTracker` свойства `progressUpdates` и `statusUpdates`. Каждое чтение возвращает новый поток,
который начинается с текущего значения:

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

Значения отправляются, пока блокировка удерживается, поэтому каждый подписчик видит изменения в том порядке, в
котором они произошли. Для типа `Equatable` присваивание свойству значения, которое у него уже есть, ничего не
отправляет; в app-target с изоляцией MainActor по умолчанию объявляйте такой тип как `nonisolated`, как
`UploadStatus` выше, иначе его соответствие будет принадлежать главному actor, и каждое присваивание будет
отправляться. Подписчик, который отстаёт, сохраняет только самое новое значение. Потоки завершаются, когда объект
освобождается, и поток не удерживает свой объект в памяти.

### Инициализаторы и weak-ссылки

Свойства продолжают работать в инициализаторах, опционалы начинаются с `nil`, а `weak` остаётся слабой ссылкой:

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

### Что пишет макрос

Чтобы увидеть код для любого класса, используйте в Xcode **Editor › Expand Macro**. Для `var hits = 0` он такой:

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

Кроме того, один раз на класс добавляются `private let _lock = SwiftCodeGen.SynchronizedLock()`, метод `withLock` и
`extension ImageCache: Sendable {}`. Хранилище помечено `nonisolated(unsafe)`, потому что его защищает блокировка, а
не компилятор; все остальные члены класса по-прежнему проверяются.

### Что макрос отклоняет

| Объявление | Ошибка и предлагаемое исправление |
| --- | --- |
| `struct`, `enum` | Типы-значения `Sendable`, когда `Sendable` их хранимые свойства. |
| `actor` | Actor уже защищает своё состояние. |
| `class` без `final` | Подкласс мог бы добавить состояние, которое блокировка не защищает. Исправление: добавьте `final`. |
| `@MainActor` на классе или свойстве | Блокировка заменяет изоляцию actor. Исправление: уберите его. |
| `lazy var` | Исправление: уберите `lazy`. |
| `willSet` / `didSet` | Перенесите код в метод, который устанавливает свойство. |
| Property wrapper | Его хранилище не было бы защищено. |
| `var a = 0, b = 1`, `var (a, b) = …` | Объявляйте каждое свойство на отдельной строке. |
| `@Streamed` на `let`, `static`, вычисляемом, `weak` или не имеющем типа свойстве | Для каждого случая своё сообщение. |

Чтобы намеренно исключить свойство, пометьте его `nonisolated(unsafe)`.

## Демо

Демонстрационное приложение в [`Examples/SyncDemo`](Examples/SyncDemo) запускает оба макроса на iPhone или на Mac.
Скриншоты ниже сделаны в его сборке для Mac скриптом
[`scripts/capture-mac-screens.sh`](scripts/capture-mac-screens.sh);
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) делает те же экраны в симуляторе iPhone.

| Общий счётчик | Ход загрузки |
| --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-counter-dark.png"><img src="docs/images/demo-counter-light.png" width="320" alt="Общий счётчик: восемь задач прибавляют единицу по 20 000 раз каждая; один шаг под блокировкой даёт 160 000, два шага под блокировкой теряют обновления"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-upload-dark.png"><img src="docs/images/demo-upload-light.png" width="320" alt="Ход загрузки: один подписчик показывает 100 процентов после 21 значения, другой по одному разу показывает «ожидание», «загрузка» и «завершено»"></picture> |

## Документация

- [Справочник SwiftCodeGen](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/)
- [Начало работы](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/gettingstarted)
- [Потоковая передача изменений](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/streamingchanges)
- [Выбор инструмента](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/choosingatool)

## Руководства

- [Начало работы](Sources/SwiftCodeGen/SwiftCodeGen.docc/GettingStarted.md) — что меняет макрос, `withLock`,
  изоляция MainActor по умолчанию и объявления, которые он отклоняет.
- [Потоковая передача изменений](Sources/SwiftCodeGen/SwiftCodeGen.docc/StreamingChanges.md) — что получает
  подписчик, когда завершается поток, и `StreamBroadcast` сам по себе.
- [Выбор инструмента](Sources/SwiftCodeGen/SwiftCodeGen.docc/ChoosingATool.md) — когда лучше подойдёт actor, `Mutex`
  или другой пакет.

## Когда лучше выбрать другое

SwiftCodeGen — не универсальный генератор кода. Для задач, которые решают известные инструменты, используйте их:

| Что вам нужно | Что использовать |
| --- | --- |
| Состояние, работа с которым `async` (сеть, диск) | `actor`: его методы могут приостанавливаться, а блокировку нельзя удерживать через `await`. |
| Одно-два защищённых значения на iOS 18+ | `Mutex` из модуля Synchronization. |
| Состояние интерфейса, за которым наблюдает SwiftUI | `@Observable` на главном actor. |
| Моки и шпионы (spy) для протоколов | [Mockable](https://github.com/Kolos65/Mockable), [swift-spyable](https://github.com/Matejkob/swift-spyable) |
| Код, генерируемый по шаблонам для многих типов | [Sourcery](https://github.com/krzysztofzablocki/Sourcery) |
| Клиенты и серверы по документу OpenAPI | [swift-openapi-generator](https://github.com/apple/swift-openapi-generator) |
| Типизированные имена для изображений, цветов и строк | Символы ресурсов и String Catalog, которые генерирует Xcode; [SwiftGen](https://github.com/SwiftGen/SwiftGen) для шрифтов, plist и других файлов |
| Повторные попытки, тайм-ауты, single-flight запросы | [SwiftConcurrency](https://github.com/muhittincamdali/SwiftConcurrency) |

## Требования

| Платформа | Минимальная версия |
| --- | --- |
| iOS | 16 |
| macOS | 13 |
| tvOS | 16 |
| watchOS | 9 |
| visionOS | 1 |
| Инструменты | Swift 6.2 · Xcode 26+ |

## Архитектура

| Target | Содержимое |
| --- | --- |
| `SwiftCodeGen` | Объявления макросов, `SynchronizedLock` (рекурсивная блокировка) и `StreamBroadcast` (`AsyncStream` с несколькими подписчиками) |
| `SwiftCodeGenMacros` | Плагин компилятора: `SynchronizedMacro` (роли member, member-attribute и extension), `SynchronizedPropertyMacro` (аксессоры и хранилище), `StreamedMacro` (проверки), `PropertyAnalysis` и диагностика |
| `SwiftCodeGenTests` | Тесты времени выполнения на macOS и в симуляторе iOS: конкурентность, потоки, примеры из README |
| `SwiftCodeGenMainActorTests` | Макросы в target с изоляцией MainActor по умолчанию, как в новом приложении |
| `SwiftCodeGenMacrosTests` | Точные раскрытия и каждая диагностика с её fix-it (macOS) |

- **Одна блокировка на объект, а не на свойство.** Именно одна рекурсивная блокировка позволяет `withLock`
  охватывать несколько свойств, а коду внутри него — использовать обычный синтаксис свойств.
- **Init-аксессоры, а не body-макросы.** Хранилище инициализируется через `@storageRestrictions(initializes:)`,
  поэтому инициализаторы и значения по умолчанию работают так, как написаны, на любом компиляторе Swift 6.2.
- **`_modify` под блокировкой.** Изменения на месте отдают хранилище через `yield`, пока блокировка удерживается;
  именно это делает `+=` и `append` атомарными. Свойство `weak` или `unowned` получает только `get` и `set`.

## План развития

- Параметр для задания имени свойства-потока (`@Streamed(as: "progressStream")`).
- Публичный `withLock` для публичных классов в виде опции (`@Synchronized(.publicLock)`); сейчас он `internal`,
  чтобы код вне модуля не мог удерживать блокировку.
- Linux в CI: пакет использует только `NSRecursiveLock` и `NSLock` из Foundation, но тестируется только на
  платформах Apple.

## Участие в разработке

Мы рады вашему участию. Перед открытием pull request прочитайте [руководство для участников](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CONTRIBUTING.md) и [кодекс поведения](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CODE_OF_CONDUCT.md). О проблемах безопасности сообщайте конфиденциально, как описано в [политике безопасности](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/SECURITY.md).

## Лицензия

Распространяется по лицензии MIT. Подробнее — в файле [LICENSE](LICENSE).
