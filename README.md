Two!Ears binaural simulator
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
* use the pre-compiled binaries provided inside `MAT_DIR/src/mex`

##### Alternative 2
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
* use the pre-compiled binaries provided inside `MAT_DIR/src/mex`

##### Alternative 2
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

Add descriptions for the following applications of the model and add a general
description at this position.

See the [API documentation] for further details.

### Configuration

Explain the usage of the xml-configuration file and the possibility to set the
values without configuration file.

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
[Two!Ears data]:https://gitlab.tubit.tu-berlin.de/twoears/data/tree/master
[GNU General Public License, version 2]:http://www.gnu.org/licenses/gpl-2.0.html
