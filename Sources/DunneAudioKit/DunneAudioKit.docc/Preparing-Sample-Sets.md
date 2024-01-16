# Sampler sample sets

Preparing sets of samples for ``Sampler`` involves a few steps and lot of testing. 

We suggest to approach it in four steps:
1. Preparing (or acquiring) sample files
2. Compressing sample files
3. Creating a SFZ metadata file
4. Testing

This document describes the process of preparing a set of demonstration samples, starting with the sample files included with [ROMPlayer](https://github.com/AudioKit/ROMPlayer).

You can download the finished SFZ and samples from [this link](https://github.com/AudioKit/ROMPlayer/tree/master/RomPlayer/Sounds/sfz).

## Preparing/acquiring sample files
The demo samples were recorded and prepared by Matthew Fecher from a Yamaha TX81z hardware FM synthesizer module, using commercial sampling software called [SampleRobot](http://www.samplerobot.com). If you have *MainStage 3* on the Mac, you can use its excellent *autosampler* function instead. See <doc:Sampler-SFZ-files>

**Important:** If you're planning to work with existing samples, or capture the output from a sample-based instrument, *give careful consideration to copyright issues*. See Matt Fecher's excellent summary [What Sounds Can You Use in your App?](https://github.com/AudioKit/ROMPlayer#what-sounds-can-you-use-in-your-app) *Be very careful with SoundFont files you find on the Internet.* Many are marked "public domain", but actually consist of unlicensed, illegally copied content. While such things are fine for your own personal use, distributing them publicly with your name attached (e.g. in an iOS app on the App Store) can land you in serious legal trouble.

Turning a set of rough digital recordings into cleanly-playing, looping samples is a complex process in itself, which is beyond the scope of this document. For a quick introduction, see [The Secrets of Great Sounding Samples](http://tweakheadz.com/sampling-tips/). For in-depth exploration, look into YouTube videos by [John Lemkuhl aka PlugInGuru](https://www.youtube.com/user/thepluginguru), in particular [this one](https://youtu.be/o7rL38xrRSE), [this one](https://youtu.be/qPbf5nNyQYo) and [this one](https://youtu.be/Bx9PC8JJNGg).

## Sample file compression
``Sampler`` reads `.wv` files compressed using the open-source [Wavpack](http://www.wavpack.com) software. On the Mac, you must first install the Wavpack command-line tools. Then you can use the following Python 2 script to compress a whole folder-full of `.wav` files:

```python
import os, subprocess

for wav in os.listdir('.'):
  if os.path.isfile(wav) and aif.endswith('.wav'):
    print 'converting', wav
    name = wav[:-4]
    wv = name + '.wv'
    subprocess.call(['/usr/local/bin/wavpack', '-q', '-r', '-b24', wav])
    #os.remove(wav)
```
Uncomment the last line if you're sure you want to delete WAV files after converting them.

Note that the `wavpack` command-line program does not recognize the `.aif` file format, which is too bad because that's what *MainStage 3*'s autosampler produces. However, we can use the `afconvert` command-line utility built into macOS to convert `.aif` files to `.wav` like this:

```python
import os, subprocess

for aif in os.listdir('.'):
  if os.path.isfile(aif) and aif.endswith('.aif'):
    print 'converting', aif
    name = aif[:-4]
    wav = name + '.wav'
    wv = name + '.wv'
    subprocess.call(['/usr/bin/afconvert', '-f', 'WAVE', '-d', 'LEI24', aif, wav])
    subprocess.call(['/usr/local/bin/wavpack', '-q', '-r', '-b24', wav])
    os.remove(wav)
    #os.remove(aif)
```

## Creating a SFZ metadata file
Mapping of MIDI (note-number, velocity) pairs to sample files requires additional data, for which ``Sampler`` uses a simple subset of the [SFZ format](https://en.wikipedia.org/wiki/SFZ_(file_format)) declared at https://sfzformat.com/headers/. SFZ is essentially a text-based, open-standard alternative to the proprietary [SoundFont](https://en.wikipedia.org/wiki/SoundFont) format.

In addition to key-mapping, SFZ files can also contain other important metadata such as loop-start and -end points for each sample file.

The full SFZ standard is very rich, but at the time of writing, ``Sampler``'s SFZ import capability is limited to key mapping and loop metadata only. The import capability also is strict about the order of the opcodes: check the sourcecode of `Sampler+SFZ.swift` and place your `sample=YOURSAMPLENAME.YOURFILEFORMAT` as the last element in the `<region>` line, otherwise the samples will not load.

Since SFZ files are simply plain-text files, you can use an ordinary text editor to create them.

You'll find more details and a simple example in the article <doc:Sampler-SFZ-files>.


## Other methods to create SFZ files

In [Software > Tools](https://sfzformat.com/software/tools/) of sfzformat.com you'll find some more tools to work with SFZ files. 

At the moment of this writing (January 2024) there is a freeware called EXS2SFZ by bjoernbojahr that does a good job in coverting EXS files. They will not be directly usable by ``Sampler`` but are a good starting point to edit the SFZ files manually. The resulting SFZ have opcodes in group that ``Sampler`` wants in region and the other way round as well as they don't follow the strict order needed by ``Sampler``.  

At the other end of the scale, a company called Chicken Systems sells a very powerful tool called [Translator](http://www.chickensys.com/products2/translator/), which can convert both sample and metadata to and from a huge list of professional formats, including EXS24 (Apple), SoundFont (SF2 and SFZ), Kontakt 5 (Native Instruments), and many more. The full version costs $149 (USD), but if you're only interested in converting to SFZ, you can buy the "Special Edition" for just $79.


## Testing
Whatever methods you use to create samples and metadata files, it's important to test, test, test, to make sure things are working the way you want.

## Going further
The subject of preparing sample sets is deep and complex, and this article has barely scratched the surface. We hope to provide additional online resources as time goes on, especially as ``Sampler``'s implementation expands and changes. Interested users, especially those with practical experience to share, are encouraged to get in touch with the AudioKit team to help with this process.
