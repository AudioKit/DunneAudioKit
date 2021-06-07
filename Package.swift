// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DunneAudioKit",
    platforms: [.macOS(.v10_14), .iOS(.v13), .tvOS(.v13)],
    products: [.library(name: "DunneAudioKit", targets: ["DunneAudioKit"])],
    dependencies: [
        .package(url: "https://github.com/AudioKit/KissFFT", from: "1.0.0"),
        .package(url: "https://github.com/AudioKit/AudioKit", from: "5.2.0")
    ],
    targets: [
        .target(name: "DunneAudioKit", dependencies: ["AudioKit", "CDunneAudioKit"]),
        .target(
            name: "CDunneAudioKit",
            dependencies: ["AudioKit", "KissFFT"],
            exclude: [
                "DunneCore/Sampler/Wavpack/license.txt",
                "DunneCore/Common/README.md",
                "DunneCore/Common/Envelope.hpp",
                "DunneCore/Sampler/README.md",
                "DunneCore/README.md",
            ],
            cxxSettings: [.headerSearchPath("DunneCore/Common")]),
        .testTarget(name: "DunneAudioKitTests", dependencies: ["DunneAudioKit"], resources: [.copy("TestResources/")]),
    ],
    cxxLanguageStandard: .cxx14
)
