// Copyright AudioKit. All Rights Reserved. Revision History at http://github.com/AudioKit/AudioKit/

#pragma once
#include "LinearRamper.h"
#include "FunctionTable.h"

namespace AudioKitCore
{

    struct EnvelopeSegmentParameters
    {
        // where this segment starts
        float initialLevel;

        // where it ends
        float finalLevel;

        // how long it takes to get there
        float seconds;
    };

    struct EnvelopeParameters
    {
        float sampleRateHz;

        // number of segments
        int nSegments;

        // points to an array of nSegments elements
        EnvelopeSegmentParameters *pSeg;

        // start() begins at this segment
        int attackSegmentIndex;

        // index of first sustain segment (-1 if none)
        int sustainSegmentIndex;

        // release() jumps to this segment
        int releaseSegmentIndex;

        EnvelopeParameters();
        void init(float newSampleRateHz,
                  int nSegs,
                  EnvelopeSegmentParameters *pSegParameters,
                  int susSegIndex = -1,
                  int attackSegIndex = 0,
                  int releaseSegIndex = -1);
        void updateSampleRate(float newSampleRateHz);
    };

    struct Envelope
    {
        EnvelopeParameters *pParameters;
        LinearRamper ramper;
        int currentSegmentIndex;

        void init(EnvelopeParameters *pParameters);

        // begin attack segment
        void start();

        // go to segment 0
        void restart();

        // go to release segment
        void release();

        // reset to idle state
        void reset();
        bool isIdle() { return currentSegmentIndex < 0; }
        bool isReleasing() { return currentSegmentIndex >= pParameters->releaseSegmentIndex; }

        float getSample();
    };
}
