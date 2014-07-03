% Script for testing the MEX file for the Binaural renderer

clear all
close all

test_startup;

%% input signals
[input] = ...
  audioread(dbGetFile('stimuli/anechoic/instruments/anechoic_cello.wav'));

input = single(input(:,1)./max(abs(input(:,1))));

%% processing parameters

xml.dbValidate('test.xml');

theDoc = xmlread('test.xml');
theNode = theDoc.getDocumentElement;

sim = SimulatorConvexRoom();  % simulator object

sim.XML(theNode);

%% initialization
sim.set('Init',true);

%% static scene

sim.set('Refresh',true);
sim.draw();

while ~sim.Sources(2).isEmpty();
  sim.set('Process',true);
end

out = sim.Sinks.getData();
out = out/max(abs(out(:))); % normalize
audiowrite('out_xml.wav',out,sim.SampleRate);

%% dynamic scene (dynamic scene, static head)
position = [];  % reset source position

% the SoundScapeRenderer (core of the Simulator) processes the input signal
% in a blockwise manner. This implies an internal memory of the renderer.
% To start a new simulation, you have to clear the memory
sim.set('ClearMemory',true);

% reset inputbuffer
sim.Sources(1).AudioBuffer.setData(input);
sim.Sources(2).set('Mute', true);

% reset outputbuffer
sim.Sinks.removeData();

% for dynamic scenes:
%   * devide your input signal into smaller parts
%   * set invidual source positions for each part
%   * process the i-th part by sim.process(input(i_begin:i_end,:))

partsize = 32;
signallength = size(input, 1);
parts = ceil(signallength/partsize);

% vary source position on a shifted circle
fr = 0.33;
alpha = 2*pi*fr/sim.SampleRate*partsize*(0:parts-1);
position(:,:,1) = [2.0*sin(alpha);-1.0+2.0*cos(alpha); 1.75*ones(size(alpha))];
position = permute(position,[1 3 2]);

idx = 0;
while ~sim.Sources(1).isEmpty()
  idx = idx + 1;
  pos_idx = floor( (idx-1)*sim.BlockSize/partsize ) + 1;
  sim.Sources(1).set('Position', position(:,:,pos_idx));  % apply new source position
  sim.set('Refresh',true);  % refresh image sources
  sim.set('Process',true);  % refresh image sources
end

out = sim.Sinks.getData();
out = out/max(abs(out(:))); % normalize
audiowrite('out_dynamic.wav',out,sim.SampleRate);

%% dynamic scene (dynamic head, static scene)

% the SoundScapeRenderer (core of the Simulator) processes the input signal
% in a blockwise manner. This implies an internal memory of the renderer.
% To start a new simulation, you have to clear the memory
sim.set('ClearMemory',true);

% reset outputbuffer
sim.Sinks.removeData();

% source should be in front (distance: 1m)
sim.Sources(1).set('Position', [0; 1.0; 1.75]);
sim.Sources(1).AudioBuffer.setData(input);
sim.Sources(1).set('Mute', false);

sim.Sources(2).set('Mute', true);

sim.Sinks.set('Position', [0; 0; 1.75]);
% head should move from left to right
%head.set('Position', [-2.0; 0.0; 1.75]);
%head.setDynamic('Position', 'Velocity',[0.4; 0.4; inf]);
%head.set('Position', [2.0; 0.0; 1.75]);

% head should rotate from 30 to 150 degree with 10 degrees per second
sim.Sinks.set('UnitFront', [cosd(30); sind(30); 0]);
sim.Sinks.setDynamic('UnitFront', 'Velocity', 10);
sim.Sinks.set('UnitFront', [cosd(150); sind(150); 0]);

while ~sim.Sources(1).isEmpty()
  sim.set('Refresh',true);  % refresh image sources
  sim.set('Process',true);
end

out = sim.Sinks.getData();
out = out/max(abs(out(:))); % normalize
audiowrite('out_dynamic2.wav',out,sim.SampleRate);

%% clean up
sim.set('ShutDown',true);
