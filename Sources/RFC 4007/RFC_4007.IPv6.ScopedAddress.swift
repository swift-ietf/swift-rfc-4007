public import RFC_4291

extension RFC_4007.IPv6 {

    public struct ScopedAddress: Hashable, Sendable {

        public let address: RFC_4291.IPv6.Address

        public let zone: String?

        public init<S: StringProtocol>(
            address: RFC_4291.IPv6.Address,
            zone: S?
        ) {
            self.address = address
            self.zone = zone.map { String($0) }
        }

        public init(
            address: RFC_4291.IPv6.Address,
            zone: String? = nil
        ) {
            self.address = address
            self.zone = zone
        }
    }
}

extension RFC_4007.IPv6.ScopedAddress {

    public var requiresZone: Bool {
        address.is.linkLocal || address.is.uniqueLocal
    }

    public var isProperlyScoped: Bool {
        if requiresZone {
            return zone != nil
        }
        return true
    }
}
