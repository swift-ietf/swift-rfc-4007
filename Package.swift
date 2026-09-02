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
        .library(name: "RFC 4007", targets: ["RFC 4007"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-5952.git", branch: "main"),
        .package(
            url: "https://github.com/swift-atoms/swift-standard-library-extensions.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii-serializer.git",
            branch: "main"
        ),
        .package(
            url: "https://github.com/swift-molecules/swift-ascii-parser.git",
            branch: "main"
        ),
    ],
    targets: [
        .target(
            name: "RFC 4007",
            dependencies: [
                .product(name: "RFC 5952", package: "swift-rfc-5952"),
                .product(
                    name: "Standard Library Extensions",
                    package: "swift-standard-library-extensions"
                ),
                .product(
                    name: "ASCII Serializer",
                    package: "swift-ascii-serializer"
                ),
                .product(
                    name: "Parseable ASCII",
                    package: "swift-ascii-parser"
                )
            ]
        ),
        .testTarget(
            name: "RFC 4007 Tests",
            dependencies: [
                .target(name: "RFC 4007")
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
