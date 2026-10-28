<!-- i18n-source: README.md@75c95a1af2692e0963799c764db0ab6495616095 status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg" alt="SwiftCodeGen: Swift macros that make a class Sendable without @unchecked and stream its changes."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml/badge.svg" alt="Estado de CI"></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg" alt="Última versión: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatibles: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg" alt="Versión del lenguaje: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg" alt="Licencia: MIT"></picture></a>
</p>

<p align="center">
<a href="#inicio-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-es-light.svg" alt="Empezar"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-es-light.svg" alt="Documentación"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-es-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-es-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-es-light.svg" alt="Ejemplos"></picture></a>
</p>

> Esta es una traducción del README en inglés. Si hay diferencias, la versión en inglés es la vigente.

<!-- brand:end -->

SwiftCodeGen es un pequeño paquete de macros de Swift 6 para un problema que la concurrencia estricta
(strict concurrency) vuelve habitual: una clase cuyo estado comparte código síncrono entre hilos, como una caché,
una sesión, un delegate de descargas o un contador. Swift 6 solo permite que una clase así cruce hilos cuando es
`Sendable`, y las soluciones habituales son un lock escrito a mano detrás de `@unchecked Sendable`, que el
compilador deja de comprobar, o un actor, que convierte cada llamada en un `await`. En su lugar, añade
`@Synchronized`: cada `var` almacenada queda protegida por un único lock, `count += 1` no puede perder una
actualización, `withLock` agrupa varios pasos y la clase pasa a ser `Sendable` con la comprobación del compilador
aún activa. `@Streamed` añade un `AsyncStream` con los valores de una propiedad para cualquier número de
suscriptores.

## Lo más destacado

- **`Sendable` comprobado, sin `@unchecked`** — la macro añade una conformidad `Sendable` real, así que un `let` de
  un tipo que no es `Sendable` sigue siendo un error de compilación.
- **Sin actualizaciones perdidas** — los getters, los setters y los cambios in situ (`+=`, `append`,
  `dict[key] =`) se ejecutan bajo el lock; 2.000 `+=` concurrentes en las pruebas suman exactamente 2.000.
- **Varios pasos como uno** — `withLock { … }` mantiene el lock durante un bloque de código con la sintaxis normal
  de propiedades en su interior, y deja pasar los errores tipados (`throws(Failure)`).
- **Nada que reescribir** — los valores por defecto, `self.x = x` en `init`, el `nil` implícito, `weak` y
  `unowned` siguen funcionando; las propiedades `let`, calculadas y `static` no se tocan.
- **Flujos de cambios** — `@Streamed var progress: Double` añade `progressUpdates`: primero el valor actual y
  después cada cambio en orden, con un valor en búfer por suscriptor, y el flujo termina cuando el objeto
  desaparece.
- **Errores en lugar de sorpresas** — los structs, los actores, las clases que no son `final`, `@MainActor`,
  `lazy`, los observadores y los property wrappers se rechazan con una explicación y, cuando la solución es clara,
  con una corrección.

## Inicio rápido

**1. Añade el paquete**

En Xcode, elige **File › Add Package Dependencies…**, introduce la URL del repositorio y añade la biblioteca
**SwiftCodeGen** a tu target. En la primera compilación, elige **Trust & Enable** para las macros.

```text
https://github.com/muhittincamdali/SwiftCodeGen.git
```

**2. Importa el módulo**

```swift
import SwiftCodeGen
```

**3. Añade `@Synchronized` a una clase final**

Una caché que cualquier hilo puede usar sin `await`
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

`ImageCache` ya es `Sendable`: pásala a un `Task.detached`, a un task group o a un callback en cualquier cola, y
llámala sin `await`.

## Instalación

### Swift Package Manager

Añádelo a `dependencies` en tu `Package.swift`:

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

