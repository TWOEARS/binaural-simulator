classdef (Abstract) Base < hgsetget
  %AUDIOBUFFERBASE is the base class for all audio buffers. 

  properties (SetAccess=protected)
    ChannelMapping;
  end   
  properties (Dependent)
    NumberOfInputs;
    NumberOfOutputs;
  end  
    
  methods
    function obj = Base(mapping) 
      if nargin < 1
        mapping = 1;
      end
      obj.ChannelMapping = mapping;      
    end
  end
  
  %% Abstract Functions
  methods (Abstract)
    data = getData(obj, length)
  % function data = getData(obj, length)
  % reads data from buffer of specified length 
  %
  % If length is longer than the current buffer content, zero padding is applied
  %
  % Parameters:
  %   length: number of deleted samples @type integer @default inf
  %
  % Return values:
  %   data: @type double[][]
  end  
  
  %% Setter, Getter
  methods
    function set.ChannelMapping(obj,v)
      isargvector(v);
      obj.ChannelMapping = v;
    end
    function v = get.NumberOfOutputs(obj)
      v = length(obj.ChannelMapping);
    end
    function v = get.NumberOfInputs(obj)
      v = max(obj.ChannelMapping);
    end
  end  
end

