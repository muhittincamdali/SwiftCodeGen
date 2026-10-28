import SwiftCodeGen
import Testing

// This target uses MainActor as the default isolation, like a new Xcode 26+ app target.

@Synchronized
final class Downloads {
    var finished = 0
    @Streamed var phase: Phase = .idle
}

/// Without `nonisolated`, this enum and its Equatable conformance would belong to the main actor,
/// and the stream, which compares values off the main actor, would send repeated values.
nonisolated enum Phase: Sendable, Equatable {
    case idle
    case running
    case done
}

/// Runs off the main actor: compiles only because `Downloads` is not isolated to it.
nonisolated func finishFromBackground(_ downloads: Downloads, count: Int) async {
    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<count {
            group.addTask {
                downloads.finished += 1
                downloads.phase = .running
            }
        }
    }
    downloads.phase = .done
}

@Suite("MainActor default isolation")
struct DefaultIsolationTests {
    @Test("A @Synchronized class is usable from background tasks")
    func backgroundUse() async {
        let downloads = Downloads()
        await finishFromBackground(downloads, count: 1_000)
        #expect(downloads.finished == 1_000)
        #expect(downloads.phase == .done)
    }

    @Test("A nonisolated Equatable type has repeated values skipped")
    func deduplication() async {
        var downloads: Downloads? = Downloads()
        var phases = downloads!.phaseUpdates.makeAsyncIterator()
        #expect(await phases.next() == .idle)
        await Task.detached { [downloads] in downloads!.phase = .running }.value
        #expect(await phases.next() == .running)
        // The same value again, then the owner goes away and the stream ends. A repeated value
        // would still be waiting in the buffer.
        await Task.detached { [downloads] in downloads!.phase = .running }.value
        downloads = nil
        #expect(await phases.next() == nil)
    }
}
