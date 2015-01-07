Two!Ears Binaural Simulator
===========================

The Two!Ears binaural simulator enables the creation of binaural audio signals
for different situations. This is done via the usage of head-related transfer
functions (HRTFs) or binaural room impulse responses (BRIRs), which are provided
in the [Two!Ears data] repository.

## Installation

### Prerequisites

#### Linux/Mac

* Debian or Debian-based Linux operating system (e.g. Ubuntu) recommended
* matlab + mex-compiler
* packages (install with apt-get, aptitude, synaptic, macports, ...)
    * **make**
    * **g++** (at least version 4.7.3)
    * **libsndfile1-dev**
    * **libxml2-dev**
    * **libfftw3-dev**
* optional: get SoundScape Renderer (location will be denoted as `SSR_DIR`)
    <pre>
    git clone https://github.com/TWOEARS/twoears-ssr.git SSR_DIR
    git checkout origin/master -b master
    </pre>

#### Windows 7 64bit

* get SoundScape Renderer (location will be denoted as `SSR_DIR`)
    <pre>
    git clone https://github.com/TWOEARS/twoears-ssr.git SSR_DIR
    git checkout origin/win64 -b win64
    </pre>
* add `SSR_DIR\3rdparty\win64\bin` to PATH enviroment variable ([HOWTO](http://www.computerhope.com/issues/ch000549.htm))

* optional: get [MinGW 64bit](http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/4.8.2/threads-win32/seh/x86_64-4.8.2-release-win32-seh-rt_v3-rev4.7z/download) (location will be denoted as `MINGW_DIR`)
* optional: get [MSYS](http://sourceforge.net/projects/mingw-w64/files/External%20binary%20packages%20%28Win64%20hosted%29/MSYS%20%2832-bit%29/MSYS-20111123.zip/download) (location will be denoted as `MSYS_DIR`)

### MEX Binaries

#### Linux/Mac

##### Alternative 1
* use the pre-compiled binaries provided inside `src/mex`

##### Alternative 2 (requires optional prerequisites)
* switch to directory containing the mex-files
    <pre>
    cd SSR_DIR/mex/
    </pre>
* if you are using a Mac and installed Matlab at /Applications/MATLAB_R2013a.app
    <pre>
    export PATH="/Applications/MATLAB_R2013a.app/bin:$PATH"
    export CPPFLAGS="-I/Applications/MATLAB_R2013a.app/extern/include"
    </pre>
* generate mex-files
    <pre>
    make matlab
    </pre>
* If you get an error saying that the version of `GLIBCXX` is not correct this is due to the usage of the Matlab provided libstdc++ which is for an older gcc version. You can solve this by deleting linking it to your system libstdc++ via
    <pre>
    ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.<LIBSTDC-VERSION> /usr/local/MATLAB/MATLAB-VERSION/bin/glnxa64/libstdc++.so.6
    </pre>
* open Matlab and add `SSR_DIR/mex/` to MATLAB-path using `pathtool` or `addpath`

#### Windows 7 64bit

##### Alternative 1
* use the pre-compiled binaries provided inside `src/mex`

##### Alternative 2 (requires optional prerequisites)
* edit `SSR_DIR/mex/win64/Makefile` and set the `MATLABROOT` to the location of your systems MATLAB
* edit or create `MSYS_DIR\etc\fstab` and add mounts for `MINGW_DIR` and `SSR_DIR`
    <pre>
    MINGW_DIR    /mingw
    SSR_DIR      /ssr
    </pre>
* start the shell by executing `MSYS_DIR/msys.bat`
* switch to directory and compile sources
    <pre>
    cd /ssr/mex/win64
    make
    </pre>
* open Matlab and add `SSR_DIR/mex/` to MATLAB-path using `pathtool` or `addpath`

## Usage

If you want to use the
[Two!Ears Binaural Simulator](https://github.com/TWOEARS/binaural-simulator)
without any other part of the
[Two!Ears Auditory Model](https://github.com/TWOEARS/TwoEars)
you can start it as a single module with the
`startTwoEars` function which is part of the
[Two!Ears Auditory Model](https://github.com/TWOEARS/TwoEars) repository.

```Matlab
startTwoEars('BinauralSimulator.xml');
```
### Configuration

There are basically two ways for controlling and configurating the binaural
simulator.

#### Configuration using MATLAB script

The binaural simulator uses the object-oriented programming architecture of
MATLAB. In order to initialize the simulation tool an Object of the
`SimulatorConvexRoom()`-Class has to be instantiated by

```Matlab
sim = simulator.SimulatorConvexRoom();
```

Note that the constructor returns a handle, which is the pendant to a reference
of an object in other programming language. Assigning `sim` to a another
variable does not copy the object. It is not recommended to instantiate
more than one object of the `SimulatorConvexRoom()`-Class by calling the
constructor multiple times. To see all configurable parameters of the
simulator call the object's name in MATLAB:

```Matlab
>> sim

sim =

  SimulatorConvexRoom with properties:

                BlockSize: 4096
               SampleRate: 44100
          NumberOfThreads: 1
                 Renderer: @ssr_binaural
              HRIRDataset: [1x1 simulator.DirectionalIR]
             MaximumDelay: 0.0500
                 PreDelay: 0
       LengthOfSimulation: 5
                  Sources: {[1x1 simulator.source.Point]  [1x1 simulator.source.Point]}
                    Sinks: [1x1 simulator.AudioSink]
                    Walls: []
    ReverberationRoomType: 'shoebox'
    ReverberationMaxOrder: 0
```
In order to change various processing parameters of the simulator the build-in
set/get functionality of MATLAB should be used, e.g.

```Matlab
% some processing parameters
set(sim, ...
  'BlockSize', 4096, ...
  'SampleRate', 44100, ...
  );
```

Line 4 to 8 set the sample rate of the simulator to 44.1 kHz and defines a block
size aka. frame size of 4096 Samples. To define the acoustic scene, e.g.
the sound sources and the listener.

```Matlab
% acoustic scene
set(sim, ...
  'Sources', {simulator.source.Point(), simulator.source.Point()}, ...
  'Sinks', simulator.AudioSink(2) ...
  );
```

Sound sources are stored in a cell array. Line 3 defines two point sources,
are created by calling the constructor of the `simulator.source.Point`-class.
For the binaural simulation the parameter `Sinks` must contain only one object
of the `simulator.AudioSink`-Class describing the listener (Line 4). The
argument `2` in the contructor's call defines the number of input channel of
the sink, which is 2 for binaural signals. Since sources and sinks are also
handles, they can be accessed using the same set/get procedure as for the
simulator object, e.g.:

```Matlab
% set parameters of audio sources
set(sim.Sources{1}, ...
  'AudioBuffer', simulator.buffer.FIFO(1), ...
  'Position', [1; 2; 1.75], ...
  'Name', 'Cello', ...
  'Volume', 0.4 ...
  );
% set parameters of head
set(sim.Sinks, ...
  'Position' , [0; 0; 1.75], ...
  'UnitFront', [1; 0; 0], ...
  'UnitUp', [0; 0; 1], ...
  'Name', 'Head' ...
  );
```

`Name` (Line 5 and 13) defines an unique identifier for the scene object, which
should not be re-used for any other scene object. `Position` (Line 4 and 10)
defines the position of the scene object in 3D cartesian coordinates. In order
to emit sound from a sound source, a audio buffer has to be defined, which
contains the source's audio signal. In Line 3 a simple FIFO-Buffer
(First-In-First-Out) is defined. Again, the argument of the constructor defines
the number of channels. For more details about possible buffer types please
refer to the [API documentation on buffers]. To load a sound file into the
buffer execute

```Matlab
% set audio input of buffers
set(sim.Sources{1}.AudioBuffer, ...
  'File', 'stimuli/anechoic/instruments/anechoic_cello.wav');
```

#### Configuration using XML Scene Description

```Matlab
sim = SimulatorConvexRoom('scene_description.xml');
```

### Simulate direct sound

Explain how to use HRTFs


### Dynamic scenes

Explain how to rotate the head and how to create moving sources.


### Simulate rooms

Explain how to incorporate rooms from BRIRs, image source model, and plane waves
for diffuse sound.


### Incorporate binaural room scanning files

Explain how to use BRS files used with the SoundScape Renderer.


## License

[GNU General Public License, version 2]


[API documentation]:https://twoears.github.io/binaural-simulator-doc
[API documentation on buffers]:http://twoears.github.io/binaural-simulator-doc/namespacesimulator_1_1buffer.html

[Two!Ears data]:https://gitlab.tubit.tu-berlin.de/twoears/data/tree/master
[GNU General Public License, version 2]:http://www.gnu.org/licenses/gpl-2.0.html
