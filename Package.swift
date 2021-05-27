// swift-tools-version:5.3
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "DunneAudioKit",
    platforms: [.macOS(.v10_14), .iOS(.v13), .tvOS(.v13)],
    products: [.library(name: "DunneAudioKit", targets: ["DunneAudioKit"])],
    dependencies: [
        .package(url: "https://github.com/AudioKit/KissFFT", .branch("main")),
        .package(url: "https://github.com/AudioKit/AudioKit", .branch("develop"))
    ],
    targets: [
        .target(name: "DunneAudioKit", dependencies: ["AudioKit", "CDunneAudioKit"]),
        .target(
            name: "CDunneAudioKit",
            dependencies: ["AudioKit", "KissFFT"],
            exclude: [
                "AudioKitCore/Sampler/Wavpack/license.txt",
                "AudioKitCore/Common/README.md",
                "AudioKitCore/Common/Envelope.hpp",
                "AudioKitCore/Sampler/README.md",
                "AudioKitCore/README.md",
            ],
            cxxSettings: [.headerSearchPath("AudioKitCore/Common")]),
        .testTarget(name: "DunneAudioKitTests", dependencies: ["DunneAudioKit"], resources: [.copy("TestResources/")]),
    ],
    cxxLanguageStandard: .cxx14
)
