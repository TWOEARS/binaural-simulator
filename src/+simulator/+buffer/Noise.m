classdef Noise < simulator.buffer.Base
  %AUDIONOISEBUFFER is the class for noise sources.
  
  properties
    Mean = 0.0
    Variance = 1.0
  end  
  
  methods
    function obj = Noise(channels)
      if nargin < 1
        channels = 1;
      end
      obj = obj@simulator.buffer.Base(channels);
    end
    function data = getData(obj, length)
      % function data = getData(obj, length)
      % reads data from buffer of specified length
      %
      % Parameters:
      %   length: number of samples @type integer @default inf
      %
      % Return values:
      %   data: @type double[][]
      data = obj.Variance.*randn(length,obj.NumberOfInputs) - obj.Mean;
      data = data(:,obj.ChannelMapping);
    end
  end
  
  methods
    function set.Variance(obj,v)
      isargscalar(v);
      obj.Variance = v;
    end
    function set.Mean(obj,v)
      isargscalar(v);
      obj.Mean = v;
    end
  end
end

