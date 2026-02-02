// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "SwiftCodeGen",
    platforms: [
        .macOS(.v13),
        .iOS(.v15)
    ],
    products: [
        .executable(
            name: "swiftcodegen",
            targets: ["SwiftCodeGenCLI"]
        ),
        .library(
            name: "SwiftCodeGen",
            targets: ["SwiftCodeGen"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser.git", from: "1.3.0")
    ],
    targets: [
        .executableTarget(
            name: "SwiftCodeGenCLI",
            dependencies: [
                "SwiftCodeGen",
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ],
            path: "Sources/SwiftCodeGen/CLI"
        ),
        .target(
            name: "SwiftCodeGen",
            dependencies: [],
            path: "Sources/SwiftCodeGen",
            exclude: ["CLI"]
        ),
        .testTarget(
            name: "SwiftCodeGenTests",
            dependencies: ["SwiftCodeGen"]
        )
    ]
)
