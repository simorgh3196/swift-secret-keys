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

    @Flag(name: .shortAndLong,
          help: "Enables verbose log messages")
    var verbose = false

    func run() throws {
        Logger.log(.debug, "Run `Generate` command")

        let configData = try FileIO.readFileContents(for: configurationFilePath).data(using: .utf8)!
        let config = try YAMLDecoder().decode(Configuration.self, from: configData)
        Logger.log(.debug, "Config: \(config)")

        switch config.exportType {
        case .swiftpm:
            try SwiftpmProjectGenerator.generate(with: config)
        case .cocoapods:
            try CocoaodsProjectGenerator.generate(with: config)
        }
    }
}
