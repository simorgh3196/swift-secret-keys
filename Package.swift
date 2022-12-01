// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "SecretKeys",
    platforms: [.macOS(.v11)],
    products: [
        .executable(name: "secret-keys", targets: ["SecretKeys"]),
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.2.0"),
    ],
    targets: [
        .executableTarget(
            name: "SecretKeys",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser"),
            ]),
        .testTarget(
            name: "SecretKeysTests",
            dependencies: ["SecretKeys"]),
    ]
)
