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
    "-[SamplerTests testSampler]": "8739229f6bc52fa5db3cc2afe85ee580",
    "-[SamplerTests testSamplerAttackVolumeEnvelope]": "bf00177ac48148fa4f780e5e364e84e2",
    "-[SynthTests testChord]": "155d8175419836512ead0794f551c7a0",
    "-[SynthTests testMonophonicPlayback]": "77fb882efcaf29c3a426036d85d04090",
    "-[SynthTests testParameterInitialization]": "e27794e7055b8ebdbf7d0591e980484e",
    "-[TransientShaperTests testAttackAmount]": "481068b77fc73b349315f2327fb84318",
    "-[TransientShaperTests testDefault]": "cea9fc1deb7a77fe47a071d7aaf411d3",
    "-[TransientShaperTests testOutputAmount]": "e84963aeedd6268dd648dd6a862fb76a",
    "-[TransientShaperTests testplayerAmount]": "f70c4ba579921129c86b9a6abb0cb52e",
    "-[TransientShaperTests testReleaseAmount]": "accb7a919f3c63e4dbec41c0e7ef88db",
]
