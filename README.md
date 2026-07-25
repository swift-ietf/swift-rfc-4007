# swift-rfc-4007

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

IPv6 scoped-address zone identifiers and scope semantics of RFC 4007.

## Standard Reference

- **RFC**: 4007
- **Title**: IPv6 Scoped Address Architecture

## Installation

Add the package to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/swift-ietf/swift-rfc-4007.git", from: "0.1.6")
]
```

Add the product to a target that needs it:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "RFC 4007", package: "swift-rfc-4007")
    ]
)
```

## License

Apache 2.0. See [LICENSE.md](LICENSE.md).
