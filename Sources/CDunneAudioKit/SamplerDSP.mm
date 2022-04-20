// Copyright AudioKit. All Rights Reserved.

#import "SamplerDSP.h"
#include "wavpack.h"
#include <math.h>

#import "DSPBase.h"
#include "DunneCore/Sampler/CoreSampler.h"
#include "LinearParameterRamp.h"
#include "AtomicDataPtr.h"

CoreSamplerRef akCoreSamplerCreate(void) {
    return new CoreSampler();
}

void akCoreSamplerLoadData(CoreSamplerRef pSampler, SampleDataDescriptor *pSDD) {
    pSampler->loadSampleData(*pSDD);
}

void akCoreSamplerLoadCompressedFile(CoreSamplerRef pSampler, SampleFileDescriptor *pSFD) {
    char errMsg[100];
    WavpackContext *wpc = WavpackOpenFileInput(pSFD->path, errMsg, OPEN_2CH_MAX, 0);
    if (wpc == 0)
    {
        printf("Wavpack error loading %s: %s\n", pSFD->path, errMsg);
        return;
    }

    SampleDataDescriptor sdd;
    sdd.sampleDescriptor = pSFD->sampleDescriptor;
    sdd.sampleRate = (float)WavpackGetSampleRate(wpc);
    sdd.channelCount = WavpackGetReducedChannels(wpc);
    sdd.sampleCount = WavpackGetNumSamples(wpc);
    sdd.isInterleaved = sdd.channelCount > 1;
    sdd.data = new float[sdd.channelCount * sdd.sampleCount];

    int mode = WavpackGetMode(wpc);
    WavpackUnpackSamples(wpc, (int32_t*)sdd.data, sdd.sampleCount);
    if ((mode & MODE_FLOAT) == 0)
    {
        // convert samples to floating-point
        int bps = WavpackGetBitsPerSample(wpc);
        float scale = 1.0f / (1 << (bps - 1));
        float *pf = sdd.data;
        int32_t *pi = (int32_t*)pf;
        for (int i = 0; i < (sdd.sampleCount * sdd.channelCount); i++)
            *pf++ = scale * *pi++;
    }
    WavpackCloseFile(wpc);

    pSampler->loadSampleData(sdd);
    delete[] sdd.data;
}

void akCoreSamplerSetNoteFrequency(CoreSamplerRef pSampler, int noteNumber, float noteFrequency) {
    pSampler->setNoteFrequency(noteNumber, noteFrequency);
}

void akCoreSamplerBuildSimpleKeyMap(CoreSamplerRef pSampler) {
    pSampler->buildSimpleKeyMap();
}

void akCoreSamplerBuildKeyMap(CoreSamplerRef pSampler) {
    pSampler->buildKeyMap();
}

void akCoreSamplerSetLoopThruRelease(CoreSamplerRef pSampler, bool value) {
    pSampler->setLoopThruRelease(value);
}

struct SamplerDSP : DSPBase
{
    // ramped parameters
    LinearParameterRamp masterVolumeRamp;
    LinearParameterRamp pitchBendRamp;
    LinearParameterRamp vibratoDepthRamp;
    LinearParameterRamp vibratoFrequencyRamp;
    LinearParameterRamp voiceVibratoDepthRamp;
    LinearParameterRamp voiceVibratoFrequencyRamp;
    LinearParameterRamp filterCutoffRamp;
    LinearParameterRamp filterStrengthRamp;
    LinearParameterRamp filterResonanceRamp;
    LinearParameterRamp pitchADSRSemitonesRamp;
    LinearParameterRamp glideRateRamp;

    AtomicDataPtr<CoreSampler> sampler;

    std::vector<std::unique_ptr<CoreSampler>> cleanupArray;

    SamplerDSP();
    void init(int channelCount, double sampleRate) override;
    void deinit() override;

    void setParameter(uint64_t address, float value, bool immediate) override;
    float getParameter(uint64_t address) override;

