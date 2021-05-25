// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DunneAudioKit",
    platforms: [
        .macOS(.v10_14), .iOS(.v13), .tvOS(.v13)
    ],
    products: [
        // Products define the executables and libraries a package produces, and make them visible to other packages.
        .library(
            name: "DunneAudioKit",
            targets: ["DunneAudioKit"]),
    ],
    dependencies: [
        // Dependencies declare other packages that this package depends on.
        .package(url: "https://github.com/AudioKit/KissFFT", .branch("main")),
        .package(url: "https://github.com/AudioKit/AudioKit", .branch("develop")),

    ],
    targets: [
        // Targets are the basic building blocks of a package. A target can define a module or a test suite.
        // Targets can depend on other targets in this package, and on products in packages this package depends on.
        .target(
            name: "DunneAudioKit",
            dependencies: ["AudioKit", "CDunneAudioKit"]),
        .target(
            name: "CDunneAudioKit",
            dependencies: ["AudioKit", "KissFFT"],
            exclude: [
                "AudioKitCore/Modulated Delay/README.md",
                "AudioKitCore/Sampler/Wavpack/license.txt",
                "AudioKitCore/Common/README.md",
                "AudioKitCore/Common/Envelope.hpp",
                "AudioKitCore/Sampler/README.md",
                "AudioKitCore/README.md",
            ],
            publicHeadersPath: "include",
            cxxSettings: [
                .headerSearchPath("AudioKitCore/Common"),
                .headerSearchPath(".")]),
        .testTarget(
            name: "DunneAudioKitTests",
            dependencies: ["DunneAudioKit"],
            resources: [.copy("TestResources/")]),
    ],
    cxxLanguageStandard: .cxx14
)
