// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "PendulumSolver",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "PendulumSolver",
            targets: ["PendulumSolver"]
        ),
        .executable(
            name: "PendulumSolverCLI",
            targets: ["PendulumSolverCLI"]
        )
    ],
    targets: [
        // Main Swift library - Hybrid MPC + Learning Pendulum Solver
        .target(
            name: "PendulumSolver",
            dependencies: [],
            path: "Sources/PendulumSolver",
            resources: [
                .process("Resources")
            ]
            // Note: When C library is compiled, add linker settings:
            // linkerSettings: [
            //     .linkedLibrary("pendulum_solver", .when(platforms: [.macOS, .iOS])),
            //     .unsafeFlags(["-L../../c_lib/lib"], .when(platforms: [.macOS, .iOS]))
            // ]
        ),

        // CLI tool for testing
        .executableTarget(
            name: "PendulumSolverCLI",
            dependencies: ["PendulumSolver"],
            path: "Sources/PendulumSolverCLI"
        ),

        // Tests
        .testTarget(
            name: "PendulumSolverTests",
            dependencies: ["PendulumSolver"],
            path: "Tests/PendulumSolverTests"
        )
    ]
)
