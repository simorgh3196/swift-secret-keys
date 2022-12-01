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
// # In addition to environment variables, properties files can be read.
// sources:
//   - .env
//   - .env.default
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
//     sources: # additional properties files can be specified
//       - .env.production
//     keys: # can override keys
//       clientID: PRODUCTION_CLIENT_ID
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
        var sources: [String]?
        var keys: [String: String]?
    }

    var packageManager = PackageManager.spm
    var namespace = "Keys"
    var withUnitTest = false
    var outputDirectory = "./Dependencies"
    var sources: [String]
    var keys: [String: String]
    var targets: [Target]

    func overrided(namespace: String?,
                   withUnitTest: Bool?,
                   outputDirectory: String?,
                   sources: [String]?,
                   keys: [String: String]?,
                   targets: [Target]?) -> Configuration {
        Configuration(
            namespace: namespace ?? self.namespace,
            withUnitTest: withUnitTest ?? self.withUnitTest,
            outputDirectory: outputDirectory ?? self.outputDirectory,
            sources: sources ?? self.sources,
            keys: keys ?? self.keys,
            targets: targets ?? self.targets
        )
    }
}