    void handleMIDIEvent(AUMIDIEvent const& midiEvent) override;
    void process(FrameRange range) override;

    void updateCoreSampler(CoreSampler* newSampler) {
        newSampler->init(sampleRate);
        newSampler->setADSRAttackDurationSeconds(sampler->getADSRAttackDurationSeconds());
        newSampler->setADSRDecayDurationSeconds(sampler->getADSRDecayDurationSeconds());
        newSampler->setADSRHoldDurationSeconds(sampler->getADSRHoldDurationSeconds());
        newSampler->setADSRSustainFraction(sampler->getADSRSustainFraction());
        newSampler->setADSRReleaseHoldDurationSeconds(sampler->getADSRReleaseHoldDurationSeconds());
        newSampler->setADSRReleaseDurationSeconds(sampler->getADSRReleaseDurationSeconds());
        
        newSampler->setFilterAttackDurationSeconds(sampler->getFilterAttackDurationSeconds());
        newSampler->setFilterDecayDurationSeconds(sampler->getFilterDecayDurationSeconds());
        newSampler->setFilterSustainFraction(sampler->getFilterSustainFraction());
        newSampler->setFilterReleaseDurationSeconds(sampler->getFilterReleaseDurationSeconds());
        
        newSampler->setPitchAttackDurationSeconds(sampler->getPitchAttackDurationSeconds());
        newSampler->setPitchDecayDurationSeconds(sampler->getPitchDecayDurationSeconds());
        newSampler->setPitchSustainFraction(sampler->getPitchSustainFraction());
        newSampler->setPitchReleaseDurationSeconds(sampler->getPitchReleaseDurationSeconds());
        newSampler->pitchADSRSemitones = sampler->pitchADSRSemitones;
        
        newSampler->pitchOffset = sampler->pitchOffset;
        newSampler->cutoffEnvelopeStrength = sampler->cutoffEnvelopeStrength;
        newSampler->cutoffMultiple = sampler->cutoffMultiple;
        newSampler->filterEnvelopeVelocityScaling = sampler->filterEnvelopeVelocityScaling;
        newSampler->glideRate = sampler->glideRate;
        newSampler->isFilterEnabled = sampler->isFilterEnabled;
        newSampler->isLegato = sampler->isLegato;
        newSampler->isMonophonic = sampler->isMonophonic;
        newSampler->keyTracking = sampler->keyTracking;
        newSampler->linearResonance = sampler->linearResonance;
        newSampler->masterVolume = sampler->masterVolume;
        newSampler->portamentoRate = sampler->portamentoRate;
        newSampler->vibratoDepth = sampler->vibratoDepth;
        newSampler->vibratoFrequency = sampler->vibratoFrequency;
        newSampler->voiceVibratoDepth = sampler->voiceVibratoDepth;
        newSampler->voiceVibratoFrequency = sampler->voiceVibratoFrequency;
        newSampler->setLoopThruRelease(sampler->loopThruRelease);
        
        sampler.set(newSampler);
    }
};

DSPRef akSamplerCreateDSP() {
    return new SamplerDSP();
}

void akSamplerUpdateCoreSampler(DSPRef pDSP, CoreSamplerRef pSampler) {
    ((SamplerDSP*)pDSP)->updateCoreSampler(pSampler);
}

SamplerDSP::SamplerDSP()
{
    sampler.set(new CoreSampler);
    sampler.update();
    masterVolumeRamp.setTarget(1.0, true);
    pitchBendRamp.setTarget(0.0, true);
    vibratoDepthRamp.setTarget(0.0, true);
    vibratoFrequencyRamp.setTarget(5.0, true);
    voiceVibratoDepthRamp.setTarget(0.0, true);
    voiceVibratoFrequencyRamp.setTarget(5.0, true);
    filterCutoffRamp.setTarget(4, true);
    filterStrengthRamp.setTarget(20.0f, true);
    filterResonanceRamp.setTarget(1.0, true);
    pitchADSRSemitonesRamp.setTarget(0.0, true);
    glideRateRamp.setTarget(0.0, true);
}

