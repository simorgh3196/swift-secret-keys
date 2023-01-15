// The MIT License (MIT)
//
// Copyright (c) 2023 Tomoya Hayakawa (github.com/simorgh3196).

import XCTest
@testable import CocoaPodsExample

final class CocoaPodsExampleTests: XCTestCase {
    func testKeysInDebug() throws {
        XCTAssertEqual(KeysInDebug.clientID, 12345)
        XCTAssertEqual(KeysInDebug.clientSecret, "abcde")
        XCTAssertEqual(KeysInDebug.timeout, 2.5)
    }

    func testKeysInRelease() throws {
        #if DEBUG
        XCTAssertEqual(KeysInRelease.clientID, 34567)
        XCTAssertEqual(KeysInRelease.clientSecret, "fghij")
        XCTAssertEqual(KeysInRelease.timeout, 2.5)
        #else
        XCTAssertEqual(KeysInRelease.clientID, 98765)
        XCTAssertEqual(KeysInRelease.clientSecret, "vWxYz")
        XCTAssertEqual(KeysInRelease.timeout, 2.5)
        #endif
    }
}
