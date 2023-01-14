// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum SwiftpmProjectGenerator {
    static func generate(with config: Configuration) throws {
        let projectName = "SecretKeys"
        let projectPath = "\(config.output)/\(projectName)"
        let projectSourcePath = "\(projectPath)/Sources"

        try FileIO.cleanDirectory(path: projectPath)

        try writeCode(GitignoreCodeGenerator.generateCode(),
                      path: projectPath,
                      fileName: ".gitignore")
        try writeCode(PackageCodeGenerator.generateCode(projectName: projectName, config: config),
                      path: projectPath,
                      fileName: "Package.swift")
        try writeCode(SecretValueDecoderCodeGenerator.generateCode(),
                      path: "\(projectSourcePath)/SecretValueDecoder",
                      fileName: "SecretValueDecoder.swift")

        let loader = EnvironmentLoader(envFile: config.envFile)
        let valueEncoder = SecretValueEncoder()

        for target in config.targets {
            let secrets = try target.keys.map { key -> Secret in
                let envKey = try loader.loadEnvironmentKey(forName: key.nameOfEnvironment)
                let configuredSecrets = Dictionary(uniqueKeysWithValues: try key.config
                    .map { (config, nameOfEnvironment) in
                        (config, try loader.loadEnvironmentKey(forName: nameOfEnvironment).value)
                    }
                )
                return Secret(name: key.nameOfVariable,
                              value: envKey.value,
                              configuredSecrets: configuredSecrets)
            }

            let salt = try SaltGenerator.generate()
            let code = SecretKeysCodeGenerator.generateCode(namespace: target.namespace,
                                                            secrets: secrets,
                                                            salt: salt,
                                                            encoder: valueEncoder,
                                                            includeBase: false)
            try writeCode(code,
                          path: "\(projectSourcePath)/\(target.name)",
                          fileName: "SecretKeys+Keys.swift")

            let baseCode = SecretKeysBaseCodeGenerator.generateCode(namespace: target.namespace)
            try writeCode(baseCode,
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
