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
  'Sources', {simulator.source.BRSGroup(), simulator.source.BRSGroup()}, ...
  'Sinks', simulator.AudioSink(2) ...
  );

% Source #1 - Cello located at the first (index 1) loudspeaker position of the 
%             BRIRs dataset
set(sim.Sources{1}, ...
  'AudioBuffer', simulator.buffer.Ring(1), ...
  'Name', 'Cello', ...
  'Volume', 0.4 ...
  );
sim.Sources{1}.loadBRSFile('impulse_responses/twoears_kemar_adream/TWOEARS_KEMAR_ADREAM_posall.sofa', 1);
set(sim.Sources{1}.AudioBuffer, ...
  'File', 'stimuli/anechoic/instruments/anechoic_cello.wav');

% Source #2 - Castanets located at the 2nd (index 2) loudspeaker position of the 
%             BRIRs dataset
set(sim.Sources{2}, ...
  'AudioBuffer', simulator.buffer.Ring(1), ...
  'Name', 'Castanets' ...
  );
sim.Sources{2}.loadBRSFile('impulse_responses/twoears_kemar_adream/TWOEARS_KEMAR_ADREAM_posall.sofa', 2);
set(sim.Sources{2}.AudioBuffer, ...
  'File', 'stimuli/anechoic/instruments/anechoic_castanets.wav');

% Binaural sensor (start at position #1)
set(sim.Sinks, 'Name', 'Head', ...
  'Position', sim.Sources{1}.SubSources(1).Position);

%% initialization
% note that all the parameters including objects' positions have to be
% defined BEFORE initialization in order to init properly
sim.set('Init',true);

%% simulation
sig = [];
for idx=1:4
  set(sim.Sinks, 'Position', sim.Sources{1}.SubSources(idx).Position);
  sig = [sig; sim.getSignal(10)];  % 10 seconds signal
end
savewav(sig./max(abs(sig(:))), 'out_toulouse.wav', sim.SampleRate);

%% clean up
sim.set('ShutDown',true);
