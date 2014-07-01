classdef (Abstract) Data < simulator.buffer.Base
  % Base class for all data-based audio buffers.
  
  properties (SetAccess = protected, Hidden)
    % data source
    % @type double[][]
    data = [];
  end
  properties (GetAccess = private, Dependent)
    % file for data source (will automatically set by setting property)
    % @type char[]
    %
    % See also: data
    File;
  end
  
  methods
    function obj = Data(mapping)
      % function obj = Data(mapping)
      % constructor
      %
      % Parameters:
      %   mapping: corresponds to ChannelMapping @type integer[] @default 1
      if nargin < 1
        mapping = 1;
      end
      obj = obj@simulator.buffer.Base(mapping);
      obj.addXMLAttribute('File', 'dbfile');
    end
    function b = isEmpty(obj)
      % function b = isEmpty(obj)
      % indicates if buffer is empty
      %
      % Return values:
      %   b: indicates if buffer is empty @type logical
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
  %% setter/getter
  methods
    function set.File(obj, f)
      isargchar(f);
      isargfile(f);
      obj.data = audioread(f);
      obj.data = single(obj.data./max(abs(obj.data(:))));
    end
  end
end