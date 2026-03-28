// swift-tools-version: 6.0
import PackageDescription

private let openAPIProducts: [Target.Dependency] = [
    .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
    .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession"),
]

private let openAPIGeneratorPlugin: [Target.PluginUsage] = [
    .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator"),
]

let package = Package(
    name: "swift-microsoft-graph",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "MicrosoftGraph", targets: ["MicrosoftGraph"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.5.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0"),
    ],
    targets: [
        // ── Auth ──────────────────────────────────────────────────────────
        .target(name: "GraphAuth"),

        // ── Client (shared bearer middleware + GraphClient facade) ─────────
        .target(
            name: "GraphClient",
            dependencies: [
                "GraphAuth",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
            ]
        ),

        // ── Mail (sendMail endpoint) ───────────────────────────────────────
        .target(
            name: "GraphMail",
            dependencies: ["GraphClient"] + openAPIProducts,
            plugins: openAPIGeneratorPlugin
        ),

        // ── Users (list users v1.0 + beta) ────────────────────────────────
        .target(
            name: "GraphUsers",
            dependencies: ["GraphClient"] + openAPIProducts,
            plugins: openAPIGeneratorPlugin
        ),

        // ── OAuth (GET /me with delegated token) ──────────────────────────
        .target(
            name: "GraphOAuth",
            dependencies: ["GraphClient"] + openAPIProducts,
            plugins: openAPIGeneratorPlugin
        ),

        // ── Umbrella library product ───────────────────────────────────────
        .target(
            name: "MicrosoftGraph",
            dependencies: ["GraphMail", "GraphUsers", "GraphOAuth"]
        ),

        .testTarget(
            name: "MicrosoftGraphTests",
            dependencies: ["MicrosoftGraph"]
        ),
    ]
)
