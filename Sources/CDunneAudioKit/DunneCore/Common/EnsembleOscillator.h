// Copyright AudioKit. All Rights Reserved.

#pragma once

#include "FunctionTable.h"
#include "WaveStack.h"
#include <random>

namespace DunneCore
{

    /// An EnsembleOscillator is WaveStack-based oscillator which provides an "ensemble" effect
    /// based on up to 10 simultaneous waveform-readout "phases" differing slightly in frequency
    /// (pitch spread) and left/right balance (pan spread).
    /// If the phases variable is set to 0, the oscillator is disabled. If set to 1, the result
    /// is a conventional, single-phase oscillator.
    struct EnsembleOscillator
    {
        std::mt19937* gen;
        std::uniform_real_distribution<float> dis{0.0f, 1.0f};

        /// current output sample rate
        double sampleRateHz;

        /// pointer to shared WaveStack
        WaveStack *pWaveStack;

        /// number of unison/ensemble phases
        int phaseCount;
        /// frequency difference between phases, cents
        float frequencySpread;

        // per-phase variables

        /// maximum number of phases
        static constexpr int maxPhases = 10;

        /// WaveStack octave used by this phase
        int octave[maxPhases];

        /// Fraction of the way through waveform
        float phase[maxPhases];

        /// normalized frequency: cycles per sample
        float phaseDelta[maxPhases];
        float leftGain[maxPhases];
        float rightGain[maxPhases];

        // performance variables

        /// phaseDelta multiplier for pitchbend, vibrato
        float phaseDeltaMultiplier;

        EnsembleOscillator(std::mt19937* gen) : phaseCount(1), frequencySpread(0.0f), gen(gen) {}
        void init(double sampleRate, WaveStack *pStack);
        void setPhases(int nPhases);
        void setFreqSpread(float fSpread) { frequencySpread = fSpread; }

        /// argument is a fraction: 0 = no spread, 1 = max spread
        void setPanSpread(float fSpread);
        void setFrequency(float frequency);

        float getSample();
        void getSamples(float *pLeft, float *pRight, float gain);
    };

}
