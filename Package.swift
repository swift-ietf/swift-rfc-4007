// swift-tools-version: 6.4
import PackageDescription

let package = Package(
    name: "swift-rfc-4007",
    platforms: [
        .macOS(.v27),
        .iOS(.v27),
        .tvOS(.v27),
        .watchOS(.v27),
    ],
    products: [
        .library(name: "RFC 4007", targets: ["RFC 4007"]),
        .library(
            name: "RFC 4007 Foundation Integration",
            targets: ["RFC 4007 Foundation Integration"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-4291.git", branch: "main"),
        .package(url: "https://github.com/swift-ietf/swift-rfc-5952.git", branch: "main"),
    ],
    targets: [
        .target(
            name: "RFC 4007",
            dependencies: [
                .product(name: "RFC 4291", package: "swift-rfc-4291")
            ]
        ),
        .target(
            name: "RFC 4007 Foundation Integration",
            dependencies: [
                .target(name: "RFC 4007"),
                .product(name: "RFC 4291", package: "swift-rfc-4291"),
                .product(name: "RFC 5952", package: "swift-rfc-5952"),
            ]
        ),
        .testTarget(
            name: "RFC 4007 Foundation Integration Tests",
            dependencies: [
                .target(name: "RFC 4007"),
                .target(name: "RFC 4007 Foundation Integration"),
                .product(name: "RFC 4291", package: "swift-rfc-4291"),
            ]
        ),
        .testTarget(
            name: "RFC 4007 Tests",
            dependencies: [
                .target(name: "RFC 4007"),
                .product(name: "RFC 4291", package: "swift-rfc-4291"),
            ]
        ),
    ],
    swiftLanguageModes: [.v6]
)

for target in package.targets where ![.system, .binary, .plugin, .macro].contains(target.type) {
    let ecosystem: [SwiftSetting] = [
        .strictMemorySafety(),
        .enableUpcomingFeature("ExistentialAny"),
        .enableUpcomingFeature("InternalImportsByDefault"),
        .enableUpcomingFeature("MemberImportVisibility"),
        .enableUpcomingFeature("NonisolatedNonsendingByDefault"),
        .enableExperimentalFeature("Lifetimes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
