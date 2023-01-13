// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum SourcesOnlyGenerator {
    static func generate(with config: Configuration) throws {
        try writeCode(GitignoreCodeGenerator.generateCode(),
                      path: config.output,
                      fileName: ".gitignore")
        try writeCode(SecretValueDecoderCodeGenerator.generateCode(),
                      path: config.output,
                      fileName: "SecretValueDecoder.generated.swift")

        let loader = SecretLoader()
        let valueEncoder = SecretValueEncoder()

        for target in config.targets {
            let secrets = try target.keys.map { key -> Secret in
                let rawSecret = try loader.loadSecret(forKey: key.nameOfEnvironment, from: config.envFile)
                // TODO: load configured secret
                return Secret(key: key.nameOfVariable, value: rawSecret.value)
            }

            let salt = try SaltGenerator.generate()
            let code = SecretKeysCodeGenerator.generateCode(namespace: target.namespace,
                                                            secrets: secrets,
                                                            salt: salt,
                                                            encoder: valueEncoder,
                                                            includeBase: true)
            try writeCode(code,
                          path: "\(config.output)/\(target.name)",
                          fileName: "\(target.namespace).generated.swift")
        }

        Logger.log(.info, "✨ Project generated to \(config.output)")
    }

    private static func writeCode(_ content: String, path: String, fileName: String) throws {
        try FileIO.writeFile(content: content, toDirectoryPath: path, fileName: fileName)
        Logger.log(.debug, "Success to generate: \(path)/\(fileName)")
    }
}
