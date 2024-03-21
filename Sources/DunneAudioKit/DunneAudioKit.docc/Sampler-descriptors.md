# Sampler initialisation with descriptors


## Sample descriptors
When using `loadRawSampleData()` and `loadCompressedSampleFile()` to load individual samples, you will need to create instances of one of three Swift structure types as follows.

The structures are defined as C structs in *Sampler_Typedefs.h* (which lives in the *AudioKit/Core/DunneCore/Sampler* folder in the main AudioKit repo). This file is simple enough to reproduce here:

    typedef struct
    {
        int noteNumber;
        float noteHz;
        
        int min_note, max_note;
        int min_vel, max_vel;
        
        bool bLoop;
        float fLoopStart, fLoopEnd;
        float fStart, fEnd;

    } SampleDescriptor;

    typedef struct
    {
        SampleDescriptor sd;
        
        float sampleRateHz;
        bool bInterleaved;
        int nChannels;
        int nSamples;
        float *pData;

    } SampleDataDescriptor;

    typedef struct
    {
        SampleDescriptor sd;
        
        const char* path;
        
    } SampleFileDescriptor;

By the miracle of Swift/Objective-C bridging (see [Using Swift with Cocoa and Objective-C](https://developer.apple.com/library/content/documentation/Swift/Conceptual/BuildingCocoaApps/InteractingWithCAPIs.html)), each of these three structures is accessible from Swift as a similarly-named class, which you can create by simply providing values for all the properties, as you'll see in the examples below.

## SampleDataDescriptor and loadRawSampleData()

*SampleDataDescriptor*, which is required when calling `loadRawSampleData()`, has an *SampleDescriptor* property (as described above) plus several additional properties to provide all the information ``Sampler`` needs about the sample:

* *sampleRateHz* is the sampling rate at which the sample data were acquired. If the sampler needs to play back the sample at a different rate, it will need to scale its playback rate based on the ratio of the two rates.
* *nChannels* will be 1 if the sample is monophonic, or 2 if stereo. Note the sampler can play back mono samples as stereo; it simply plays the same data to both output channels. (In the reverse case, only the Left channel data will sound.)
* *bInterleaved* should be set *true* only for stereo samples represented in memory as Left1, Right1, Left2, Right2, etc. Set *false* for mono samples, or non-interleaved stereo samples where all the Left samples come first, followed by all the Right samples.
* *pSamples* is a pointer to the raw sample data; it has the slightly-scary Swift type *UnsafeMutablePointer\<Float\>*.

Here's an example of creating a sample programmatically in Swift, and loading it using `loadRawSampleData()`:

    var myData = [Float](repeating: 0.0, count: 1000)
    for i in 0..<1000 {
        myData[i] = sin(2.0 * Float(i)/1000 * Float.pi)
    }
    let sampleRate = Float(Settings.sampleRate)
    let desc = SampleDescriptor(noteNumber: 69,
                                      noteHz: sampleRate/1000,
                                    min_note: -1,
                                    max_note: -1,
                                     min_vel: -1,
                                     max_vel: -1,
                                       bLoop: true,
                                  fLoopStart: 0,
                                    fLoopEnd: 1,
                                      fStart: 0,
                                        fEnd: 0)
    let ptr = UnsafeMutablePointer<Float>(mutating: myData)
    let ddesc = SampleDataDescriptor(sd: desc,
                             sampleRateHz: sampleRate,
                             bInterleaved: false,
                                nChannels: 1,
                                 nSamples: 1000,
                                    pData: ptr)
    sampler.loadRawSampleData(sdd: ddesc)
    sampler.setLoop(thruRelease: true)
    sampler.buildSimpleKeyMap()

A few points to note about this example:

* We get the scary-typed pointer by calling the pointer type's `init(mutating:)` function
* `Settings.sampleRate` provides the current audio sampling rate
* Since we have only one note, the `noteNumber` can be anything
* We can set `min_note` etc. to -1, because we call `buildSimpleKeyMap()` not `buildKeyMap()`
* `fLoopStart` and `fLoopEnd` are normally sample counts (i.e., we could specify 0.0 and 999.0 to loop over the whole sample), but values between 0 and 1 are interpreted as *fractions* of the full sample length. Hence we can just use 0 to mean "start of the sample" and 1 to mean "end of the sample".
* setting `fEnd` to 0 also means "end of the sample"
* To ensure the sampler keeps looping even after each note is released (very important with such short samples), we call `setLoop(thruRelease: true)`.

## SampleFileDescriptor and loadCompressedSampleFile()
*SampleFileDescriptor*, used in calls to `loadCompressedSampleFile()` is very simple. Like *SampleDataDescriptor*, it has an *SampleDescriptor* property, to which it simply adds a `String` property `path`. Here's an example of using `loadCompressedSampleFile()`, taken from the Sampler demo program:

    private func loadCompressed(baseURL: URL,
                             noteNumber: MIDINoteNumber,
                             folderName: String,
                             fileEnding: String,
                               min_note: Int32 = -1,
                               max_note: Int32 = -1,
                               min_vel: Int32 = -1,
                               max_vel: Int32 = -1)
    {
        let folderURL = baseURL.appendingPathComponent(folderName)
        let fileName = folderName + fileEnding
        let fileURL = folderURL.appendingPathComponent(fileName)
        let freq = float(PolyphonicNode.tuningTable.frequency(forNoteNumber: noteNumber))
        let sd = SampleDescriptor(noteNumber: Int32(noteNumber),
                                        noteHz: freq,
                                      min_note: min_note,
                                      max_note: max_note,
                                       min_vel: min_vel,
                                       max_vel: max_vel,
                                         bLoop: true,
                                    fLoopStart: 0.2,
                                      fLoopEnd: 0.3,
                                        fStart: 0.0,
                                          fEnd: 0.0)
        let fdesc = SampleFileDescriptor(sd: sd, path: fileURL.path)
        sampler.loadCompressedSampleFile(sfd: fdesc)
    }

Note in the last line of the code above, `sampler` is a ``Sampler`` instance. See the *Conductor.swift* file in the SamplerDemo macOS example for more context.
