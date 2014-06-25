classdef AudioSink < simulator.buffer.FIFO & simulator.Object
  % Class for sink-objects in audio scene

  methods
    function obj = AudioSink(channels)
  % function obj = AudioSink(channels)
  % constructor of AudioSink class
  % 
  % Parameters:
  %   channels: number of input channels (2 for binaural) @type integer
      if nargin < 1
        channels = 1;
      end
      obj = obj@simulator.buffer.FIFO(1:channels);
      obj = obj@simulator.Object();
    end
  end  
end