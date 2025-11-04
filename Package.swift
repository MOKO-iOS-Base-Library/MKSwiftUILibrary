// swift-tools-version: 6.1
import PackageDescription

let package = Package(
    name: "MKSwiftUILibrary",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "MKSwiftUILibrary",
            type: .dynamic,
            targets: ["MKSwiftUILibrary"]
        ),
    ],
    dependencies: [
        .package(url: "https://github.com/MOKO-iOS-Base-Library/MKBaseSwiftModule.git", from: "1.0.15"),
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
            ],
            linkerSettings: [
                .linkedLibrary("z"),
                .linkedLibrary("iconv"),
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit")
            ]
        ),
        .testTarget(
            name: "MKSwiftUILibraryTests",
            dependencies: ["MKSwiftUILibrary"]
        )
    ]
)
