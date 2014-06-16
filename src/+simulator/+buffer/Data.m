classdef (Abstract) Data < simulator.buffer.Base
  %AUDIOBUFFERDATA is the base class for all data-based audio buffers.
  
  properties (Access = protected, Hidden)
    data = [];
  end
  
  methods
    function obj = Data(mapping) 
      if nargin < 1
        mapping = 1;
      end
      obj = obj@simulator.buffer.Base(mapping);    
    end
    function b = isEmpty(obj)
      b = isempty(obj.data);
    end
  end
  
  %% Access-Functionality
  methods
    function setData(obj, data)
      % function setData(obj, data)
      % sets data of buffer (deletes old data)
      %
      % Parameters:
      %   data: data which is stored in buffer @type double[][]
      if size(data,2) ~= obj.NumberOfInputs
        error('number of columns does not match number of input channels');
      end
      obj.data = data;
    end
  end
  methods (Abstract)
    removeData(obj, length)
  end
end

