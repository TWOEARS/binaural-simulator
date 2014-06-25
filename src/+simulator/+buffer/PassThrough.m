classdef PassThrough < simulator.buffer.Base
  % Class uses other buffer object as input and maps it to a new output
  
  properties
    % Input buffer
    % @type simulator.buffer.Base
    ParentBuffer
  end
  
  methods
    function obj = PassThrough(mapping, buffer)
      % function obj = Data(mapping)
      % constructor
      %
      % Parameters:
      %   mapping: corresponds to ChannelMapping @type integer[]
      %   buffer: corresponds to ParentBuffer @type simulator.buffer.Base
      obj = obj@simulator.buffer.Base(mapping);
      obj.ParentBuffer = buffer;
    end
  end
  
  %% Access-Functionality
  methods
    function data = getData(obj, length)
      if nargin < 2
        data = obj.ParentBuffer.getData();
      else
        data = obj.ParentBuffer.getData(length);
      end
      data = data(:,obj.ChannelMapping);
    end
  end
  %% setter/getter
  methods
    function set.ParentBuffer(obj, v)
      isargclass('simulator.buffer.Base', v);
      obj.ParentBuffer = v;
    end
  end
end