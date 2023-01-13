// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation
import PackagePlugin

/// Creates a secret-keys project from a Swift Package.
@main
struct SecretKeysBuildPlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let secretKeysExecutablePath = try context.tool(named: "secret-keys").path

        return [
            .buildCommand(
                displayName: "Generating SecretKeys",
                executable: secretKeysExecutablePath,
                arguments: []
            )
        ]
    }
}
