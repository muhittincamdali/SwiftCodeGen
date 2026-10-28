import Foundation
import Testing

/// Runs the README samples (ReadmeSamples.swift, shared with the example app).
@Suite("README samples")
struct ReadmeSampleTests {
    @Test("ImageCache counts every hit and miss from concurrent readers")
    func imageCache() async {
        let cache = ImageCache()
        let cached = URL(string: "https://images.example/cat.png")!
        let missing = URL(string: "https://images.example/dog.png")!
        cache.store(Data([1, 2, 3]), for: cached)

        await withTaskGroup(of: Void.self) { group in
            for index in 0..<1_000 {
                group.addTask { _ = cache.image(for: index.isMultiple(of: 2) ? cached : missing) }
            }
        }
        #expect(cache.hits == 500)
        #expect(cache.misses == 500)
        #expect(cache.image(for: cached) == Data([1, 2, 3]))
    }

    @Test("UploadTracker statuses arrive in order, once each, ending with finished")
    func uploadTracker() async {
        let tracker = UploadTracker(totalChunks: 10)
        let statuses = Task { await waitForUpload(tracker) }
        var progress = tracker.progressUpdates.makeAsyncIterator()
        #expect(await progress.next() == 0)
        await Task.detached {
            // More chunks than the total: progress stops at 1.
            for _ in 0..<12 { tracker.chunkSent() }
        }.value
        let seen = await statuses.value
        // The subscriber may join at any point of the upload; whatever it saw is in order, ends
        // with finished and has no repeated status.
        let order: [UploadStatus] = [.waiting, .uploading, .finished]
        #expect(seen.last == .finished)
        #expect(seen == order.filter(seen.contains))
        #expect(tracker.progress == 1)
        #expect(await progress.next() == 1)
    }

    @Test("Session keeps its initializer values and a weak observer")
    func session() {
        let session = Session(token: "abc")
        #expect(session.token == "abc")
        #expect(session.expiresAt == nil)
        var observer: SessionObserver? = SessionObserver()
        session.observer = observer
        #expect(session.observer != nil)
        observer = nil
        #expect(session.observer == nil)
    }
}
