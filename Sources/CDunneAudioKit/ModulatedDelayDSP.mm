// Copyright AudioKit. All Rights Reserved.

#import <AudioToolbox/AudioToolbox.h>
#import <AudioUnit/AudioUnit.h>
#import <AVFoundation/AVFoundation.h>
#include <math.h>

#include "ModulatedDelayDSP.h"
#import "DSPBase.h"
#import "ParameterRamper.h"

#import "AudioKitCore/Modulated Delay/ModulatedDelay_Defines.h"
#import "AudioKitCore/Modulated Delay/ModulatedDelay.h"

const float kChorus_DefaultFrequency = kChorusDefaultModFreqHz;
const float kChorus_DefaultDepth = kChorusDefaultDepth;
const float kChorus_DefaultFeedback = kChorusDefaultFeedback;
const float kChorus_DefaultDryWetMix = kChorusDefaultMix;

const float kChorus_MinFrequency = kChorusMinModFreqHz;
const float kChorus_MaxFrequency = kChorusMaxModFreqHz;
const float kChorus_MinFeedback  = kChorusMinFeedback;
const float kChorus_MaxFeedback  = kChorusMaxFeedback;
const float kChorus_MinDepth     = kChorusMinDepth;
const float kChorus_MaxDepth     = kChorusMaxDepth;
const float kChorus_MinDryWetMix = kChorusMinDryWetMix;
const float kChorus_MaxDryWetMix = kChorusMaxDryWetMix;

const float kFlanger_DefaultFrequency = kFlangerDefaultModFreqHz;
const float kFlanger_DefaultDepth = kFlangerDefaultDepth;
const float kFlanger_DefaultFeedback = kFlangerDefaultFeedback;
const float kFlanger_DefaultDryWetMix = kFlangerDefaultMix;

const float kFlanger_MinFrequency = kFlangerMinModFreqHz;
const float kFlanger_MaxFrequency = kFlangerMaxModFreqHz;
const float kFlanger_MinFeedback  = kFlangerMinFeedback;
const float kFlanger_MaxFeedback  = kFlangerMaxFeedback;
const float kFlanger_MinDepth     = kFlangerMinDepth;
const float kFlanger_MaxDepth     = kFlangerMaxDepth;
const float kFlanger_MinDryWetMix = kFlangerMinDryWetMix;
const float kFlanger_MaxDryWetMix = kFlangerMaxDryWetMix;

struct ModulatedDelayDSP : DSPBase
{
private:
    // ramped parameters
    ParameterRamper frequencyRamp;
    ParameterRamper depthRamp;
    ParameterRamper feedbackRamp;
    ParameterRamper dryWetMixRamp;
    ModulatedDelay delay;

public:
    ModulatedDelayDSP(ModulatedDelayType type);

    void init(int channelCount, double sampleRate) override;

    void deinit() override;

    void process(FrameRange range) override;
};

ModulatedDelayDSP::ModulatedDelayDSP(ModulatedDelayType type)
    : DSPBase(1, true), delay(type)
{
    parameters[ModulatedDelayParameterFrequency] = &frequencyRamp;
    parameters[ModulatedDelayParameterDepth] = &depthRamp;
    parameters[ModulatedDelayParameterFeedback] = &feedbackRamp;
    parameters[ModulatedDelayParameterDryWetMix] = &dryWetMixRamp;
}

void ModulatedDelayDSP::init(int channels, double sampleRate)
{
    DSPBase::init(channels, sampleRate);
    delay.init(channels, sampleRate);
}

void ModulatedDelayDSP::deinit()
{
    DSPBase::deinit();
    delay.deinit();
}

#define CHUNKSIZE 8     // defines ramp interval

void ModulatedDelayDSP::process(FrameRange range)
{
    float *inBuffers[2], *outBuffers[2];
    inBuffers[0]  = (float *)inputBufferLists[0]->mBuffers[0].mData  + range.start;
    inBuffers[1]  = (float *)inputBufferLists[0]->mBuffers[1].mData  + range.start;
    outBuffers[0] = (float *)outputBufferList->mBuffers[0].mData + range.start;
    outBuffers[1] = (float *)outputBufferList->mBuffers[1].mData + range.start;
    unsigned channelCount = outputBufferList->mNumberBuffers;

    if (!isStarted)
    {
        // effect bypassed: just copy input to output
        memcpy(outBuffers[0], inBuffers[0], range.count * sizeof(float));
        if (channelCount > 0)
            memcpy(outBuffers[1], inBuffers[1], range.count * sizeof(float));
        return;
    }

    // process in chunks of maximum length CHUNKSIZE
    for (int frameIndex = 0; frameIndex < range.count; frameIndex += CHUNKSIZE) {
        int chunkSize = range.count - frameIndex;
        if (chunkSize > CHUNKSIZE) chunkSize = CHUNKSIZE;

        // ramp parameters
        frequencyRamp.stepBy(chunkSize);
        depthRamp.stepBy(chunkSize);
        feedbackRamp.stepBy(chunkSize);
        dryWetMixRamp.stepBy(chunkSize);

        // apply changes
        delay.setModFrequencyHz(frequencyRamp.get());
        delay.setModDepthFraction(depthRamp.get());
        float fb = feedbackRamp.get();
        delay.setLeftFeedback(fb);
        delay.setRightFeedback(fb);
        delay.setDryWetMix(dryWetMixRamp.get());

        // process
        delay.Render(channelCount, chunkSize, inBuffers, outBuffers);

        // advance pointers
        inBuffers[0] += chunkSize;
        inBuffers[1] += chunkSize;
        outBuffers[0] += chunkSize;
        outBuffers[1] += chunkSize;
    }
}

struct ChorusDSP : ModulatedDelayDSP {
    ChorusDSP() : ModulatedDelayDSP(kChorus) { }
};

struct FlangerDSP : ModulatedDelayDSP {
    FlangerDSP() : ModulatedDelayDSP(kFlanger) { }
};

AK_REGISTER_DSP(ChorusDSP, "chrs");
AK_REGISTER_DSP(FlangerDSP, "flgr");
