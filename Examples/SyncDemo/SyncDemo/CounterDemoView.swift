import SwiftCodeGen
import SwiftUI

/// The counter that eight background tasks share.
@Synchronized
final class HitCounter {
    var hits = 0
}

/// How each background task adds one.
enum IncrementStyle: String, CaseIterable, Identifiable {
    /// `counter.hits += 1`: the read and the write happen under the lock as one step.
    case oneStep
    /// `let value = counter.hits; counter.hits = value + 1`: two locked steps, so two tasks can
    /// read the same value and one of the two increments is lost.
    case readThenWrite

    var id: Self { self }

    var code: String {
        switch self {
        case .oneStep: "counter.hits += 1"
        case .readThenWrite: "let value = counter.hits\ncounter.hits = value + 1"
        }
    }
}

struct CounterRun: Identifiable {
    let style: IncrementStyle
    let expected: Int
    let counted: Int
    let duration: Duration

    var id: IncrementStyle { style }
    var lost: Int { expected - counted }
}

/// Runs `workers` detached tasks that each add one `increments` times.
nonisolated func runCounter(
    style: IncrementStyle,
    workers: Int,
    increments: Int
) async -> CounterRun {
    let counter = HitCounter()
    let clock = ContinuousClock()
    let start = clock.now
    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<workers {
            group.addTask {
                for _ in 0..<increments {
                    switch style {
                    case .oneStep:
                        counter.hits += 1
                    case .readThenWrite:
                        let value = counter.hits
                        counter.hits = value + 1
                    }
                }
            }
        }
    }
    return CounterRun(
        style: style,
        expected: workers * increments,
        counted: counter.hits,
        duration: start.duration(to: clock.now)
    )
}

struct CounterDemoView: View {
    let runsOnAppear: Bool

    private let workers = 8
    private let increments = 20_000
    @State private var runs: [CounterRun] = []
    @State private var isRunning = false

    var body: some View {
        List {
            Section {
                Text("\(workers) background tasks each add one \(increments.formatted()) times to the same `@Synchronized` counter.")
                    .font(.callout)
                Button(isRunning ? "Running…" : "Run both") {
                    Task { await run() }
                }
                .disabled(isRunning)
            }
            ForEach(IncrementStyle.allCases) { style in
                Section {
                    Text(style.code)
                        .font(.system(.callout, design: .monospaced))
                    if let run = runs.first(where: { $0.style == style }) {
                        result(run)
                    } else {
                        Text("Not run yet").foregroundStyle(.secondary)
                    }
                } header: {
                    Text(style == .oneStep ? "One locked step" : "Two locked steps")
                }
            }
        }
        .navigationTitle("Shared counter")
        .task {
            if runsOnAppear { await run() }
        }
    }

    private func result(_ run: CounterRun) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            LabeledContent("Expected", value: run.expected.formatted())
            LabeledContent("Counted", value: run.counted.formatted())
            if run.lost == 0 {
                Label("No update lost", systemImage: "checkmark.circle.fill")
                    .foregroundStyle(.blue)
            } else {
                Label("\(run.lost.formatted()) updates lost", systemImage: "exclamationmark.triangle.fill")
                    .foregroundStyle(.secondary)
            }
            Text(run.duration.formatted(.units(allowed: [.milliseconds])))
                .font(.footnote)
                .foregroundStyle(.secondary)
        }
    }

    private func run() async {
        isRunning = true
        runs = []
        for style in IncrementStyle.allCases {
            runs.append(await runCounter(style: style, workers: workers, increments: increments))
        }
        isRunning = false
    }
}
