test_startup;

%% processing paramet
sim = simulator.SimulatorConvexRoom('test_diffuse.xml');  % simulator object

%% initialization
% note that all the parameters including objects' positions have to be
% defined BEFORE initialization in order to init properly
sim.set('Init',true);

%% dynamic scene

while ~sim.isFinished()
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end

sim.plot();

% save file
sim.Sinks.saveFile('out_diffuse.wav',sim.SampleRate);
%% clean up
sim.set('ShutDown',true);
