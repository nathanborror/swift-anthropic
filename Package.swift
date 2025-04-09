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
    ],
    dependencies: [
        .package(url: "https://github.com/nathanborror/swift-json", branch: "main"),
        .package(url: "https://github.com/apple/swift-argument-parser", branch: "main"),
    ],
    targets: [
        .target(name: "Anthropic", dependencies: [
            .product(name: "JSON", package: "swift-json"),
        ]),
        .executableTarget(name: "CLI", dependencies: [
            "Anthropic",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
    ]
)
