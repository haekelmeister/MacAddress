import XCTest
@testable import MacAddress

final class MacAddressTests: XCTestCase {
    static var allTests = [
        ("testMacAddressCreation", testMacAddressCreation),
        ("testToHexString", testToHexString),
        ("testZeroAndBroadcast", testZeroAndBroadcast),
        ("testDefault", testDefault),
        ("testBroadcast", testBroadcast),
        ("testIsZero", testIsZero),
        ("testIsBroadcast", testIsBroadcast),
        ("testIsUnicast", testIsUnicast),
        ("testIsMulticast", testIsMulticast),
        ("testIsUniversal", testIsUniversal),
        ("testIsLocal", testIsLocal),
        ("testToCanonicalFormat", testToCanonicalFormat),
        ("testToHexFormat", testToHexFormat),
        ("testToDotFormat", testToDotFormat),
        ("testToHexadecimal", testToHexadecimal),
        ("testToInterfaceId", testToInterfaceId),
        ("testToLinkLocal", testToLinkLocal),
        ("testSuccessfulParseFromString", testSuccessfulParseFromString),
        ("testParseFromTooShortString", testParseFromTooShortString),
        ("testParseFromString", testParseFromString),
        ("testParseFromStringWithInvalidCharacter", testParseFromStringWithInvalidCharacter),
        ("testBytes", testBytes),
        ("testEquality", testEquality),
        ("testJsonEncoding", testJsonEncoding),
        ("testJsonDeserialisation", testJsonDeserialisation),
        ("testSerializationRoundTrip", testSerializationRoundTrip),
        ("testCustomDebugStringConvertible", testCustomDebugStringConvertible),
        ("testCustomStringConvertible", testCustomStringConvertible),
        ("testParseErrorFormatting", testParseErrorFormatting),
        ("testCopyInitializer", testCopyInitializer)
    ]

    func testMacAddressCreation() {
        let eui: [UInt8] = [0x12, 0x34, 0x56, 0xAB, 0xCD, 0xEF]
        let mac = MacAddress(fromArray: eui)!
        XCTAssertEqual(eui, mac.eui)

        let tooLongMac = MacAddress(fromArray: [0x12, 0x34, 0x56, 0xAB, 0xCD, 0xEF, 0x12, 0x34, 0x56, 0xAB, 0xCD, 0xEF])
        XCTAssertNil(tooLongMac)

        let tooShortMac = MacAddress(fromArray: [0x12, 0x34, 0x56, 0xAB, 0xCD])
        XCTAssertNil(tooShortMac)
    }

    func testToHexString() {
        let mac = MacAddress(fromArray: [0x12, 0x34, 0x56, 0xAB, 0xCD, 0xEF])!

        XCTAssert("12:34:56:ab:cd:ef" == mac.hexFormat)
    }

    func testZeroAndBroadcast() {
        let zero = MacAddress(withType: .zero)
        XCTAssert(zero.isZero)
        XCTAssertEqual("00:00:00:00:00:00", zero.hexFormat)

        let broadcast = MacAddress(withType: .broadcast)
        XCTAssert(!broadcast.isZero)
        XCTAssertEqual("ff:ff:ff:ff:ff:ff", broadcast.hexFormat)
    }

    func testDefault() {
        let defaultMac = MacAddress()
        XCTAssert(defaultMac.isZero)
        XCTAssertEqual("00:00:00:00:00:00", defaultMac.hexFormat)
    }

    func testBroadcast() {
        let broadcast = MacAddress(withType: .broadcast)
        let notBroadcast = MacAddress()
        XCTAssertEqual("ff:ff:ff:ff:ff:ff", broadcast.hexFormat)
        XCTAssert(broadcast.isBroadcast)
        XCTAssert(!notBroadcast.isBroadcast)
    }

    func testIsZero() {
        let zero = MacAddress()
        XCTAssert(zero.isZero)

        let macAddress = MacAddress(fromString: "01:00:5E:AB:CD:EF")!
        XCTAssert(!macAddress.isZero)
    }

    func testIsBroadcast() {
        let broadcast = MacAddress(withType: .broadcast)
        XCTAssert(broadcast.isBroadcast)

        let notBroadcast = MacAddress(fromString: "01:00:5E:AB:CD:EF")!
        XCTAssert(!notBroadcast.isBroadcast)
    }

