clear all;
close all;

test_startup;

%% xml configuration

xml.validate('test.xml','tef.xsd');

theDoc = xmlread('test.xml');
theNode = theDoc.getDocumentElement;

sim = SimulatorConvexRoom();  % simulator object

% Simulator
sim.XML(theNode);

%% processing
sim.set('Init',true);

sim.set('Refresh',true);
sim.draw();

% 5 seconds processing
for idx=1:ceil(5*sim.SampleRate/sim.BlockSize)
  sim.set('Process',true);
end

out = sim.Sinks.getData();
out = out/max(abs(out(:))); % normalize
audiowrite('out_xml.wav',out,sim.SampleRate);

%% clean up
sim.set('ShutDown',true);
