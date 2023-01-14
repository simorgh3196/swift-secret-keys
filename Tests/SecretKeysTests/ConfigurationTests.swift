// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

@testable import secret_keys
import XCTest
import Yams

final class ConfigurationDecoderTests: XCTestCase {
    var decoder: YAMLDecoder!

    override func setUpWithError() throws {
        decoder = YAMLDecoder()
    }

    func testDecodeConfigurationDefaultValues() throws {
        let configYamlData = """
        targets:
          SecretKeys:
            keys:
              apiKey:
                name: API_KEY
        """

        let config = try decoder.decode(Configuration.self, from: configYamlData)

        XCTAssertEqual(config.exportType, .swiftpm)
        XCTAssertEqual(config.withUnitTest, false)
        XCTAssertEqual(config.output, "Dependencies")
        XCTAssertEqual(config.targets, [
            Configuration.Target(name: "SecretKeys", namespace: "Key", keys: [
                Configuration.Key(nameOfVariable: "apiKey",
                                  nameOfEnvironment: "API_KEY",
                                  config: [:])
            ])
        ])
    }

    func testDecodeConfigurationCustomValues() throws {
        let configYamlData = """
        exportType: cocoapods
        withUnitTest: true
        output: OUTPUT
        envFile: .env.dev
        targets:
          SecretKeysDebug:
            namespace: MySecretKeys
            keys:
              clientID:
                name: CLIENT_ID_DEBUG
              clientSecret:
                name: CLIENT_SECRET_DEBUG
              apiPath:
                name: BASE_API_PATH
              home:
                name: HOME

          SecretKeysProduction:
            namespace: MySecretKeys
            keys:
              clientID:
                name: CLIENT_ID_PRODUCTION
                config:
                  DEBUG: CLIENT_ID_ADHOC
              clientSecret:
                name: CLIENT_SECRET_PRODUCTION
                config:
                  DEBUG: CLIENT_SECRET_ADHOC
              apiPath:
                name: BASE_API_PATH
        """.data(using: .utf8)!

        let config = try decoder.decode(Configuration.self, from: configYamlData)

        XCTAssertEqual(config.exportType, .cocoapods)
        XCTAssertEqual(config.withUnitTest, true)
        XCTAssertEqual(config.output, "OUTPUT")
        XCTAssertEqual(config.envFile, ".env.dev")
        XCTAssertEqual(config.targets.count, 2)

        let targets = config.targets.sorted(by: { $0.name < $1.name })

        XCTAssertEqual(targets[0].name, "SecretKeysDebug")
        XCTAssertEqual(targets[0].namespace, "MySecretKeys")
        XCTAssertEqual(targets[0].keys.sorted(by: { $0.id < $1.id }), [
            Configuration.Key(nameOfVariable: "clientID",
                              nameOfEnvironment: "CLIENT_ID_DEBUG",
                              config: [:]),
            Configuration.Key(nameOfVariable: "clientSecret",
                              nameOfEnvironment: "CLIENT_SECRET_DEBUG",
                              config: [:]),
            Configuration.Key(nameOfVariable: "apiPath",
                              nameOfEnvironment: "BASE_API_PATH",
                              config: [:]),
            Configuration.Key(nameOfVariable: "home",
                              nameOfEnvironment: "HOME",
                              config: [:]),
        ].sorted(by: { $0.id < $1.id }))

        XCTAssertEqual(targets[1].name, "SecretKeysProduction")
        XCTAssertEqual(targets[1].namespace, "MySecretKeys")
        XCTAssertEqual(targets[1].keys.sorted(by: { $0.id < $1.id }), [
            Configuration.Key(nameOfVariable: "clientID",
                              nameOfEnvironment: "CLIENT_ID_PRODUCTION",
                              config: ["DEBUG": "CLIENT_ID_ADHOC"]),
            Configuration.Key(nameOfVariable: "clientSecret",
                              nameOfEnvironment: "CLIENT_SECRET_PRODUCTION",
                              config: ["DEBUG": "CLIENT_SECRET_ADHOC"]),
            Configuration.Key(nameOfVariable: "apiPath",
                              nameOfEnvironment: "BASE_API_PATH",
                              config: [:]),
        ].sorted(by: { $0.id < $1.id }))
    }
}
