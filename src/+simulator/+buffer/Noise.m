classdef Noise < simulator.buffer.Base
  % Class basically implements a AWGN buffer
  
  properties
    % mu of gaussian distribution
    % @type double
    Mean = 0.0
    % sigma of gaussian distribution
    % @type double
    Variance = 1.0
  end
  
  methods
    function obj = Noise(mapping)
      % function obj = Data(mapping)
      % constructor
      %
      % Parameters:
      %   mapping: corresponds to ChannelMapping @type integer[] @default 1
      if nargin < 1
        mapping = 1;
      end
      obj = obj@simulator.buffer.Base(mapping);
    end
  end
  
  %% Access-Functionality
  methods
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
    function v = isEmpty(obj)
      % function b = isEmpty(obj)
      % always false
      v = false;
    end
  end
  
  %% Setter, Getter
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