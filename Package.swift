// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "swift-anthropic",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "Anthropic", targets: ["Anthropic"]),
        .executable(name: "AnthropicCmd", targets: ["AnthropicCmd"]),
    ],
    dependencies: [
        .package(url: "git@github.com:nathanborror/swift-shared-kit", branch: "main"),
        .package(url: "git@github.com:apple/swift-argument-parser", branch: "main"),
    ],
    targets: [
        .target(name: "Anthropic", dependencies: [
            .product(name: "SharedKit", package: "swift-shared-kit"),
        ]),
        .executableTarget(name: "AnthropicCmd", dependencies: [
            "Anthropic",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .testTarget(name: "AnthropicTests", dependencies: ["Anthropic"]),
    ]
)
