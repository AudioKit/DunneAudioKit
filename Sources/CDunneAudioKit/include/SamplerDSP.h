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
typedef struct CoreSampler* CoreSamplerRef;

DSPRef akSamplerCreateDSP(void);

/// Takes ownership of the CoreSampler.
void akSamplerUpdateCoreSampler(DSPRef pDSP, CoreSamplerRef pSampler);

CoreSamplerRef akCoreSamplerCreate(void);
void akCoreSamplerLoadData(CoreSamplerRef pSampler, SampleDataDescriptor *pSDD);
void akCoreSamplerLoadCompressedFile(CoreSamplerRef pSampler, SampleFileDescriptor *pSFD);
void akCoreSamplerSetNoteFrequency(CoreSamplerRef pSampler, int noteNumber, float noteFrequency);
void akCoreSamplerBuildSimpleKeyMap(CoreSamplerRef pSampler);
void akCoreSamplerBuildKeyMap(CoreSamplerRef pSampler);
void akCoreSamplerSetLoopThruRelease(CoreSamplerRef pSampler, bool value);
CF_EXTERN_C_END

