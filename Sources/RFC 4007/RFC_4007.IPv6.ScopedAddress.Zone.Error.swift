extension RFC_4007.IPv6.ScopedAddress.Zone {
    public enum Error: Swift::Error, Sendable, Equatable {
        case empty
        case invalidCharacter(_ zone: String, byte: UInt8)
    }
}

extension RFC_4007.IPv6.ScopedAddress.Zone.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Zone identifier cannot be empty"

        case .invalidCharacter(let zone, let byte):
            return
                "Zone identifier '\(zone)' has invalid byte 0x\(String(byte, radix: 16)): only letters, digits, '-', '.' and '_' are allowed"
        }
    }
}
