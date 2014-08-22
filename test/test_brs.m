% Script for testing the MEX file for the Binaural renderer

clear all
close all

test_startup;

%% processing paramet
sim = SimulatorConvexRoom('test_brs.xml');  % simulator object

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
