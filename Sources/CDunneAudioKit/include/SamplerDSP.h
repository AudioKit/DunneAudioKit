// Copyright AudioKit. All Rights Reserved.

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "Interop.h"

typedef NS_ENUM(AUParameterAddress, SamplerParameter)
{
    // ramped parameters
    SamplerParameterMasterVolume,
    SamplerParameterPitchBend,
    SamplerParameterVibratoDepth,
    SamplerParameterVibratoFrequency,
    SamplerParameterVoiceVibratoDepth,
    SamplerParameterVoiceVibratoFrequency,
    SamplerParameterFilterCutoff,
    SamplerParameterFilterStrength,
    SamplerParameterFilterResonance,
    SamplerParameterGlideRate,

    // simple parameters
    SamplerParameterAttackDuration,
    SamplerParameterHoldDuration,
    SamplerParameterDecayDuration,
    SamplerParameterSustainLevel,
    SamplerParameterReleaseHoldDuration,
    SamplerParameterReleaseDuration,
    SamplerParameterFilterAttackDuration,
    SamplerParameterFilterDecayDuration,
    SamplerParameterFilterSustainLevel,
    SamplerParameterFilterReleaseDuration,
    SamplerParameterFilterEnable,
    SamplerParameterRestartVoiceLFO,
    SamplerParameterPitchAttackDuration,
    SamplerParameterPitchDecayDuration,
    SamplerParameterPitchSustainLevel,
    SamplerParameterPitchReleaseDuration,
    SamplerParameterPitchADSRSemitones,
    SamplerParameterLoopThruRelease,
    SamplerParameterMonophonic,
    SamplerParameterLegato,
    SamplerParameterKeyTrackingFraction,
    SamplerParameterFilterEnvelopeVelocityScaling,
    
    // ensure this is always last in the list, to simplify parameter addressing
    SamplerParameterRampDuration,
};

#include "Sampler_Typedefs.h"

CF_EXTERN_C_BEGIN
DSPRef akSamplerCreateDSP(void);
void akSamplerLoadData(DSPRef pDSP, SampleDataDescriptor *pSDD);
void akSamplerLoadCompressedFile(DSPRef pDSP, SampleFileDescriptor *pSFD);
void akSamplerUnloadAllSamples(DSPRef pDSP);
void akSamplerSetNoteFrequency(DSPRef pDSP, int noteNumber, float noteFrequency);
void akSamplerBuildSimpleKeyMap(DSPRef pDSP);
void akSamplerBuildKeyMap(DSPRef pDSP);
void akSamplerSetLoopThruRelease(DSPRef pDSP, bool value);

typedef struct CoreSampler* CoreSamplerRef;
CoreSamplerRef akCoreSamplerCreate(void);
void akCoreSamplerLoadData(CoreSamplerRef pSampler, SampleDataDescriptor *pSDD);
void akCoreSamplerLoadCompressedFile(CoreSamplerRef pSampler, SampleFileDescriptor *pSFD);
void akCoreSamplerSetNoteFrequency(CoreSamplerRef pSampler, int noteNumber, float noteFrequency);
void akCoreSamplerBuildSimpleKeyMap(CoreSamplerRef pSampler);
void akCoreSamplerBuildKeyMap(CoreSamplerRef pSampler);
void akCoreSamplerSetLoopThruRelease(CoreSamplerRef pSampler, bool value);
CF_EXTERN_C_END

