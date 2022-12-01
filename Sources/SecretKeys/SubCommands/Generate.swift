// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import ArgumentParser
import Foundation

struct Generate: ParsableCommand {
    @Option(name: [.short, .customLong("env")],
            help: "The path to the file that contains environment variables")
    var environmentFilePath = ".env"

    @Option(name: [.short, .customLong("output")],
            help: "The path of output directory",
            completion: .directory)
    var outputDirectoryPath = "./Dependencies"

    @Flag(name: [.customLong("unit-test")],
          help: "Also generate unit tests")
    var withUnitTest = false

    @Flag(name: .shortAndLong,
          help: "Enables verbose log messages")
    var verbose = false

    func run() throws {
        Logger.log(.debug, "Run `Generate` command")

        let secrets = try loadSecrets(environmentFilePath: environmentFilePath)

        try generateProject(projectName: "SecretKeys", secrets: secrets)
    }

    private func loadSecrets(environmentFilePath: String) throws -> [Secret] {
        Logger.log(.info, "Loading properties from \(environmentFilePath)")
        let envFileContent = try FileIO.readFileContents(for: environmentFilePath)

        Logger.log(.debug, "Parsing properties")
        let secrets = try PropertiesFileDecoder().decode(content: envFileContent)

        let secretsLog = secrets.map { "\($0.key): \($0.value.stringValue)" }.joined(separator: ", ")
        Logger.log(.debug, "Success to load properties: [\(secretsLog)]")

        return secrets
    }

    private func generateProject(projectName: String, secrets: [Secret]) throws {
        let projectPath = "\(outputDirectoryPath)/\(projectName)"
        Logger.log(.debug, "Start generating project to \(projectPath)")

        let salt = try SaltGenerator.generate()

        try FileIO.cleanDirectory(path: projectPath)

        do {
            let code = PackageCodeGenerator.generateCode(projectName: projectName, withUnitTest: withUnitTest)
            try FileIO.writeFile(content: code, toDirectoryPath: projectPath, fileName: "Package.swift")
            Logger.log(.debug, "Success to generate swift code: \(projectPath)/Package.swift")
        }

        do {
            let code = SecretKeysCodeGenerator.generateCode(secrets: secrets,
                                                            salt: salt,
                                                            encoder: SecretValueEncoder())
            try FileIO.writeFile(content: code,
                                 toDirectoryPath: projectPath + "/Sources/\(projectName)",
                                 fileName: "SecretKeys.swift")
            Logger.log(.debug, "Success to generate swift code: \(projectPath)/Sources/\(projectName)/SecretKeys.swift")
        }

        do {
            let code = SecretValueDecoderCodeGenerator.generateCode()
            try FileIO.writeFile(content: code,
                                 toDirectoryPath: projectPath + "/Sources/\(projectName)",
                                 fileName: "SecretValueDecoder.swift")
            Logger.log(.debug, "Success to generate swift code: \(projectPath)/Sources/\(projectName)/SecretValueDecoder.swift")
        }

        Logger.log(.info, "✨ Project generated to \(projectPath)")
    }
}
