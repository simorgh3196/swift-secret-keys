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

    func testDecodeConfiguration() throws {
        let configYamlData = """
        # Select the package manager to use from `spm` or `cocoapods`. (Default: `spm`)
        packageManager: spm

        # Determine the name of the struct. (Default: `Keys`)
        namespace: TestKeys

        # Also generate unit tests for accessing keys. (Default: `false`)
        withUnitTest: true

        # The path of output directory. (Default: `./Dependencies`)
        outputDirectory: _Keys

        # In addition to environment variables, a properties file can be read.
        source: .env.default

        # Mapping variable names to environment variable names.
        keys:
          clientID: CLIENT_ID
          clientSecret: CLIENT_SECRET

        # Set the target according to the environment and other requirements that
        # you want to use different build modes, etc.
        targets:
          - name: SharedSecretKeys
            namespace: SharedKeys # can override namespace
          - name: SecretKeysDebug
          - name: SecretKeysProduction
            source: .env.production # can replace a properties file
            keys: # can override keys
              clientSecret: PRODUCTION_CLIENT_SECRET
        """.data(using: .utf8)!

        let config = try decoder.decode(Configuration.self, from: configYamlData)

        XCTAssertEqual(config.packageManager, .spm)
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
