public import RFC_4291

extension IETF.RFC.`4007`.IPv6 {

    public struct Address: Hashable, Sendable {

        public let address: IETF.RFC.`4291`.IPv6.Address

        public let zone: Zone?

        public init(
            address: IETF.RFC.`4291`.IPv6.Address,
            zone: Zone? = nil
        ) {
            self.address = address
            self.zone = zone
        }
    }
}

extension IETF.RFC.`4007`.IPv6.Address {

    public var requiresZone: Bool {
        address.is.linkLocal
    }

    public var isProperlyScoped: Bool {
        if requiresZone {
            return zone != nil
        }
        return true
    }
}
