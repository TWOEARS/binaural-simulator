classdef (Abstract) Base < simulator.Object
  % Class for source-objects in audio scene

  properties
    % mute flag to mute source output
    %
    % Note that toggling Mute will fade in/out the source signal in next block.
    % There is no instantly switch on/off. If you want that behaviour, see
    % Volume
    %
    % See also: Volume
    %
    % @type logical
    % @default false
    Mute = false;
    % audio buffer which contains input signal of source
    % @type simulator.buffer.Base
    AudioBuffer;
    % volume of sound source (additional weighting of buffer signal)
    %
    % Note that setting Volume to 0 is different setting Mute to false.
    % Changes in Volume will instantly be applied without any cross-fade between
    % the old and the new value.
    %
    % See also: Mute
    % @type double
    % @default 1.0
    Volume = 1.0;
    % impulse response file for BRS or Generic Renderer
    %
    % This File is required for the BRS Renderer, defining the BRIR-Dataset of
    % the source. This should be a n-channel *.wav file. All other Renderers
    % will ignore this property
    %
    % See also: simulator.xml.dbGetFile()
    % @type DirectionalIR
    % @default simulator.DirectionalIR()
    IRDataset = simulator.DirectionalIR();
  end

  properties (SetAccess = protected)
    % required number of channels of input signal
    % @type integer
    % @default 1
    %
    % To set AudioBuffer to the Source object AudioBuffer.NumberOfChannels
    % has to match RequiredChannels
    RequiredChannels = 1;
  end

  methods
    function obj = Base()
      % function obj = Base()

      obj.addXMLAttribute('Mute', 'logical');
      obj.addXMLAttribute('Volume', 'double');
      obj.addXMLAttribute('IRDataset',  ...
        'simulator.DirectionalIR', ...
        'IRs', ...
        @(x) simulator.DirectionalIR(xml.dbGetFile(x)));
    end
  end

  methods
    function init(obj)
      if obj.AudioBuffer.NumberOfOutputs ~= obj.RequiredChannels
        obj.errormsg(...
          'Number of outputs of obj.AudioBuffer does not match obj.RequiredChannels!');
      end
    end
  end

  %% SSR compatible stuff
  methods
    function v = ssrData(obj, BlockSize)
      v = obj.getData(BlockSize);
    end
    function v = ssrChannels(obj)
      v = obj.RequiredChannels;
    end
    function v = ssrMute(obj)
      v = obj.Mute;
    end
    function v = ssrIRFile(obj)
      v = cell(size(obj));
      for idx=1:numel(v)
        v{idx} = obj(idx).IRDataset.Filename;
      end
    end
  end
  methods (Abstract)
    v = ssrType(obj);
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

  %% MISC
  methods
    function [h, leg] = plot(obj, figureid)
      if nargin < 2
        figure;
      else
        figure(figureid);
      end

      [h, leg] = obj.plot@simulator.Object(figureid);
      set(h,'MarkerEdgeColor', [0, 0, 0]);
      if (~obj.Mute)
        set(h,'MarkerFaceColor', [1.0, 0, 0]);
      end
    end
  end

  %% setter/getter
  methods
    function set.AudioBuffer(obj, b)
      isargclass('simulator.buffer.Base', b);

      if b.NumberOfOutputs ~= obj.RequiredChannels
        obj.warnmsg(...
          'Number of outputs of obj.AudioBuffer does not match obj.RequiredChannels!');
      end
      obj.AudioBuffer = b;
    end
    function set.Volume(obj, v)
      isargpositivescalar(v);
      obj.Volume = v;
    end
    function v = get.Volume(obj)
      v = obj.Volume;
      try
        v = v * obj.GroupObject.Volume;
      catch
      end
    end
    function v = get.Mute(obj)
      v = obj.Mute;
      try
        v = v || obj.GroupObject.Mute;
      catch
      end
    end
  end

  %% functionalities of AudioBuffer which have to be encapsulated
  methods
    function setData(obj,data)
      obj.AudioBuffer.setData(data);
    end
    function d = getData(obj,length)
      if obj.Volume ~= 0
        if nargin < 2
          d = obj.AudioBuffer.getData();
        else
          d = obj.AudioBuffer.getData(length);
        end
        d = obj.Volume.*d;
      else
        d = zeros(length,obj.RequiredChannels);
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
