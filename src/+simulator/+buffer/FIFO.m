classdef FIFO < simulator.buffer.Data
  % Class basically implements a FIFO buffer
  
  methods
    function obj = FIFO(mapping)
      % function obj = Data(mapping)
      % constructor
      %
      % Parameters:
      %   mapping: corresponds to ChannelMapping @type integer[] @default 1
      if nargin < 1
        mapping = 1;
      end
      obj = obj@simulator.buffer.Data(mapping);
    end
  end
  
  %% Access-Functionality
  methods
    function appendData(obj, data)
      % function appendData(obj, data)
      % append data to existing data of FIFO buffer
      %
      % Parameters:
      %   data: data which is appended @type double[][]
      if (size(data,2) ~= obj.NumberOfInputs)
        error('number of columns does not match number of inputs');
      end
      obj.data = [obj.data; data];
    end
    function removeData(obj, length)
      % function removeData(obj, length)
      % removes data from FIFO buffer of specified length
      %
      % If length is longer than the current buffer content, the buffer is flushed
      %
      % Parameters:
      %   length: number of deleted samples @type integer @default inf
      if ~isempty(obj.data)
        if nargin < 2
          obj.data = [];
        elseif length > size(obj.data,1)
          obj.data = [];
        else
          obj.data(1:length,:) = [];
        end
      end
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
        data = obj.data;
      elseif length > size(obj.data,1)
        data = zeros(length, size(obj.data,2));
        if size(obj.data,1) > 0
          data(1:size(obj.data,1),:) = obj.data;
        end
      else
        data = obj.data(1:length,:);
      end
      data = data(:,obj.ChannelMapping);
    end
  end
end