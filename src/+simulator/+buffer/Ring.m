classdef Ring < simulator.buffer.Data
  %AUDIORINGBUFFER
  properties (SetAccess = private)
    DataPointer;
  end
  
  methods
    function obj = Ring(mapping, StartPointer)
      if nargin < 1
        mapping = 1;
      end
      obj = obj@simulator.buffer.Data(mapping);
      
      if nargin < 2
        StartPointer = zeros(1, obj.NumberOfOutputs);
      end
      obj.DataPointer = StartPointer;
    end
    function setData(obj, data, StartPointer)
      if nargin < 3
        StartPointer = zeros(1, obj.NumberOfOutputs);
      end
      obj.DataPointer = StartPointer;
      obj.setData@simulator.buffer.Data(data);
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
      else
        data = zeros(length, obj.NumberOfOutputs);
        if size(obj.data,1) ~= 0
          data = zeros(length, obj.NumberOfOutputs);
          for idx=1:obj.NumberOfOutputs
            selector = mod(obj.DataPointer(idx)+(0:length-1),size(obj.data,1));
            data(:,idx) = obj.data(selector+1,obj.ChannelMapping(idx));
          end
        end
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
  
  %% Setter, Getter
  methods
    function set.DataPointer(obj, v)
      isargvector(v)
      if obj.NumberOfOutputs ~= length(v)
        error('number of outputs (%d) does not match number of start pointers (%d)', ...
          obj.NumberOfOutputs, length(v));
      end
      obj.DataPointer = v;
    end
  end
  
  
end