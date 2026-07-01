// swift-tools-version: 6.2
import PackageDescription

extension String {
    static let rfc4007 = "RFC 4007"
    var tests: Self { "\(self) Tests" }
}

extension Target.Dependency {
    static let rfc4007 = Self.target(name: .rfc4007)
    static let rfc5952 = Self.product(name: "RFC 5952", package: "swift-rfc-5952")
    static let standards = Self.product(name: "Standard Library Extensions", package: "swift-standard-library-extensions")
    static let incits41986 = Self.product(name: "ASCII Serializer Primitives", package: "swift-ascii-serializer-primitives")
    static let asciiParser = Self.product(name: "Parseable ASCII Primitives", package: "swift-ascii-parser-primitives")
}

let package = Package(
    name: "swift-rfc-4007",
    platforms: [
        .macOS(.v26),
        .iOS(.v26),
        .tvOS(.v26),
        .watchOS(.v26)
    ],
    products: [
        .library(name: "RFC 4007", targets: ["RFC 4007"])
    ],
    dependencies: [
        .package(url: "https://github.com/swift-ietf/swift-rfc-5952.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-standard-library-extensions.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ascii-serializer-primitives.git", branch: "main"),
        .package(url: "https://github.com/swift-primitives/swift-ascii-parser-primitives.git", branch: "main")
    ],
    targets: [
        .target(
            name: "RFC 4007",
            dependencies: [.rfc5952, .standards, .incits41986, .asciiParser]
        ),
        .testTarget(
            name: "RFC 4007 Tests",
            dependencies: [
                "RFC 4007",
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
        .enableExperimentalFeature("SuppressedAssociatedTypes"),
    ]

    let package: [SwiftSetting] = []

    target.swiftSettings = (target.swiftSettings ?? []) + ecosystem + package
}
