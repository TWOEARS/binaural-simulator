classdef AudioSink < simulator.buffer.FIFO & simulator.Object
  %UNTITLED2 Summary of this class goes here
  %   Detailed explanation goes here

  methods
    function obj = AudioSink(channels)
      if nargin < 1
        channels = 1;
      end
      obj = obj@simulator.buffer.FIFO(1:channels);
      obj = obj@simulator.Object();
    end
  end  
end