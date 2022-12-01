// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SecretKeys",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "secret-keys", targets: ["secret-keys"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
        .package(url: "https://github.com/jpsim/Yams.git", from: "5.0.1"),
    ],
    targets: [
        .executableTarget(
            name: "secret-keys",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
                .product(name: "Yams", package: "Yams"),
            ],
            path: "Sources/SecretKeys"),
        .testTarget(
            name: "anima-tests",
            dependencies: ["secret-keys"],
            path: "Tests/SecretKeysTests"),
    ]
)
