// swift-tools-version: 5.6
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AuthSpoton",
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AuthSpoton",
            targets: ["AuthSpoton"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url:"https://github.com/openid/AppAuth-iOS.git", from: "1.0.0"),
        .package(url:"https://github.com/auth0/JWTDecode.swift", from: "2.6.0"),
        .package(url:"https://github.com/belozierov/SwiftCoroutine", from: "2.0.0")
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AuthSpoton",
            dependencies: [.product(name: "AppAuth", package: "AppAuth-iOS"),
                           .product(name: "JWTDecode", package: "JWTDecode.swift"),
                           .product(name: "SwiftCoroutine", package: "SwiftCoroutine")],
        path: "Sources"),
        .testTarget(
            name: "AuthSpotonTests",
            dependencies: ["AuthSpoton"]),
    ]
)
