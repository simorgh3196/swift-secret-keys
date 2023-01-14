// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

/*
 Configuration file interface:

 ```yaml
 # Select the export type from `swiftpm`, `cocoapods` or `sourcesOnly`. (Default: `swiftpm`)
 exportType: swiftpm

 # Also generate unit tests for accessing keys. (Default: `false`)
 withUnitTest: false

 # The path of output directory. (Default: `Dependencies`)
 output: Dependencies

 # In addition to environment variables, a properties file can be read.
 envFile: .env

 # Set the target according to the environment and other requirements that
 # you want to use different build modes, etc.
 targets:
   SecretKeysDebug:
     namespace: MySecretKeys # can override namespace (Default: `Keys`)
     keys:
       clientID:
         name: CLIENT_ID_DEBUG
       clientSecret:
         name: CLIENT_SECRET_DEBUG
       apiPath:
         name: BASE_API_PATH
       home:
         name: HOME # can load environment variables

   SecretKeysProduction:
     namespace: MySecretKeys # can override namespace (Default: `Keys`)
     keys:
       clientID:
         name: CLIENT_ID_PRODUCTION
         config:
           DEBUG: CLIENT_ID_ADHOC # can override `name` only when `#if DEBUG`
       clientSecret:
         name: CLIENT_SECRET_PRODUCTION
         config:
           DEBUG: CLIENT_SECRET_ADHOC
       apiPath:
         name: BASE_API_PATH
 ```
 */

struct Configuration: Equatable {
    enum ExportType: String, Equatable, Decodable {
        case swiftpm
        case cocoapods
        case sourcesOnly
    }

    struct Target: Equatable {
        var name: String
        var namespace: String
        var keys: [Key]
    }

    struct Key: Identifiable, Equatable {
        var id: String { nameOfVariable }
        var nameOfVariable: String
        var nameOfEnvironment: String
        var config: [String: String]
    }

    var exportType: ExportType
    var withUnitTest: Bool
    var output: String
    var envFile: String?
    var targets: [Target]
}

extension Configuration: Decodable {
    private enum CodingKeys: CodingKey {
        case exportType
        case withUnitTest
        case output
        case envFile
        case targets
    }

    private struct _Target: Equatable, Decodable {
        var namespace: String?
        var keys: [String: _Key]
    }

    private struct _Key: Equatable, Decodable {
        var name: String
        var config: [String: String]?
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.exportType = try container.decodeIfPresent(ExportType.self, forKey: .exportType) ?? .swiftpm
        self.withUnitTest = try container.decodeIfPresent(Bool.self, forKey: .withUnitTest) ?? false
        self.output = try container.decodeIfPresent(String.self, forKey: .output) ?? "Dependencies"
        self.envFile = try container.decodeIfPresent(String.self, forKey: .envFile)
        self.targets = try container.decode([String: _Target].self, forKey: .targets).map { target in
            Target(
                name: target.key,
                namespace: target.value.namespace ?? "Key",
                keys: target.value.keys.map { variableName, key in
                    Key(nameOfVariable: variableName,
                        nameOfEnvironment: key.name,
                        config: key.config ?? [:])
                }
            )
        }
    }
}
