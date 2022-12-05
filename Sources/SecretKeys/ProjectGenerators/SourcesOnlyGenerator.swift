// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum SourcesOnlyGenerator {
    static func generate(with config: Configuration) throws {
        try writeCode(GitignoreCodeGenerator.generateCode(),
                      path: config.outputDirectory,
                      fileName: ".gitignore")
        try writeCode(SecretValueDecoderPodspecCodeGenerator.generateCode(),
                      path: "\(config.outputDirectory)/SecretValueDecoder",
                      fileName: "SecretValueDecoder.swift")

        let loader = SecretLoader()
        let valueEncoder = SecretValueEncoder()

        for target in config.targets {
            let source = target.source ?? config.source
            let keyMaps = config.keys.merging(target.keys ?? [:]) { _, keyInTarget in keyInTarget }

            let secrets = try keyMaps.map { keyMap -> Secret in
                let rawSecret = try loader.loadSecret(forKey: keyMap.value, from: source)
                return Secret(key: keyMap.key, value: rawSecret.value)
            }

            let salt = try SaltGenerator.generate()
            let namespace = target.namespace ?? config.namespace
            let code = SecretKeysCodeGenerator.generateCode(namespace: namespace,
                                                            secrets: secrets,
                                                            salt: salt,
                                                            encoder: valueEncoder,
                                                            importDecoder: false)
            try writeCode(code,
                          path: "\(config.outputDirectory)/\(target.name)",
                          fileName: "\(namespace).generated.swift")
        }

        Logger.log(.info, "✨ Project generated to \(config.outputDirectory)")
    }

    private static func writeCode(_ content: String, path: String, fileName: String) throws {
        try FileIO.writeFile(content: content, toDirectoryPath: path, fileName: fileName)
        Logger.log(.debug, "Success to generate: \(path)/\(fileName)")
    }
}
