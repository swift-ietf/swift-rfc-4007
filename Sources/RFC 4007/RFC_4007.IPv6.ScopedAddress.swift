// ===----------------------------------------------------------------------===//
//
// Copyright (c) 2025 Coen ten Thije Boonkkamp
// Licensed under Apache License v2.0
//
// See LICENSE.txt for license information
// See CONTRIBUTORS.txt for the list of project contributors
//
// SPDX-License-Identifier: Apache-2.0
//
// ===----------------------------------------------------------------------===//

// RFC_4007.IPv6.ScopedAddress.swift
// swift-rfc-4007
//
// IPv6 Scoped Address with Zone Identifier

public import ASCII_Serializer_Primitives
public import Parseable_ASCII_Primitives

extension RFC_4007.IPv6 {
    /// IPv6 Scoped Address (RFC 4007)
    ///
    /// An IPv6 address with an optional zone identifier for disambiguating
    /// non-global addresses.
    ///
    /// ## Zone Identifier Semantics (RFC 4007 Section 6)
    ///
    /// Zone identifiers are:
    /// - **Node-local**: Only meaningful on the local node
    /// - **Never transmitted**: MUST NOT appear in packets on the wire
    /// - **Display purposes**: For APIs, UIs, and configuration
    ///
    /// ## When Zone IDs Are Needed
    ///
    /// Zone identifiers are primarily used with:
    /// - **Link-local addresses** (fe80::/10): Required when multiple interfaces exist
    /// - **Site-local addresses** (deprecated): Needed for site disambiguation
    ///
    /// Global addresses typically don't need zone identifiers.
    ///
    /// ## Example
    ///
    /// ```swift
    /// // Link-local address on eth0
    /// let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
    /// let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "eth0")
    ///
    /// print(String(scoped))  // "fe80::1%eth0"
    ///
    /// // Global address (no zone needed)
    /// let global = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
    /// let unscoped = RFC_4007.IPv6.ScopedAddress(address: global, zone: nil)
    ///
    /// print(String(unscoped))  // "2001:db8::1"
    /// ```
    public struct ScopedAddress: Hashable, Sendable, Codable {
        /// The IPv6 address
        public let address: RFC_4291.IPv6.Address

        /// The zone identifier (e.g., "eth0", "1")
        ///
        /// Per RFC 4007 Section 11: The zone ID is a string that identifies
        /// the zone. It can be an interface name or numeric ID.
        ///
        /// `nil` indicates the address doesn't require a zone identifier
        /// (e.g., global addresses).
        public let zone: String?

        /// Creates value WITHOUT validation
        ///
        /// **Warning**: Bypasses RFC validation. Only use for:
        /// - Static constants
        /// - Pre-validated values
        /// - Internal construction after validation
        init(__unchecked: Void, address: RFC_4291.IPv6.Address, zone: String?) {
            self.address = address
            self.zone = zone
        }

        /// Creates a scoped IPv6 address
        ///
        /// - Parameters:
        ///   - address: The IPv6 address
        ///   - zone: Optional zone identifier for non-global addresses
        public init<S: StringProtocol>(
            address: RFC_4291.IPv6.Address,
            zone: S?
        ) {
            self.address = address
            self.zone = zone.map { String($0) }
        }

        /// Creates a scoped IPv6 address
        ///
        /// - Parameters:
        ///   - address: The IPv6 address
        ///   - zone: Optional zone identifier for non-global addresses
        public init(
            address: RFC_4291.IPv6.Address,
            zone: String? = nil
        ) {
            self.address = address
            self.zone = zone
        }
    }
}

// MARK: - Convenience Properties

extension RFC_4007.IPv6.ScopedAddress {
    /// Whether this address requires a zone identifier
    ///
    /// Returns `true` for addresses where a zone identifier is meaningful:
    /// - Link-local addresses (fe80::/10)
    /// - Unique local addresses (fc00::/7)
    ///
    /// Global addresses and loopback don't require zone identifiers.
    public var requiresZone: Bool {
        address.is.linkLocal || address.is.uniqueLocal
    }

    /// Whether this is a properly scoped address
    ///
    /// Returns `true` if:
    /// - The address requires a zone and has one, OR
    /// - The address doesn't require a zone
    public var isProperlyScoped: Bool {
        if requiresZone {
            return zone != nil
        }
        return true
    }
}

// MARK: - String Transformation

extension String {
    /// Creates the text representation of a scoped IPv6 address
    ///
    /// This is a convenience transformation that composes through the canonical
    /// byte representation:
    /// ```
    /// IPv6.ScopedAddress → [Byte] (ASCII) → String (UTF-8 interpretation)
    /// ```
    ///
    /// This follows RFC 4007 Section 11.7 format:
    /// ```
    /// <address>%<zone_id>
    /// ```
    ///
    /// If no zone identifier is present, returns just the address in RFC 5952
    /// canonical format.
    ///
    /// ## Category Theory
    ///
    /// This is functor composition - the String transformation is derived from
    /// the more universal [Byte] transformation. ASCII is a subset of UTF-8,
    /// so this conversion is always safe.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // With zone
    /// let linkLocal = RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1)
    /// let scoped = RFC_4007.IPv6.ScopedAddress(address: linkLocal, zone: "eth0")
    /// String(scoped)  // "fe80::1%eth0"
    ///
    /// // Without zone
    /// let global = RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1)
    /// let unscoped = RFC_4007.IPv6.ScopedAddress(address: global, zone: nil)
    /// String(unscoped)  // "2001:db8::1"
    /// ```
    ///
    /// - Parameter scopedAddress: The scoped IPv6 address to represent
    public init(
        _ scopedAddress: RFC_4007.IPv6.ScopedAddress
    ) {
        // Materialize the RFC 4007 §11.7 text form via the [FAM-012]
        // `ASCII.Serializable` verb (through `.asciiCodes`); ASCII ⊂ UTF-8, so
        // decoding the ASCII codes as UTF-8 is always valid.
        self.init(decoding: scopedAddress.asciiCodes.map(\.underlying), as: UTF8.self)
    }
}

