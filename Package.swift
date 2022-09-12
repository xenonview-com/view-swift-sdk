// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "xenon-view-sdk",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "xenon-view-sdk",
            targets: ["xenon-view-sdk"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        // .package(url: /* package url */, from: "1.0.0"),
        .package(url:"https://github.com/Quick/Quick.git", from: "5.0.1"),
        .package(url:"https://github.com/Quick/Nimble", from: "10.0.0"),
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "xenon-view-sdk",
            dependencies: []),
        .testTarget(
            name: "xenon-view-sdkTests",
            dependencies: ["xenon-view-sdk", "Quick", "Nimble"]),
    ]
)
