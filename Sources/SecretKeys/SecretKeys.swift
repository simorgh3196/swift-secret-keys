// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import ArgumentParser

@main
struct SecretKeys: ParsableCommand {
    static let configuration = CommandConfiguration(
        commandName: "secret-keys",
        abstract: "A Swift command-line tool to generate a project that access the environment file",
        version: "0.0.1",
        subcommands: [Generate.self]
    )
}
