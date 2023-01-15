// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum PackageCodeGenerator {
    static func generateCode(projectName: String, config: Configuration) -> String {
        """
        // swift-tools-version: 5.6

        // DO NOT MODIFY
        // Automatically generated by SecretKeys (https://github.com/simorgh3196/swift-secret-keys)

        import PackageDescription

        let package = Package(
            name: "\(projectName)",
            platforms: [
                .iOS(.v11),
                .macOS(.v11),
                .tvOS(.v11),
                .watchOS(.v4),
            ],
            products: [
        \(generateProductsCode(config: config))
            ],
            targets: [
        \(generateTargetsCode(config: config))

                .target(name: "SecretValueDecoder", path: "Sources/SecretValueDecoder"),
            ]
        )
        """
    }

    private static func generateProductsCode(config: Configuration) -> String {
        config.targets
            .sorted(by: { $0.name < $1.name })
            .map { "        .library(name: \"\($0.name)\", targets: [\"\($0.name)\"])," }
            .joined(separator: "\n")
    }

    private static func generateTargetsCode(config: Configuration) -> String {
        config.targets
            .sorted(by: { $0.name < $1.name })
            .map { "        .target(name: \"\($0.name)\", dependencies: [\"SecretValueDecoder\"])," }
            .joined(separator: "\n")
    }
}
