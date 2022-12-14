// swift-tools-version: 5.7
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
        name: "xenon_view_sdk",
        platforms: [
            .macOS(.v12), .iOS(.v11), .tvOS(.v15)
        ],
        products: [
            // Products define the executables and libraries a package produces, and make them visible to other packages.
            .library(
                    name: "xenon_view_sdk",
                    targets: ["xenon_view_sdk"]),
        ],
        dependencies: [
            // Dependencies declare other packages that this package depends on.
            // .package(url: /* package url */, from: "1.0.0"),
            .package(url: "https://github.com/Quick/Quick", revision: "be947fe35f2745650ef3aecf4f54d9de5811ab9f"),
            .package(url: "https://github.com/Quick/Nimble", from: "10.0.0"),
            .package(name: "Mockingbird", url: "https://github.com/birdrides/mockingbird", from: "0.20.0"),
            .package(url: "https://github.com/sindresorhus/ExceptionCatcher", from: "2.0.0"),
            .package(url: "https://github.com/SwiftyLab/AsyncObjects.git", from: "1.0.0"),
            .package(url: "https://github.com/SwiftyJSON/SwiftyJSON.git", from: "5.0.0"),
        ],
        targets: [
            // Targets are the basic building blocks of a package. A target can define a module or a test suite.
            // Targets can depend on other targets in this package, and on products in packages this package depends on.
            .target(
                    name: "xenon_view_sdk",
                    dependencies: ["ExceptionCatcher", "SwiftyJSON"]),
            .testTarget(
                    name: "xenon_view_sdkTests",
                    dependencies: ["xenon_view_sdk", "Quick", "Nimble", "Mockingbird", "AsyncObjects"],
                    resources: [.process("api/fetch/DigiCertTLSECCP384RootG5.crt")]),
        ]
)
