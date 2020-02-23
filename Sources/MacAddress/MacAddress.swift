import Foundation

public enum InitType {
    case zero
    case broadcast
}

public struct MacAddress: Codable, Equatable {
    let eui: [UInt8]

    public init?(fromArray eui: [UInt8]) {
        guard eui.count == 6 else {
            return nil
        }
        self.eui = eui
    }

    public init?(fromString macAddress: String) {
        if case let .success(eui) = parseMacAddress(fromString: macAddress) {
            self.eui = eui
        } else {
            return nil
        }
    }

    public init(withType type: InitType) {
        switch type {
        case .zero: self.eui = Array(repeating: 0, count: 6)
        case .broadcast: self.eui = Array(repeating: 0xff, count: 6)
        }
    }

    public init(fromMacAddress mac: MacAddress) {
        self.eui = mac.eui
    }

    public init() {
        self.init(withType: .zero)
    }

    public var isZero: Bool {
        self.eui == Array(repeating: 0, count: 6)
    }

    public var isBroadcast: Bool {
        self.eui == Array(repeating: 0xff, count: 6)
    }

    // Returns true if bit 1 of Y is 0 in address 'xY:xx:xx:xx:xx:xx'
    public var isUnicast: Bool {
        self.eui[0] & 1 == 0
    }

    // Returns true if bit 1 of Y is 1 in address 'xY:xx:xx:xx:xx:xx'
    public var isMulticast: Bool {
        self.eui[0] & 1 == 1
    }

    // Returns true if bit 2 of Y is 0 in address 'xY:xx:xx:xx:xx:xx'
    public var isUniversal: Bool {
        self.eui[0] & 1 << 1 == 0
    }

    // Returns true if bit 2 of Y is 1 in address 'xY:xx:xx:xx:xx:xx'
    public var isLocal: Bool {
        self.eui[0] & 1 << 1 == 2
    }

    public var hexadecimal: String {
        String(format: "0x%02x%02x%02x%02x%02x%02x",
               self.eui[0],
               self.eui[1],
               self.eui[2],
               self.eui[3],
               self.eui[4],
               self.eui[5]
        )
    }

    public var interfaceId: String {
        String(format: "%02x%02x:%02xff:fe%02x:%02x%02x",
               (self.eui[0] ^ 0x02),
               self.eui[1],
               self.eui[2],
               self.eui[3],
               self.eui[4],
               self.eui[5]
        )
    }

    public var linkLocal: String {
        String(format: "ff80::%02x%02x:%02xff:fe%02x:%02x%02x",
               (self.eui[0] ^ 0x02),
               self.eui[1],
               self.eui[2],
               self.eui[3],
               self.eui[4],
               self.eui[5]
        )
    }

    public var hexFormat: String {
        String(format: "%02x:%02x:%02x:%02x:%02x:%02x",
               self.eui[0],
               self.eui[1],
               self.eui[2],
               self.eui[3],
               self.eui[4],
               self.eui[5]
        )
    }

    public var dotFormat: String {
        String(format: "%02x%02x.%02x%02x.%02x%02x",
               self.eui[0],
               self.eui[1],
               self.eui[2],
               self.eui[3],
               self.eui[4],
               self.eui[5]
        )
    }

    public var canonicalFormat: String {
        String(format: "%02x-%02x-%02x-%02x-%02x-%02x",
               self.eui[0],
               self.eui[1],
               self.eui[2],
               self.eui[3],
               self.eui[4],
               self.eui[5]
        )
    }
}

extension MacAddress: CustomStringConvertible {
    public var description: String {
        "\(self.hexFormat)"
    }
}

extension MacAddress: CustomDebugStringConvertible {
    public var debugDescription: String {
        "MacAddress(\"\(self.hexFormat)\")"
    }
}

enum ParseError: Error, Equatable {
    case invalidLength(Int)
    case invalidCharacter(String, Int)
}

extension ParseError: CustomStringConvertible {
    var description: String { "MacAddress parse error" }
}

extension ParseError: CustomDebugStringConvertible {
    var debugDescription: String {
        switch self {
        case .invalidLength(let length):
            return "Invalid length; expecting 14 or 17 characters, found \(length)"
        case .invalidCharacter(let character, let position):
            return "Invalid character; found '\(character)' at offset \(position)"
        }
    }
}

func parseMacAddress(fromString macAddress: String) -> Result<[UInt8], ParseError> {
    var offset = 0
    var highNibble: Bool = false
    var eui: [UInt8] = Array(repeating: 0, count: 6)
    var start = 0

    if macAddress.count != 14 && macAddress.count != 17 {
        return .failure(.invalidLength(macAddress.count))
    }

    if macAddress.starts(with: "0x") || macAddress.starts(with: "0X") {
        start = 2
    }

    for index in start..<macAddress.count {
        if offset >= 6 {
            // We shouln't still be parsing
            return .failure(.invalidLength(macAddress.count))
        }

        let character = macAddress[index]

        switch character {
        case "-", ":", ".": break
        case "0"..."9", "a"..."f", "A"..."F":
            let hexValue = UInt8(String(character), radix: 16)!

            if highNibble {
                eui[offset] += hexValue
                offset += 1
            } else {
                eui[offset] = hexValue << 4
            }

            highNibble.toggle()
        default: return .failure(.invalidCharacter(character, index))
        }
    }

    if offset != 6 {
        return .failure(.invalidLength(macAddress.count))
    }

    return .success(eui)
}

extension String {
    subscript(idx: Int) -> String {
        return String(self[index(startIndex, offsetBy: idx)])
    }
}
