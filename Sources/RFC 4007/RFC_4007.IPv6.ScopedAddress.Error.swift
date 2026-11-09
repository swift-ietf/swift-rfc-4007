public import RFC_4291

extension RFC_4007.IPv6.ScopedAddress {
    public enum Error: Swift::Error, Sendable, Equatable {
        case empty
        case invalidAddress(_ underlying: RFC_4291.IPv6.Address.Error)
        case missingAddress
        case missingZone
        case invalidZone(_ underlying: RFC_4007.IPv6.ScopedAddress.Zone.Error)
    }
}

extension RFC_4007.IPv6.ScopedAddress.Error: CustomStringConvertible {
    public var description: String {
        switch self {
        case .empty:
            return "Scoped address cannot be empty"

        case .invalidAddress(let error):
            return "Invalid IPv6 address: \(error)"

        case .missingAddress:
            return "Missing IPv6 address component"

        case .missingZone:
            return "Missing zone identifier after '%'"

        case .invalidZone(let error):
            return "Invalid zone identifier: \(error)"
        }
    }
}
