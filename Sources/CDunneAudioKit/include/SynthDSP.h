// Copyright AudioKit. All Rights Reserved.

#pragma once

#import <AVFoundation/AVFoundation.h>
#import "Interop.h"

typedef NS_ENUM(AUParameterAddress, SynthParameter)
{
    // ramped parameters
    
    SynthParameterMasterVolume,
    SynthParameterPitchBend,
    SynthParameterVibratoDepth,
    SynthParameterFilterCutoff,
    SynthParameterFilterStrength,
    SynthParameterFilterResonance,

    // simple parameters

    SynthParameterAttackDuration,
    SynthParameterDecayDuration,
    SynthParameterSustainLevel,
    SynthParameterReleaseDuration,
    SynthParameterFilterAttackDuration,
    SynthParameterFilterDecayDuration,
    SynthParameterFilterSustainLevel,
    SynthParameterFilterReleaseDuration,

    // ensure this is always last in the list, to simplify parameter addressing
    SynthParameterRampDuration,
};
CF_EXTERN_C_BEGIN
DSPRef akSynthCreateDSP(void);
CF_EXTERN_C_END
