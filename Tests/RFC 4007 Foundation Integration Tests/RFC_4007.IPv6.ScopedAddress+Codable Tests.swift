import Foundation
import RFC_4007
import RFC_4007_Foundation_Integration
import RFC_4291
import Testing

@Suite
struct `RFC_4007.IPv6.ScopedAddress+Codable Tests` {

    @Test
    func `a scoped address codes as its address and zone`() async throws {
        let scoped = RFC_4007.IPv6.ScopedAddress(
            address: RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1),
            zone: "eth0"
        )

        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        let encoded = try encoder.encode(scoped)

        #expect(String(decoding: encoded, as: UTF8.self) == #"{"address":"fe80::1","zone":"eth0"}"#)
        #expect(try JSONDecoder().decode(RFC_4007.IPv6.ScopedAddress.self, from: encoded) == scoped)
    }

    @Test
    func `a scoped address without a zone omits the zone key`() async throws {
        let scoped = RFC_4007.IPv6.ScopedAddress(
            address: RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
        )

        let encoded = try JSONEncoder().encode(scoped)

        #expect(String(decoding: encoded, as: UTF8.self) == #"{"address":"2001:db8::1"}"#)
        #expect(try JSONDecoder().decode(RFC_4007.IPv6.ScopedAddress.self, from: encoded) == scoped)
    }

    @Test
    func `a malformed address fails to decode`() async throws {
        let encoded = Data(#"{"address":"not an address","zone":"eth0"}"#.utf8)

        #expect(throws: DecodingError.self) {
            try JSONDecoder().decode(RFC_4007.IPv6.ScopedAddress.self, from: encoded)
        }
    }
}
