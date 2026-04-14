import AVFoundation
import XCTest

extension XCTestCase {
    func testMD5(_ buffer: AVAudioPCMBuffer) {
        let localMD5 = buffer.md5
        let name = description
        XCTAssertFalse(buffer.isSilent)
        XCTAssert(validatedMD5s[name] == buffer.md5, "\nFAILEDMD5 \"\(name)\": \"\(localMD5)\",")
    }
}

let validatedMD5s: [String: String] = [
    "-[SamplerTests testSampler]": "764e9a29c81659ea19b942afead19c1e",
    "-[SamplerTests testSamplerAttackVolumeEnvelope]": "2b10675e27c588c5fc7aa70ec1b299c5",
    "-[SynthTests testChord]": "4f1199e90b38cf7ede595c62600bb307",
    "-[SynthTests testMonophonicPlayback]": "2851284c61e62af0ade1e0ac5ee786c9",
    "-[SynthTests testParameterInitialization]": "0030b568eff9dcdbd5b532a5de1e32dd"
]
