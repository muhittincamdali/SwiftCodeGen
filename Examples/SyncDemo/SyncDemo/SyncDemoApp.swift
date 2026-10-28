import SwiftUI

@main
struct SyncDemoApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView(initialDemo: Demo.fromLaunchArguments())
                .preferredColorScheme(Self.colorSchemeFromLaunchArguments())
        }
        #if os(macOS)
        .defaultSize(width: 480, height: 640)
        #endif
    }

    /// `-appearance light` or `-appearance dark` fixes the appearance; the screenshot script uses it.
    static func colorSchemeFromLaunchArguments(
        _ arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> ColorScheme? {
        guard let index = arguments.firstIndex(of: "-appearance"), index + 1 < arguments.count else { return nil }
        switch arguments[index + 1] {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }
}

/// The screens of the app.
enum Demo: String, CaseIterable, Identifiable, Hashable {
    case counter
    case upload

    var id: Self { self }

    var title: String {
        switch self {
        case .counter: "Shared counter"
        case .upload: "Upload progress"
        }
    }

    var summary: String {
        switch self {
        case .counter: "@Synchronized: 8 threads, no lost update"
        case .upload: "@Streamed: one writer, two live subscribers"
        }
    }

    var systemImage: String {
        switch self {
        case .counter: "number.circle"
        case .upload: "arrow.up.circle"
        }
    }

    /// `-demo upload` opens a screen directly and runs its scenario; the screenshot script uses it.
    static func fromLaunchArguments(_ arguments: [String] = ProcessInfo.processInfo.arguments) -> Demo? {
        guard let index = arguments.firstIndex(of: "-demo"), index + 1 < arguments.count else { return nil }
        return Demo(rawValue: arguments[index + 1])
    }
}

struct ContentView: View {
    let initialDemo: Demo?
    @State private var path: [Demo] = []

    var body: some View {
        NavigationStack(path: $path) {
            List(Demo.allCases) { demo in
                NavigationLink(value: demo) {
                    Label {
                        VStack(alignment: .leading, spacing: 2) {
                            Text(demo.title)
                            Text(demo.summary)
                                .font(.footnote)
                                .foregroundStyle(.secondary)
                        }
                    } icon: {
                        Image(systemName: demo.systemImage)
                    }
                }
            }
            .navigationTitle("SwiftCodeGen")
            .navigationDestination(for: Demo.self) { demo in
                switch demo {
                case .counter: CounterDemoView(runsOnAppear: demo == initialDemo)
                case .upload: UploadDemoView(runsOnAppear: demo == initialDemo)
                }
            }
        }
        .tint(.blue)
        .onAppear {
            if let initialDemo, path.isEmpty {
                path = [initialDemo]
            }
        }
    }
}
