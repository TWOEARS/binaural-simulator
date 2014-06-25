% Script for testing the MEX file for the Binaural renderer

clear all
close all

test_startup; 
%% input signals

% input
[input{1}] = ...
  audioread('../../twoears-data/stimuli/anechoic/instruments/anechoic_cello.wav');
[input{2}, fs] = ...
  audioread('../../twoears-data/stimuli/anechoic/instruments/anechoic_castanets.wav');
[input{3}] = ...
  audioread('../../twoears-data/stimuli/binaural/binaural_forest.wav');

% SSR works with single-precision
input{1} = single(input{1}(:,1)./max(abs(input{1}(:,1))));
input{2} = single(input{2}(:,1)./max(abs(input{2}(:,1))));
%
input{3} = single(0.10*input{3}./max(abs(input{3}(:))));

%% processing parameters
% Sources
source(1) = AudioSource(AudioSourceType.POINT,buffer.FIFO());
source(2) = AudioSource(AudioSourceType.POINT,buffer.FIFO());

% Sinks/Head
head = AudioSink(2);

% Diffuse Forest Noise
source(3) = AudioSource(AudioSourceType.DIRECT,buffer.Ring([1,2]));
source(3).AudioBuffer.setData(input{3});
% White Noise
source(4) = AudioSource(AudioSourceType.DIRECT,buffer.Noise([1,2]));
source(4).AudioBuffer.set(...
  'Variance', 0.02, ...
  'Mean', 0.0);

% HRIRs
% construct
hrir = DirectionalIR( ...
  '../../twoears-data/impulse_responses/qu_kemar_anechoic/QU_KEMAR_anechoic_3m.wav');  
hrir.plot();  % plot hrirs

% Reflectors
reflector = Wall();
reflector.set(...
  'Position', [-1; -3.5; 0], ...
  'UnitFront', [0; 0; 1.0], ...
  'UnitUp', [0; 1.0; 0.0], ...
  'Vertices', [0.0, 0.0; 3.0, 0.0; 3.0, 5.0; 0.0, 5.0;]', ...
  'ReflectionCoeff', 0.8);
reflector = reflector.createUniformPrism(2.80, '3D'); % rectangular room

% Simulator
sim = SimulatorConvexRoom();  % simulator object

sim.set(...
  'SampleRate', fs, ...           % sampling frequency
  'BlockSize', 2^12, ...          % blocksize
  'NumberOfThreads', 1, ...       % number of threads
  'MaximumDelay', 0.0, ...        % maximum distance delay in seconds
  'Renderer', @ssr_binaural, ...  % SSR rendering function (do not change this!)
  'HRIRDataset', hrir, ...
  'Sources', source, ...
  'Sinks', head, ...
  'Walls', reflector, ...
  'ReverberationMaxOrder', 1);
%% initialization
sim.set('Init',true);

%% static scene

% head is looking to positive x
head.set('Position', [0; 0; 1.75]);
head.set('UnitFront', [1.0; 0.0; 0.0]);
head.removeData();

% source should be on the left (distance: 1m)
source(1).set('Position', [0; 1.0; 1.75]);
source(1).AudioBuffer.setData(input{1});
source(1).set('Mute', false);

% source should be on the right (distance: 3m)
source(2).set('Position', [0; -3.0; 1.75]);
source(2).AudioBuffer.setData(input{2});
source(2).set('Mute', false);

sim.set('Refresh',true);
sim.draw();

while ~source(1).isEmpty()
  sim.set('Process',true);
end

out = head.getData();
out = out/max(abs(out(:))); % normalize
audiowrite('out_static.wav',out,sim.SampleRate);

%% dynamic scene (dynamic scene, static head)
position = [];  % reset source position

% the SoundScapeRenderer (core of the Simulator) processes the input signal
% in a blockwise manner. This implies an internal memory of the renderer.
% To start a new simulation, you have to clear the memory
sim.set('ClearMemory',true);

% reset inputbuffer
source(1).AudioBuffer.setData(input{1});
source(2).set('Mute', true);

% reset outputbuffer
head.removeData();

% for dynamic scenes:
%   * devide your input signal into smaller parts
%   * set invidual source positions for each part
%   * process the i-th part by sim.process(input(i_begin:i_end,:))

partsize = 32;
signallength = size(input{1}, 1);
parts = ceil(signallength/partsize);

% vary source position on a shifted circle
fr = 0.33;
alpha = 2*pi*fr/sim.SampleRate*partsize*(0:parts-1);
position(:,:,1) = [2.0*sin(alpha);-1.0+2.0*cos(alpha); 1.75*ones(size(alpha))];
position = permute(position,[1 3 2]);

idx = 0;
while ~source(1).isEmpty()
  idx = idx + 1;
  pos_idx = floor( (idx-1)*sim.BlockSize/partsize ) + 1;
  source(1).set('Position', position(:,:,pos_idx));  % apply new source position
  sim.set('Refresh',true);  % refresh image sources
  sim.set('Process',true);  % refresh image sources
end

out = head.getData();
out = out/max(abs(out(:))); % normalize
audiowrite('out_dynamic.wav',out,sim.SampleRate);

%% dynamic scene (dynamic head, static scene)

% the SoundScapeRenderer (core of the Simulator) processes the input signal
% in a blockwise manner. This implies an internal memory of the renderer.
% To start a new simulation, you have to clear the memory
sim.set('ClearMemory',true);

% reset outputbuffer
head.removeData();

% source should be in front (distance: 1m)
source(1).set('Position', [0; 1.0; 1.75]);
source(1).AudioBuffer.setData(input{1});
source(1).set('Mute', false);

source(2).set('Mute', true);

head.set('Position', [0; 0; 1.75]);
% head should move from left to right
%head.set('Position', [-2.0; 0.0; 1.75]);
%head.setDynamic('Position', 'Velocity',[0.4; 0.4; inf]);
%head.set('Position', [2.0; 0.0; 1.75]);

% head should rotate from 30 to 150 degree with 10 degrees per second
head.set('UnitFront', [cosd(30); sind(30); 0]);
head.setDynamic('UnitFront', 'Velocity', 10);
head.set('UnitFront', [cosd(150); sind(150); 0]);

while ~source(1).isEmpty()
  sim.set('Refresh',true);  % refresh image sources
  sim.set('Process',true);
end

out = head.getData();
out = out/max(abs(out(:))); % normalize
audiowrite('out_dynamic2.wav',out,sim.SampleRate);

%% clean up
sim.set('ShutDown',true);
