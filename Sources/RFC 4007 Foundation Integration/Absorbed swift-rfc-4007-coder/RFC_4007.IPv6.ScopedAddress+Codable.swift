#if Coder
    import ASCII
    import Byte
    public import RFC_4007
    import RFC_4291
    import RFC_4291
    import RFC_5952
    import Serializer

    extension RFC_4007.IPv6.ScopedAddress: Encodable, Decodable {

        private enum CodingKeys: String, CodingKey {
            case address
            case zone
        }

        public init(from decoder: any Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            let text = try container.decode(String.self, forKey: .address)
            let address: RFC_4291.IPv6.Address
            do throws(RFC_4291.IPv6.Address.Error) {
                address = try RFC_4291.IPv6.Address(ascii: text.utf8.map(Byte.init(bitPattern:)))
            } catch {
                throw DecodingError.dataCorruptedError(
                    forKey: .address,
                    in: container,
                    debugDescription: "\(error)"
                )
            }
            let zone: RFC_4007.IPv6.ScopedAddress.Zone?
            if let text = try container.decodeIfPresent(String.self, forKey: .zone) {
                do throws(RFC_4007.IPv6.ScopedAddress.Zone.Error) {
                    zone = try RFC_4007.IPv6.ScopedAddress.Zone(text)
                } catch {
                    throw DecodingError.dataCorruptedError(
                        forKey: .zone,
                        in: container,
                        debugDescription: "\(error)"
                    )
                }
            } else {
                zone = nil
            }
            self.init(address: address, zone: zone)
        }

        public func encode(to encoder: any Encoder) throws {
            var codes: [ASCII.Code] = []
            RFC_4291.IPv6.Address.Text.Canonical().serialize(address, into: &codes)

            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(String(decoding: codes.map(\.underlying), as: UTF8.self), forKey: .address)
            try container.encodeIfPresent(zone?.rawValue, forKey: .zone)
        }
    }
#endif
