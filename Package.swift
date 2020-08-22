// swift-tools-version:5.3

import PackageDescription

let package = Package(
    name: "VaporDog",
    platforms: [
       .macOS(.v10_15)
    ],
    products: [
        .library(
            name: "VaporDog",
            targets: ["VaporDog"]),
    ],
    dependencies: [
        .package(url: "https://github.com/vapor/vapor.git", from: "4.0.0"),
    ],
    targets: [
        .target(
            name: "VaporDog",
            dependencies: [
                .product(name: "Vapor", package: "vapor")
            ]),
        .testTarget(
            name: "VaporDogTests",
            dependencies: ["VaporDog"]),
    ]
)
