classdef (Abstract) Base < hgsetget
  %AUDIOBUFFERBASE is the base class for all audio buffers. 

  properties (SetAccess=protected)
    ChannelMapping;
  end
  
  properties (Access = protected, Hidden)
    data = [];
  end
  
  properties (Dependent)
    NumberOfInputs;
    NumberOfOutputs;
  end  
    
  methods
    function obj = Base(mapping)     
      obj.ChannelMapping = mapping;      
    end
    function b = isEmpty(obj)
      b = isempty(obj.data);
    end
    function setData(obj, data)
  % function setData(obj, data)
  % sets data of buffer (deletes old data) 
  %
  % Parameters:
  %   data: data which is stored in buffer @type double[][]
      if size(data,2) ~= obj.NumberOfInputs
        error('number of columns does not match number of channels');
      end
      obj.data = data;
    end
    function removeData(obj, length)
    end
  end
  
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

