test_startup;

%% processing paramet
sim = SimulatorConvexRoom('test_robot.xml');  % simulator object

%% initialization
% note that all the parameters including objects' positions have to be
% defined BEFORE initialization in order to init properly
sim.set('Init',true);

%% static scene
% get 1.5 seconds signal
[sig, actualTime] = sim.getSignal(1.5);  
% display length of sig in seconds
display(actualTime);
% rotate the head 90 degrees to the left (relative)
sim.rotateHead(90);
% append 2.5 seconds signal
sig = [sig; sim.getSignal(2.5)];
% rotate the head degrees to the right (absolute, which is 180 relative)
sim.rotateHead(-90, 'absolute');
% append 3 seconds signal
sig = [sig; sim.getSignal(3)];
% save normalized signal
audiowrite('out_robot.wav', sig/max(abs(sig(:))),sim.SampleRate);

%% clean up
sim.set('ShutDown',true);