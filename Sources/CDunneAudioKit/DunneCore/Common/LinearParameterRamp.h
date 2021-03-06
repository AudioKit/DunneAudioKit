// Copyright AudioKit. All Rights Reserved.

#pragma once

#import "ParameterRampBase.h"

#ifdef __cplusplus

// Currently Unused

struct LinearParameterRamp : ParameterRampBase {

    float computeValueAt(int64_t atSample) override {
        float fract = (float)(atSample - _startSample) / _duration;
        return _value = _startValue + (_target - _startValue) * fract;
    }

};

#endif