void SamplerDSP::init(int channelCount, double sampleRate)
{
    DSPBase::init(channelCount, sampleRate);
    sampler->init(sampleRate);
}

void SamplerDSP::deinit()
{
    DSPBase::deinit();
    sampler->deinit();
}

void SamplerDSP::setParameter(AUParameterAddress address, float value, bool immediate) __attribute__((no_sanitize("thread")))
{
    switch (address) {
        case SamplerParameterRampDuration:
            masterVolumeRamp.setRampDuration(value, sampleRate);
            pitchBendRamp.setRampDuration(value, sampleRate);
            vibratoDepthRamp.setRampDuration(value, sampleRate);
            vibratoFrequencyRamp.setRampDuration(value, sampleRate);
            voiceVibratoDepthRamp.setRampDuration(value, sampleRate);
            voiceVibratoFrequencyRamp.setRampDuration(value, sampleRate);
            filterCutoffRamp.setRampDuration(value, sampleRate);
            filterStrengthRamp.setRampDuration(value, sampleRate);
            filterResonanceRamp.setRampDuration(value, sampleRate);
            pitchADSRSemitonesRamp.setRampDuration(value, sampleRate);
            glideRateRamp.setRampDuration(value, sampleRate);
            break;

        case SamplerParameterMasterVolume:
            masterVolumeRamp.setTarget(value, immediate);
            break;
        case SamplerParameterPitchBend:
            pitchBendRamp.setTarget(value, immediate);
            break;
        case SamplerParameterVibratoDepth:
            vibratoDepthRamp.setTarget(value, immediate);
            break;
        case SamplerParameterVibratoFrequency:
            vibratoFrequencyRamp.setTarget(value, immediate);
            break;
        case SamplerParameterVoiceVibratoDepth:
            voiceVibratoDepthRamp.setTarget(value, immediate);
            break;
        case SamplerParameterVoiceVibratoFrequency:
            voiceVibratoFrequencyRamp.setTarget(value, immediate);
            break;
        case SamplerParameterFilterCutoff:
            filterCutoffRamp.setTarget(value, immediate);
            break;
        case SamplerParameterFilterStrength:
            filterStrengthRamp.setTarget(value, immediate);
            break;
        case SamplerParameterFilterResonance:
            filterResonanceRamp.setTarget(pow(10.0, -0.05 * value), immediate);
            break;
        case SamplerParameterGlideRate:
            glideRateRamp.setTarget(value, immediate);
            break;

        case SamplerParameterAttackDuration:
            sampler->setADSRAttackDurationSeconds(value);
            break;
        case SamplerParameterHoldDuration:
            sampler->setADSRHoldDurationSeconds(value);
            break;
        case SamplerParameterDecayDuration:
            sampler->setADSRDecayDurationSeconds(value);
            break;
        case SamplerParameterSustainLevel:
            sampler->setADSRSustainFraction(value);
            break;
        case SamplerParameterReleaseHoldDuration:
            sampler->setADSRReleaseHoldDurationSeconds(value);
            break;
        case SamplerParameterReleaseDuration:
            sampler->setADSRReleaseDurationSeconds(value);
            break;

        case SamplerParameterFilterAttackDuration:
            sampler->setFilterAttackDurationSeconds(value);
            break;
        case SamplerParameterFilterDecayDuration:
            sampler->setFilterDecayDurationSeconds(value);
            break;
        case SamplerParameterFilterSustainLevel:
            sampler->setFilterSustainFraction(value);
            break;
        case SamplerParameterFilterReleaseDuration:
            sampler->setFilterReleaseDurationSeconds(value);
            break;

        case SamplerParameterPitchAttackDuration:
            sampler->setPitchAttackDurationSeconds(value);
            break;
        case SamplerParameterPitchDecayDuration:
            sampler->setPitchDecayDurationSeconds(value);
            break;
        case SamplerParameterPitchSustainLevel:
            sampler->setPitchSustainFraction(value);
            break;
        case SamplerParameterPitchReleaseDuration:
            sampler->setPitchReleaseDurationSeconds(value);
            break;
        case SamplerParameterPitchADSRSemitones:
            pitchADSRSemitonesRamp.setTarget(value, immediate);
            break;

        case SamplerParameterRestartVoiceLFO:
            sampler->restartVoiceLFO = value > 0.5f;
            break;

        case SamplerParameterFilterEnable:
            sampler->isFilterEnabled = value > 0.5f;
            break;
        case SamplerParameterLoopThruRelease:
            sampler->loopThruRelease = value > 0.5f;
            break;
        case SamplerParameterMonophonic:
            sampler->isMonophonic = value > 0.5f;
            break;
        case SamplerParameterLegato:
            sampler->isLegato = value > 0.5f;
            break;
        case SamplerParameterKeyTrackingFraction:
            sampler->keyTracking = value;
            break;
        case SamplerParameterFilterEnvelopeVelocityScaling:
            sampler->filterEnvelopeVelocityScaling = value;
            break;
    }
}

