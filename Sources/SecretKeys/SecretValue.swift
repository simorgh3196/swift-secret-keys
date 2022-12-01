// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

enum SecretValue: Equatable {
    case int(Int)
    case double(Double)
    case bool(Bool)
    case string(String)

    var type: String {
        switch self {
        case .int:
            return "Int"
        case .double:
            return "Double"
        case .bool:
            return "Bool"
        case .string:
            return "String"
        }
    }

    var stringValue: String {
        switch self {
        case .int(let intValue):
            return String(intValue)
        case .double(let doubleValue):
            return String(doubleValue)
        case .bool(let boolValue):
            return String(boolValue)
        case .string(let stringValue):
            return stringValue
        }
    }

    init(stringValue: String) {
        if let intValue = Int(stringValue) { // if the values is non-floating decimal
            self = .int(intValue)
        } else if let doubleValue = Double(stringValue) { // if the values is floating decimal
            self = .double(doubleValue)
        } else if let boolValue = Bool(stringValue) { // if the value is `true` or `false`
            self = .bool(boolValue)
        } else {
            self = .string(stringValue)
        }
    }
}
