// Copyright AudioKit. All Rights Reserved.

import AudioKit
import AVFoundation
import CDunneAudioKit
import DunneAudioKit
import XCTest

class SamplerTests: XCTestCase {
    
    func testSampler() {
        let engine = AudioEngine()
        let sampleURL = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav")!
        let file = try! AVAudioFile(forReading: sampleURL)
        let sampler = Sampler(sampleDescriptor: SampleDescriptor(noteNumber: 64, noteFrequency: 440, minimumNoteNumber: 0, maximumNoteNumber: 127, minimumVelocity: 0, maximumVelocity: 127, isLooping: false, loopStartPoint: 0, loopEndPoint: 1000.0, startPoint: 0.0, endPoint: 44100.0 * 5.0), file: file)
        sampler.buildKeyMap()
        sampler.masterVolume = 0.1
        engine.output = sampler
        let audio = engine.startTest(totalDuration: 5.0)
        sampler.play(noteNumber: 64, velocity: 127)
        audio.append(engine.render(duration: 1.0))
        sampler.stop(noteNumber: 64)
        sampler.play(noteNumber: 68, velocity: 127)
        audio.append(engine.render(duration: 1.0))
        sampler.stop(noteNumber: 68)
        sampler.play(noteNumber: 71, velocity: 127)
        audio.append(engine.render(duration: 1.0))
        sampler.stop(noteNumber: 71)
        sampler.play(noteNumber: 76, velocity: 127)
        audio.append(engine.render(duration: 1.0))
        sampler.stop(noteNumber: 76)
        sampler.play(noteNumber: 88, velocity: 127)
        audio.append(engine.render(duration: 1.0))
        sampler.stop(noteNumber: 88)
        testMD5(audio)
    }

    func testVoiceVibratoFreq() {
        let engine = AudioEngine()
        let sampleURL = Bundle.module.url(forResource: "TestResources/12345", withExtension: "wav")!
        let file = try! AVAudioFile(forReading: sampleURL)
        let sampler = Sampler(sampleDescriptor: SampleDescriptor(noteNumber: 64, noteFrequency: 440, minimumNoteNumber: 0, maximumNoteNumber: 127, minimumVelocity: 0, maximumVelocity: 127, isLooping: false, loopStartPoint: 0, loopEndPoint: 1000.0, startPoint: 0.0, endPoint: 44100.0 * 5.0), file: file)
        sampler.buildKeyMap()
        sampler.masterVolume = 0.1

        engine.output = sampler

        let voiceVibratoFreq: Float = 0.5
        sampler.voiceVibratoFrequency = voiceVibratoFreq
        XCTAssertEqual(sampler.voiceVibratoFrequency, voiceVibratoFreq)

    }

}
