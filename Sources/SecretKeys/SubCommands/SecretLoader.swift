// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum SecretLoadingError: Error {
    case secretNotFound(key: String)
}

class SecretLoader {
    private var secretFiles: [String: [Secret]] = [:]

    func loadSecret(forKey key: String, from sources: [String]) throws -> Secret {
        for source in sources {
            if let secret = try loadSecrets(source: source).first(where: { $0.key == key }) {
                return secret
            }
        }

        if let env = ProcessInfo.processInfo.environment.first(where: { $0.key == key }) {
            return Secret(key: env.key, stringValue: env.value)
        }

        throw SecretLoadingError.secretNotFound(key: key)
    }

    private func loadSecrets(source: String) throws -> [Secret] {
        // return cache if cache is available
        if let secrets = secretFiles[source] {
            return secrets
        }

        Logger.log(.info, "Loading properties from \(source)")
        let sourceContent = try FileIO.readFileContents(for: source)

        Logger.log(.debug, "Parsing properties")
        let secrets = try PropertiesFileDecoder().decode(content: sourceContent)

        Logger.log(.debug, "Success to load properties")

        // cache secrets
        secretFiles[source] = secrets

        return secrets
    }
}
