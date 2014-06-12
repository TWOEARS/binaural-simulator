classdef Ring < simulator.buffer.Base
  %AUDIORINGBUFFER
  properties (SetAccess = private)
    DataPointer;
  end  
  
  methods
    function obj = Ring(mapping, StartPointer)
      if nargin < 1
        mapping = 1;
      end
      obj = obj@simulator.buffer.Base(mapping);
      
      if nargin < 2
        StartPointer = zeros(1, obj.NumberOfOutputs);
      elseif obj.NumberOfOutputs ~= length(StartPointer)
        error('number of outputs does not match number of start pointers');
      end      
      obj.DataPointer = StartPointer;
    end
    function setData(obj, data)
      obj.DataPointer = 0;
      obj.setData@simulator.buffer.Base(data);
    end
    function data = getData(obj, length)
  % function data = getData(obj, length)
  % reads data from FIFO buffer of specified length 
  %
  % If length is longer than the current buffer content, zero padding is applied
  %
  % Parameters:
  %   length: number of samples @type integer @default inf
  %
  % Return values:
  %   data: @type double[][]  
      if nargin < 2
        data = obj.data(:,obj.ChannelMapping);
      elseif size(obj.data,1) == 0
        data = zeros(length, obj.NumberOfOutputs);
      else
        data = obj.data(:,obj.ChannelMapping);        
        selector = mod(obj.DataPointer+(0:length-1),size(obj.data,1));
        data = data(selector+1,:);
      end      
    end
    function removeData(obj, length)
  % function removeData(obj, length)
  % shifts the data DataPointer about length
  %
  % Parameters:
  %   length: shift in samples @type integer @default inf
      if ~isempty(obj.data)
        obj.DataPointer = mod(obj.DataPointer+length,size(obj.data,1));
      end
    end
  end
end