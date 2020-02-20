import XCTest
@testable import MacAddress

final class MacAddressParseTests: XCTestCase {
    static var allTests = [
        ("testSuccessfulParseFromString", testSuccessfulParseFromString),
        ("testParseFromTooShortString", testParseFromTooShortString),
        ("testParseFromString", testParseFromString),
        ("testParseFromStringWithInvalidCharacter", testParseFromStringWithInvalidCharacter)
    ]

    func testSuccessfulParseFromString() {
        XCTAssertEqual("0x123456abcdef", MacAddress(fromString: "0x123456ABCDEF")!.hexadecimal)
        XCTAssertEqual("1234.56ab.cdef", MacAddress(fromString: "1234.56AB.CDEF")!.dotFormat)
        XCTAssertEqual("12:34:56:ab:cd:ef", MacAddress(fromString: "12:34:56:AB:CD:EF")!.hexFormat)
        XCTAssertEqual("12-34-56-ab-cd-ef", MacAddress(fromString: "12-34-56-AB-CD-EF")!.canonicalFormat)
    }

    func testParseFromTooShortString() {
        XCTAssertEqual(nil, MacAddress(fromString: ""))
        switch parseMacAddress(fromString: "") {
        case let .failure(invalidLength): XCTAssertEqual(ParseError.invalidLength(0), invalidLength)
        default: XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "0"))
        switch parseMacAddress(fromString: "0") {
        case let .failure(invalidLength): XCTAssertEqual(ParseError.invalidLength(1), invalidLength)
        default: XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "123456ABCDEF"))
        switch parseMacAddress(fromString: "123456ABCDEF") {
        case let .failure(invalidLength): XCTAssertEqual(ParseError.invalidLength(12), invalidLength)
        default: XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "0x1234567890A"))
        switch parseMacAddress(fromString: "0x1234567890A") {
        case let .failure(invalidLength): XCTAssertEqual(ParseError.invalidLength(13), invalidLength)
        default: XCTFail("Parsing not failed")
        }
    }

    func testParseFromString() {
        XCTAssertEqual(nil, MacAddress(fromString: "1234567890ABCD"))
        if case let .failure(invalidLength) = parseMacAddress(fromString: "1234567890ABCD") {
            XCTAssertEqual(ParseError.invalidLength(14), invalidLength)
        } else {
            XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "0x00:00:00:00:"))
        if case let .failure(invalidLength) = parseMacAddress(fromString: "0x00:00:00:00:") {
            XCTAssertEqual(ParseError.invalidLength(14), invalidLength)
        } else {
            XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "::::::::::::::"))
        if case let .failure(invalidLength) = parseMacAddress(fromString: "::::::::::::::") {
            XCTAssertEqual(ParseError.invalidLength(14), invalidLength)
        } else {
            XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "1234567890ABCDEF"))
        if case let .failure(invalidLength) = parseMacAddress(fromString: "1234567890ABCDEF") {
            XCTAssertEqual(ParseError.invalidLength(16), invalidLength)
        } else {
            XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "01234567890ABCDEF"))
        if case let .failure(invalidLength) = parseMacAddress(fromString: "01234567890ABCDEF") {
            XCTAssertEqual(ParseError.invalidLength(17), invalidLength)
        } else {
            XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "0x1234567890ABCDE"))
        if case let .failure(invalidLength) = parseMacAddress(fromString: "0x1234567890ABCDE") {
            XCTAssertEqual(ParseError.invalidLength(17), invalidLength)
        } else {
            XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "0x00:00:00:00:00:"))
        if case let .failure(invalidLength) = parseMacAddress(fromString: "0x00:00:00:00:00:") {
            XCTAssertEqual(ParseError.invalidLength(17), invalidLength)
        } else {
            XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: ":::::::::::::::::"))
        if case let .failure(invalidLength) = parseMacAddress(fromString: ":::::::::::::::::") {
            XCTAssertEqual(ParseError.invalidLength(17), invalidLength)
        } else {
            XCTFail("Parsing not failed")
        }
    }

    func testParseFromStringWithInvalidCharacter() {
        XCTAssertEqual(nil, MacAddress(fromString: "0x0x0x0x0x0x0x"))
        switch parseMacAddress(fromString: "0x0x0x0x0x0x0x") {
        case let .failure(invalidCharacter): XCTAssertEqual(ParseError.invalidCharacter("x", 3), invalidCharacter)
        default: XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "!0x00000000000"))
        switch parseMacAddress(fromString: "!0x00000000000") {
        case let .failure(invalidCharacter): XCTAssertEqual(ParseError.invalidCharacter("!", 0), invalidCharacter)
        default: XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "0x00000000000!"))
        switch parseMacAddress(fromString: "0x00000000000!") {
        case let .failure(invalidCharacter): XCTAssertEqual(ParseError.invalidCharacter("!", 13), invalidCharacter)
        default: XCTFail("Parsing not failed")
        }
    }
}
