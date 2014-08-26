clear all
close all

test_startup;

%% processing paramet
sim = SimulatorConvexRoom('test_binaural.xml');  % simulator object

%% initialization
% note that all the parameters including objects' positions have to be
% defined BEFORE initialization in order to init properly
sim.set('Init',true);

%% dynamic scene

% move first source with 0.25 meters per seconds
sim.Sources{1}.setDynamic('Position', 'Velocity', 0.25);
sim.Sources{1}.set('Position', [1; -2; 1.75]);

while ~sim.isFinished()
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end

sim.plot();

% save file
sim.Sinks.saveFile('out_binaural.wav',sim.SampleRate);
%% clean up
sim.set('ShutDown',true);
