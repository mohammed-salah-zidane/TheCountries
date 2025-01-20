// swift-tools-version: 6.0
// The swift-tools-version declares the minimum version of Swift required to build this package.
import PackageDescription

let package = Package(
    name: "Presentation",
    platforms: [.iOS(.v16)],
    products: [
        // Products define the executables and libraries a package produces
        .library(
            name: "Presentation",
            type: .dynamic,
            targets: ["Presentation"]),
    ],
    dependencies: [
        // Add Core module dependency for domain models and protocols
        .package(path: "../Core"),
        // Add Data module dependency for repository implementations
        .package(path: "../Data")
    ],
    targets: [
        // Main target with dependencies on Core and Data
        .target(
            name: "Presentation",
            dependencies: [
                .product(name: "Core", package: "Core"),
                .product(name: "Data", package: "Data")
            ],
            path: "Sources"
        ),
        .testTarget(
            name: "PresentationTests",
            dependencies: ["Presentation"]
        ),
    ]
)
