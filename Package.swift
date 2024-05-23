// swift-tools-version: 5.8
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "AmazonLocationiOSTrackingSDK",
    platforms: [.iOS(.v13)],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "AmazonLocationiOSTrackingSDK",
            targets: ["AmazonLocationiOSTrackingSDK"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/makeen-project/amazon-location-mobile-auth-sdk-ios.git", branch: "ALMS-134_AmazonHttpClient"),
        .package(url: "https://github.com/aws-amplify/aws-sdk-ios-spm.git", .upToNextMajor(from: "2.0.0"))
    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "AmazonLocationiOSTrackingSDK",
            dependencies: [
                .product(name: "AmazonLocationiOSAuthSDK", package: "amazon-location-mobile-auth-sdk-ios"),
                .product(name: "AWSLocationXCF", package: "aws-sdk-ios-spm"),
                .product(name: "AWSMobileClientXCF", package: "aws-sdk-ios-spm"),
            ],
            path: "Sources"),
        .testTarget(
            name: "AWSTrackingSDKiOSTests",
            dependencies: ["AmazonLocationiOSTrackingSDK"],
            resources: [
                .process("TestConfig.plist")
            ]),
    ]
)