El paquete depende de [swift-syntax](https://github.com/swiftlang/swift-syntax) (602 a 604), que el compilador usa
para expandir las macros; nada de eso se enlaza en tu app. Las compilaciones desde la línea de comandos con
`xcodebuild` necesitan `-skipMacroValidation`, o confiar una vez en Xcode.

## Uso

Los ejemplos siguientes están copiados de
[`ReadmeSamples.swift`](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift), que la app de ejemplo compila con el
aislamiento por defecto de MainActor (default isolation) y que la suite de pruebas ejecuta.

### Cambiar varias propiedades a la vez

Cada acceso a una propiedad es un paso bloqueado. Los pasos que van juntos se meten en `withLock`, de modo que
ningún otro hilo ve `progress` y `status` en desacuerdo:

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

El lock es recursivo, así que los accesos a propiedades dentro de `withLock` lo toman de nuevo en el mismo hilo. No
tomes los locks de dos objetos en orden opuesto en dos hilos; eso provoca un deadlock, como con cualquier par de
locks.

### Seguir los cambios con `for await`

`@Streamed` ha dado a `UploadTracker` las propiedades `progressUpdates` y `statusUpdates`. Cada lectura devuelve un
flujo nuevo que empieza con el valor actual:

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

Los valores se envían mientras se mantiene el lock, así que cada suscriptor ve los cambios en el orden en que
ocurrieron. En un tipo `Equatable`, asignar a una propiedad el valor que ya tiene no envía nada; en un target de app
con aislamiento por defecto de MainActor, declara ese tipo como `nonisolated`, como `UploadStatus` más arriba, o su
conformidad pertenecerá al actor principal y se enviará cada asignación. Un suscriptor que se queda atrás conserva
solo el valor más reciente. Los flujos terminan cuando se libera el objeto, y un flujo no mantiene vivo a su objeto.

### Inicializadores y referencias weak

Las propiedades siguen funcionando en los inicializadores, los opcionales empiezan en `nil` y `weak` sigue siendo
débil:

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

### Qué escribe la macro

Usa **Editor › Expand Macro** en Xcode para ver el código de cualquier clase. Para `var hits = 0` es:

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

Además, una vez por clase, `private let _lock = SwiftCodeGen.SynchronizedLock()`, el método `withLock` y
`extension ImageCache: Sendable {}`. El almacenamiento es `nonisolated(unsafe)` porque lo protege el lock, no el
compilador; el resto de los miembros de la clase se siguen comprobando.

### Qué rechaza la macro

| Declaración | Error y corrección que ofrece |
| --- | --- |
| `struct`, `enum` | Los tipos de valor son `Sendable` cuando lo son sus propiedades almacenadas. |
| `actor` | Un actor ya protege su estado. |
| `class` sin `final` | Una subclase podría añadir estado que el lock no protege. Corrección: añade `final`. |
| `@MainActor` en la clase o en una propiedad | El lock sustituye al aislamiento del actor. Corrección: quítalo. |
| `lazy var` | Corrección: quita `lazy`. |
| `willSet` / `didSet` | Mueve el código a un método que asigne la propiedad. |
| Un property wrapper | Su almacenamiento no estaría protegido. |
| `var a = 0, b = 1`, `var (a, b) = …` | Declara cada propiedad en su propia línea. |
| `@Streamed` en una propiedad `let`, `static`, calculada, `weak` o sin tipo | Cada caso tiene su propio mensaje. |

Para dejar una propiedad fuera a propósito, márcala como `nonisolated(unsafe)`.

## Demo

La app de ejemplo de [`Examples/SyncDemo`](Examples/SyncDemo) ejecuta ambas macros en un iPhone o en un Mac. Las
capturas de pantalla siguientes se han tomado de su versión para Mac con
[`scripts/capture-mac-screens.sh`](scripts/capture-mac-screens.sh);
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) toma las mismas pantallas en un simulador
de iPhone.

| Contador compartido | Progreso de subida |
| --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-counter-dark.png"><img src="docs/images/demo-counter-light.png" width="320" alt="Contador compartido: ocho tareas suman uno 20.000 veces cada una; un paso bloqueado cuenta 160.000, dos pasos bloqueados pierden actualizaciones"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-upload-dark.png"><img src="docs/images/demo-upload-light.png" width="320" alt="Progreso de subida: un suscriptor muestra el 100 por ciento tras 21 valores, el otro muestra en espera, subiendo y terminado una vez cada uno"></picture> |

## Documentación

- [Referencia de SwiftCodeGen](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/)
- [Primeros pasos](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/gettingstarted)
- [Flujo de cambios](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/streamingchanges)
- [Cómo elegir una herramienta](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/choosingatool)

## Guías

- [Primeros pasos](Sources/SwiftCodeGen/SwiftCodeGen.docc/GettingStarted.md) — qué cambia la macro, `withLock`, el
  aislamiento por defecto de MainActor y las declaraciones que rechaza.
- [Flujo de cambios](Sources/SwiftCodeGen/SwiftCodeGen.docc/StreamingChanges.md) — qué recibe un suscriptor, cuándo
  termina un flujo y `StreamBroadcast` por separado.
