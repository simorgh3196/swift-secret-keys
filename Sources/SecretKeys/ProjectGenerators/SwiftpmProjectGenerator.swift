// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum SwiftpmProjectGenerator {
    static func generate(with config: Configuration) throws {
        let projectName = "_SecretKeys"
        let projectPath = "\(config.outputDirectory)/\(projectName)"
        let projectSourcePath = "\(projectPath)/Sources"

        try FileIO.cleanDirectory(path: projectPath)

        try writeCode(GitignoreCodeGenerator.generateCode(),
                      path: projectPath,
                      fileName: ".gitignore")
        try writeCode(PackageCodeGenerator.generateCode(projectName: projectName, config: config),
                      path: projectPath,
                      fileName: "Package.swift")
        try writeCode(SecretValueDecoderPodspecCodeGenerator.generateCode(),
                      path: "\(projectSourcePath)/SecretValueDecoder",
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
            let code = SecretKeysCodeGenerator.generateCode(namespace: target.namespace ?? config.namespace,
                                                            secrets: secrets,
                                                            salt: salt,
                                                            encoder: valueEncoder,
                                                            importDecoder: true)
            try writeCode(code,
                          path: "\(projectSourcePath)/\(target.name)",
                          fileName: "SecretKeys.swift")
        }

        Logger.log(.info, "✨ Project generated to \(projectPath)")
    }

    private static func writeCode(_ content: String, path: String, fileName: String) throws {
        try FileIO.writeFile(content: content, toDirectoryPath: path, fileName: fileName)
        Logger.log(.debug, "Success to generate: \(path)/\(fileName)")
    }
}
