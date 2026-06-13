// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "SwiftCodeGen",
    platforms: [
        .iOS(.v15),
        .macOS(.v13)
    ],
    products: [
        .library(name: "SwiftCodeGen", targets: ["SwiftCodeGen"]),
    ],
    targets: [
        .target(
            name: "SwiftCodeGen",
            path: "Sources/SwiftCodeGen",
            exclude: ["CLI"],
            swiftSettings: [
                .enableExperimentalFeature("StrictConcurrency")
            ]
        ),
        .testTarget(
            name: "SwiftCodeGenTests",
            dependencies: ["SwiftCodeGen"]
        )
    ]
)
