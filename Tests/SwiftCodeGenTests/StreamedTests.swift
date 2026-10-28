import SwiftCodeGen
import Testing

@Suite("@Streamed")
struct StreamedTests {
    @Test("A stream starts with the current value, then delivers each change in order")
    func currentThenChanges() async {
        let progress = Progress()
        progress.fraction = 0.25
        var iterator = progress.fractionUpdates.makeAsyncIterator()
        #expect(await iterator.next() == 0.25)
        progress.fraction = 0.5
        #expect(await iterator.next() == 0.5)
        progress.fraction += 0.25
        #expect(await iterator.next() == 0.75)
    }

    @Test("In-place mutation sends the new value once")
    func inPlaceMutation() async {
        let progress = Progress()
        var iterator = progress.logUpdates.makeAsyncIterator()
        #expect(await iterator.next() == [])
        progress.log.append("start")
        #expect(await iterator.next() == ["start"])
        progress.withLock {
            progress.log.append("a")
            progress.log.append("b")
        }
        // Each append is a change; a subscriber that is behind skips to the newest value.
        #expect(await iterator.next() == ["start", "a", "b"])
    }

    @Test("Every subscriber receives every change")
    func multipleSubscribers() async {
        let progress = Progress()
        var first = progress.fractionUpdates.makeAsyncIterator()
        var second = progress.fractionUpdates.makeAsyncIterator()
        #expect(await first.next() == 0)
        #expect(await second.next() == 0)
        progress.fraction = 1
        #expect(await first.next() == 1)
        #expect(await second.next() == 1)
    }

    @Test("Assigning an Equatable property its current value sends nothing")
    func equatableDeduplication() async {
        var progress: Progress? = Progress()
        var iterator = progress!.titleUpdates.makeAsyncIterator()
        #expect(await iterator.next() == .some(nil))
        progress!.title = nil
        progress!.title = "Copying"
        #expect(await iterator.next() == "Copying")
        progress!.title = "Copying"
        // The stream ends with the object; a repeated "Copying" would still be buffered.
        progress = nil
        #expect(await iterator.next() == nil)
    }

    @Test("A type that is not Equatable sends every assignment")
    func nonEquatableSendsAll() async {
        let progress = Progress()
        var iterator = progress.tickUpdates.makeAsyncIterator()
        #expect(await iterator.next()?.value == 0)
        progress.tick = Tick(value: 0)
        #expect(await iterator.next()?.value == 0)
    }

    @Test("An implicitly unwrapped optional is streamed as an optional")
    func implicitlyUnwrapped() async {
        let progress = Progress()
        var iterator = progress.tokenUpdates.makeAsyncIterator()
        #expect(await iterator.next() == .some(nil))
        progress.token = "abc"
        #expect(await iterator.next() == "abc")
    }

    @Test("A slow subscriber keeps only the newest value, not every change")
    func boundedBuffer() async {
        let progress = Progress()
        var iterator = progress.fractionUpdates.makeAsyncIterator()
        for step in 1...10_000 {
            progress.fraction = Double(step)
        }
        #expect(await iterator.next() == 10_000)
    }

    @Test("Concurrent writers: the last value a subscriber sees is the final value")
    func concurrentWriters() async {
        let progress = Progress()
        let updates = progress.logUpdates
        await withTaskGroup(of: Void.self) { group in
            for index in 0..<500 {
                group.addTask { progress.log.append("\(index)") }
            }
        }
        #expect(progress.log.count == 500)
        var last: [String] = []
        for await value in updates {
            last = value
            if value.count == 500 { break }
        }
        #expect(last.count == 500)
        #expect(Set(last) == Set((0..<500).map(String.init)))
    }

    @Test("Streams end when the object is released")
    func streamEndsWithOwner() async {
        var progress: Progress? = Progress()
        let updates = progress!.fractionUpdates
        let consumer = Task {
            var received: [Double] = []
            for await value in updates {
                received.append(value)
            }
            return received
        }
        progress = nil
        let received = await consumer.value
        #expect(received.count <= 1)
    }

    @Test("Public read access gives a public stream of a private(set) property")
    func publicModel() async {
        let model = PublicModel()
        var iterator = model.countUpdates.makeAsyncIterator()
        #expect(await iterator.next() == 0)
        model.increment()
        #expect(await iterator.next() == 1)
    }
}
