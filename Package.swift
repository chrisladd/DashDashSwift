// swift-tools-version:5.1

import PackageDescription

let package = Package(
    name: "DashDashSwift",
    products: [
        .library(
            name: "DashDashSwift",
            targets: ["DashDashSwift"]),
    ],
    dependencies: [],
    targets: [
        .target(
            name: "DashDashSwift",
            dependencies: []),
        .testTarget(
            name: "DashDashSwiftTests",
            dependencies: ["DashDashSwift"]),
    ]
)
