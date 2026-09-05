public import RFC_4007
import RFC_4291
import RFC_5952

extension RFC_4007.IPv6.ScopedAddress: Encodable, Decodable {

    private enum CodingKeys: String, CodingKey {
        case address
        case zone
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.init(
            address: try container.decode(RFC_4291.IPv6.Address.self, forKey: .address),
            zone: try container.decodeIfPresent(String.self, forKey: .zone)
        )
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(address, forKey: .address)
        try container.encodeIfPresent(zone, forKey: .zone)
    }
}
