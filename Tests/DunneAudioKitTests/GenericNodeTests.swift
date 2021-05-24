// Copyright AudioKit. All Rights Reserved.

import Foundation
import AudioKit
@testable import DunneAudioKit
import AVFoundation
import XCTest

class GenericNodeTests: XCTestCase {

    func nodeParameterTest(md5: String, factory: (Node)->Node, m1MD5: String = "", audition: Bool = false) {

        let url = Bundle.module.url(forResource: "12345", withExtension: "wav", subdirectory: "TestResources")!
        let player = AudioPlayer(url: url)!
        let node = factory(player)

        let duration = node.parameters.count + 1

        let engine = AudioEngine()
        var bigBuffer: AVAudioPCMBuffer? = nil

        engine.output = node

        /// Do the default parameters first
        if bigBuffer == nil {
            let audio = engine.startTest(totalDuration: 1.0)
            player.play()
            player.isLooping = true
            audio.append(engine.render(duration: 1.0))
            bigBuffer = AVAudioPCMBuffer(pcmFormat: audio.format, frameCapacity: audio.frameLength * UInt32(duration))

            bigBuffer?.append(audio)
        }

        for i in 0 ..< node.parameters.count {

            let node = factory(player)
            engine.output = node

            let param = node.parameters[i]

            node.start()

            param.value = param.def.range.lowerBound
            param.ramp(to: param.def.range.upperBound, duration: 1)

            let audio = engine.startTest(totalDuration: 1.0)
            audio.append(engine.render(duration: 1.0))

            bigBuffer?.append(audio)

        }

        XCTAssertFalse(bigBuffer!.isSilent)

        if audition {
            bigBuffer!.audition()
        }
        XCTAssertTrue([md5, m1MD5].contains(bigBuffer!.md5), "\(node)\nFAILEDMD5 \(bigBuffer!.md5)")
    }



    func testEffects() {
        nodeParameterTest(md5: "1f023474b6150286e854485f00a0d1b4", factory: { input in Flanger(input) })
        nodeParameterTest(md5: "2d667d22162edd87d6ae8ec8bfccc77e", factory: { input in StereoDelay(input) })
    }
}