    func testIsUnicast() {
        let uncastMac = MacAddress(fromString: "FE:00:5E:AB:CD:EF")!
        XCTAssert(uncastMac.isUnicast)

        let notUnicastMac = MacAddress(fromString: "01:00:5E:AB:CD:EF")!
        XCTAssert(!notUnicastMac.isUnicast)

        XCTAssertEqual("fe:00:5e:ab:cd:ef", uncastMac.hexFormat) // Catch modifying first octet

        let mac = MacAddress(fromString: "FF:00:5E:AB:CD:EF")!
        XCTAssert(!mac.isUnicast)
        XCTAssertEqual("ff:00:5e:ab:cd:ef", mac.hexFormat) // Catch modifying first octet
        XCTAssert(MacAddress().isUnicast)
        XCTAssert(!MacAddress(withType: .broadcast).isUnicast)
    }

    func testIsMulticast() {
        let unicastMac = MacAddress(fromString: "FE:00:5E:AB:CD:EF")!
        XCTAssert(!unicastMac.isMulticast)

        let multicastMac = MacAddress(fromString: "01:00:5E:AB:CD:EF")!
        XCTAssert(multicastMac.isMulticast)
        XCTAssertEqual("01:00:5e:ab:cd:ef", multicastMac.hexFormat) // Catch modifying first octet

        XCTAssert(!MacAddress().isMulticast)

        let mac = MacAddress(fromString: "F0:00:5E:AB:CD:EF")!
        XCTAssert(!mac.isMulticast)
        XCTAssertEqual("f0:00:5e:ab:cd:ef", mac.hexFormat) // Catch modifying first octet
        XCTAssert(MacAddress(withType: .broadcast).isMulticast)
    }

    func testIsUniversal() {
        let universalMac = MacAddress(fromString: "11:24:56:AB:CD:EF")!
        XCTAssert(universalMac.isUniversal)

        let notUniversalMac = MacAddress(fromString: "12:24:56:AB:CD:EF")!
        XCTAssert(!notUniversalMac.isUniversal)
        XCTAssertEqual("11:24:56:ab:cd:ef", universalMac.hexFormat) // Catch modifying first octet
    }

    func testIsLocal() {
        let localMac = MacAddress(fromString: "06:34:56:AB:CD:EF")!
        XCTAssert(localMac.isLocal)

        let notLocalMac = MacAddress(fromString: "00:34:56:AB:CD:EF")!
        XCTAssert(!notLocalMac.isLocal)
        XCTAssertEqual("06:34:56:ab:cd:ef", localMac.hexFormat) // Catch modifying first octet
    }

    func testToCanonicalFormat() {
        let mac = MacAddress(fromArray: [0x12, 0x34, 0x56, 0xAB, 0xCD, 0xEF])!
        XCTAssertEqual("12-34-56-ab-cd-ef", mac.canonicalFormat)
    }

    func testToHexFormat() {
        let mac = MacAddress(fromArray: [0x12, 0x34, 0x56, 0xAB, 0xCD, 0xEF])!
        XCTAssertEqual("12:34:56:ab:cd:ef", mac.hexFormat)
    }

    func testToDotFormat() {
        let mac = MacAddress(fromArray: [0x12, 0x34, 0x56, 0xAB, 0xCD, 0xEF])!
        XCTAssertEqual("1234.56ab.cdef", mac.dotFormat)
    }

    func testToHexadecimal() {
        let mac = MacAddress(fromArray: [0x12, 0x34, 0x56, 0xAB, 0xCD, 0xEF])!
        XCTAssertEqual("0x123456abcdef", mac.hexadecimal)
    }

    func testToInterfaceId() {
        let mac = MacAddress(fromArray: [0x12, 0x34, 0x56, 0xAB, 0xCD, 0xEF])!
        XCTAssertEqual("1034:56ff:feab:cdef", mac.interfaceId)
    }

