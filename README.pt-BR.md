<!-- i18n-source: README.md@aafb1ff03311ce9811cf816cb4006c4bb83dac5a status=reviewed -->
<!-- brand:start -->

<p align="center"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/banner-light.svg" alt="SwiftCodeGen: Swift macros that make a class Sendable without @unchecked and stream its changes."></picture></p>

<!-- lang-selector:start -->
<p align="center"><a href="README.md">English</a> · <a href="README.tr.md">Türkçe</a> · <a href="README.zh-CN.md">简体中文</a> · <a href="README.ja.md">日本語</a> · <a href="README.ko.md">한국어</a> · <a href="README.es.md">Español</a> · <a href="README.de.md">Deutsch</a> · <a href="README.fr.md">Français</a> · <a href="README.pt-BR.md">Português (Brasil)</a> · <a href="README.ru.md">Русский</a></p>
<!-- lang-selector:end -->

<p align="center">
<a href="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml"><img src="https://github.com/muhittincamdali/SwiftCodeGen/actions/workflows/ci.yml/badge.svg" alt="Status da CI"></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/releases"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-version-light.svg" alt="Versão mais recente: v2.0.0"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-platforms-light.svg" alt="Plataformas compatíveis: iOS 16+ · macOS 13+ · tvOS 16+ · watchOS 9+ · visionOS 1+"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/Package.swift"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-language-light.svg" alt="Versão da linguagem: Swift 6.2+ · Swift 6 mode"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/blob/main/LICENSE"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/badge-license-light.svg" alt="Licença: MIT"></picture></a>
</p>

<p align="center">
<a href="#início-rápido"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-start-pt-BR-light.svg" alt="Começar"></picture></a>
<a href="https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-docs-pt-BR-light.svg" alt="Documentação"></picture></a>
<a href="https://github.com/muhittincamdali/SwiftCodeGen/tree/main/Examples"><picture><source media="(prefers-color-scheme: dark)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-pt-BR-dark.svg"><source media="(prefers-color-scheme: light)" srcset="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-pt-BR-light.svg"><img src="https://raw.githubusercontent.com/muhittincamdali/SwiftCodeGen/main/.github/brand/button-examples-pt-BR-light.svg" alt="Exemplos"></picture></a>
</p>

> Esta é uma tradução do README em inglês. Se houver diferença, vale a versão em inglês.

<!-- brand:end -->

O SwiftCodeGen é um pequeno pacote de macros do Swift 6 para um problema que a concorrência estrita (strict
concurrency) tornou comum: uma classe cujo estado é compartilhado entre threads por código síncrono, como um cache,
uma sessão, um delegate de download ou um contador. O Swift 6 só deixa uma classe assim cruzar threads quando ela é
`Sendable`, e as soluções de sempre são um lock escrito à mão atrás de `@unchecked Sendable`, que o compilador deixa
de verificar, ou um actor, que transforma cada chamada em um `await`. Use `@Synchronized` no lugar: cada `var`
armazenada é protegida por um único lock, `count += 1` não perde nenhuma atualização, `withLock` agrupa vários
passos, e a classe passa a ser `Sendable` com a verificação do compilador ainda ativa. O `@Streamed` adiciona um
`AsyncStream` com os valores de uma propriedade para qualquer número de assinantes.

## Destaques

- **`Sendable` verificado, sem `@unchecked`** — a macro adiciona uma conformidade `Sendable` de verdade, então um
  `let` de um tipo que não é `Sendable` continua sendo um erro de compilação.
- **Nenhuma atualização perdida** — getters, setters e alterações no local (`+=`, `append`, `dict[key] =`) rodam
  sob o lock; 2.000 `+=` concorrentes nos testes somam exatamente 2.000.
- **Vários passos como um só** — `withLock { … }` mantém o lock durante um bloco de código com a sintaxe comum de
  propriedades dentro dele, e repassa erros tipados (`throws(Failure)`).
- **Nada para reescrever** — valores padrão, `self.x = x` no `init`, `nil` implícito, `weak` e `unowned` continuam
  funcionando; propriedades `let`, computadas e `static` ficam como estão.
- **Fluxos de mudanças** — `@Streamed var progress: Double` adiciona `progressUpdates`: primeiro o valor atual,
  depois cada mudança em ordem, com um valor em buffer por assinante; o fluxo termina quando o objeto é liberado.
- **Erros em vez de surpresas** — structs, actors, classes sem `final`, `@MainActor`, `lazy`, observadores e
  property wrappers são rejeitados com um motivo e, quando a correção é clara, com uma sugestão de correção.

## Início rápido

**1. Adicione o pacote**

No Xcode, escolha **File › Add Package Dependencies…**, informe a URL do repositório e adicione a biblioteca
**SwiftCodeGen** ao seu target. No primeiro build, escolha **Trust & Enable** para as macros.

```text
https://github.com/muhittincamdali/SwiftCodeGen.git
```

**2. Importe o módulo**

```swift
import SwiftCodeGen
```

**3. Use `@Synchronized` em uma classe final**

