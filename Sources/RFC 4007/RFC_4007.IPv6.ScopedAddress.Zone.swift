extension RFC_4007.IPv6.ScopedAddress {

    public struct Zone: Hashable, Sendable {

        public let rawValue: String

        init(
            __unchecked _: Void,
            rawValue: String
        ) {
            self.rawValue = rawValue
        }
    }
}

extension RFC_4007.IPv6.ScopedAddress.Zone {

    public init(_ text: some StringProtocol) throws(Error) {
        let rawValue = String(text)
        guard !rawValue.isEmpty else { throw Error.empty }
        for byte in rawValue.utf8 where !Self.isZoneByte(byte) {
            throw Error.invalidCharacter(rawValue, byte: byte)
        }
        self.init(__unchecked: (), rawValue: rawValue)
    }

    static func isZoneByte(_ byte: UInt8) -> Bool {
        switch byte {
        case 0x30...0x39, 0x41...0x5A, 0x61...0x7A, 0x2D, 0x2E, 0x5F:
            return true
        default:
            return false
        }
    }
}

extension RFC_4007.IPv6.ScopedAddress.Zone: CustomStringConvertible {

    public var description: String {
        rawValue
    }
}
