% Script for testing the MEX file for the Binaural renderer

clear all
close all

test_startup; 

%% Noise Source

% angles of diffuse source (CAUTION: propagation direction is defined)
angles = (90:5:135);
directions = [cosd(angles);sind(angles); zeros(1, length(angles))];

% ChannelMapping defines which input signal is mapped to an output of an 
% audio source. If you're not sure, just use a 1-to-1 Mapping by
% [1,2,3,..., N]
ChannelMapping = 1:length(angles);

% NoiseBuffer with white gaussian noise
NoiseBuffer = buffer.Noise(ChannelMapping);
NoiseBuffer.set(...
  'Variance', 0.02, ...
  'Mean', 0.0);

% Source
noise = AudioSource(...         % define AudioSource with .. 
  AudioSourceType.PWD, ...      % PlaneWaveDecomposition Type
  NoiseBuffer, ...              % Buffer as signal source;
  directions);                  % directions of PWD

% set orientation of the Source to the unit vectors of the world coordinate
% system
noise.set(...
  'UnitFront', [0.0; 0.0; 1.0], ...
  'UnitUp', [0.0; 1.0; 0.0]);

%% Direct Source
% angle of direct source
sourceangle = 60;
distance = 3;

% SourceBuffer with file
SourceBuffer = buffer.FIFO();
input = audioread(xml.dbGetFile( ...
  'stimuli/anechoic/instruments/anechoic_castanets.wav'));
SourceBuffer.setData(input);

% Source
source = AudioSource(...        % define AudioSource with .. 
  AudioSourceType.POINT, ...    % Point Source Type
  SourceBuffer);                % Buffer as signal source

source.set('Position', distance*[cosd(sourceangle);sind(sourceangle); 0]); 

%% Other Parameters

% Sinks/Head
head = AudioSink(2);
head.set('Position', [0; 0; 1.75]);  
head.set('UnitFront', [1.0; 0.0; 0.0]);  % head is looking to positive x

% HRIRs
hrir = DirectionalIR( ...
  xml.dbGetFile('impulse_responses/qu_kemar_anechoic/QU_KEMAR_anechoic_3m.wav'));  
hrir.plot();  % plot hrirs

% Simulator
sim = SimulatorConvexRoom();  % simulator object

sim.set(...
  'SampleRate', 44100, ...        % sampling frequency
  'BlockSize', 2^12, ...          % blocksize
  'NumberOfThreads', 1, ...       % number of threads
  'MaximumDelay', 0.0, ...        % maximum distance delay in seconds
  'Renderer', @ssr_binaural, ...  % SSR rendering function (do not change this!)
  'HRIRDataset', hrir, ...        % assign HRIR-Object to Simulator
  'Sources', [source, noise], ... % assign sources to Simulator
  'Sinks', head);                 % assign sinks to Simulator
%% processing of direct signal
noise.set('Mute', true);

% always 'ReInit' AFTER setting the start parameters
sim.set('Init',true);

% 5 seconds processing
for idx=1:ceil(5*sim.SampleRate/sim.BlockSize)
  sim.set('Process',true);
end

out = head.getData();
out = out/max(abs(out(:))); % normalize
audiowrite('out_direct.wav',out,sim.SampleRate);
%% processing of noise source signal
head.removeData();

noise.set('Mute', false);
source.set('Mute', true);

% always 'ReInit' AFTER setting the start parameters
sim.set('ReInit',true);

sim.draw();

% 5 seconds processing
for idx=1:ceil(5*sim.SampleRate/sim.BlockSize)
  sim.set('Process',true);
end

out = head.getData();
out = out/max(abs(out(:))); % normalize
audiowrite('out_diffuse.wav',out,sim.SampleRate);

%% clean up
sim.set('ShutDown',true);
