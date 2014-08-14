% Script for testing the MEX file for the Binaural renderer

clear all
close all

test_startup;

%% input signals
[input] = ...
  audioread(dbGetFile('stimuli/anechoic/instruments/anechoic_cello.wav'));

input = single(input(:,1)./max(abs(input(:,1))));

%% processing parameters

sim = SimulatorConvexRoom();  % simulator object
sim.loadConfig('test.xml');

%% initialization
% note that all the parameters including objects' positions have to be
% defined BEFORE initialization in order to init properly
sim.set('Init',true);

sim.draw();

%% event based scene

while ~sim.Sources(2).isEmpty();
  sim.set('Refresh',true);
  sim.set('Process',true);
end

sim.Sinks.saveFile('out_static.wav',sim.SampleRate);

%% dynamic scene (dynamic scene, static head)
position = [];  % reset source position

% reset inputbuffer
sim.Sources(1).AudioBuffer.setData(input);
sim.Sources(2).set('Mute', true);

% The SoundScapeRenderer (core of the Simulator) processes the input signal
% in a blockwise manner. This implies an internal memory of the renderer saving
% a scene history over a certain time. To start a new simulation, you have to 
% clear the history. Be sure that you have set all the parameters to start with
% in the new simulation BEFORE running 'ReInit'.
sim.set('ReInit',true);

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
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);  % processing 
end

sim.Sinks.saveFile('out_dynamic1.wav',sim.SampleRate);

%% dynamic scene (dynamic head, static scene)

% reset outputbuffer
sim.Sinks.removeData();

% source should be in front (distance: 1m)
sim.Sources(1).set('Position', [0; 1.0; 1.75]);
sim.Sources(1).AudioBuffer.setData(input);
sim.Sources(1).set('Mute', false);

sim.Sources(2).set('Mute', true);

sim.Sinks.set('Position', [0; 0; 1.75]);
sim.Sinks.set('UnitFront', [cosd(30); sind(30); 0]);

sim.set('ReInit',true);

% head should rotate from 30 to 150 degree with 10 degrees per second
sim.Sinks.setDynamic('UnitFront', 'Velocity', 10);
sim.Sinks.set('UnitFront', [cosd(150); sind(150); 0]);

while ~sim.Sources(1).isEmpty()
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end

sim.Sinks.saveFile('out_dynamic2.wav',sim.SampleRate);

%% clean up
sim.set('ShutDown',true);
