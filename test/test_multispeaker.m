test_startup;

% this is a first test script for the binaural simulator using the
% MultispeakerBRIR convention of SOFA. You may change the listener position or
% the source position by respectively changing idx or kdx in
% 'IRDataset', simulator.DirectionalIR( ...
%    'impulse_responses/twoears_kemar_adream/TWOEARS_KEMAR_ADREAM_pos<idx>.sofa', <kdx>
%    )
%
% Note that for Binaural Room Impulse Responses changes in the position of 
% sound sources and the listener during the simulation is not supported, i.e. 
% do not have any effect on the binaural signal

%% processing parameters
sim = simulator.SimulatorConvexRoom();  % simulator object

% Basis Parameters - Block size, sample rate and the renderer type
set(sim, ...
  'BlockSize', 4096, ...
  'SampleRate', 44100, ...
  'Renderer', @ssr_brs ...
  );

% Acoustic scene - Two sources and a binaural sensor
set(sim, ...
  'Sources', {simulator.source.Point(), simulator.source.Point()}, ...
  'Sinks', simulator.AudioSink(2) ...
  );

% Source #1 - Cello located at the first (index 1) loudspeaker position of the 
%             BRIRs dataset
set(sim.Sources{1}, ...
  'AudioBuffer', simulator.buffer.FIFO(1), ...
  'Name', 'Cello', ...
  'Volume', 0.4, ...
  'IRDataset', simulator.DirectionalIR( ...
    'impulse_responses/twoears_kemar_adream/TWOEARS_KEMAR_ADREAM_pos1.sofa', 1 ) ...
  );
set(sim.Sources{1}.AudioBuffer, ...
  'File', 'stimuli/anechoic/instruments/anechoic_cello.wav');

% Source #2 - Castanets located at the 2nd (index 2) loudspeaker position of the 
%             BRIRs dataset
set(sim.Sources{2}, ...
  'AudioBuffer', simulator.buffer.FIFO(1), ...
  'Name', 'Castanets', ...
  'IRDataset', simulator.DirectionalIR( ...
    'impulse_responses/twoears_kemar_adream/TWOEARS_KEMAR_ADREAM_pos1.sofa', 2) ...
  );
set(sim.Sources{2}.AudioBuffer, ...
  'File', 'stimuli/anechoic/instruments/anechoic_castanets.wav');

% Binaural sensor
set(sim.Sinks, 'Name', 'Head');

%% initialization
% note that all the parameters including objects' positions have to be
% defined BEFORE initialization in order to init properly
sim.set('Init',true);

%% dynamic scene

sim.rotateHead(-27.7541, 'absolute');
sim.Sinks.setDynamic('UnitX', 'Velocity', 30);
sim.rotateHead(176.2459, 'absolute');

while ~sim.isFinished()
  sim.set('Refresh',true);  % refresh all objects
  sim.set('Process',true);
end

% save file
sim.Sinks.saveFile('out_multispeaker.wav',sim.SampleRate);
%% clean up
sim.set('ShutDown',true);
