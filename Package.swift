// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "MKSwiftUILibrary",
    platforms: [.iOS(.v15)], // 保持 iOS 15
    products: [
        .library(
            name: "MKSwiftUILibrary",
            targets: ["MKSwiftUILibrary"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/MOKO-iOS-Base-Library/MKBaseSwiftModule.git", from: "1.0.20"),
    ],
    targets: [
        .target(
            name: "MKSwiftUILibrary",
            dependencies: [
                .product(name: "MKBaseSwiftModule", package: "MKBaseSwiftModule"),
            ],
            path: "Sources",
            resources: [.process("Assets")],
            swiftSettings: [
                .define("DEBUG", .when(configuration: .debug)),
                .define("IOS15_OR_LATER"),
            ]
        ),
        .testTarget(
            name: "MKSwiftUILibraryTests",
            dependencies: ["MKSwiftUILibrary"]
        )
    ]
)
