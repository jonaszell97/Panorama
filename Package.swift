// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Panorama",
    platforms: [
        .iOS(.v14),
        .macOS(.v11),
    ],
    products: [
        .library(
            name: "Panorama",
            targets: ["Panorama"]),
    ],
    dependencies: [
        .package(url: "https://github.com/jonaszell97/Toolbox", from: "0.1.0"),
    ],
    targets: [
        .target(
            name: "Panorama",
            dependencies: ["Toolbox"]),
        .testTarget(
            name: "PanoramaTests",
            dependencies: ["Panorama", "Toolbox"]),
    ]
)
