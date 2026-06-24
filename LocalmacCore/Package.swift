// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "LocalmacCore",
    platforms: [.macOS(.v13)],
    products: [
        .library(name: "LocalmacCore", targets: ["LocalmacCore"]),
    ],
    targets: [
        .target(
            name: "LocalmacCore",
            path: "Sources/LocalmacCore"
        ),
        .testTarget(
            name: "LocalmacCoreTests",
            dependencies: ["LocalmacCore"],
            path: "Tests/LocalmacCoreTests"
        ),
    ]
)
