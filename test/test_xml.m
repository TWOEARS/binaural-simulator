clear all;
close all;

test_startup;

%% xml configuration

theDoc = xmlread('test.xml');
theNode = theDoc.getDocumentElement;

sim = SimulatorConvexRoom();  % simulator object

% Simulator
sim.XML(theNode);

%% some configuration which is not yet implemented in xml

% HRIRs
hrir = DirectionalIR( ...
  fullfile([database_path, 'impulse_responses/qu_kemar_anechoic/QU_KEMAR_anechoic_3m.wav']));

sim.set(...
  'Renderer', @ssr_binaural, ...  % SSR rendering function (do not change this!)
  'HRIRDataset', hrir)            % assign HRIR-Object to Simulator

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
