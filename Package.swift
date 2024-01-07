// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AnthropicKit",
    platforms: [
        .iOS(.v16),
        .macOS(.v13),
        .watchOS(.v9),
        .tvOS(.v16),
    ],
    products: [
        .library(name: "AnthropicKit", targets: ["AnthropicKit"]),
        .executable(name: "AnthropicCmd", targets: ["AnthropicCmd"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", branch: "main"),
    ],
    targets: [
        .target(name: "AnthropicKit"),
        .executableTarget(name: "AnthropicCmd", dependencies: [
            "AnthropicKit",
            .product(name: "ArgumentParser", package: "swift-argument-parser"),
        ]),
        .testTarget(name: "AnthropicKitTests", dependencies: ["AnthropicKit"]),
    ]
)
