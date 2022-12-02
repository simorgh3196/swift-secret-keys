// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import ArgumentParser
import Foundation
import Yams

struct Generate: ParsableCommand {
    @Option(name: [.short, .customLong("config")],
            help: "The path to the configuration file")
    var configurationFilePath = ".secretkeys.yml"

    @Flag(name: .long,
          help: "Enables verbose log messages")
    var verbose = false

    func run() throws {
        Logger.log(.debug, "Run `Generate` command")

        let configData = try FileIO.readFileContents(for: configurationFilePath).data(using: .utf8)!
        let config = try YAMLDecoder().decode(Configuration.self, from: configData)
        Logger.log(.debug, "Config: \(config)")

        try generateProject(with: config)
    }

    private func generateProject(with config: Configuration) throws {
        let projectName = "SecretKeys"
        let projectPath = "\(config.outputDirectory)/\(projectName)"

        try FileIO.cleanDirectory(path: projectPath)

        do {
            let code = GitignoreCodeGenerator.generateCode()
            try FileIO.writeFile(content: code, toDirectoryPath: projectPath, fileName: ".gitignore")
            Logger.log(.debug, "Success to generate: \(projectPath)/.gitignore")
        }

        do {
            let code = PackageCodeGenerator.generateCode(projectName: projectName, config: config)
            try FileIO.writeFile(content: code, toDirectoryPath: projectPath, fileName: "Package.swift")
            Logger.log(.debug, "Success to generate: \(projectPath)/Package.swift")
        }

        do {
            let code = SecretValueDecoderPodspecCodeGenerator.generateCode()
            try FileIO.writeFile(content: code, toDirectoryPath: projectPath, fileName: "SecretValueDecoder.podspec")
            Logger.log(.debug, "Success to generate swift code: \(projectPath)/SecretValueDecoder.podspec")
        }

        do {
            let code = SecretValueDecoderCodeGenerator.generateCode()
            try FileIO.writeFile(content: code,
                                 toDirectoryPath: projectPath + "/Sources/SecretValueDecoder",
                                 fileName: "SecretValueDecoder.swift")
            Logger.log(.debug, "Success to generate: \(projectPath)/Sources/SecretValueDecoder/SecretValueDecoder.swift")
        }

        try generateTargets(projectPath: projectPath, with: config)

        Logger.log(.info, "✨ Project generated to \(projectPath)")
    }

    private func generateTargets(projectPath: String, with config: Configuration) throws {
        let loader = SecretLoader()

        for target in config.targets {
            let sources = [target.source, config.source].compactMap { $0 }

            let secrets = try config.keys
                .merging(target.keys ?? [:], uniquingKeysWith: { _, keyInTarget in keyInTarget })
                .map { keyMap in
                    let rawSecret = try loader.loadSecret(forKey: keyMap.value, from: sources)
                    return Secret(key: keyMap.key, value: rawSecret.value)
                }

            do {
                let salt = try SaltGenerator.generate()

                let code = SecretKeysCodeGenerator.generateCode(namespace: target.namespace ?? config.namespace,
                                                                secrets: secrets,
                                                                salt: salt,
                                                                encoder: SecretValueEncoder())
                try FileIO.writeFile(content: code,
                                     toDirectoryPath: projectPath + "/Sources/\(target.name)",
                                     fileName: "SecretKeys.swift")
                Logger.log(.debug, "Success to generate: \(projectPath)/Sources/\(target.name)/SecretKeys.swift")
            }

            let code = TargetPodspecCodeGenerator.generateCode(target: target)
            try FileIO.writeFile(content: code, toDirectoryPath: projectPath, fileName: "\(target.name).podspec")
            Logger.log(.debug, "Success to generate swift code: \(projectPath)/\(target.name).podspec")
        }
    }
}