float SamplerDSP::getParameter(AUParameterAddress address) __attribute__((no_sanitize("thread")))
{
    switch (address) {
        case SamplerParameterRampDuration:
            return pitchBendRamp.getRampDuration(sampleRate);

        case SamplerParameterMasterVolume:
            return masterVolumeRamp.getTarget();
        case SamplerParameterPitchBend:
            return pitchBendRamp.getTarget();
        case SamplerParameterVibratoDepth:
            return vibratoDepthRamp.getTarget();
        case SamplerParameterVibratoFrequency:
            return vibratoFrequencyRamp.getTarget();
        case SamplerParameterVoiceVibratoDepth:
            return voiceVibratoDepthRamp.getTarget();
        case SamplerParameterVoiceVibratoFrequency:
            return voiceVibratoFrequencyRamp.getTarget();
        case SamplerParameterFilterCutoff:
            return filterCutoffRamp.getTarget();
        case SamplerParameterFilterStrength:
            return filterStrengthRamp.getTarget();
        case SamplerParameterFilterResonance:
            return -20.0f * log10(filterResonanceRamp.getTarget());

        case SamplerParameterGlideRate:
            return glideRateRamp.getTarget();

        case SamplerParameterAttackDuration:
            return sampler->getADSRAttackDurationSeconds();
        case SamplerParameterHoldDuration:
            return sampler->getADSRHoldDurationSeconds();
        case SamplerParameterDecayDuration:
            return sampler->getADSRDecayDurationSeconds();
        case SamplerParameterSustainLevel:
            return sampler->getADSRSustainFraction();
        case SamplerParameterReleaseHoldDuration:
            return sampler->getADSRReleaseHoldDurationSeconds();
        case SamplerParameterReleaseDuration:
            return sampler->getADSRReleaseDurationSeconds();

        case SamplerParameterFilterAttackDuration:
            return sampler->getFilterAttackDurationSeconds();
        case SamplerParameterFilterDecayDuration:
            return sampler->getFilterDecayDurationSeconds();
        case SamplerParameterFilterSustainLevel:
            return sampler->getFilterSustainFraction();
        case SamplerParameterFilterReleaseDuration:
            return sampler->getFilterReleaseDurationSeconds();

        case SamplerParameterPitchAttackDuration:
            return sampler->getPitchAttackDurationSeconds();
        case SamplerParameterPitchDecayDuration:
            return sampler->getPitchDecayDurationSeconds();
        case SamplerParameterPitchSustainLevel:
            return sampler->getPitchSustainFraction();
        case SamplerParameterPitchReleaseDuration:
            return sampler->getPitchReleaseDurationSeconds();
        case SamplerParameterPitchADSRSemitones:
            return pitchADSRSemitonesRamp.getTarget();
        case SamplerParameterRestartVoiceLFO:
            return sampler->restartVoiceLFO ? 1.0f : 0.0f;

        case SamplerParameterFilterEnable:
            return sampler->isFilterEnabled ? 1.0f : 0.0f;
        case SamplerParameterLoopThruRelease:
            return sampler->loopThruRelease ? 1.0f : 0.0f;
        case SamplerParameterMonophonic:
            return sampler->isMonophonic ? 1.0f : 0.0f;
        case SamplerParameterLegato:
            return sampler->isLegato ? 1.0f : 0.0f;
        case SamplerParameterKeyTrackingFraction:
            return sampler->keyTracking;
        case SamplerParameterFilterEnvelopeVelocityScaling:
            return sampler->filterEnvelopeVelocityScaling;
    }
    return 0;
}

