// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "swift-microsoft-graph",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MicrosoftGraph", targets: ["MicrosoftGraph"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "MicrosoftGraph",
            dependencies: []
        ),
        .testTarget(
            name: "MicrosoftGraphTests",
            dependencies: ["MicrosoftGraph"]
        ),
    ]
)
