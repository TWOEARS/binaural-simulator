test_startup;

%% processing paramet
sim = simulator.SimulatorConvexRoom('test_brs.xml');  % simulator object

%% initialization
% note that all the parameters including objects' positions have to be
% defined BEFORE initialization in order to init properly
sim.set('Init',true);

%% static scene, dynamic head

% brirs dataset limits head orientation from -90:90

% this should work (head orientation at 90)
sim.rotateHead(90, 'relative'); 
while sim.Time < 1.5
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end
sim.getCurrentHeadOrientation() 

% this should work (head orientation at -90)
sim.rotateHead(-90, 'absolute'); 
while sim.Time < 3
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end
sim.getCurrentHeadOrientation()

% this should work (head orientation at 0)
sim.rotateHead(90, 'relative'); 
while sim.Time < 4.5
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end
sim.getCurrentHeadOrientation()

% this should not work (head orientation still at 0)
try
  sim.rotateHead(100, 'absolute');
  while ~sim.isFinished()
    sim.set('Refresh',true);  % refresh all objects
    sim.set('Process',true);
  end
catch
  fprintf('we successfully produced an error!\n');
end
sim.getCurrentHeadOrientation()

% save file
sim.Sinks.saveFile('out_brs.wav',sim.SampleRate);
%% clean up
sim.set('ShutDown',true);
