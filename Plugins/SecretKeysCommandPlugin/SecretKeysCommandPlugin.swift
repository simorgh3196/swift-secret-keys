// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation
import PackagePlugin

/// Creates a secret-keys project from a Swift Package.
@main
struct SecretKeysCommandPlugin: CommandPlugin {
    func performCommand(context: PluginContext, arguments: [String]) throws {
        let secretKeysExecutableURL = URL(fileURLWithPath: try context.tool(named: "secret-keys").path.string)

        // If the `--help` or `-h` flag was passed, print the plugin's help information
        // and exit.
        if arguments.contains("--help") || arguments.contains("-h") {
            print(Self.helpText)
            return
        }

        let process = try Process.run(secretKeysExecutableURL, arguments: arguments)
        process.waitUntilExit()

        if process.terminationReason == .uncaughtSignal || process.terminationStatus != 0 {
            let problem = "\(process.terminationReason):\(process.terminationStatus)"
            Diagnostics.error("SecretKeys project generation failed: \(problem)")
        }
    }

    private static let helpText = """
        OVERVIEW: Generates a project to access the values of environment variables and properties files.
        USAGE: secret-keys generate [--config <config>] [--verbose]

        OPTIONS:
        -c, --config <config>   The path to the configuration file (default: .secretkeys.yml)
        -v, --verbose           Enables verbose log messages
        --version               Show the version.
        -h, --help              Show help information.

        """
}
