// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import ArgumentParser
import Foundation
import Yams

struct Generate: ParsableCommand {
    @Option(name: [.short, .customLong("config")],
            help: "The path to the configuration file for `SecretKeys`")
    var configurationFilePath = ".secretkeys.yml"

    @Option(name: [.short, .customLong("env")],
            help: "The path to the file that contains environment variables")
    var environmentFilePath: String?

    @Option(name: [.short, .customLong("output")],
            help: "The path of output directory",
            completion: .directory)
    var outputDirectoryPath: String?

    @Flag(name: .long,
          help: "Enables verbose log messages")
    var verbose = false

    func run() throws {
        Logger.log(.debug, "Run `Generate` command")

        let configData = try FileIO.readFileContents(for: configurationFilePath).data(using: .utf8)!
        let config = try YAMLDecoder().decode(Configuration.self, from: configData).overrided(
            outputDirectory: outputDirectoryPath,
            source: environmentFilePath
        )

        try generateProject(with: config)
    }

    private func loadSecrets(environmentFilePath: String) throws -> [Secret] {
        Logger.log(.info, "Loading properties from \(environmentFilePath)")
        let envFileContent = try FileIO.readFileContents(for: environmentFilePath)

        Logger.log(.debug, "Parsing properties")
        let secrets = try PropertiesFileDecoder().decode(content: envFileContent)

        let secretsLog = secrets.map { "\($0.key): \($0.value.stringValue)" }.joined(separator: ", ")
        Logger.log(.debug, "Success to load properties")

        return secrets
    }

    private func generateProject(with config: Configuration) throws {
        let projectName = "SecretKeys"
        let projectPath = "\(config.outputDirectory)/\(projectName)"

        try FileIO.cleanDirectory(path: projectPath)

        do {
            let code = PackageCodeGenerator.generateCode(projectName: projectName, config: config)
            try FileIO.writeFile(content: code, toDirectoryPath: projectPath, fileName: "Package.swift")
            Logger.log(.debug, "Success to generate swift code: \(projectPath)/Package.swift")
        }

        do {
            let code = SecretValueDecoderCodeGenerator.generateCode()
            try FileIO.writeFile(content: code,
                                 toDirectoryPath: projectPath + "/Sources/SecretValueDecoder",
                                 fileName: "SecretValueDecoder.swift")
            Logger.log(.debug, "Success to generate swift code: \(projectPath)/Sources/SecretValueDecoder/SecretValueDecoder.swift")
        }

        try generateTargets(projectPath: projectPath, with: config)

        Logger.log(.info, "✨ Project generated to \(projectPath)")
    }

    private func generateTargets(projectPath: String, with config: Configuration) throws {
        var secretFiles: [String: [Secret]] = [:]
        if let source = config.source {
            secretFiles[source] = try loadSecrets(environmentFilePath: source)
        }
        try config.targets.compactMap(\.source).forEach { source in
            secretFiles[source] = try loadSecrets(environmentFilePath: source)
        }

        for target in config.targets {
            let secrets = (target.source.flatMap { secretFiles[$0] } ?? []) + (config.source.flatMap { secretFiles[$0] } ?? [])

            let requiredKeyMaps = config.keys.merging(target.keys ?? [:],
                                                      uniquingKeysWith: { _, keyInTarget in keyInTarget })

            let mappedSecrets = try requiredKeyMaps.map { keyMap in
                guard let secret = secrets.first(where: { $0.key == keyMap.value }) else {
                    throw NSError() // TODO:
                }

                return Secret(key: keyMap.key, value: secret.value)
            }

            do {
                let salt = try SaltGenerator.generate()

                let code = SecretKeysCodeGenerator.generateCode(namespace: target.namespace ?? config.namespace,
                                                                secrets: mappedSecrets,
                                                                salt: salt,
                                                                encoder: SecretValueEncoder())
                try FileIO.writeFile(content: code,
                                     toDirectoryPath: projectPath + "/Sources/\(target.name)",
                                     fileName: "SecretKeys.swift")
                Logger.log(.debug, "Success to generate swift code: \(projectPath)/Sources/\(target.name)/SecretKeys.swift")
            }
        }
    }
}