    func testToLinkLocal() {
        let mac = MacAddress(fromArray: [0x12, 0x34, 0x56, 0xAB, 0xCD, 0xEF])!
        XCTAssertEqual("ff80::1034:56ff:feab:cdef", mac.linkLocal)
    }

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
        switch parseMacAddress(fromString: "1234567890ABCD") {
        case let .failure(invalidLength): XCTAssertEqual(ParseError.invalidLength(14), invalidLength)
        default: XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "0x00:00:00:00:"))
        switch parseMacAddress(fromString: "0x00:00:00:00:") {
        case let .failure(invalidLength): XCTAssertEqual(ParseError.invalidLength(14), invalidLength)
        default: XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "::::::::::::::"))
        switch parseMacAddress(fromString: "::::::::::::::") {
        case let .failure(invalidLength): XCTAssertEqual(ParseError.invalidLength(14), invalidLength)
        default: XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "1234567890ABCDEF"))
        switch parseMacAddress(fromString: "1234567890ABCDEF") {
        case let .failure(invalidLength): XCTAssertEqual(ParseError.invalidLength(16), invalidLength)
        default: XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "01234567890ABCDEF"))
        switch parseMacAddress(fromString: "01234567890ABCDEF") {
        case let .failure(invalidLength): XCTAssertEqual(ParseError.invalidLength(17), invalidLength)
        default: XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "0x1234567890ABCDE"))
        switch parseMacAddress(fromString: "0x1234567890ABCDE") {
        case let .failure(invalidLength): XCTAssertEqual(ParseError.invalidLength(17), invalidLength)
        default: XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: "0x00:00:00:00:00:"))
        switch parseMacAddress(fromString: "0x00:00:00:00:00:") {
        case let .failure(invalidLength): XCTAssertEqual(ParseError.invalidLength(17), invalidLength)
        default: XCTFail("Parsing not failed")
        }

        XCTAssertEqual(nil, MacAddress(fromString: ":::::::::::::::::"))
        switch parseMacAddress(fromString: ":::::::::::::::::") {
        case let .failure(invalidLength): XCTAssertEqual(ParseError.invalidLength(17), invalidLength)
        default: XCTFail("Parsing not failed")
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

    func testBytes() {
        let mac = MacAddress(withType: .broadcast)

        XCTAssertEqual(mac.eui.count, 6)

        XCTAssertEqual(mac.eui[0], 0xff)
        XCTAssertEqual(mac.eui[1], 0xff)
        XCTAssertEqual(mac.eui[2], 0xff)
        XCTAssertEqual(mac.eui[3], 0xff)
        XCTAssertEqual(mac.eui[4], 0xff)
        XCTAssertEqual(mac.eui[5], 0xff)
    }

    func testEquality() {
        let zero = MacAddress()
        let broadcast = MacAddress(withType: .broadcast)

        XCTAssertEqual(zero, zero)
        XCTAssertEqual(broadcast, broadcast)
        XCTAssertNotEqual(zero, broadcast)
        XCTAssertNotEqual(broadcast, zero)

        let originalMac = MacAddress(fromString: "12:34:56:AB:CD:EF")!
        let copiedMac = originalMac

        XCTAssertEqual(originalMac, originalMac)
        XCTAssertEqual(copiedMac, copiedMac)
        XCTAssertEqual(originalMac, copiedMac)
        XCTAssertEqual(copiedMac, originalMac)
    }

    func testJsonEncoding() {
        let mac = MacAddress(fromString: "12:34:56:AB:CD:EF")!
        let jsonData = try? JSONEncoder().encode(mac)
        let jsonString = String(data: jsonData!, encoding: .utf8)!

        XCTAssertEqual(#"{"eui":[18,52,86,171,205,239]}"#, jsonString)
    }

    func testJsonDeserialisation() {
        let jsonData = #"{"eui":[18,52,86,171,205,239]}"#.data(using: .utf8)!
        let macData = try? JSONDecoder().decode(MacAddress.self, from: jsonData)
        let mac = MacAddress(fromString: "12:34:56:AB:CD:EF")!

        XCTAssertEqual(mac, macData)
    }

    func testSerializationRoundTrip() {
        let originalMac = MacAddress(fromString: "12:34:56:AB:CD:EF")!
        let macData = try? JSONEncoder().encode(originalMac)
        let jsonString = String(data: macData!, encoding: .utf8)!

        let jsonData = jsonString.data(using: .utf8)!
        let decodedMac = try? JSONDecoder().decode(MacAddress.self, from: jsonData)

        XCTAssertEqual(originalMac, decodedMac!)
    }

    func testCustomDebugStringConvertible() {
        let mac = MacAddress(fromString: "12:34:56:AB:CD:EF")!
        XCTAssertEqual(
            #"MacAddress("12:34:56:ab:cd:ef")"#,
            mac.debugDescription)
    }

    func testCustomStringConvertible() {
        let mac = MacAddress(fromString: "12:34:56:AB:CD:EF")!
        XCTAssertEqual(
            "12:34:56:ab:cd:ef",
            mac.description)
    }

    func testParseErrorFormatting() {
        XCTAssertEqual(
            "Invalid length; expecting 14 or 17 characters, found 2",
            ParseError.invalidLength(2).debugDescription)

        XCTAssertEqual(
            "Invalid character; found '&' at offset 2",
            ParseError.invalidCharacter("&", 2).debugDescription)

        XCTAssertEqual(
            "MacAddress parse error",
            ParseError.invalidLength(2).description)

        XCTAssertEqual(
            "MacAddress parse error",
            ParseError.invalidCharacter("&", 2).description)
    }

    func testCopyInitializer() {
        let eui: [UInt8] = [0x12, 0x34, 0x56, 0xAB, 0xCD, 0xEF]
        let mac = MacAddress(fromArray: eui)!

        XCTAssertEqual(eui, mac.eui)
        XCTAssertEqual(mac, MacAddress(fromMacAddress: mac))
    }
}
