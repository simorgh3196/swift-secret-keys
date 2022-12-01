// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

struct SecretValueEncoder {
    func encode(secret: Secret, with salt: [UInt8]) -> [UInt8] {
        Array(secret.value.stringValue.utf8CString)
            .map(UInt8.init)
            .enumerated()
            .map { index, byte in
                byte ^ salt[index % salt.count]
            }
    }
}
