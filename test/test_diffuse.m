% Script for testing the MEX file for the Binaural renderer

clear all
close all

test_startup; 

%% input signals

% input
[input{1}] = ...
  audioread(fullfile([database_path, 'stimuli/anechoic/instruments/anechoic_cello.wav']));
% SSR works with single-precision
input{1} = single(input{1}(:,1)./max(abs(input{1}(:,1))));

%% processing parameters
% Sources
% source(1) = AudioSource(AudioSourceType.POINT,buffer.FIFO());

angles = (-45:5:45);
source(1) = AudioSource(...
  AudioSourceType.PWD,buffer.Noise(1:length(angles)), ...
  [cosd(angles);sind(angles); zeros(1, length(angles))]);
source(1).set(...
  'UnitFront', [0.0; 0.0; 1.0], ...
  'UnitUp', [0.0; 1.0; 0.0]);

source(1).AudioBuffer.set(...
  'Variance', 0.02, ...
  'Mean', 0.0);

% Sinks/Head
head = AudioSink(2);

% HRIRs
% construct
hrir = DirectionalIR( ...
  fullfile([database_path, 'impulse_responses/qu_kemar_anechoic/QU_KEMAR_anechoic_3m.wav']));  
hrir.plot();  % plot hrirs

% Simulator
sim = SimulatorConvexRoom();  % simulator object

sim.set(...
  'SampleRate', 44100, ...           % sampling frequency
  'BlockSize', 2^12, ...          % blocksize
  'NumberOfThreads', 1, ...       % number of threads
  'MaximumDelay', 0.1, ...        % maximum distance delay in seconds
  'Renderer', @ssr_binaural, ...  % SSR rendering function (do not change this!)
  'HRIRDataset', hrir, ...
  'Sources', source, ...
  'Sinks', head);
%% initialization
sim.set('Init',true);

%% static scene

% head is looking to positive x
head.set('Position', [0; 0; 1.75]);
head.set('UnitFront', [1.0; 0.0; 0.0]);
head.removeData();

sim.set('Refresh',true);
sim.draw();

for idx=1:ceil(5*sim.SampleRate/sim.BlockSize)
  sim.set('Process',true);
end

out = head.getData();
out = out/max(abs(out(:))); % normalize
audiowrite('out_static.wav',out,sim.SampleRate);

%% clean up
sim.set('ShutDown',true);
