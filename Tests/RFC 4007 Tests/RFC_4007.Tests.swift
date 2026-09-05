import RFC_4007
import RFC_4291
import Testing

@Suite
struct `RFC 4007 Tests` {
    @Suite struct `Scoped Address Tests` {}
    @Suite struct `Scope Tests` {}
}

extension `RFC 4007 Tests`.`Scoped Address Tests` {

    @Test
    func `holds an address and a zone`() {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")

        #expect(scoped.address == address)
        #expect(scoped.zone == "eth0")
    }

    @Test
    func `holds an address without a zone`() {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: address, zone: nil)

        #expect(scoped.address == address)
        #expect(scoped.zone == nil)
    }

    @Test
    func `defaults the zone to nil`() {
        let scoped = RFC_4007.IPv6.ScopedAddress(address: RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1))

        #expect(scoped.zone == nil)
    }
}

extension `RFC 4007 Tests`.`Scope Tests` {

    @Test
    func `a link-local address requires a zone`() {
        let scoped = RFC_4007.IPv6.ScopedAddress(address: RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1))

        #expect(scoped.requiresZone)
        #expect(!scoped.isProperlyScoped)
    }

    @Test
    func `a link-local address with a zone is properly scoped`() {
        let scoped = RFC_4007.IPv6.ScopedAddress(
            address: RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1),
            zone: "eth0"
        )

        #expect(scoped.requiresZone)
        #expect(scoped.isProperlyScoped)
    }

    @Test
    func `a unique local address requires a zone`() {
        let scoped = RFC_4007.IPv6.ScopedAddress(address: RFC_4291.IPv6.Address(0xfc00, 0, 0, 0, 0, 0, 0, 1))

        #expect(scoped.requiresZone)
        #expect(!scoped.isProperlyScoped)
    }

    @Test
    func `a global address does not require a zone`() {
        let scoped = RFC_4007.IPv6.ScopedAddress(address: RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1))

        #expect(!scoped.requiresZone)
        #expect(scoped.isProperlyScoped)
    }

    @Test
    func `the loopback address does not require a zone`() {
        let scoped = RFC_4007.IPv6.ScopedAddress(address: RFC_4291.IPv6.Address.loopback)

        #expect(!scoped.requiresZone)
        #expect(scoped.isProperlyScoped)
    }
}
