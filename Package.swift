// swift-tools-version:5.10
import PackageDescription

let package = Package(
    name: "Bashbox",
    platforms: [.macOS(.v14)],
    products: [
        .executable(name: "Bashbox", targets: ["Bashbox"]),
    ],
    dependencies: [
        .package(url: "https://github.com/migueldeicaza/SwiftTerm.git", from: "1.5.0"),
    ],
    targets: [
        // Curriculum, workspaces, and mission checks. No UI, so it is easy to test.
        .target(name: "BashboxCore"),
        // The SwiftUI app with the embedded bash terminal.
        .executableTarget(
            name: "Bashbox",
            dependencies: ["BashboxCore", .product(name: "SwiftTerm", package: "SwiftTerm")]
        ),
        .testTarget(name: "BashboxCoreTests", dependencies: ["BashboxCore"]),
    ]
)
