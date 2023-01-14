// The MIT License (MIT)
//
// Copyright (c) 2023 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

struct Secret: Equatable {
    var name: String
    var value: SecretValue
    var configuredSecrets: [String: SecretValue]

    init(name: String, value: SecretValue, configuredSecrets: [String: SecretValue]) {
        self.name = name
        self.value = value
        self.configuredSecrets = configuredSecrets
    }
}
