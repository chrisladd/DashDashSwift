// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "Flag",
    products: [
        .library(
            name: "Flag",
            targets: ["Flag"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "Flag",
            dependencies: []),
        .testTarget(
            name: "FlagTests",
            dependencies: ["Flag"]),
    ]
)
