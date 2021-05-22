// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

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

AK_API DSPRef akSamplerCreateDSP(void);
AK_API void akSamplerLoadData(DSPRef pDSP, SampleDataDescriptor *pSDD);
AK_API void akSamplerLoadCompressedFile(DSPRef pDSP, SampleFileDescriptor *pSFD);
AK_API void akSamplerUnloadAllSamples(DSPRef pDSP);
AK_API void akSamplerSetNoteFrequency(DSPRef pDSP, int noteNumber, float noteFrequency);
AK_API void akSamplerBuildSimpleKeyMap(DSPRef pDSP);
AK_API void akSamplerBuildKeyMap(DSPRef pDSP);
AK_API void akSamplerSetLoopThruRelease(DSPRef pDSP, bool value);
AK_API void akSamplerPlayNote(DSPRef pDSP, UInt8 noteNumber, UInt8 velocity);
AK_API void akSamplerStopNote(DSPRef pDSP, UInt8 noteNumber, bool immediate);
AK_API void akSamplerStopAllVoices(DSPRef pDSP);
AK_API void akSamplerRestartVoices(DSPRef pDSP);
AK_API void akSamplerSustainPedal(DSPRef pDSP, bool pedalDown);

