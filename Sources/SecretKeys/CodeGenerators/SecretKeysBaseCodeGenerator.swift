
// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum SecretKeysBaseCodeGenerator {
    static func generateCode(namespace: String) -> String {
        """
        // DO NOT MODIFY
        // Automatically generated by SecretKeys (https://github.com/simorgh3196/swift-secret-keys)

        import Foundation
        import SecretValueDecoder

        public enum \(namespace) {
            static let decoder = SecretValueDecoder()
        }
        """
    }
}
