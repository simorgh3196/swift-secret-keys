// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum SecretLoadingError: Error {
    case secretNotFound(key: String)
}

final class SecretLoader {
    private var cachedFiles: [String: [Secret]] = [:]

    func loadSecret(forKey key: String, from source: String?) throws -> Secret {
        if let source, let secret = try loadSecrets(source: source).first(where: { $0.key == key }) {
            return secret
        }

        if let env = ProcessInfo.processInfo.environment.first(where: { $0.key == key }) {
            return Secret(key: env.key, stringValue: env.value)
        }

        throw SecretLoadingError.secretNotFound(key: key)
    }

    private func loadSecrets(source: String) throws -> [Secret] {
        // return cache if cache is available
        if let secrets = cachedFiles[source] {
            return secrets
        }

        Logger.log(.info, "Loading properties from \(source)")
        let sourceContent = try FileIO.readFileContents(for: source)

        Logger.log(.debug, "Parsing properties")
        let secrets = try PropertiesFileDecoder().decode(content: sourceContent)

        Logger.log(.debug, "Success to load properties")

        // cache secrets
        cachedFiles[source] = secrets

        return secrets
    }
}
