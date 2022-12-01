// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

struct Secret: Equatable {
    let key: String
    let value: SecretValue

    init(key: String, value: SecretValue) {
        self.key = key
        self.value = value
    }

    init(key: String, stringValue: String) {
        self.init(key: key, value: SecretValue(stringValue: stringValue))
    }
}
