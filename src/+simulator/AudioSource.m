classdef AudioSource < simulator.Object & dynamicprops
  % Class for source-objects in audio scene
  
  properties
    % mute flag to mute source output
    % @type logical
    % @default false
    Mute = false;
    % audio buffer which contains input signal of source
    % @type simulator.buffer.Base
    AudioBuffer;
  end
  
  properties (SetAccess = private)
    % source type
    % @type simulator.AudioSourceType
    Type;
  end
  
  properties (SetAccess = private, Dependent)
    % required number of channels of input signal (type dependent)
    % @type integer
    %
    % To set AudioBuffer to the Source object AudioBuffer.NumberOfChannels
    % has to match RequiredChannels
    RequiredChannels;
  end
  
  methods
    function obj = AudioSource(type, buffer, directions)
      % function obj = AudioSource(type, buffer, directions)
      % 
      % Parameters:
      %   type: type of AudioSource @type simulator.AudioSourceType
      %   buffer: audio buffer as signal source @type simulator.buffer.Base
      %   directions: directions of plane wave for simulator.AudioSourceType.PWD
      %      @type double[][]
      obj = obj@simulator.Object();
      obj.addXMLAttribute('Mute', 'logical');
      
      obj.Type = type;
      
      if obj.Type == simulator.AudioSourceType.PWD
        addprop(obj,'Directions');
        obj.Directions = directions;
      end
      
      if nargin >= 2
        obj.AudioBuffer = buffer;
      end
    end
  end
  
  %% XML
  methods (Access=protected)
    function configureXMLSpecific(obj, xmlnode)
      % init Buffer
      buffer = xmlnode.getElementsByTagName('buffer').item(0);
      
      mapping = 1:obj.RequiredChannels;
      
      import simulator.buffer.*
      switch (char(buffer.getAttribute('Type')))
        case 'fifo'
          obj.AudioBuffer = simulator.buffer.FIFO(mapping);
        case 'ring'
          obj.AudioBuffer = simulator.buffer.Ring(mapping);
        case 'noise'
          obj.AudioBuffer = simulator.buffer.Noise(mapping);
        otherwise
          error('source type (%s) not supported',char(buffer.getAttribute('Type')));
      end
      obj.AudioBuffer.XML(buffer);
    end
  end
  
  %% setter/getter
  methods
    function set.AudioBuffer(obj, b)
      isargclass('simulator.buffer.Base', b);
      import simulator.AudioSourceType
      
      if b.NumberOfOutputs ~= obj.RequiredChannels
        error('Number of outputs of audio buffer does not match source type!');
      end
      obj.AudioBuffer = b;
    end
    function set.Type(obj, t)
      isargclass('simulator.AudioSourceType', t);
      obj.Type = t;
    end
    function v = get.RequiredChannels(obj)
      import simulator.AudioSourceType
      
      switch obj.Type
        case AudioSourceType.POINT
          v = 1;
        case AudioSourceType.PLANE
          v = 1;
        case AudioSourceType.DIRECT
          v = 2;
        case AudioSourceType.PWD
          v = size(obj.Directions,2);
        otherwise
          error('Unknown source type!');
      end
    end
  end
  
  %% functionalities of AudioBuffer which have to be encapsulated
  methods
    function setData(obj,data)
      obj.AudioBuffer.setData(data);
    end
    function d = getData(obj,length)
      if nargin < 2
        d = obj.AudioBuffer.getData();
      else
        d = obj.AudioBuffer.getData(length);
      end
    end
    function removeData(obj, length)
      if nargin < 2
        obj.AudioBuffer.removeData();
      else
        obj.AudioBuffer.removeData(length);
      end
    end
    function appendData(obj, data)
      obj.AudioBuffer.appendData(data);
    end
    function b = isEmpty(obj)
      b = obj.AudioBuffer.isEmpty();
    end
  end
end