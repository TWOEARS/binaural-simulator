classdef PassThrough < simulator.buffer.Base
  %CHANNELBUFFER selects output channels as input

  properties
    ParentBuffer@simulator.buffer.Base % 
  end
  
  methods
    function obj = PassThrough(buffer, mapping)
      if nargin < 2
        mapping = 1;
      end
      obj = obj@simulator.buffer.Base(mapping);
      obj.ParentBuffer = buffer;
    end
    function appendData(obj, data)
      error('not implemented for PassThroughBuffer');
    end
    function removeData(obj, length)
      error('not implemented for PassThroughBuffer');
    end
    function data = getData(obj, length)
      if nargin < 2
        data = obj.ParentBuffer.getData();
      else
        data = obj.ParentBuffer.getData(length);
      end
      data = data(:,obj.ChannelMapping);
    end
  end
end