#if Coder
    public import ASCII
    public import Binary
    public import Byte
    import RFC_4291
    import RFC_4291
    import RFC_5952
    import RFC_5952

    extension RFC_4007.IPv6.ScopedAddress: ASCII.Parseable {

        public init<Bytes: Swift::Collection>(ascii bytes: Bytes) throws(Error)
        where Bytes.Element == Byte {
            guard !bytes.isEmpty else { throw Error.empty }

            guard let percentIndex = bytes.firstIndex(of: ASCII.Code.percentSign.byte) else {
                do throws(RFC_4291.IPv6.Address.Error) {
                    self.init(address: try RFC_4291.IPv6.Address(ascii: bytes))
                } catch {
                    throw Error.invalidAddress(error)
                }
                return
            }

            let addressBytes = bytes[..<percentIndex]
            let zoneBytes = bytes[bytes.index(after: percentIndex)...]

            guard !addressBytes.isEmpty else { throw Error.missingAddress }
            guard !zoneBytes.isEmpty else { throw Error.missingZone }

            do throws(RFC_4291.IPv6.Address.Error) {
                self.init(
                    address: try RFC_4291.IPv6.Address(ascii: addressBytes),
                    zone: String(decoding: zoneBytes, as: UTF8.self)
                )
            } catch {
                throw Error.invalidAddress(error)
            }
        }
    }

    extension RFC_4007.IPv6.ScopedAddress: ASCII.Serializable, Binary.Serializable {

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ scopedAddress: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == ASCII.Code {
            var address: [ASCII.Code] = []
            RFC_4291.IPv6.Address.Text.Canonical().serialize(scopedAddress.address, into: &address)
            buffer.append(contentsOf: address)
            if let zone = scopedAddress.zone {
                buffer.append(ASCII.Code.percentSign)
                for byte in zone.utf8 { buffer.append(ASCII.Code(byte)) }
            }
        }

        public static func serialize<Buffer: RangeReplaceableCollection>(
            _ scopedAddress: Self,
            into buffer: inout Buffer
        ) where Buffer.Element == Byte {
            var codes: [ASCII.Code] = []
            Self.serialize(scopedAddress, into: &codes)
            buffer.append(contentsOf: codes.map(\.byte))
        }
    }
#endif
