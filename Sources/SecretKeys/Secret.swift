// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

struct Secret: Equatable {
    let key: String
    let value: SecretValue

    init(key: String, stringValue: String) {
        self.key = key
        self.value = SecretValue(stringValue: stringValue)
    }
}
