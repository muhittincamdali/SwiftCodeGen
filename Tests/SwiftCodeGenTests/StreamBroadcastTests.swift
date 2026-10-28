import SwiftCodeGen
import Testing

@Suite("StreamBroadcast")
struct StreamBroadcastTests {
    @Test("A subscriber whose task is cancelled is forgotten")
    func cancelledSubscriberIsRemoved() async {
        let broadcast = StreamBroadcast<Int>()
        let stream = broadcast.subscribe(current: 0)
        let started = AsyncStream<Void>.makeStream()
        let consumer = Task {
            for await _ in stream {
                started.continuation.yield()
            }
        }
        for await _ in started.stream { break }
        #expect(broadcast.subscriberCount == 1)
        consumer.cancel()
        await consumer.value
        #expect(broadcast.subscriberCount == 0)
    }

    @Test("A stream dropped without being iterated is forgotten")
    func droppedStreamIsRemoved() {
        let broadcast = StreamBroadcast<Int>()
        for value in 0..<1_000 {
            _ = broadcast.subscribe(current: value)
        }
        #expect(broadcast.subscriberCount == 0)
    }

    @Test("A loop that breaks out of the stream is forgotten")
    func brokenLoopIsRemoved() async {
        let broadcast = StreamBroadcast<Int>()
        do {
            for await _ in broadcast.subscribe(current: 1) { break }
        }
        #expect(broadcast.subscriberCount == 0)
    }

    @Test("finishAll ends every loop; later subscribers get new streams")
    func finishAll() async {
        let broadcast = StreamBroadcast<String>()
        let stream = broadcast.subscribe(current: "a")
        let consumer = Task {
            var values: [String] = []
            for await value in stream { values.append(value) }
            return values
        }
        broadcast.finishAll()
        let values = await consumer.value
        #expect(values.count <= 1)
        #expect(broadcast.subscriberCount == 0)

        var iterator = broadcast.subscribe(current: "b").makeAsyncIterator()
        broadcast.send("c")
        #expect(await iterator.next() == "c")
    }

    @Test("Many subscribers each receive the newest value")
    func manySubscribers() async {
        let broadcast = StreamBroadcast<Int>()
        var iterators = (0..<100).map { _ in broadcast.subscribe(current: 0).makeAsyncIterator() }
        broadcast.send(7)
        for index in iterators.indices {
            #expect(await iterators[index].next() == 7)
        }
        #expect(broadcast.subscriberCount == 100)
    }
}
