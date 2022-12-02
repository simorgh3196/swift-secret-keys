// The MIT License (MIT)
//
// Copyright (c) 2022 Tomoya Hayakawa (github.com/simorgh3196).

import XCTest
@testable import secret_keys

final class SecretValueSerializerTests: XCTestCase {
    func testEncodeValue() {
        let encoder = SecretValueEncoder()
        let text = "text"

        let encodedValue = encoder.encode(value: .string(text), with: [.zero])

        XCTAssertEqual(encodedValue, text.utf8CString.map(UInt8.init))
    }

    func testDecodeStringValue() throws {
        let encoder = SecretValueEncoder()
        let decoder = SecretValueDecoder()
        let salt: [UInt8] = [0x01, 0x02]
        let data = encoder.encode(value: .string("text"), with: salt)

        let decodedValue: String = try decoder.decode(bytes: data, with: salt)

        XCTAssertEqual(decodedValue, "text")
    }

    func testDecodeIntValue() throws {
        let encoder = SecretValueEncoder()
        let decoder = SecretValueDecoder()
        let salt: [UInt8] = [0x01, 0x02]
        let data = encoder.encode(value: .int(123), with: salt)

        let decodedValue: Int = try decoder.decode(bytes: data, with: salt)

        XCTAssertEqual(decodedValue, 123)
    }

    func testDecodeIntValueThrowsWhenWrongTypecast() throws {
        let encoder = SecretValueEncoder()
        let decoder = SecretValueDecoder()
        let salt: [UInt8] = [0x01, 0x02]
        let data = encoder.encode(value: .int(123), with: salt)

        XCTAssertThrowsError(try decoder.decode(bytes: data, with: salt) as Bool)
    }

    func testDecodeDoubleValue() throws {
        let encoder = SecretValueEncoder()
        let decoder = SecretValueDecoder()
        let salt: [UInt8] = [0x01, 0x02]
        let data = encoder.encode(value: .double(123.456), with: salt)

        let decodedValue: Double = try decoder.decode(bytes: data, with: salt)

        XCTAssertEqual(decodedValue, 123.456)
    }

    func testDecodeDoubleValueThrowsWhenWrongTypecast() throws {
        let encoder = SecretValueEncoder()
        let decoder = SecretValueDecoder()
        let salt: [UInt8] = [0x01, 0x02]
        let data = encoder.encode(value: .double(123.456), with: salt)

        XCTAssertThrowsError(try decoder.decode(bytes: data, with: salt) as Bool)
    }

    func testDecodeBoolValue() throws {
        let encoder = SecretValueEncoder()
        let decoder = SecretValueDecoder()
        let salt: [UInt8] = [0x01, 0x02]
        let data = encoder.encode(value: .bool(false), with: salt)

        let decodedValue: Bool = try decoder.decode(bytes: data, with: salt)

        XCTAssertEqual(decodedValue, false)
    }

    func testDecodeBoolValueThrowsWhenWrongTypecast() throws {
        let encoder = SecretValueEncoder()
        let decoder = SecretValueDecoder()
        let salt: [UInt8] = [0x01, 0x02]
        let data = encoder.encode(value: .bool(true), with: salt)

        XCTAssertThrowsError(try decoder.decode(bytes: data, with: salt) as Int)
    }
}
