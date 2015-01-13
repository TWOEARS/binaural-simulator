Two!Ears Binaural Simulator
===========================

The [Two!Ears Binaural Simulator] enables the creation of binaural audio signals
for different situations. This is done via the usage of head-related transfer
functions (HRTFs) or binaural room impulse responses (BRIRs), which are provided
in the [Two!Ears data] repository.
It can be used as one module in the [Two!Ears Auditory Model].


### Table of Contents

**[Installation](#Installation)**
**[Usage](#Usage)**
**[Examples](#Examples)**
**[Credits](#Credits)**
**[License](#License)**
**[Funding](#Funding)**


## Installation

### Prerequisites

#### Linux/Mac

* Debian or Debian-based Linux operating system (e.g. Ubuntu) recommended
* MATLAB + mex-compiler
* packages (install with apt-get, aptitude, synaptic, macports, ...)
  * **make**
  * **g++** (at least version 4.7.3)
  * **libsndfile1-dev**
  * **libxml2-dev**
  * **libfftw3-dev**
* optional: get SoundScape Renderer (location will be denoted as `SSR_DIR`)
  ```
  git clone https://github.com/TWOEARS/twoears-ssr.git SSR_DIR
  git checkout origin/master -b master
  ```

#### Windows 7 64bit

* get SoundScape Renderer (location will be denoted as `SSR_DIR`)
  ```
  git clone https://github.com/TWOEARS/twoears-ssr.git SSR_DIR
  git checkout origin/win64 -b win64
  ```
* add `SSR_DIR\3rdparty\win64\bin` to `PATH` environment variable ([HOWTO])

* optional: get [MinGW 64bit], location will be denoted as `MINGW_DIR`
* optional: get [MSYS], location will be denoted as `MSYS_DIR`

### MEX Binaries

#### Linux/Mac

##### Alternative 1
* use the pre-compiled binaries provided inside `src/mex`

##### Alternative 2 (requires optional prerequisites)
* switch to directory containing the mex-files
  ```
  cd SSR_DIR/mex/
  ```
* if you are using a Mac and installed MATLAB at `/Applications/MATLAB_R2013a.app`
  ```
  export PATH="/Applications/MATLAB_R2013a.app/bin:$PATH"
  export CPPFLAGS="-I/Applications/MATLAB_R2013a.app/extern/include"
  ```
* generate mex-files
  ```
  make matlab
  ```
* If you get an error saying that the version of `GLIBCXX` is not correct this
  is due to the usage of the MATLAB provided `libstdc++? which is for an older
  gcc version. You can solve this by deleting linking it to your system
  `libstdc++` via
    ```
    ln -s /usr/lib/x86_64-linux-gnu/libstdc++.so.<LIBSTDC-VERSION> \
          /usr/local/MATLAB/MATLAB-VERSION/bin/glnxa64/libstdc++.so.6
    ```

* open Matlab and add `SSR_DIR/mex/` to MATLAB-path using `pathtool` or `addpath`

#### Windows 7 64bit

##### Alternative 1
* use the pre-compiled binaries provided inside `src/mex`

##### Alternative 2 (requires optional prerequisites)
* edit `SSR_DIR/mex/win64/Makefile` and set the `MATLABROOT` to the location of your systems MATLAB
* edit or create `MSYS_DIR\etc\fstab` and add mounts for `MINGW_DIR` and `SSR_DIR`
  ```
    MINGW_DIR    /mingw
    SSR_DIR      /ssr
  ```
* start the shell by executing `MSYS_DIR/msys.bat`
* switch to directory and compile sources
  ```
    cd /ssr/mex/win64
    make
  ```
* open Matlab and add `SSR_DIR/mex/` to MATLAB-path using `pathtool` or `addpath`


## Usage

If you want to use the [Two!Ears Binaural Simulator] without any other part of the
[Two!Ears Auditory Model] you can start it as a single module with the
`startTwoEars` function which is part of the [Two!Ears Auditory Model] repository.

```Matlab
startTwoEars('BinauralSimulator.xml');
```

### Configuration

There are basically two ways for controlling and configuring the binaural
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
argument `2` in the constructor's call defines the number of input channel of
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
defines the position of the scene object in 3D Cartesian coordinates (measured
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


## Examples

The following examples apply the configuration directly in MATLAB. For larger
setups it will be easier to use the [XML Scene Description](#Configuration
using XML Scene Description). Examples using the [XML Scene
Description](#Configuration using XML Scene Description) can be found in the
`test/` directory.

### Simulate two dry sources

In this example, two dry sources will be simulated and the binaural output is written to the file `out_two_sources.wav`.
One source is a cello placed to the left of the listener and the other source is castanets placed in the front of the listener.

```Matlab
sim = simulator.SimulatorConvexRoom();
set(sim, ...
    'HRIRDataset', simulator.DirectionalIR( ...
        'impulse_responses/qu_kemar_anechoic/QU_KEMAR_anechoic_3m.sofa'), ...
    'Sources', {simulator.source.Point(), simulator.source.Point()}, ...
    'Sinks',   simulator.AudioSink(2) ...
    );
set(sim.Sources{1}, ...
    'Name', 'Cello', ...
    'Position', [1; 2; 0], ...
    'AudioBuffer', simulator.buffer.FIFO(1) ...
    );
set(sim.Sources{1}.AudioBuffer, ...
    'File', 'stimuli/anechoic/instruments/anechoic_cello.wav' ...
    );
set(sim.Sources{2}, ...
    'Name', 'Castanets', ...
    'Position', [0; 0; 0], ...
    'AudioBuffer', simulator.buffer.FIFO(1) ...
    );
set(sim.Sources{2}.AudioBuffer, ...
    'File', 'stimuli/anechoic/instruments/anechoic_castanets.wav' ...
    );
set(sim.Sinks, ...
    'Name', 'Head', ...
    'UnitFront', [1; 0; 0], ...
    'Position', [0; 0; 0] ...
    );
sim.set('Init',true);
while ~sim.isFinished()
    sim.set('Refresh',true);  % refresh all objects
    sim.set('Process',true);
end
data = sim.Sinks.getData();
sim.Sinks.saveFile('out_two_sources.wav',sim.SampleRate);
sim.set('ShutDown',true);
```

### Simulate a moving source

The following example simulates a dry cello that moves from the left to the right of the listener.

```Matlab
sim = simulator.SimulatorConvexRoom();
set(sim, ...
    'HRIRDataset', simulator.DirectionalIR( ...
        'impulse_responses/qu_kemar_anechoic/QU_KEMAR_anechoic_3m.sofa'), ...
    'Sources', {simulator.source.Point()}, ...
    'Sinks',   simulator.AudioSink(2) ...
    );
set(sim.Sources{1}, ...
    'Name', 'Cello', ...
    'Position', [1; 2; 0], ...
    'AudioBuffer', simulator.buffer.FIFO(1) ...
    );
set(sim.Sources{1}.AudioBuffer, ...
    'File', 'stimuli/anechoic/instruments/anechoic_cello.wav' ...
    );
sim.set('Init',true);
sim.Sources{1}.setDynamic( ...
    'Position', 'Velocity', 0.25); % move source with 0.25 m/s
set(sim.Sources{1}, ...
    'Position', [1; -2; 0] ... %end position
    );
while ~sim.isFinished()
    sim.set('Refresh',true);  % refresh all objects
    sim.set('Process',true);
end
data = sim.Sinks.getData();
sim.Sinks.saveFile('out_moving_source.wav',sim.SampleRate);
sim.set('ShutDown',true);
```

### Simulate rooms using the Image Source Model

The following example simulates a dry cello in a shoebox room

```MATLAB
sim = simulator.SimulatorConvexRoom();
set(sim, ...
    'MaximumDelay', 0.05, ...
    'PreDelay', 0.0, ...
    'ReverberationMaxOrder', 8,...
    'HRIRDataset', simulator.DirectionalIR( ...
        'impulse_responses/qu_kemar_anechoic/QU_KEMAR_anechoic_3m.sofa'), ...
    'Sources', {simulator.source.ISMShoeBox(sim)}, ...
    'Sinks', simulator.AudioSink(2), ...
    'Walls', simulator.Wall ...
    );
set(sim.Sources{1}, ...
    'Name', 'Cello', ...
    'Position', [2.5; 2.5; 0], ...
    'AudioBuffer', simulator.buffer.FIFO(1) ...
    );
set(sim.Sources{1}.AudioBuffer, ...
    'File', 'stimuli/anechoic/instruments/anechoic_cello.wav' ...
    );

% define floor of the room
set(sim.Walls(1), ...
    'Name', 'Room', ...
    'Vertices', [3 -3; 3 3; -3 3; -3 -3]', ...
    'Position', [0; 0; -1.75], ...
    'UnitFront', [0; 0; 1], ...
    'UnitUp', [0; 1; 0] ...
    );
% createUniformPrism(height, mode, RT60) creates the whole room
%   height:  height in metre of resulting room
%   mode:    '2D' for skipping the floor and the ceiling of the room
%            '3D' for including the floor and the ceiling of the room
%   RT60:    RT60 in seconds (used to calculate absorptions coefficients using
%            Sabine's formula
sim.Walls = sim.Walls(1).createUniformPrism(2.50, '2D', 2.3);

sim.set('Init',true);
while ~sim.isFinished()
    sim.set('Refresh',true);  % refresh all objects
    sim.set('Process',true);
end
data = sim.Sinks.getData();
sim.Sinks.saveFile('out_room.wav',sim.SampleRate);
sim.set('ShutDown',true);
```

### Simulate rooms using Binaural Room Impulse Responses

The following example simulates a cello in a reverberant environment

```MATLAB
sim = simulator.SimulatorConvexRoom();
set(sim, ...
    'Renderer', @ssr_brs, ...
    'Sources', {simulator.source.Point()}, ...
    'Sinks', simulator.AudioSink(2) ...
    );

set(sim.Sources{1}, ...
    'Name', 'Cello', ...
    'IRDataset', simulator.DirectionalIR( ...
      ['impulse_responses/qu_kemar_rooms/auditorium3/', ...
       'QU_KEMAR_Auditorium3_src3_xs+2.20_ys-1.94.sofa']), ...
    'AudioBuffer', simulator.buffer.FIFO(1) ...
    );

set(sim.Sources{1}.AudioBuffer, ...
    'File', 'stimuli/anechoic/instruments/anechoic_cello.wav' ...
    );

%% initialization
% note that all the parameters including objects' positions have to be
% defined BEFORE initialization in order to init properly
sim.set('Init',true);

%% static scene, dynamic head

% head should rotate about 170 degree to the right with 20 degrees per second
sim.Sinks.setDynamic('UnitFront', 'Velocity', 20);
sim.Sinks.set('UnitFront', [cosd(85); sind(85); 0]);

while ~sim.isFinished()
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end

% save file
sim.Sinks.saveFile('out_brs.wav',sim.SampleRate);
%% clean up
sim.set('ShutDown',true);
```


## Credits

The Two!Ears Binaural Simulator is developed by Fiete Winter from Universität Rostock, and
the rest of the [Two!Ears team].


## License

The Two!Ears Binaural Simulator is released under [GNU General Public License, version 2].


## Funding

This project has received funding from the European Union’s Seventh Framework
Programme for research, technological development and demonstration under grant
agreement no 618075.

![EU Flag](doc/img/eu-flag.gif) [![Tree](doc/img/tree.jpg)](http://cordis.europa.eu/fet-proactive/)


[MinGW 64bit]:http://sourceforge.net/projects/mingw-w64/files/Toolchains%20targetting%20Win64/Personal%20Builds/mingw-builds/4.8.2/threads-win32/seh/x86_64-4.8.2-release-win32-seh-rt_v3-rev4.7z/download
[MSYS]:http://sourceforge.net/projects/mingw-w64/files/External%20binary%20packages%20%28Win64%20hosted%29/MSYS%20%2832-bit%29/MSYS-20111123.zip/download
[HOWTO]:http://www.computerhope.com/issues/ch000549.htm
[API documentation]:https://twoears.github.io/binaural-simulator-doc
[API documentation on the Simulator]:http://twoears.github.io/binaural-simulator-doc/classsimulator_1_1_simulator_interface.html
[API documentation on buffers]:http://twoears.github.io/binaural-simulator-doc/namespacesimulator_1_1buffer.html
[Two!Ears data]:https://gitlab.tubit.tu-berlin.de/twoears/data/tree/master
[Two!Ears team]:http://twoears.aipa.tu-berlin.de/consortium
[Two!Ears Binaural Simulator]:https://github.com/TWOEARS/binaural-simulator
[Two!Ears Auditory Model]:https://github.com/TWOEARS/TwoEars
[GNU General Public License, version 2]:http://www.gnu.org/licenses/gpl-2.0.html
