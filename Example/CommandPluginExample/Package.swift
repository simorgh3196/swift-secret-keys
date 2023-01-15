// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "CommandPluginExample",
    platforms: [
        .macOS(.v12),
    ],
    dependencies: [
        .package(name: "swift-secret-keys", path: "../../"),
        .package(name: "SecretKeys", path: "Dependencies/SwiftPM/SecretKeys"),
    ],
    targets: [
        .target(
            name: "InstallationWithSource"),
        .testTarget(
            name: "InstallationWithSourceTests",
            dependencies: ["InstallationWithSource"]),

        .target(
            name: "InstallationWithSPM",
            dependencies: [
                .product(name: "SecretKeysDebug", package: "SecretKeys"),
                .product(name: "SecretKeysProduction", package: "SecretKeys"),
            ]),
        .testTarget(
            name: "InstallationWithSPMTests",
            dependencies: ["InstallationWithSPM"]),
    ]
)
