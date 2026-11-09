# swift-rfc-4007

Use this package when an IPv6 address has to carry the zone it belongs to, such as `fe80::1%eth0`, and you need to read, write or check that text. Start from `RFC_4007.IPv6.ScopedAddress`. If you only need the address without a zone, use `RFC_4291.IPv6.Address` from swift-rfc-4291. For `Codable`, add the `RFC 4007 Foundation Integration` product.

## Laws

- The text form is the address, then `%` and the zone when there is one. The address is always written in its canonical RFC 5952 form.
- A zone is an `RFC_4007.IPv6.ScopedAddress.Zone`: one or more ASCII letters, digits, -, . or _, so every value serializes to text the coder reads back. Anything else fails with `RFC_4007.IPv6.ScopedAddress.Zone.Error`, and in text with `RFC_4007.IPv6.ScopedAddress.Error.invalidZone`. A zone is kept exactly as given and is not checked against any interface. Two values with the same address and different zones are different.
- Text that is empty, has nothing before the `%`, or nothing after it, fails.
- `RFC_4007.IPv6.ScopedAddress.Coder` reads only ASCII letters, digits, %, -, ., : and _, and stops at the first other byte, such as `]` or a space. When parsing fails, the input is left where it was.
- A zone is never required to build a value. `RFC_4007.IPv6.ScopedAddress.requiresZone` is true only for link-local addresses, and `RFC_4007.IPv6.ScopedAddress.isProperlyScoped` is false only when such an address has no zone. Unique local addresses (fc00::/7) have global scope (RFC 4193 section 3.3) and do not require one. A global address may still carry a zone, and keeps it.
- With `RFC 4007 Foundation Integration`, a value encodes as an object with the canonical `address` text and a `zone` key that is left out when there is no zone. An address or zone that doesn't parse fails to decode with a data-corrupted `DecodingError`.
