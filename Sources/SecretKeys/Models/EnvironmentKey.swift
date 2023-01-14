// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

struct EnvironmentKey: Identifiable, Equatable {
    var id: String { name }
    var name: String
    var value: SecretValue

    init(name: String, value: SecretValue) {
        self.name = name
        self.value = value
    }

    init(name: String, stringValue: String) {
        self.init(name: name, value: SecretValue(stringValue: stringValue))
    }
}
