// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Networking",
    platforms: [.iOS(.v12)],
    products: [
        .library(
            name: "Networking",
            targets: ["Networking"])
    ],
    targets: [
        .target(
            name: "ObjcUtils",
            path: "Sources/ObjcUtils",
            cSettings: [.headerSearchPath("Include")]
        ),
        .target(
            name: "Networking",
            dependencies: ["ObjcUtils"],
            path: "Sources",
            exclude: ["ObjcUtils"],
            swiftSettings: [.define("OBJC_UTILS_IS_MODULE")]
        ),
        .testTarget(
            name: "NetworkingTests",
            dependencies: ["Networking"])
    ]
)