void SamplerDSP::handleMIDIEvent(const AUMIDIEvent &midiEvent)
{
    if (midiEvent.length != 3) return;
    uint8_t status = midiEvent.data[0] & 0xF0;
    //uint8_t channel = midiEvent.data[0] & 0x0F; // works in omni mode.
    switch (status) {
        case MIDI_NOTE_OFF : {
            uint8_t note = midiEvent.data[1];
            if (note > 127) break;
            sampler->stopNote(note, false);
            break;
        }
        case MIDI_NOTE_ON : {
            uint8_t note = midiEvent.data[1];
            uint8_t veloc = midiEvent.data[2];
            if (note > 127 || veloc > 127) break;
            sampler->playNote(note, veloc);
            break;
        }
        case MIDI_CONTINUOUS_CONTROLLER : {
            uint8_t num = midiEvent.data[1];
            if (num == 64) {
                uint8_t value = midiEvent.data[2];
                if (value <= 63) {
                    sampler->sustainPedal(false);
                } else {
                    sampler->sustainPedal(true);
                }
            }
            if (num == 123) { // all notes off
                sampler->stopAllVoices();
            }
            break;
        }
    }
}

void SamplerDSP::process(FrameRange range)
{

    float *pLeft = (float *)outputBufferList->mBuffers[0].mData + range.start;
    float *pRight = (float *)outputBufferList->mBuffers[1].mData + range.start;

    memset(pLeft, 0, range.count * sizeof(float));
    memset(pRight, 0, range.count * sizeof(float));

    sampler.update();

    // process in chunks of maximum length CORESAMPLER_CHUNKSIZE
    for (int frameIndex = 0; frameIndex < range.count; frameIndex += CORESAMPLER_CHUNKSIZE) {
        int frameOffset = int(frameIndex + range.start);
        int chunkSize = range.count - frameIndex;
        if (chunkSize > CORESAMPLER_CHUNKSIZE) chunkSize = CORESAMPLER_CHUNKSIZE;

        // ramp parameters
        masterVolumeRamp.advanceTo(now + frameOffset);
        sampler->masterVolume = (float)masterVolumeRamp.getValue();
        pitchBendRamp.advanceTo(now + frameOffset);
        sampler->pitchOffset = (float)pitchBendRamp.getValue();
        vibratoDepthRamp.advanceTo(now + frameOffset);
        sampler->vibratoDepth = (float)vibratoDepthRamp.getValue();
        vibratoFrequencyRamp.advanceTo(now + frameOffset);
        sampler->vibratoFrequency = (float)vibratoFrequencyRamp.getValue();
        voiceVibratoDepthRamp.advanceTo(now + frameOffset);
        sampler->voiceVibratoDepth = (float)voiceVibratoDepthRamp.getValue();
        voiceVibratoFrequencyRamp.advanceTo(now + frameOffset);
        sampler->voiceVibratoFrequency = (float)voiceVibratoFrequencyRamp.getValue();
        filterCutoffRamp.advanceTo(now + frameOffset);
        sampler->cutoffMultiple = (float)filterCutoffRamp.getValue();
        filterStrengthRamp.advanceTo(now + frameOffset);
        sampler->cutoffEnvelopeStrength = (float)filterStrengthRamp.getValue();
        filterResonanceRamp.advanceTo(now + frameOffset);
        sampler->linearResonance = (float)filterResonanceRamp.getValue();
        
        pitchADSRSemitonesRamp.advanceTo(now + frameOffset);
        sampler->pitchADSRSemitones = (float)pitchADSRSemitonesRamp.getValue();

        glideRateRamp.advanceTo(now + frameOffset);
        sampler->glideRate = (float)glideRateRamp.getValue();

        // get data
        float *outBuffers[2];
        outBuffers[0] = (float *)outputBufferList->mBuffers[0].mData + frameOffset;
        outBuffers[1] = (float *)outputBufferList->mBuffers[1].mData + frameOffset;
        unsigned channelCount = outputBufferList->mNumberBuffers;
        sampler->render(channelCount, chunkSize, outBuffers);
    }
}

