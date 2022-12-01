// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

// Configuration file interface:
//
// ```yaml:.secretkeys.yml
// # Select the package manager to use from `spm` or `cocoapods`. (Default: `spm`)
// packageManager: spm
//
// # Determine the name of the struct. (Default: `Keys`)
// namespace: Keys
//
// # Also generate unit tests for accessing keys. (Default: `false`)
// withUnitTest: false
//
// # The path of output directory. (Default: `./Dependencies`)
// outputDirectory: ./Dependencies
//
// # In addition to environment variables, a properties file can be read.
// source: .env
//
// # Mapping variable names to environment variable names.
// keys:
//   clientID: CLIENT_ID
//   clientSecret: CLIENT_SECRET
//
// # Set the target according to the environment and other requirements that
// # you want to use different build modes, etc.
// targets:
//   - name: SharedSecretKeys
//     namespace: SharedKeys # can override namespace
//   - name: SecretKeysDebug
//   - name: SecretKeysProduction
//     source: .env.production # can replace a properties file
//     keys: # can override key mappings
//       clientSecret: PRODUCTION_CLIENT_SECRET
// ```

struct Configuration: Equatable, Codable {
    enum PackageManager: String, Equatable, Codable {
        case spm
        case cocoapods
    }

    struct Target: Equatable, Codable {
        var name: String
        var namespace: String?
        var source: String?
        var keys: [String: String]?
    }

    var packageManager = PackageManager.spm
    var namespace = "Keys"
    var withUnitTest = false
    var outputDirectory = "./Dependencies"
    var source: String?
    var keys: [String: String]
    var targets: [Target]

    func overrided(namespace: String? = nil,
                   withUnitTest: Bool? = nil,
                   outputDirectory: String? = nil,
                   source: String? = nil,
                   keys: [String: String]? = nil,
                   targets: [Target]? = nil) -> Configuration {
        Configuration(
            namespace: namespace ?? self.namespace,
            withUnitTest: withUnitTest ?? self.withUnitTest,
            outputDirectory: outputDirectory ?? self.outputDirectory,
            source: source ?? self.source,
            keys: keys ?? self.keys,
            targets: targets ?? self.targets
        )
    }
}