- [Cómo elegir una herramienta](Sources/SwiftCodeGen/SwiftCodeGen.docc/ChoosingATool.md) — cuándo un actor,
  `Mutex` u otro paquete es la mejor opción.

## Cuándo usar otra cosa

SwiftCodeGen no es un generador de código general. Para los trabajos que hacen las herramientas conocidas, úsalas:

| Lo que quieres | Usa |
| --- | --- |
| Estado cuyo trabajo es `async` (red, disco) | Un `actor`: sus métodos pueden suspenderse, y un lock no debe mantenerse a través de un `await`. |
| Uno o dos valores protegidos en iOS 18+ | `Mutex` del módulo Synchronization. |
| Estado de interfaz que SwiftUI observa | `@Observable` en el actor principal. |
| Mocks y spies de protocolos | [Mockable](https://github.com/Kolos65/Mockable), [swift-spyable](https://github.com/Matejkob/swift-spyable) |
| Código generado a partir de plantillas para muchos tipos | [Sourcery](https://github.com/krzysztofzablocki/Sourcery) |
| Clientes y servidores a partir de un documento OpenAPI | [swift-openapi-generator](https://github.com/apple/swift-openapi-generator) |
| Nombres tipados para imágenes, colores y cadenas | Los símbolos de recursos y de String Catalog que genera Xcode; [SwiftGen](https://github.com/SwiftGen/SwiftGen) para fuentes, plists y otros archivos |
| Reintentos, tiempos de espera, peticiones single-flight | [SwiftConcurrency](https://github.com/muhittincamdali/SwiftConcurrency) |

## Requisitos

| Plataforma | Versión mínima |
| --- | --- |
| iOS | 16 |
| macOS | 13 |
| tvOS | 16 |
| watchOS | 9 |
| visionOS | 1 |
| Herramientas | Swift 6.2 · Xcode 26+ |

## Arquitectura

| Target | Contenido |
| --- | --- |
| `SwiftCodeGen` | Las declaraciones de las macros, `SynchronizedLock` (un lock recursivo) y `StreamBroadcast` (un `AsyncStream` con varios suscriptores) |
| `SwiftCodeGenMacros` | El plugin del compilador: `SynchronizedMacro` (roles member, member-attribute y extension), `SynchronizedPropertyMacro` (accesores y almacenamiento), `StreamedMacro` (comprobaciones), `PropertyAnalysis` y los diagnósticos |
| `SwiftCodeGenTests` | Pruebas en tiempo de ejecución en macOS y en el simulador de iOS: concurrencia, flujos, ejemplos del README |
| `SwiftCodeGenMainActorTests` | Las macros en un target con aislamiento por defecto de MainActor, como una app nueva |
| `SwiftCodeGenMacrosTests` | Las expansiones exactas y cada diagnóstico con su fix-it (macOS) |

- **Un lock por objeto, no por propiedad.** Un único lock recursivo es lo que permite que `withLock` cubra varias
  propiedades y que el código de su interior use la sintaxis normal de propiedades.
- **Init accessors, no body macros.** El almacenamiento se inicializa mediante `@storageRestrictions(initializes:)`,
  así que los inicializadores y los valores por defecto funcionan tal como están escritos en todos los compiladores
  de Swift 6.2.
- **`_modify` bajo el lock.** Los cambios in situ ceden el almacenamiento con `yield` mientras se mantiene el lock;
  eso es lo que hace atómicos `+=` y `append`. Una propiedad `weak` o `unowned` solo recibe `get` y `set`.

## Hoja de ruta

- Una opción para nombrar la propiedad del flujo (`@Streamed(as: "progressStream")`).
- Un `withLock` público para clases públicas, como opción voluntaria (`@Synchronized(.publicLock)`); hoy es
  `internal` para que el código de fuera del módulo no pueda mantener el lock.
- Linux en CI: el paquete solo usa `NSRecursiveLock` y `NSLock` de Foundation, pero se prueba únicamente en
  plataformas de Apple.

## Contribuir

Las contribuciones son bienvenidas. Lee la [guía de contribución](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CONTRIBUTING.md) y el [código de conducta](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CODE_OF_CONDUCT.md) antes de abrir una pull request. Informa de los problemas de seguridad de forma privada, como se describe en la [política de seguridad](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/SECURITY.md).

## Licencia

Publicado bajo la licencia MIT. Consulta [LICENSE](LICENSE).