// MARK: - ASCII.Serializable ([FAM-012] text-only sibling — RFC 4007 §6: zone never on wire)

extension RFC_4007.IPv6.ScopedAddress: ASCII.Serializable {
    /// Serializes the scoped address as RFC 4007 §11.7 text `<address>%<zone_id>`.
    ///
    /// [FAM-012] text-only sibling. A scoped address has **no wire form**: per RFC
    /// 4007 §6 the zone identifier is node-local and MUST NOT be sent on the wire,
    /// so `ScopedAddress` conforms `ASCII.Serializable` ONLY — there is no
    /// `Binary.Serializable` peer (a wire verb could only drop the zone, which is
    /// redundant with the address's own wire form, or transmit it, which the spec
    /// forbids; neither is a valid distinct scoped-address binary form).
    ///
    /// Clause-9 composition: the address component composes
    /// ``RFC_4291/IPv6/Address``'s same-format (`ASCII.Code`) verb directly into
    /// the sink — the RFC 5952 canonical text form served by swift-rfc-5952 — then
    /// appends the `%` separator and the zone characters.
    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ scopedAddress: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {
        // Address component: the RFC 5952 canonical ASCII verb, composed directly
        // into the ASCII.Code sink (NOT via a [Byte] detour) — clause-9.
        RFC_4291.IPv6.Address.serialize(scopedAddress.address, into: &buffer)
        if let zone = scopedAddress.zone {
            // RFC 4007 §11.7: Format is <address>%<zone_id>
            buffer.append(ASCII.Code.percentSign)
            for byte in zone.utf8 { buffer.append(ASCII.Code(byte)) }
        }
    }
}

// MARK: - ASCII.Parseable ([FAM-012] parse — free-standing init)

extension RFC_4007.IPv6.ScopedAddress: ASCII.Parseable {

    /// Creates a scoped IPv6 address from ASCII bytes (AUTHORITATIVE IMPLEMENTATION)
    ///
    /// Parses RFC 4007 format: `<address>%<zone_id>`. The address component is
    /// parsed by ``RFC_4291/IPv6/Address``'s `init(ascii:)` (RFC 4291 §2.2 text
    /// grammar, via swift-rfc-5952); the zone identifier is the remaining UTF-8
    /// slice after the `%` separator.
    ///
    /// ## Examples
    ///
    /// ```swift
    /// // With zone identifier
    /// let scoped1 = try RFC_4007.IPv6.ScopedAddress(ascii: Array<Byte>("fe80::1%eth0".utf8))
    ///
    /// // Without zone identifier
    /// let scoped2 = try RFC_4007.IPv6.ScopedAddress(ascii: Array<Byte>("2001:db8::1".utf8))
    /// ```
    public init<Bytes: Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard !bytes.isEmpty else { throw Error.empty }

        // Find the '%' separator
        if let percentIndex = bytes.firstIndex(of: ASCII.Code.percentSign.byte) {
            // Split address and zone
            let addressBytes = bytes[..<percentIndex]
            let zoneBytes = bytes[bytes.index(after: percentIndex)...]

            guard !addressBytes.isEmpty else { throw Error.missingAddress }
            guard !zoneBytes.isEmpty else { throw Error.missingZone }

            // Parse address using RFC 4291 §2.2 text grammar
            let address: RFC_4291.IPv6.Address
            do {
                address = try RFC_4291.IPv6.Address(ascii: addressBytes)
            } catch {
                throw Error.invalidAddress(error)
            }

            // Zone is just a string - decode the remaining bytes as UTF-8
            let zone = String(decoding: zoneBytes, as: UTF8.self)

            self.init(__unchecked: (), address: address, zone: zone)
        } else {
            // No zone identifier - just an address
            let address: RFC_4291.IPv6.Address
            do {
                address = try RFC_4291.IPv6.Address(ascii: bytes)
            } catch {
                throw Error.invalidAddress(error)
            }

            self.init(__unchecked: (), address: address, zone: nil)
        }
    }
}

// MARK: - RawRepresentable

extension RFC_4007.IPv6.ScopedAddress: Swift.RawRepresentable {
    /// The canonical RFC 4007 §11.7 `<address>%<zone_id>` string form.
    ///
    /// Re-provides `Swift.RawRepresentable` directly — the retired deprecated
    /// ASCII serialization attachments no longer synthesize it.
    public var rawValue: String { description }

    /// Creates a scoped address by parsing `rawValue`, or `nil` if it is malformed.
    public init?(rawValue: String) {
        try? self.init(ascii: rawValue.utf8.map { Byte($0) })
    }
}

// MARK: - CustomStringConvertible

extension RFC_4007.IPv6.ScopedAddress: CustomStringConvertible {
    /// The RFC 4007 §11.7 `<address>%<zone_id>` text form — the same grammar the
    /// `ASCII.Serializable` verb emits (routed through the `String` transformation).
    public var description: String {
        String(self)
    }
}
