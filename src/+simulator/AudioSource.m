classdef AudioSource < simulator.Object & dynamicprops
  %UNTITLED2 Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Mute = false;
    AudioBuffer@simulator.buffer.Base;
  end
  
  properties (SetAccess = immutable)
    Type@simulator.AudioSourceType;
    RequiredChannels;    
  end
  
  methods
    function obj = AudioSource(type, buffer, directions)
      obj = obj@simulator.Object();
      obj.addXMLProperty('Mute', 'logical');
      
      import simulator.AudioSourceType
      
      if nargin > 1
        if nargin == 2
          switch type
            case AudioSourceType.POINT
              obj.RequiredChannels = 1;
            case AudioSourceType.PLANE
              obj.RequiredChannels = 1;
            case AudioSourceType.DIRECT
              obj.RequiredChannels = 2;
            otherwise
              error('Number of input Arguments does not match the source type');
          end
        elseif nargin == 3 && type == AudioSourceType.PWD           
          P = addprop(obj,'Directions');
          P.SetAccess = 'private';
          %P.SetMethod = @obj.set_Directions;
          obj.Directions = directions;
          obj.RequiredChannels = size(obj.Directions,2);
        else
          error('Number of input Arguments does not match the source type');
        end
        obj.AudioBuffer = buffer;
      end      
      obj.Type = type;     
    end
  end
  
  %% XML
  methods (Access=protected)
    function XMLChilds(obj, xmlnode)
      % init Buffer
      buffer = xmlnode.getElementsByTagName('buffer').item(0);
      
      import simulator.buffer.*
      switch (char(buffer.getAttribute('Type')))
        case 'fifo'
          obj.AudioBuffer = simulator.buffer.FIFO();
        case 'ring'
          obj.AudioBuffer = simulator.buffer.Ring();
        case 'noise'
          obj.AudioBuffer = simulator.buffer.Noise();
      end
      obj.AudioBuffer.XML(buffer);
    end
  end 
  
  %% setter/getter
  methods
    function set.AudioBuffer(obj, b)
      import simulator.AudioSourceType
      
      if b.NumberOfOutputs ~= obj.RequiredChannels
        error('Number of outputs of audio buffer does not match source type!');
      end
      obj.AudioBuffer = b;
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

