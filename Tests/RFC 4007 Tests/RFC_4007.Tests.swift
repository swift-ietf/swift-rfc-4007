import Testing

@testable import RFC_4007
@testable import RFC_4291

@Suite("RFC 4007: IPv6 Scoped Address Tests")
struct RFC4007Tests {
    @Suite struct Unit {}
    @Suite struct `Edge Case` {}
    @Suite struct Integration {}
}

extension RFC4007Tests.Unit {

    @Test
    func `ScopedAddress initialization with zone`() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")

        #expect(scoped.address == address)
        #expect(scoped.zone == "eth0")
    }

    @Test
    func `ScopedAddress initialization without zone`() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: address, zone: nil)

        #expect(scoped.address == address)
        #expect(scoped.zone == nil)
    }

    @Test
    func `ScopedAddress default zone is nil`() throws {
        let address = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: address)

        #expect(scoped.zone == nil)
    }

    @Test
    func `ScopedAddress accepts StringProtocol types`() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)

        let fullString = "eth0_interface"
        let substring = fullString.prefix(4)
        let scoped1 = RFC_4007.IPv6.ScopedAddress(address: address, zone: substring)

        #expect(scoped1.zone == "eth0")
        #expect(String(scoped1) == "fe80::1%eth0")

        let scoped2 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "wlan0")
        #expect(scoped2.zone == "wlan0")
        #expect(String(scoped2) == "fe80::1%wlan0")
    }

    @Test
    func `Link-local addresses require zone`() throws {
        let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal)

        #expect(scoped.requiresZone == true)
        #expect(scoped.isProperlyScoped == false)
    }

    @Test
    func `Link-local with zone is properly scoped`() throws {
        let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "eth0")

        #expect(scoped.requiresZone == true)
        #expect(scoped.isProperlyScoped == true)
    }

    @Test
    func `Unique local addresses require zone`() throws {
        let ula = RFC_4291.IPv6.Address(0xfc00, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: ula)

        #expect(scoped.requiresZone == true)
        #expect(scoped.isProperlyScoped == false)
    }

    @Test
    func `Global addresses don't require zone`() throws {
        let global = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: global)

        #expect(scoped.requiresZone == false)
        #expect(scoped.isProperlyScoped == true)
    }

    @Test
    func `Loopback doesn't require zone`() throws {
        let loopback = RFC_4291.IPv6.Address.loopback
        let scoped = RFC_4007.IPv6.ScopedAddress(address: loopback)

        #expect(scoped.requiresZone == false)
        #expect(scoped.isProperlyScoped == true)
    }

    @Test
    func `RFC 4007 Section 11.7: Link-local with zone string format`() throws {
        let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "eth0")

        let text = String(scoped)
        #expect(text == "fe80::1%eth0")
    }

    @Test
    func `RFC 4007 Section 11.7: Numeric zone ID`() throws {
        let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "1")

        let text = String(scoped)
        #expect(text == "fe80::1%1")
    }

    @Test
    func `Global address without zone`() throws {
        let global = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: global)

        let text = String(scoped)
        #expect(text == "2001:db8::1")
        #expect(!text.contains("%"))
    }

    @Test
    func `Global address with zone (unusual but allowed)`() throws {
        let global = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: global, zone: "eth0")

        let text = String(scoped)
        #expect(text == "2001:db8::1%eth0")
    }

    @Test
    func `Unspecified address without zone`() throws {
        let unspecified = RFC_4291.IPv6.Address.unspecified
        let scoped = RFC_4007.IPv6.ScopedAddress(address: unspecified)

        let text = String(scoped)
        #expect(text == "::")
    }

    @Test
    func `CustomStringConvertible description`() throws {
        let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "eth0")

        #expect(scoped.description == "fe80::1%eth0")
    }

    @Test
    func `Equality with same address and zone`() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped1 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")
        let scoped2 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")

        #expect(scoped1 == scoped2)
    }

    @Test
    func `Inequality with different zones`() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped1 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")
        let scoped2 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth1")

        #expect(scoped1 != scoped2)
    }

    @Test
    func `Inequality with zone vs no zone`() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped1 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")
        let scoped2 = RFC_4007.IPv6.ScopedAddress(address: address, zone: nil)

        #expect(scoped1 != scoped2)
    }

    @Test
    func `Hashable allows use in Set`() throws {
        let address1 = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let address2 = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 2)

        let scoped1 = RFC_4007.IPv6.ScopedAddress(address: address1, zone: "eth0")
        let scoped2 = RFC_4007.IPv6.ScopedAddress(address: address1, zone: "eth1")
        let scoped3 = RFC_4007.IPv6.ScopedAddress(address: address2, zone: "eth0")

        var set: Set<RFC_4007.IPv6.ScopedAddress> = []
        set.insert(scoped1)
        set.insert(scoped2)
        set.insert(scoped3)

        #expect(set.count == 3)
    }

    @Test
    func `Link-local on multiple interfaces`() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0x0200, 0x5eff, 0xfe00, 0x0001)

        let eth0 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")
        let eth1 = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth1")

        #expect(String(eth0) == "fe80::200:5eff:fe00:1%eth0")
        #expect(String(eth1) == "fe80::200:5eff:fe00:1%eth1")
        #expect(eth0 != eth1)
    }

    @Test
    func `Multicast with zone`() throws {

        let multicast = RFC_4291.IPv6.Address(0xff02, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: multicast, zone: "eth0")

        #expect(String(scoped) == "ff02::1%eth0")
    }

    @Test
    func `Documentation address (global scope)`() throws {
        let docs = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: docs)

        #expect(scoped.requiresZone == false)
        #expect(String(scoped) == "2001:db8::1")
    }

    @Test
    func `ASCII.Parseable: parse with zone`() throws {
        let scoped = try RFC_4007.IPv6.ScopedAddress(
            ascii: Array("fe80::1%eth0".utf8.map { Byte($0) })
        )

        #expect(scoped.address == RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1))
        #expect(scoped.zone == "eth0")
    }

    @Test
    func `ASCII.Parseable: parse without zone`() throws {
        let scoped = try RFC_4007.IPv6.ScopedAddress(
            ascii: Array("2001:db8::1".utf8.map { Byte($0) })
        )

        #expect(scoped.address == RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1))
        #expect(scoped.zone == nil)
    }

    @Test
    func `ASCII round-trip: parse-serialize-parse identity, canonical string golden`() throws {

        let golden = [
            "fe80::1%eth0",
            "fe80::1%1",
            "2001:db8::1",
            "ff02::1%eth0",
            "fe80::200:5eff:fe00:1%eth1",
            "::",
        ]
        for text in golden {
            let parsed = try RFC_4007.IPv6.ScopedAddress(ascii: Array(text.utf8.map { Byte($0) }))
            let serialized = String(parsed)
            #expect(serialized == text)
            let reparsed = try RFC_4007.IPv6.ScopedAddress(
                ascii: Array(serialized.utf8.map { Byte($0) })
            )
            #expect(parsed == reparsed)
        }
    }

    @Test
    func `ASCII.Parseable: malformed inputs throw`() throws {

        #expect(throws: RFC_4007.IPv6.ScopedAddress.Error.self) {
            _ = try RFC_4007.IPv6.ScopedAddress(ascii: [Byte]())
        }

        #expect(throws: RFC_4007.IPv6.ScopedAddress.Error.self) {
            _ = try RFC_4007.IPv6.ScopedAddress(ascii: Array("fe80::1%".utf8.map { Byte($0) }))
        }

        #expect(throws: RFC_4007.IPv6.ScopedAddress.Error.self) {
            _ = try RFC_4007.IPv6.ScopedAddress(ascii: Array("%eth0".utf8.map { Byte($0) }))
        }
    }

    @Test
    func `RawRepresentable round-trips through canonical text`() throws {
        let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
        let scoped = RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")

        #expect(scoped.rawValue == "fe80::1%eth0")
        #expect(RFC_4007.IPv6.ScopedAddress(rawValue: "fe80::1%eth0") == scoped)
        #expect(RFC_4007.IPv6.ScopedAddress(rawValue: "not an address") == nil)
    }
}
