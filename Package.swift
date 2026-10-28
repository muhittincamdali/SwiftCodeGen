// swift-tools-version: 6.2
import CompilerPluginSupport
import PackageDescription

let package = Package(
    name: "SwiftCodeGen",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "SwiftCodeGen", targets: ["SwiftCodeGen"]),
    ],
    dependencies: [
        .package(url: "https://github.com/swiftlang/swift-syntax.git", "602.0.0"..<"605.0.0"),
    ],
    targets: [
        .macro(
            name: "SwiftCodeGenMacros",
            dependencies: [
                .product(name: "SwiftSyntax", package: "swift-syntax"),
                .product(name: "SwiftSyntaxBuilder", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacros", package: "swift-syntax"),
                .product(name: "SwiftCompilerPlugin", package: "swift-syntax"),
                .product(name: "SwiftDiagnostics", package: "swift-syntax"),
            ]
        ),
        .target(
            name: "SwiftCodeGen",
            dependencies: ["SwiftCodeGenMacros"]
        ),
        .testTarget(
            name: "SwiftCodeGenTests",
            dependencies: ["SwiftCodeGen"]
        ),
        .testTarget(
            name: "SwiftCodeGenMacrosTests",
            dependencies: [
                "SwiftCodeGenMacros",
                .product(name: "SwiftSyntaxMacrosGenericTestSupport", package: "swift-syntax"),
                .product(name: "SwiftSyntaxMacroExpansion", package: "swift-syntax"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)
