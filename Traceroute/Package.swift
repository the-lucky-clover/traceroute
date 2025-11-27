// swift-tools-version:5.9
import PackageDescription

// Note: App and UI targets require macOS and will only build on macOS
// Core, Network, and Parser modules are cross-platform

#if os(macOS)
let appTarget: [Target] = [
    .executableTarget(
        name: "App",
        dependencies: ["Core", "UI", "Network", "Parser"],
        path: "Sources/App"
    ),
    .target(
        name: "UI",
        dependencies: ["Core", "Network", "Parser"],
        path: "Sources/UI"
    )
]
let appProducts: [Product] = [
    .executable(name: "Traceroute", targets: ["App"]),
    .library(name: "TracerouteUI", targets: ["UI"])
]
#else
let appTarget: [Target] = []
let appProducts: [Product] = []
#endif

let package = Package(
    name: "Traceroute",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .library(name: "TracerouteCore", targets: ["Core"]),
        .library(name: "TracerouteNetwork", targets: ["Network"]),
        .library(name: "TracerouteParser", targets: ["Parser"])
    ] + appProducts,
    dependencies: [],
    targets: [
        .target(
            name: "Core",
            dependencies: [],
            path: "Sources/Core"
        ),
        .target(
            name: "Network",
            dependencies: ["Core"],
            path: "Sources/Network"
        ),
        .target(
            name: "Parser",
            dependencies: ["Core"],
            path: "Sources/Parser"
        ),
        .testTarget(
            name: "TracerouteTests",
            dependencies: ["Core", "Network", "Parser"],
            path: "Tests"
        )
    ] + appTarget
)
