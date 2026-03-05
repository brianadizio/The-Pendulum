// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "GoldenTheme",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
        .watchOS(.v10)
    ],
    products: [
        .library(
            name: "GoldenTheme",
            targets: ["GoldenTheme"]),
    ],
    dependencies: [
        // SciChart will be added as a binary dependency when available
    ],
    targets: [
        .target(
            name: "GoldenTheme",
            dependencies: [],
            resources: [
                .process("Assets")
            ]
        ),
        .testTarget(
            name: "GoldenThemeTests",
            dependencies: ["GoldenTheme"]),
    ]
)
