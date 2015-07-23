test_startup;

%% processing paramet
sim = simulator.SimulatorConvexRoom('test_brs.xml');  % simulator object

%% initialization
% note that all the parameters including objects' positions have to be
% defined BEFORE initialization in order to init properly
sim.set('Init',true);

%% static scene, dynamic head

% brirs dataset limits head orientation from 0 to 180 degrees

sim.Sinks.OrientationXY  % initial head orientation is 180 degrees

% this should work ( head orientation still at 180 degrees )
sim.rotateHead(180, 'relative'); 
while sim.Time < 1.5
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end
sim.Sinks.OrientationXY

% this should work ( head orientation now at 0 degree )
sim.rotateHead(-180, 'relative'); 
while sim.Time < 3
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end
sim.Sinks.OrientationXY

% this should not work ( head orientation still at 0 degree  )
sim.rotateHead(-90, 'absolute'); 
while sim.Time < 4.5
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end
sim.Sinks.OrientationXY

% this should work again ( head orientation now at 90 degree  )
sim.rotateHead(90, 'absolute'); 
while ~sim.isFinished()
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end
sim.Sinks.OrientationXY

% save file
sim.Sinks.saveFile('out_brs.wav',sim.SampleRate);
%% clean up
sim.set('ShutDown',true);
