public import ASCII_Serializer_Primitives
public import Parseable_ASCII_Primitives

extension RFC_4007.IPv6 {

    public struct ScopedAddress: Hashable, Sendable, Codable {

        public let address: RFC_4291.IPv6.Address

        public let zone: String?

        init(__unchecked: Void, address: RFC_4291.IPv6.Address, zone: String?) {
            self.address = address
            self.zone = zone
        }

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

extension String {

    public init(
        _ scopedAddress: RFC_4007.IPv6.ScopedAddress
    ) {

        self.init(decoding: scopedAddress.asciiCodes.map(\.underlying), as: UTF8.self)
    }
}

extension RFC_4007.IPv6.ScopedAddress: ASCII.Serializable {

    public static func serialize<Buffer: RangeReplaceableCollection>(
        _ scopedAddress: Self,
        into buffer: inout Buffer
    ) where Buffer.Element == ASCII.Code {

        RFC_4291.IPv6.Address.serialize(scopedAddress.address, into: &buffer)
        if let zone = scopedAddress.zone {

            buffer.append(ASCII.Code.percentSign)
            for byte in zone.utf8 { buffer.append(ASCII.Code(byte)) }
        }
    }
}

extension RFC_4007.IPv6.ScopedAddress: ASCII.Parseable {

    public init<Bytes: Swift.Collection>(ascii bytes: Bytes) throws(Error)
    where Bytes.Element == Byte {
        guard !bytes.isEmpty else { throw Error.empty }

        if let percentIndex = bytes.firstIndex(of: ASCII.Code.percentSign.byte) {

            let addressBytes = bytes[..<percentIndex]
            let zoneBytes = bytes[bytes.index(after: percentIndex)...]

            guard !addressBytes.isEmpty else { throw Error.missingAddress }
            guard !zoneBytes.isEmpty else { throw Error.missingZone }

            let address: RFC_4291.IPv6.Address
            do throws(RFC_4291.IPv6.Address.Error) {
                address = try RFC_4291.IPv6.Address(ascii: addressBytes)
            } catch {
                throw Error.invalidAddress(error)
            }

            let zone = String(decoding: zoneBytes, as: UTF8.self)

            self.init(__unchecked: (), address: address, zone: zone)
        } else {

            let address: RFC_4291.IPv6.Address
            do throws(RFC_4291.IPv6.Address.Error) {
                address = try RFC_4291.IPv6.Address(ascii: bytes)
            } catch {
                throw Error.invalidAddress(error)
            }

            self.init(__unchecked: (), address: address, zone: nil)
        }
    }
}

extension RFC_4007.IPv6.ScopedAddress: Swift.RawRepresentable {

    public var rawValue: String { description }

    public init?(rawValue: String) {
        do throws(Error) {
            try self.init(ascii: rawValue.utf8.map { Byte($0) })
        } catch {
            return nil
        }
    }
}

extension RFC_4007.IPv6.ScopedAddress: CustomStringConvertible {

    public var description: String {
        String(self)
    }
}
