# ``DunneAudioKit/Sampler``
@Metadata {
    @DocumentationExtension(mergeBehavior:append) 
}

**Sampler** is a polyphonic sample-playback engine built from scratch in C++.  It is 64-voice polyphonic and features a per-voice, stereo low-pass filter with resonance and ADSR envelopes for both amplitude and filter cutoff. Samples must be loaded into memory and remain resident there; it does not do streaming.  It reads standard audio files via **AVAudioFile**, as well as a more efficient Wavpack compressed format. 

### Sampler vs AppleSampler

**AppleSampler** and its companion class **MIDISampler** are wrappers for Apple's *AUSampler* Audio Unit, an exceptionally powerful polyphonic, multi-timbral sampler instrument which is built-in to both macOS and iOS. Unfortunately, *AUSampler* is far from perfect and not properly documented. This **Sampler** is an attempt to provide an open-source alternative.

**Sampler** is nowhere near as powerful as *AUSampler*. If your app depends on **AppleSampler** or the **MIDISampler** wrapper class, you should continue to use it.

### Loading samples
**Sampler** provides three distinct mechanisms for loading samples:

1. `loadRawSampleData()` allows use of sample data already in memory, e.g. data generated programmatically or read using custom file-reading code.
2. `loadSFZ()` loads entire sets of samples by interpreting a simplistic subset of the "SFZ" soundfont file format.
3. `loadRawSampleData()` and `loadCompressedSampleFile()` take a "descriptor" argument, whose many member variables define details like the sample's natural MIDI note-number and pitch (frequency), plus details about loop start and end points, if used. See more in <doc:Sampler-descriptors>.

For `loadUsingSfzFile()` allows all this "metadata" to be encoded in a SFZ file, using a simple plain-text format which is easy to understand and edit manually. More information on <doc:Preparing-Sample-Sets>. 

The mapping of MIDI (note number, velocity) pairs to samples is done using some internal lookup tables, which can be populated in one of two ways:

1. When your metadata includes min/max note-number and velocity values for all samples, call `buildKeyMap()` to build a full key/velocity map.
2. If you only have note-numbers for each sample, call `buildSimpleKeyMap()` to map each MIDI note-number (at any velocity) to the *nearest available* sample.

**Important:** Before loading a new group of samples, you must call `unloadAllSamples()`. Otherwise, the new samples will be loaded *in addition* to the already-loaded ones. This wastes memory and worse, newly-loaded samples will usually not sound at all, because the sampler simply plays the first matching sample it finds.
