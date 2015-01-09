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
variable does not copy the object. The simulation framework is depending on
a simulation kernel written in C++/MEX. It is not recommended to instantiate
more than one object of the `SimulatorConvexRoom()`-Class by calling the
constructor multiple times, since all objects would access the same simulation
kernel. To see all configurable parameters of the simulator call the object's
name in MATLAB:

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

For a more detailed description of each parameter refer to the
[API documentation on the Simulator]. In order to change various processing
parameters of the simulator the build-in set/get functionality of MATLAB should
be used, e.g.

```Matlab
% some processing parameters
set(sim, ...
  'BlockSize', 4096, ...
  'SampleRate', 44100, ...
  'MaximumDelay', 0.05, ...
  'PreDelay', 0.0, ...
  'LengthOfSimulation', 5.0, ...
  'Renderer', @ssr_binaural, ...
  'HRIRDataset', simulator.DirectionalIR( ...
    'impulse_responses/qu_kemar_anechoic/QU_KEMAR_anechoic_3m.sofa') ...
  );
```

Line 3 and 4 set the sample rate of the simulator to 44.1 kHz and defines a block
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

set(sim.Sources{2}, ...
  'AudioBuffer', simulator.buffer.FIFO(1), ...
  'Position', [1; -2; 1.75], ...
  'Name', 'Castanets' ...
  );

% set parameters of head
set(sim.Sinks, ...
  'Position' , [0; 0; 1.75], ...
  'UnitFront', [1; 0; 0], ...
  'UnitUp', [0; 0; 1], ...
  'Name', 'Head' ...
  );
```

`Name` defines an unique identifier for the scene object, which
should not be re-used for any other scene object. `Position`
defines the position of the scene object in 3D cartesian coordinates (measured
in meter). In order to emit sound from a sound sources, audio buffers have to be
respectively defined containing the sources' audio signals. A single-channel
FIFO-Buffer (First-In-First-Out) can be defined by `simulator.buffer.FIFO(1)`.
For more details about possible buffer types please refer to the
[API documentation on buffers]. To load a sound files into the buffers execute

```Matlab
% set audio input of buffers
set(sim.Sources{1}.AudioBuffer, ...
  'File', 'stimuli/anechoic/instruments/anechoic_cello.wav');

set(sim.Sources{2}.AudioBuffer, ...
  'File', 'stimuli/anechoic/instruments/anechoic_castanets.wav');
```

All code snippets have been taken from example script `test_binaural_wo.m`
located in `./test`.

#### Configuration using XML Scene Description

In following the configuration as defined above using a MATLAB script is done
calling the constructor of the simulator object with an extra argument defining
the filename of a XML scene description file.

```Matlab
sim = simulator.SimulatorConvexRoom('test_binaural.xml');
```

The content of `test_binaural.xml` is shown below.

```XML
<scene
  BlockSize="4096"
  SampleRate="44100"
  MaximumDelay="0.05"
  PreDelay="0.0"
  LengthOfSimulation="5.0"
  NumberOfThreads="1"
  Renderer="ssr_binaural"
  HRIRs="impulse_responses/qu_kemar_anechoic/QU_KEMAR_anechoic_3m.sofa">
  <source Position="1 2 1.75"
          Type="point"
          Name="Cello"
          Volume="0.4">
    <buffer ChannelMapping="1"
            Type="fifo"
            File="stimuli/anechoic/instruments/anechoic_cello.wav"/>
  </source>
  <source Position="1 -2 1.75"
          Type="point"
          Name="Castanets">
    <buffer ChannelMapping="1"
            Type="fifo"
            File="stimuli/anechoic/instruments/anechoic_castanets.wav"/>
  </source>
  <sink Position="0 0 1.75"
        UnitFront="1 0 0"
        UnitUp="0 0 1"
        Name="Head"/>
</scene>
```

### Simulate Ear-Signals

After setting up all parameters the simulator object is ready to simulate ear
signals according to the defined acoustic scene. In order to load all parameters
into the simulation kernel execute

```Matlab
sim.set('Init',true);
```

Note, that all the processing parameters and objects' initial positions have to
be defined BEFORE initialization in order to initialize the simulation properly.
After the simulator has been initialized it is not possible to re-assign any
property of the simulator object. Hence the number of acoustic sources cannot be
changed within one simulation run. However, modifying e.g. the position of a
scene object is possible. The following loop calculates the ear signals until
the acoustic scene is finished.

```Matlab
while ~sim.isFinished()
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end
```

The function `sim.isFinished()` yields true if the buffers of all sound sources
are empty or if `sim.LengthOfSimulation` has been reached. Note, that the
simulator is a block-wise processor: Each call of line 3 generates a block of
ear signals whose length is defined by `sim.BlockSize`. Between two processing
steps, the properties of scene objects may be manipulated, e.g. the position of
a scene object is changed. If necessary, call line 2 once before processing a new
block in order to send any modification to the simulation kernel. The ear
signals are stored in the FIFO buffer of the `sim.Sinks` object.

```Matlab
% read whole data from buffer
data = sim.Sinks.getData();
% save date into file
sim.Sinks.saveFile('out_binaural.wav',sim.SampleRate);
```

In order to access or store the data line 2 or 4 may be used respectively. To
finish the simulation shut down and clean up the simulator by calling:

```Matlab
sim.set('ShutDown',true);
```

The simulator reverts to an uninitialized state, where the manipulation of every
parameter is possible, again. This is necessary, if you want to start a new
simulation with complete different parameters like e.g. different number of
sound sources. If you want to start a new simulation with same parameters as
before a kind of a weak shut down should do the job:

```Matlab
sim.set('ReInit',true);
```

Again, objects' initial positions have to be defined BEFORE re-initialization
in order to initialize the simulation properly. The simulator however remains in
an initialized state.

### Examples

#### Simulate direct sound

Explain how to use HRTFs


#### Dynamic scenes

Explain how to rotate the head and how to create moving sources.


#### Simulate rooms

Explain how to incorporate rooms from BRIRs, image source model, and plane waves
for diffuse sound.


#### Incorporate binaural room scanning files

Explain how to use BRS files used with the SoundScape Renderer.


## License

[GNU General Public License, version 2]


[API documentation]:https://twoears.github.io/binaural-simulator-doc
[API documentation on the Simulator]:http://twoears.github.io/binaural-simulator-doc/classsimulator_1_1_simulator_interface.html
[API documentation on buffers]:http://twoears.github.io/binaural-simulator-doc/namespacesimulator_1_1buffer.html
[Two!Ears data]:https://gitlab.tubit.tu-berlin.de/twoears/data/tree/master
[GNU General Public License, version 2]:http://www.gnu.org/licenses/gpl-2.0.html