Um cache que qualquer thread pode usar sem `await`
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

`ImageCache` agora é `Sendable`: passe-a para um `Task.detached`, um task group ou um callback em qualquer fila, e
chame-a sem `await`.

## Instalação

### Swift Package Manager

Adicione-o às `dependencies` do seu `Package.swift`:

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

O pacote depende do [swift-syntax](https://github.com/swiftlang/swift-syntax) (602 a 604), que o compilador usa para
expandir as macros; nada dele é vinculado ao seu app. Builds pela linha de comando com `xcodebuild` precisam de
`-skipMacroValidation`, ou de uma confiança concedida uma única vez no Xcode.

## Uso

Os exemplos abaixo foram copiados de
[`ReadmeSamples.swift`](Examples/SyncDemo/SyncDemo/ReadmeSamples.swift), que o app de exemplo compila com o
isolamento padrão do MainActor (default isolation) e que a suíte de testes executa.

### Alterar várias propriedades juntas

Cada acesso a uma propriedade é um passo com lock. Os passos que devem acontecer juntos vão dentro de `withLock`,
para que nenhuma outra thread veja `progress` e `status` em desacordo:

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

O lock é recursivo, então os acessos às propriedades dentro de `withLock` o adquirem novamente na mesma thread. Não
adquira os locks de dois objetos em ordens opostas em duas threads; isso causa deadlock, como acontece com qualquer
par de locks.

### Acompanhar as mudanças com `for await`

O `@Streamed` deu ao `UploadTracker` as propriedades `progressUpdates` e `statusUpdates`. Cada leitura retorna um
novo fluxo que começa com o valor atual:

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

Os valores são enviados enquanto o lock está retido, então cada assinante vê as mudanças na ordem em que
aconteceram. Em um tipo `Equatable`, atribuir a uma propriedade o valor que ela já tem não envia nada; em um target
de app com isolamento padrão do MainActor, declare esse tipo como `nonisolated`, como `UploadStatus` acima, ou a
conformidade dele pertencerá ao actor principal e toda atribuição será enviada. Um assinante que fica para trás
mantém apenas o valor mais recente. Os fluxos terminam quando o objeto é liberado, e um fluxo não mantém seu objeto
vivo.

### Inicializadores e referências weak

As propriedades continuam funcionando nos inicializadores, os opcionais começam como `nil` e `weak` continua fraca:

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

### O que a macro escreve

Use **Editor › Expand Macro** no Xcode para ver o código de qualquer classe. Para `var hits = 0`, ele é:

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

Além disso, uma vez por classe, `private let _lock = SwiftCodeGen.SynchronizedLock()`, o método `withLock` e
`extension ImageCache: Sendable {}`. O armazenamento é `nonisolated(unsafe)` porque quem o protege é o lock, e não o
compilador; todos os outros membros da classe continuam sendo verificados.

### O que a macro rejeita

| Declaração | Erro e a correção que ela sugere |
| --- | --- |
| `struct`, `enum` | Tipos de valor são `Sendable` quando suas propriedades armazenadas são. |
| `actor` | Um actor já protege o próprio estado. |
| `class` sem `final` | Uma subclasse poderia adicionar estado que o lock não protege. Correção: adicione `final`. |
| `@MainActor` na classe ou em uma propriedade | O lock substitui o isolamento do actor. Correção: remova-o. |
| `lazy var` | Correção: remova `lazy`. |
| `willSet` / `didSet` | Mova o código para um método que defina a propriedade. |
| Um property wrapper | O armazenamento dele não seria protegido. |
| `var a = 0, b = 1`, `var (a, b) = …` | Declare cada propriedade em sua própria linha. |
| `@Streamed` em uma propriedade `let`, `static`, computada, `weak` ou sem tipo | Cada caso tem sua própria mensagem. |

Para deixar uma propriedade de fora de propósito, marque-a como `nonisolated(unsafe)`.

## Demonstração

O app de exemplo em [`Examples/SyncDemo`](Examples/SyncDemo) executa as duas macros em um iPhone ou em um Mac. As
capturas de tela abaixo foram feitas a partir da versão para Mac por
[`scripts/capture-mac-screens.sh`](scripts/capture-mac-screens.sh);
[`scripts/capture-example-screens.sh`](scripts/capture-example-screens.sh) captura as mesmas telas em um simulador de
iPhone.

| Contador compartilhado | Progresso do upload |
| --- | --- |
| <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-counter-dark.png"><img src="docs/images/demo-counter-light.png" width="320" alt="Contador compartilhado: oito tarefas somam um 20.000 vezes cada uma; um passo com lock conta 160.000, dois passos com lock perdem atualizações"></picture> | <picture><source media="(prefers-color-scheme: dark)" srcset="docs/images/demo-upload-dark.png"><img src="docs/images/demo-upload-light.png" width="320" alt="Progresso do upload: um assinante mostra 100 por cento após 21 valores, o outro mostra aguardando, enviando e concluído uma vez cada"></picture> |

## Documentação

- [Referência do SwiftCodeGen](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/)
- [Primeiros passos](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/gettingstarted)
- [Transmitindo mudanças](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/streamingchanges)
- [Escolhendo uma ferramenta](https://muhittincamdali.github.io/SwiftCodeGen/documentation/swiftcodegen/choosingatool)

## Guias

- [Primeiros passos](Sources/SwiftCodeGen/SwiftCodeGen.docc/GettingStarted.md) — o que a macro muda, `withLock`, o
  isolamento padrão do MainActor e as declarações que ela rejeita.
- [Transmitindo mudanças](Sources/SwiftCodeGen/SwiftCodeGen.docc/StreamingChanges.md) — o que um assinante recebe,
  quando um fluxo termina e `StreamBroadcast` isoladamente.
- [Escolhendo uma ferramenta](Sources/SwiftCodeGen/SwiftCodeGen.docc/ChoosingATool.md) — quando um actor, `Mutex` ou
  outro pacote é a melhor escolha.

## Quando usar outra coisa

O SwiftCodeGen não é um gerador de código genérico. Para os trabalhos que as ferramentas conhecidas fazem, use-as:

| Você quer | Use |
| --- | --- |
| Estado cujo trabalho é `async` (rede, disco) | Um `actor`: os métodos dele podem suspender, e um lock não deve ser retido durante um `await`. |
| Um ou dois valores protegidos no iOS 18+ | `Mutex` do módulo Synchronization. |
| Estado de interface que o SwiftUI observa | `@Observable` no actor principal. |
| Mocks e spies de protocolos | [Mockable](https://github.com/Kolos65/Mockable), [swift-spyable](https://github.com/Matejkob/swift-spyable) |
| Código gerado a partir de templates para muitos tipos | [Sourcery](https://github.com/krzysztofzablocki/Sourcery) |
| Clientes e servidores a partir de um documento OpenAPI | [swift-openapi-generator](https://github.com/apple/swift-openapi-generator) |
| Nomes tipados para imagens, cores e strings | Os símbolos de assets e de String Catalog gerados pelo Xcode; [SwiftGen](https://github.com/SwiftGen/SwiftGen) para fontes, plists e outros arquivos |
| Novas tentativas, timeouts, requisições single-flight | [SwiftConcurrency](https://github.com/muhittincamdali/SwiftConcurrency) |

## Requisitos

| Plataforma | Versão mínima |
| --- | --- |
| iOS | 16 |
| macOS | 13 |
| tvOS | 16 |
| watchOS | 9 |
| visionOS | 1 |
| Ferramentas | Swift 6.2 · Xcode 26+ |

## Arquitetura

| Target | Conteúdo |
| --- | --- |
| `SwiftCodeGen` | As declarações das macros, `SynchronizedLock` (um lock recursivo) e `StreamBroadcast` (um `AsyncStream` com vários assinantes) |
| `SwiftCodeGenMacros` | O plugin do compilador: `SynchronizedMacro` (papéis member, member-attribute e extension), `SynchronizedPropertyMacro` (acessores e armazenamento), `StreamedMacro` (verificações), `PropertyAnalysis` e os diagnósticos |
| `SwiftCodeGenTests` | Testes de execução no macOS e no simulador do iOS: concorrência, fluxos, exemplos do README |
| `SwiftCodeGenMainActorTests` | As macros em um target com isolamento padrão do MainActor, como em um app novo |
| `SwiftCodeGenMacrosTests` | As expansões exatas e cada diagnóstico com seu fix-it (macOS) |

- **Um lock por objeto, não por propriedade.** Um único lock recursivo é o que permite ao `withLock` cobrir várias
  propriedades e ao código dentro dele usar a sintaxe comum de propriedades.
- **Init accessors, não body macros.** O armazenamento é inicializado por meio de
  `@storageRestrictions(initializes:)`, então os inicializadores e os valores padrão funcionam como foram escritos
  em todos os compiladores do Swift 6.2.
- **`_modify` sob o lock.** As alterações no local cedem o armazenamento com `yield` enquanto o lock está retido; é
  isso que torna `+=` e `append` atômicos. Uma propriedade `weak` ou `unowned` recebe apenas `get` e `set`.

## Roteiro

- Uma opção para nomear a propriedade do fluxo (`@Streamed(as: "progressStream")`).
- Um `withLock` público para classes públicas, como recurso opcional (`@Synchronized(.publicLock)`); hoje ele é
  `internal`, para que o código de fora do módulo não possa reter o lock.
- Linux na CI: o pacote usa apenas `NSRecursiveLock` e `NSLock` do Foundation, mas é testado somente em plataformas
  Apple.

## Como contribuir

Contribuições são bem-vindas. Leia o [guia de contribuição](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CONTRIBUTING.md) e o [código de conduta](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/CODE_OF_CONDUCT.md) antes de abrir um pull request. Relate problemas de segurança de forma privada, como descrito na [política de segurança](https://github.com/muhittincamdali/SwiftCodeGen/blob/main/SECURITY.md).

## Licença

Publicado sob a licença MIT. Veja [LICENSE](LICENSE).
