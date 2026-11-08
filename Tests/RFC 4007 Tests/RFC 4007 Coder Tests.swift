#if Coder
    import ASCII
    import Byte
    import Coder
    import Cursor
    import Parser
    import RFC_4007
    import RFC_4291
    import Serializer
    import Testing

extension `RFC 4007 Coder Tests`.`RFC 4007 Coder Tests` {
        @Suite
        struct `RFC 4007 Coder Tests` {
        }
}

    extension `RFC 4007 Coder Tests`.`RFC 4007 Coder Tests` {
        @Suite struct `Coder Tests` {}

        @Suite struct `ASCII Tests` {}

        @Suite struct `Text Tests` {}
    }

    extension `RFC 4007 Coder Tests`.`RFC 4007 Coder Tests`.`Coder Tests` {

        @Test
        func `reads an address with a zone and stops at the delimiter`() throws {
            var input: ArraySlice<Byte> = "fe80::1%eth0]/path"
            let scoped = try RFC_4007.IPv6.ScopedAddress.coder.parse(&input)
            #expect(scoped.address == RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1))
            #expect(scoped.zone == "eth0")
            #expect(input.first == Byte(bitPattern: 0x5D))
        }

        @Test
        func `reads an address without a zone`() throws {
            var input: ArraySlice<Byte> = "2001:db8::1 rest"
            let scoped = try RFC_4007.IPv6.ScopedAddress.coder.parse(&input)
            #expect(scoped.address == RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1))
            #expect(scoped.zone == nil)
            #expect(input.first == Byte(bitPattern: 0x20))
        }

        @Test
        func `rejects a missing zone and restores the cursor`() {
            var input: ArraySlice<Byte> = "fe80::1%"
            #expect(throws: RFC_4007.IPv6.ScopedAddress.Error.missingZone) {
                try RFC_4007.IPv6.ScopedAddress.coder.parse(&input)
            }
            #expect(input.count == 8)
        }

        @Test
        func `rejects a missing address`() {
            var input: ArraySlice<Byte> = "%eth0"
            #expect(throws: RFC_4007.IPv6.ScopedAddress.Error.missingAddress) {
                try RFC_4007.IPv6.ScopedAddress.coder.parse(&input)
            }
        }

        @Test
        func `rejects empty input`() {
            var input: ArraySlice<Byte> = ""
            #expect(throws: RFC_4007.IPv6.ScopedAddress.Error.empty) {
                try RFC_4007.IPv6.ScopedAddress.coder.parse(&input)
            }
        }

        @Test
        func `rejects a malformed address`() {
            var input: ArraySlice<Byte> = "fe80:::1%eth0"
            #expect(throws: RFC_4007.IPv6.ScopedAddress.Error.self) {
                try RFC_4007.IPv6.ScopedAddress.coder.parse(&input)
            }
        }

        @Test
        func `round-trips through the canonical form`() throws {
            let scoped = RFC_4007.IPv6.ScopedAddress(
                address: RFC_4291.IPv6.Address(0xfe80, 0, 0, 0x0200, 0x5eff, 0xfe00, 0x0001, 0),
                zone: "eth1"
            )
            var bytes: [Byte] = []
            try RFC_4007.IPv6.ScopedAddress.coder.serialize(scoped, into: &bytes)
            var encoded = bytes[...]
            #expect(encoded == "fe80::200:5eff:fe00:1:0%eth1")
            #expect(try RFC_4007.IPv6.ScopedAddress.coder.parse(&encoded) == scoped)
            #expect(encoded.isEmpty)
        }
    }

    extension `RFC 4007 Coder Tests`.`RFC 4007 Coder Tests`.`ASCII Tests` {

        @Test
        func `parses bytes with a zone`() throws {
            let scoped = try RFC_4007.IPv6.ScopedAddress(ascii: "fe80::1%eth0" as [Byte])
            #expect(scoped.address == RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1))
            #expect(scoped.zone == "eth0")
        }

        @Test
        func `parses bytes without a zone`() throws {
            let scoped = try RFC_4007.IPv6.ScopedAddress(ascii: "2001:db8::1" as [Byte])
            #expect(scoped.address == RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1))
            #expect(scoped.zone == nil)
        }

        @Test
        func `serializes the canonical address and the zone after a percent sign`() {
            let scoped = RFC_4007.IPv6.ScopedAddress(
                address: RFC_4291.IPv6.Address(0xff02, 0, 0, 0, 0, 0, 0, 1),
                zone: "eth0"
            )
            #expect(scoped.serialized == "ff02::1%eth0")
        }

        @Test
        func `golden texts survive parse, serialize and parse again`() throws {
            let golden = [
                "fe80::1%eth0",
                "fe80::1%1",
                "2001:db8::1",
                "ff02::1%eth0",
                "fe80::200:5eff:fe00:1%eth1",
                "::",
            ]
            for text in golden {
                let parsed = try RFC_4007.IPv6.ScopedAddress(ascii: [Byte](utf8: text))
                #expect(String(parsed) == text)
                #expect(try RFC_4007.IPv6.ScopedAddress(ascii: parsed.serialized) == parsed)
            }
        }

        @Test
        func `malformed inputs throw`() {
            #expect(throws: RFC_4007.IPv6.ScopedAddress.Error.empty) {
                try RFC_4007.IPv6.ScopedAddress(ascii: "" as [Byte])
            }
            #expect(throws: RFC_4007.IPv6.ScopedAddress.Error.missingZone) {
                try RFC_4007.IPv6.ScopedAddress(ascii: "fe80::1%" as [Byte])
            }
            #expect(throws: RFC_4007.IPv6.ScopedAddress.Error.missingAddress) {
                try RFC_4007.IPv6.ScopedAddress(ascii: "%eth0" as [Byte])
            }
        }
    }

    extension `RFC 4007 Coder Tests`.`RFC 4007 Coder Tests`.`Text Tests` {

        @Test
        func `a link-local address with a zone reads as RFC 4007 section 11.7 text`() {
            let scoped = RFC_4007.IPv6.ScopedAddress(
                address: RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1),
                zone: "eth0"
            )
            #expect(String(scoped) == "fe80::1%eth0")
            #expect(scoped.description == "fe80::1%eth0")
        }

        @Test
        func `a numeric zone reads as text`() {
            let scoped = RFC_4007.IPv6.ScopedAddress(
                address: RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1),
                zone: "1"
            )
            #expect(String(scoped) == "fe80::1%1")
        }

        @Test
        func `a global address without a zone has no percent sign`() {
            let scoped = RFC_4007.IPv6.ScopedAddress(address: RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1))
            #expect(String(scoped) == "2001:db8::1")
        }

        @Test
        func `a global address with a zone still carries the zone`() {
            let scoped = RFC_4007.IPv6.ScopedAddress(
                address: RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1),
                zone: "eth0"
            )
            #expect(String(scoped) == "2001:db8::1%eth0")
        }

        @Test
        func `the unspecified address reads as two colons`() {
            let scoped = RFC_4007.IPv6.ScopedAddress(address: RFC_4291.IPv6.Address.unspecified)
            #expect(String(scoped) == "::")
        }

        @Test
        func `the same address on two interfaces reads differently`() {
            let address = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0x0200, 0x5eff, 0xfe00, 0x0001)
            #expect(String(RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth0")) == "fe80::200:5eff:fe00:1%eth0")
            #expect(String(RFC_4007.IPv6.ScopedAddress(address: address, zone: "eth1")) == "fe80::200:5eff:fe00:1%eth1")
        }

        @Test
        func `a raw value round-trips through the canonical text`() {
            let scoped = RFC_4007.IPv6.ScopedAddress(
                address: RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1),
                zone: "eth0"
            )
            #expect(scoped.rawValue == "fe80::1%eth0")
            #expect(RFC_4007.IPv6.ScopedAddress(rawValue: "fe80::1%eth0") == scoped)
            #expect(RFC_4007.IPv6.ScopedAddress(rawValue: "not an address") == nil)
        }

        @Test
        func `a lossless string conversion round-trips`() {
            let scoped = RFC_4007.IPv6.ScopedAddress(
                address: RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1),
                zone: "eth0"
            )
            #expect(RFC_4007.IPv6.ScopedAddress("fe80::1%eth0") == scoped)
            #expect(RFC_4007.IPv6.ScopedAddress("fe80::1%") == nil)
        }
    }
#endif
