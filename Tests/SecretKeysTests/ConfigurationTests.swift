// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import XCTest
import Yams
@testable import secret_keys

final class ConfigurationDecoderTests: XCTestCase {
    var decoder: YAMLDecoder!

    override func setUpWithError() throws {
        decoder = YAMLDecoder()
    }

    func testDecodeConfigurationDefaultValues() throws {
        let configYamlData = """
        targets:
          - name: SecretKeys
        """

        let config = try decoder.decode(Configuration.self, from: configYamlData)

        XCTAssertEqual(config.namespace, "Keys")
        XCTAssertEqual(config.withUnitTest, false)
        XCTAssertEqual(config.outputDirectory, "./Dependencies")
        XCTAssertEqual(config.source, nil)
        XCTAssertEqual(config.keys, [:])
        XCTAssertEqual(config.targets, [Configuration.Target(name: "SecretKeys")])
    }

    func testDecodeConfigurationCustomValues() throws {
        let configYamlData = """
        namespace: TestKeys
        withUnitTest: true
        outputDirectory: _Keys
        source: .env.default
        keys:
          clientID: CLIENT_ID
          clientSecret: CLIENT_SECRET
        targets:
          - name: SharedSecretKeys
            namespace: SharedKeys
          - name: SecretKeysDebug
          - name: SecretKeysProduction
            source: .env.production
            keys:
              clientSecret: PRODUCTION_CLIENT_SECRET
        """.data(using: .utf8)!

        let config = try decoder.decode(Configuration.self, from: configYamlData)

        XCTAssertEqual(config.namespace, "TestKeys")
        XCTAssertEqual(config.withUnitTest, true)
        XCTAssertEqual(config.outputDirectory, "_Keys")
        XCTAssertEqual(config.source, ".env.default")
        XCTAssertEqual(config.keys, [
            "clientID": "CLIENT_ID",
            "clientSecret": "CLIENT_SECRET",
        ])
        XCTAssertEqual(config.targets.count, 3)
        XCTAssertEqual(config.targets[0], Configuration.Target(
            name: "SharedSecretKeys",
            namespace: "SharedKeys"
        ))
        XCTAssertEqual(config.targets[1], Configuration.Target(
            name: "SecretKeysDebug"
        ))
        XCTAssertEqual(config.targets[2], Configuration.Target(
            name: "SecretKeysProduction",
            source: ".env.production",
            keys: [
                "clientSecret": "PRODUCTION_CLIENT_SECRET"
            ])
        )
    }
}
