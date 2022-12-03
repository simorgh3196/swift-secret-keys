// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

// Configuration file interface:
//
// ```yaml:.secretkeys.yml
// # Select the export type from `swiftpm` or `cocoapods`. (Default: `swiftpm`)
// exportType: swiftpm
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

struct Configuration: Equatable {
    enum ExportType: String, Equatable, Codable {
        case swiftpm
        case cocoapods
    }

    struct Target: Equatable, Codable {
        var name: String
        var namespace: String?
        var source: String?
        var keys: [String: String]?
    }

    enum CodingKeys: CodingKey {
        case exportType
        case namespace
        case withUnitTest
        case outputDirectory
        case source
        case keys
        case targets
    }

    var exportType: ExportType
    var namespace: String
    var withUnitTest: Bool
    var outputDirectory: String
    var source: String?
    var keys: [String: String]
    var targets: [Target]
}

extension Configuration: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.exportType = try container.decodeIfPresent(ExportType.self, forKey: .exportType) ?? .swiftpm
        self.namespace = try container.decodeIfPresent(String.self, forKey: .namespace) ?? "Keys"
        self.withUnitTest = try container.decodeIfPresent(Bool.self, forKey: .withUnitTest) ?? false
        self.outputDirectory = try container.decodeIfPresent(String.self, forKey: .outputDirectory) ?? "./Dependencies"
        self.source = try container.decodeIfPresent(String.self, forKey: .source)
        self.keys = try container.decodeIfPresent([String : String].self, forKey: .keys) ?? [:]
        self.targets = try container.decode([Configuration.Target].self, forKey: .targets)
    }
}
