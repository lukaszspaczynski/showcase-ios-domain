// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "ShowcaseDomain",
    platforms: [.iOS(.v13), .macOS(.v10_11)],
    products: [
        .library(name: "ShowcaseDomain", targets: ["ShowcaseDomain"]),
        .library(name: "ShowcaseDomainMocks", targets: ["ShowcaseDomainMocks"])
    ],
    dependencies: [
        .package(url: "https://github.com/ReactiveX/RxSwift.git", .upToNextMajor(from: "6.2.0")),
        .package(url: "https://github.com/Quick/Nimble.git", .upToNextMajor(from: "9.2.1")),
        .package(name: "SnapshotTesting",
                 url: "https://github.com/pointfreeco/swift-snapshot-testing.git",
                 .upToNextMajor(from: "1.9.0")),
        .package(name: "ShowcaseExtensions",
                 url: "https://github.com/lukaszspaczynski/showcase-ios-extensions.git",
                 .upToNextMajor(from: "1.0.2")),
        .package(name: "ShowcaseData",
                 url: "https://github.com/lukaszspaczynski/showcase-ios-data.git",
                 .upToNextMajor(from: "1.0.1")),
        .package(url: "https://github.com/RxSwiftCommunity/RxSwiftExt.git",
                 .upToNextMajor(from: "6.1.0")),
        .package(url: "https://github.com/RxSwiftCommunity/Action.git",
                 .upToNextMajor(from: "5.0.0"))
    ],
    targets: [
        .target(
            name: "ShowcaseDomain",
            dependencies: [
                .product(name: "RxSwift", package: "RxSwift"),
                .product(name: "RxCocoa", package: "RxSwift"),
                .product(name: "ShowcaseData", package: "ShowcaseData"),
                "ShowcaseExtensions",
                "RxSwiftExt",
                "Action"]),
        .target(
            name: "ShowcaseDomainMocks",
            dependencies: [
                .target(name: "ShowcaseDomain"),
                .product(name: "ShowcaseDataMocks", package: "ShowcaseData")
            ]),
        .testTarget(
            name: "ShowcaseDomainTests",
            dependencies: [
                .target(name: "ShowcaseDomain"),
                .target(name: "ShowcaseDomainMocks"),
                .product(name: "RxBlocking", package: "RxSwift"),
                .product(name: "RxTest", package: "RxSwift"),
                "Nimble",
                "SnapshotTesting"])
    ]
)

