classdef FIFO < simulator.buffer.Data
  % basically implements a FIFO buffer

  properties
      startIdx;
  end
  
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
      obj.startIdx = 1;
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
      obj.data = [obj.data(obj.startIdx:end,:); data];
      obj.startIdx = 1;
    end
    function removeData(obj, length)
      % function removeData(obj, length)
      % removes data from FIFO buffer of specified length
      %
      % If length is longer than the current buffer content, the buffer
      % is flushed. Same behavior holds for an undefined length.
      %
      % Parameters:
      %   length: number of deleted samples @type integer @default inf
      if ~isempty(obj.data)
        if nargin < 2
          obj.data = [];
        elseif length > size(obj.data,1) + 1 - obj.startIdx
          obj.data = [];
        else
          if obj.startIdx >= 8192 * 50
              obj.data = obj.data(obj.startIdx+length:end,:);
              obj.startIdx = 1;
          else
              obj.startIdx = obj.startIdx + length;
          end
        end
      end
    end
    function b = isEmpty(obj)
      % function b = isEmpty(obj)
      % indicates if buffer is empty
      %
      % Return values:
      %   b: indicates if buffer is empty @type logical
      b = isempty(obj.data) || obj.startIdx > size( obj.data, 1 );
    end
    function data = getData(obj, length, channels)
      % function data = getData(obj, length, channels)
      % reads data from FIFO buffer of specified length
      %
      % If length is longer than the current buffer content, zero padding
      % is applied. If no length is specified, the whole buffer is read.
      %
      % Parameters:
      %   length: number of samples @type integer @default inf
      %   channels: optional select of outputchannels @type integer[]
      %   @default [1:simulator.buffer.Base.NumberOfOutputs]
      %
      % Return values:
      %   data: @type double[][]

      % optional pre-selection of channels
      if nargin < 3
        mapping = obj.ChannelMapping;
      else
        mapping = obj.ChannelMapping(channels);
      end

      if nargin < 2
        if size(obj.data,1) + 1 - obj.startIdx > 0
          data = obj.data(obj.startIdx:end,mapping);
        else
          data = [];
        end
      elseif length > size(obj.data,1) + 1 - obj.startIdx
        data = zeros(length, obj.NumberOfOutputs);
        if size(obj.data,1) > 0
          data(1:size(obj.data,1) + 1 - obj.startIdx,:) = obj.data(obj.startIdx:end,mapping);
        end
      else
        data = obj.data(obj.startIdx:length+obj.startIdx-1,mapping);
      end
    end
  end
end
