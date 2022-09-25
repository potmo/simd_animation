// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "simd_animation",
    platforms: [.macOS(.v10_15)], 
    products: [
        .executable(name: "simd_animation_example", targets: ["simd_animation_example"]),
        .library(name: "simd_animation", targets: ["simd_animation"])

    ],
    dependencies: [],
    targets: [
        .target(name: "simd_animation"),
        .executableTarget(
            name: "simd_animation_example",
            dependencies: ["simd_animation"])
    ]
)
