// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "CommandPluginExample",
    platforms: [
        .macOS(.v12),
    ],
    products: [
        .library(
            name: "CommandPluginExample",
            targets: ["CommandPluginExample"]),
    ],
    dependencies: [
        .package(name: "swift-secret-keys", path: "../../"),
        .package(name: "SecretKeys", path: "Dependencies/SecretKeys"),
    ],
    targets: [
        .target(
            name: "CommandPluginExample",
            dependencies: [
                .product(name: "SecretKeysDebug", package: "SecretKeys"),
                .product(name: "SecretKeysProduction", package: "SecretKeys"),
            ]),
        .testTarget(
            name: "CommandPluginExampleTests",
            dependencies: ["CommandPluginExample"]),
    ]
)
