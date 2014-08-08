classdef (Abstract) Data < simulator.buffer.Base
  % abstract base class for FIFO and Ring buffers.
  
  properties (SetAccess = protected, Hidden)
    % data source
    % @type double[][]
    data = [];
  end
  properties (GetAccess = private, Dependent)
    % file for data source
    %
    % File is exspected to be a name of an existing File, which can be read
    % via MATLABs audioread
    %
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
      % function setData(obj, data, channels)
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
  %% File-IO
  methods
    function loadFile(obj, f)
      % function setData(obj, data, channels)
      % load audio file into buffer (deletes old data)
      %
      % Parameters:
      %   f: name of audio file @type char[]
      
      isargchar(f);
      isargfile(f);
      obj.data = audioread(f);
      obj.data = single(obj.data./max(abs(obj.data(:))));      
    end
    function saveFile(obj, f, fs)
      % function setData(obj, data, channels)
      % save buffer content to audio file
      %
      % Parameters:
      %   f: name of audio file @type char[]
      %   fs: optional sampling frequency @type double @default 44100
      %
      % This functionality is dependent on the the implementation of the 
      % 'getData' method of each potential sub-class.  It does not read the raw
      % data from the buffer matrix. The output content will be normalized to 
      % the absolute maximum among all samples inside the output.
      
      isargchar(f);
      if nargin < 3
        fs = 44100;
      else
        isargpositivescalar(fs);
      end
      
      tmp = obj.getData();      
      audiowrite(f, tmp./max(abs(tmp(:))), fs);
      fprintf('Saved buffer data with %d samples to %s \n', numel(tmp), f);
    end
  end
  
  
  %% setter/getter
  methods
    function set.File(obj, f)
      obj.loadFile(f);
    end
  end
end