public import RFC_4291

extension IETF.RFC.`4007`.IPv6.Address {
    public enum Error: Swift::Error, Sendable, Equatable {
        case empty
        case invalidAddress(_ underlying: IETF.RFC.`4291`.IPv6.Address.Error)
        case missingAddress
        case missingZone
        case invalidZone(_ underlying: IETF.RFC.`4007`.IPv6.Address.Zone.Error)
    }
}

extension IETF.RFC.`4007`.IPv6.Address.Error: CustomStringConvertible {
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
