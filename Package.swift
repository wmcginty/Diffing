// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "Diffing",
    platforms: [.iOS(.v10), .tvOS(.v10), .macOS(.v10_12)],
    products: [
        .library(name: "Diffing", targets: ["Diffing"]),
    ],
    targets: [
        .target(name: "Diffing", dependencies: []),
        .testTarget(name: "DiffingTests", dependencies: ["Diffing"], path: "Tests"),
    ]
)
