import RFC_4007
import RFC_4291
import Testing

enum `IETF.RFC.4007 Tests` {}

extension `IETF.RFC.4007 Tests` {
    @Suite
    struct `RFC 4007 Tests` {
    }
}

extension `IETF.RFC.4007 Tests`.`RFC 4007 Tests` {
    @Suite struct `Scoped Address Tests` {}

    @Suite struct `Scope Tests` {}

    @Suite struct `Zone Tests` {}
}

extension `IETF.RFC.4007 Tests`.`RFC 4007 Tests`.`Zone Tests` {

    @Test
    func `accepts letters, digits, hyphen, period and underscore`() throws {
        for text in ["eth0", "1", "en0.100", "wlan_0", "br-lan"] {
            #expect(try IETF.RFC.`4007`.IPv6.Address.Zone(text).rawValue == text)
        }
    }

    @Test
    func `rejects an empty zone`() {
        #expect(throws: IETF.RFC.`4007`.IPv6.Address.Zone.Error.empty) {
            try IETF.RFC.`4007`.IPv6.Address.Zone("")
        }
    }

    @Test
    func `rejects bytes the text form cannot read back`() {
        for (text, byte) in [("eth 0", UInt8(0x20)), ("eth0]", 0x5D), ("eth0/1", 0x2F), ("eth%0", 0x25)] {
            #expect(throws: IETF.RFC.`4007`.IPv6.Address.Zone.Error.invalidCharacter(text, byte: byte)) {
                try IETF.RFC.`4007`.IPv6.Address.Zone(text)
            }
        }
    }
}

extension `IETF.RFC.4007 Tests`.`RFC 4007 Tests`.`Scoped Address Tests` {

    @Test
    func `holds an address and a zone`() throws {
        let address = IETF.RFC.`4291`.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = IETF.RFC.`4007`.IPv6.Address(address: address, zone: try IETF.RFC.`4007`.IPv6.Address.Zone("eth0"))

        #expect(scoped.address == address)
        #expect(scoped.zone?.rawValue == "eth0")
    }

    @Test
    func `holds an address without a zone`() {
        let address = IETF.RFC.`4291`.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = IETF.RFC.`4007`.IPv6.Address(address: address, zone: nil)

        #expect(scoped.address == address)
        #expect(scoped.zone == nil)
    }

    @Test
    func `defaults the zone to nil`() {
        let scoped = IETF.RFC.`4007`.IPv6.Address(address: IETF.RFC.`4291`.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1))

        #expect(scoped.zone == nil)
    }
}

extension `IETF.RFC.4007 Tests`.`RFC 4007 Tests`.`Scope Tests` {

    @Test
    func `a link-local address requires a zone`() {
        let scoped = IETF.RFC.`4007`.IPv6.Address(address: IETF.RFC.`4291`.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1))

        #expect(scoped.requiresZone)
        #expect(!scoped.isProperlyScoped)
    }

    @Test
    func `a link-local address with a zone is properly scoped`() throws {
        let scoped = IETF.RFC.`4007`.IPv6.Address(
            address: IETF.RFC.`4291`.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1),
            zone: try IETF.RFC.`4007`.IPv6.Address.Zone("eth0")
        )

        #expect(scoped.requiresZone)
        #expect(scoped.isProperlyScoped)
    }

    @Test
    func `a unique local address has global scope per RFC 4193 section 3_3 and does not require a zone`() {
        let scoped = IETF.RFC.`4007`.IPv6.Address(address: IETF.RFC.`4291`.IPv6.Address(0xfd00, 0, 0, 0, 0, 0, 0, 1))

        #expect(!scoped.requiresZone)
        #expect(scoped.isProperlyScoped)
    }

    @Test
    func `a global address does not require a zone`() {
        let scoped = IETF.RFC.`4007`.IPv6.Address(address: IETF.RFC.`4291`.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1))

        #expect(!scoped.requiresZone)
        #expect(scoped.isProperlyScoped)
    }

    @Test
    func `the loopback address does not require a zone`() {
        let scoped = IETF.RFC.`4007`.IPv6.Address(address: IETF.RFC.`4291`.IPv6.Address.loopback)

        #expect(!scoped.requiresZone)
        #expect(scoped.isProperlyScoped)
    }
}
