// swift-tools-version:5.5
import PackageDescription

let package = Package(
    name: "The Pendulum",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "The Pendulum",
            targets: ["The Pendulum"])
    ],
    dependencies: [
        // Define the DGCharts dependency
        .package(url: "https://github.com/danielgindi/Charts.git", .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(
            name: "The Pendulum",
            dependencies: [
                .product(name: "DGCharts", package: "Charts")
            ],
            path: "The Pendulum")
    ]
)