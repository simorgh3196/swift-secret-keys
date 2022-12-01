// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import Foundation

public enum SecretValueDecodingError: Error {
    case invalidBytesSequence
    case cannotConvertValueOfType(String)
}

struct SecretValueDecoder {
    @inline(__always)
    func decode(bytes: [UInt8], with salt: [UInt8]) throws -> String {
        let cString = bytes.enumerated()
            .map { index, byte in
                byte ^ salt[index % salt.count]
            }
            .map(CChar.init(bitPattern:))

        guard let decodedString = String(cString: cString, encoding: .utf8) else {
            throw SecretValueDecodingError.invalidBytesSequence
        }

        return decodedString
    }

    @inline(__always)
    func decode(bytes: [UInt8], with salt: [UInt8]) throws -> Int {
        let decodedString: String = try decode(bytes: bytes, with: salt)

        guard let boolValue = Int(decodedString) else {
            throw SecretValueDecodingError.cannotConvertValueOfType("Int")
        }

        return boolValue
    }

    @inline(__always)
    func decode(bytes: [UInt8], with salt: [UInt8]) throws -> Double {
        let decodedString: String = try decode(bytes: bytes, with: salt)

        guard let doubleValue = Double(decodedString) else {
            throw SecretValueDecodingError.cannotConvertValueOfType("Double")
        }

        return doubleValue
    }

    @inline(__always)
    func decode(bytes: [UInt8], with salt: [UInt8]) throws -> Bool {
        let decodedString: String = try decode(bytes: bytes, with: salt)

        guard let boolValue = Bool(decodedString) else {
            throw SecretValueDecodingError.cannotConvertValueOfType("Bool")
        }

        return boolValue
    }
}
