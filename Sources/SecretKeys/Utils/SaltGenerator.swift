// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum SaltGeneratingError: Error {
    case failedToGenerateSalt(status: OSStatus)
}

enum SaltGenerator {
    static let saltLength = 64

    static func generate() throws -> [UInt8] {
        var bytes = [UInt8](repeating: 0, count: Self.saltLength)
        let status = SecRandomCopyBytes(kSecRandomDefault, bytes.count, &bytes)

        guard status == errSecSuccess else {
            throw SaltGeneratingError.failedToGenerateSalt(status: errSecSuccess)
        }

        return bytes
    }
}
