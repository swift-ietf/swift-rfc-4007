# swift-rfc-4007

Domain model for RFC 4007, the IPv6 Scoped Address Architecture: `RFC_4007.IPv6.ScopedAddress` pairs an `RFC_4291.IPv6.Address` with an optional zone identifier and answers whether the address's scope requires a zone (`requiresZone`) and whether it carries one when it must (`isProperlyScoped`); `ScopedAddress.Error` names the ways a scoped address can be malformed. The `RFC 4007 Foundation Integration` product bridges `ScopedAddress` to `Codable` as its address and zone. Parsing and serialization of the `address%zone` text form (`ASCII.Parseable`, `ASCII.Serializable`, the nested `Coder` and the string conformances) live in [swift-rfc-4007-coder](https://github.com/swift-ietf/swift-rfc-4007-coder).

```swift
import RFC_4007
import RFC_4291

let scoped = RFC_4007.IPv6.ScopedAddress(
    address: RFC_4291.IPv6.Address(0xfe80, 0, 0, 0, 0, 0, 0, 1),
    zone: "eth0"
)
scoped.requiresZone                                  // true
scoped.isProperlyScoped                              // true

let global = RFC_4007.IPv6.ScopedAddress(address: RFC_4291.IPv6.Address(0x2001, 0x0db8, 0, 0, 0, 0, 0, 1))
global.requiresZone                                  // false
```

Apache 2.0, see [LICENSE.md](LICENSE.md).
