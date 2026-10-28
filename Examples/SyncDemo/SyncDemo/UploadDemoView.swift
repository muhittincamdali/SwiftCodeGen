import SwiftCodeGen
import SwiftUI

/// Simulates an upload on a background task: one chunk every 120 ms.
nonisolated func simulateUpload(_ tracker: UploadTracker) async {
    for _ in 0..<tracker.totalChunks {
        try? await Task.sleep(for: .milliseconds(120))
        tracker.chunkSent()
    }
}

struct UploadDemoView: View {
    let runsOnAppear: Bool

    // One tracker per run; the views below subscribe to its streams.
    @State private var tracker = UploadTracker(totalChunks: 20)
    @State private var run = 0

    var body: some View {
        List {
            Section {
                Text("A background task writes `progress` and `status`. The two sections below read them through their own streams, `progressUpdates` and `statusUpdates`.")
                    .font(.callout)
                Button("Start upload") { start() }
            }
            Section("Subscriber 1 · progressUpdates") {
                ProgressSubscriber(tracker: tracker)
            }
            Section("Subscriber 2 · statusUpdates") {
                StatusSubscriber(tracker: tracker)
            }
        }
        .id(run)
        .navigationTitle("Upload progress")
        .task {
            if runsOnAppear { start() }
        }
    }

    private func start() {
        let tracker = UploadTracker(totalChunks: 20)
        self.tracker = tracker
        run += 1
        Task.detached { await simulateUpload(tracker) }
    }
}

private struct ProgressSubscriber: View {
    let tracker: UploadTracker
    @State private var progress = 0.0
    @State private var received = 0

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            ProgressView(value: progress)
            LabeledContent("Progress", value: progress.formatted(.percent.precision(.fractionLength(0))))
            LabeledContent("Values received", value: received.formatted())
        }
        .task {
            for await value in tracker.progressUpdates {
                progress = value
                received += 1
            }
        }
    }
}

private struct StatusSubscriber: View {
    let tracker: UploadTracker
    @State private var history: [UploadStatus] = []

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            ForEach(Array(history.enumerated()), id: \.offset) { _, status in
                Label(status.title, systemImage: status.systemImage)
            }
            Text("Equal values are not sent again: `uploading` appears once although it is assigned nineteen times.")
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
        .task {
            for await status in tracker.statusUpdates {
                history.append(status)
            }
        }
    }
}

extension UploadStatus {
    var title: String {
        switch self {
        case .waiting: "waiting"
        case .uploading: "uploading"
        case .finished: "finished"
        }
    }

    var systemImage: String {
        switch self {
        case .waiting: "clock"
        case .uploading: "arrow.up.circle"
        case .finished: "checkmark.circle.fill"
        }
    }
}
