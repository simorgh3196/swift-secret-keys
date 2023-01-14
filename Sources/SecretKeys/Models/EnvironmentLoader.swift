// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum EnvironmentLoadingError: Error {
    case environmentNotFound(name: String)
}

final class EnvironmentLoader {
    let envFile: String?
    private var cachedEnvironmentKeys: [EnvironmentKey.ID: EnvironmentKey]?

    init(envFile: String?) {
        self.envFile = envFile
    }

    func loadEnvironmentKey(forName name: String) throws -> EnvironmentKey {
        if let key = try loadKeysFromEnvFile()?[name] {
            return key
        }

        if let env = ProcessInfo.processInfo.environment.first(where: { $0.key == name }) {
            return EnvironmentKey(name: env.key, stringValue: env.value)
        }

        throw EnvironmentLoadingError.environmentNotFound(name: name)
    }

    private func loadKeysFromEnvFile() throws -> [EnvironmentKey.ID: EnvironmentKey]? {
        guard let envFile else {
            return nil
        }

        // return cache if cache is available
        if let environmentKeys = cachedEnvironmentKeys {
            return environmentKeys
        }

        Logger.log(.info, "Loading properties from \(envFile)")
        let sourceContent = try FileIO.readFileContents(for: envFile)

        Logger.log(.debug, "Parsing properties")
        let envs = try PropertiesFileDecoder().decode(content: sourceContent)
        let environmentKeys = Dictionary(uniqueKeysWithValues: envs.map { ($0.id, $0) })

        Logger.log(.debug, "Success to load properties")

        // cache secrets
        cachedEnvironmentKeys = environmentKeys

        return environmentKeys
    }
}
