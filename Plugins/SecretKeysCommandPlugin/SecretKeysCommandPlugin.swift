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

        let process = try Process.run(secretKeysExecutableURL, arguments: arguments)
        process.waitUntilExit()

        if process.terminationReason == .uncaughtSignal || process.terminationStatus != 0 {
            let problem = "\(process.terminationReason):\(process.terminationStatus)"
            Diagnostics.error("SecretKeys project generation failed: \(problem)")
        }
    }
}