AK_REGISTER_DSP(SamplerDSP, "samp")
AK_REGISTER_PARAMETER(SamplerParameterMasterVolume)
AK_REGISTER_PARAMETER(SamplerParameterPitchBend)
AK_REGISTER_PARAMETER(SamplerParameterVibratoDepth)
AK_REGISTER_PARAMETER(SamplerParameterVibratoFrequency)
AK_REGISTER_PARAMETER(SamplerParameterVoiceVibratoDepth)
AK_REGISTER_PARAMETER(SamplerParameterVoiceVibratoFrequency)
AK_REGISTER_PARAMETER(SamplerParameterFilterCutoff)
AK_REGISTER_PARAMETER(SamplerParameterFilterStrength)
AK_REGISTER_PARAMETER(SamplerParameterFilterResonance)
AK_REGISTER_PARAMETER(SamplerParameterGlideRate)
AK_REGISTER_PARAMETER(SamplerParameterAttackDuration)
AK_REGISTER_PARAMETER(SamplerParameterHoldDuration)
AK_REGISTER_PARAMETER(SamplerParameterDecayDuration)
AK_REGISTER_PARAMETER(SamplerParameterSustainLevel)
AK_REGISTER_PARAMETER(SamplerParameterReleaseHoldDuration)
AK_REGISTER_PARAMETER(SamplerParameterReleaseDuration)
AK_REGISTER_PARAMETER(SamplerParameterFilterAttackDuration)
AK_REGISTER_PARAMETER(SamplerParameterFilterDecayDuration)
AK_REGISTER_PARAMETER(SamplerParameterFilterSustainLevel)
AK_REGISTER_PARAMETER(SamplerParameterFilterReleaseDuration)
AK_REGISTER_PARAMETER(SamplerParameterFilterEnable)
AK_REGISTER_PARAMETER(SamplerParameterRestartVoiceLFO)
AK_REGISTER_PARAMETER(SamplerParameterPitchAttackDuration)
AK_REGISTER_PARAMETER(SamplerParameterPitchDecayDuration)
AK_REGISTER_PARAMETER(SamplerParameterPitchSustainLevel)
AK_REGISTER_PARAMETER(SamplerParameterPitchReleaseDuration)
AK_REGISTER_PARAMETER(SamplerParameterPitchADSRSemitones)
AK_REGISTER_PARAMETER(SamplerParameterLoopThruRelease)
AK_REGISTER_PARAMETER(SamplerParameterMonophonic)
AK_REGISTER_PARAMETER(SamplerParameterLegato)
AK_REGISTER_PARAMETER(SamplerParameterKeyTrackingFraction)
AK_REGISTER_PARAMETER(SamplerParameterFilterEnvelopeVelocityScaling)
AK_REGISTER_PARAMETER(SamplerParameterRampDuration)
