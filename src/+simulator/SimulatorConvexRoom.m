classdef SimulatorConvexRoom < simulator.SimulatorInterface & simulator.RobotInterface
  %SIMULATORCONVEXROOM is the core class for simulating acoustic room scenarios

  properties (Access=private, Hidden)
    NumberOfSSRSources;
    SSRInput;
    SSRPositionXY;
    SSROrientationXY;
    SSRMute;
    SSRReferencePosXY;
    SSRReferenceOriXY;
  end
  %% Constructor  
  methods
    function obj = SimulatorConvexRoom(xmlfile)
      % Constructor
      %
      % Parameters:
      %   xmlfile: optional name of xmlfile @type char[] @default ''
      %
      % See also: xml.dbOpenXML xml.dbValidate xml.MetaObject.XML
      
      obj = obj@simulator.SimulatorInterface();
      obj = obj@simulator.RobotInterface();
      
      if nargin < 1
        return;
      end
      obj.loadConfig(xmlfile);
    end
  end
  %% Initialization
  methods
    function obj = init(obj)
      % function init(obj)
      % initialize Simulator

      % define source types
      source_types = {};
      source_irfiles = {};
      obj.NumberOfSSRSources = 0;
      for idx=1:length(obj.Sources)
        obj.Sources{idx}.init();
        obj.NumberOfSSRSources ...
          = obj.NumberOfSSRSources + obj.Sources{idx}.ssrChannels;
        source_types = [source_types, obj.Sources{idx}.ssrType];
        source_irfiles = [source_irfiles, obj.Sources{idx}.ssrIRFile];
      end

      % initialize SSR compatible arrays
      obj.SSRPositionXY = zeros(2, obj.NumberOfSSRSources);
      obj.SSROrientationXY = zeros(1, obj.NumberOfSSRSources);
      obj.SSRReferencePosXY = zeros(2, 1);
      obj.SSRReferenceOriXY = zeros(1, 1);
      obj.SSRMute = false(1, obj.NumberOfSSRSources);
      obj.SSRInput = single(zeros(obj.BlockSize, obj.NumberOfSSRSources));

      % SSR initialization parameters
      params.block_size = obj.BlockSize;
      params.sample_rate = obj.SampleRate;
      params.hrir_file = obj.HRIRDataset.Filename;
      params.threads = obj.NumberOfThreads;
      params.delayline_size = ceil(obj.MaximumDelay*obj.SampleRate);
      params.initial_delay = ceil(obj.PreDelay*obj.SampleRate);

      % initialize SSR
      obj.Renderer('init', source_irfiles, params);
      obj.Renderer('source_model', source_types{:});

      % ensure initial scene to be valid
      obj.reinit();
    end
    %% Processing
    function process(obj)
      % function process(obj)
      % process next audio block
      %
      % process next audio block provided by the audio sources of Sources
      % Output will be written to the Buffer of Sinks

      begin = 1;
      for idx=1:length(obj.Sources)
        if obj.Sources{idx}.ssrChannels == 0
          continue;
        end
        range = begin:(begin-1+obj.Sources{idx}.ssrChannels);

        obj.SSRInput(:,range) = obj.Sources{idx}.ssrData(obj.BlockSize);
        begin = range(end) + 1;
      end

      out = obj.Renderer(...
        'source_position', obj.SSRPositionXY, ...
        'source_orientation', obj.SSROrientationXY, ...
        'source_mute', obj.SSRMute, ...
        'reference_position', obj.SSRReferencePosXY,...
        'reference_orientation', obj.SSRReferenceOriXY, ...
        'process', obj.SSRInput);

      % add binaural input and remove data for original sources
      for idx=1:length(obj.Sources)
        if isa(obj.Sources{idx},'simulator.source.Binaural') && ...
           ~obj.Sources{idx}.Mute
          out = out + obj.Sources{idx}.getData(obj.BlockSize);
        end
        obj.Sources{idx}.removeData(obj.BlockSize);
      end

      obj.Sinks.appendData(out);  % append Data to Sinks
    end
  %% Refresh
    function refresh(obj)
      % function refresh(obj)
      % refresh positions of all scene objects including image source model

      % incorporate new events from the event queue
      if ~isempty(obj.EventHandler)
        obj.EventHandler.refresh(obj.BlockSize/obj.SampleRate);
      end

      % refresh position of Sinks for limited-speed modifications
      obj.Sinks.refresh(obj.BlockSize/obj.SampleRate);

      % refresh ism and scene objects
      for idx=1:length(obj.Sources)
        obj.Sources{idx}.refresh(obj.BlockSize/obj.SampleRate);
      end

      obj.updateSSRarrays;
    end
  end
  methods (Access = private)
    function updateSSRarrays(obj)
      % refresh SSR compatible arrays
      begin = 1;
      for idx=1:length(obj.Sources)
        if obj.Sources{idx}.ssrChannels == 0
          continue;
        end
        range = begin:(begin-1+obj.Sources{idx}.ssrChannels);

        obj.SSRPositionXY(:, range) = obj.Sources{idx}.ssrPosition();
        obj.SSROrientationXY(:, range) = obj.Sources{idx}.ssrOrientation();
        obj.SSRMute(:, range) = obj.Sources{idx}.ssrMute();

        begin = range(end) + 1;
      end
      obj.SSRReferencePosXY = obj.Sinks.ssrPosition();
      obj.SSRReferenceOriXY = obj.Sinks.ssrOrientation();
    end
  end
  methods
    %% isFinished?
    function b = isFinished(obj)
      b = true;
      for idx=1:length(obj.Sources)
        if ~obj.Sources{idx}.isEmpty()
          b = false;
          return;
        end
      end
    end
    %% reinitialization
    function reinit(obj)
      % function reinit(obj)
      % re-initialize simulator
      %
      % Somehow a weak form of init, which clears the memory of the
      % convolver and clears the history of object positions, orientations
      % and mutes. However, clearing means that the memory of the convolver
      % is filled with zeros and the history is filled with current
      % properties for each object. Be sure, that you have chosen the right
      % properties BEFORE running reinit.
      %
      % See also: simulator.SimulatorInterface.init

      % init EventHandler
      if ~isempty(obj.EventHandler)
        obj.EventHandler.init();
        % get events which have a timestamp of 0 seconds
        obj.EventHandler.refresh(0);
      end

      % refresh ism and scene objects
      for idx=1:length(obj.Sources)
        obj.Sources{idx}.refresh();
      end

      obj.updateSSRarrays;

      obj.Renderer(...
        'source_position', obj.SSRPositionXY, ...
        'source_orientation', obj.SSROrientationXY, ...
        'source_mute', obj.SSRMute, ...
        'reference_position', obj.SSRReferencePosXY,...
        'reference_orientation', obj.SSRReferenceOriXY);

      % clear convolver memory by processing some zeros
      obj.clearmemory();
    end
    %% Clear Memory
    function clearmemory(obj)
      % function clearmemory(obj)
      % clear memory of renderer
      %
      % obsolete functionality (will be replaced by reinit in mid-term)
      %
      % See also: reinit
      blocks = ceil( (obj.HRIRDataset.NumberOfSamples + ...
        2*obj.MaximumDelay*obj.SampleRate)/obj.BlockSize ...
        );
      input = single(zeros(obj.BlockSize, obj.NumberOfSSRSources));
      for idx=1:blocks
        [~] = obj.Renderer('process', input);
      end
    end
    %% Shut Down
    function shutdown(obj)
      % function shutdown(obj)
      obj.SSRPositionXY = [];
      obj.SSROrientationXY = [];
      obj.SSRReferencePosXY = [];
      obj.SSRReferenceOriXY = [];
      obj.SSRMute = [];
      obj.SSRInput = [];

      obj.Renderer('clear');

      for idx=1:length(obj.Sources)
        delete(obj.Sources{idx});
      end
      delete(obj.Sinks);
      delete(obj.Walls);
      delete(obj.HRIRDataset);
    end
  end

  %% Robot-Interface
  methods (Access=protected)
    function rotateHeadRelative(obj, angleIncDeg)
      % function rotateHeadRelative(obj, angleIncDeg)
      %
      % See also: simulator.RobotInterface.rotateHeadRelative
      obj.Sinks.rotateAroundUp(angleIncDeg);
    end
    function rotateHeadAbsolute(obj, angleDeg)
      % function rotateHeadAbsolute(obj, angleDeg)
      %
      % See also: simulator.RobotInterface.rotateHeadAbsolute

      % get current XY-Orientation
      azi = obj.Sinks.OrientationXY;
      % rotate Head around z-axis
      obj.Sinks.rotateAroundAxis([0; 0; 1], angleDeg - azi);
    end
  end
  methods
    function [sig, timeIncSec, timeIncSamples] = getSignal(obj, timeIncSec)
      % function [sig, timeIncSec, timeIncSamples] = getSignal(obj, timeIncSec)
      %
      % See also: simulator.RobotInterface.getSignal

      blocks = ceil(timeIncSec*obj.SampleRate/obj.BlockSize);

      idx = 0;
      while ~obj.isFinished() && idx < blocks
        obj.refresh();
        obj.process();
        idx = idx + 1;
      end

      timeIncSamples = idx*obj.BlockSize;
      timeIncSec = timeIncSamples/obj.SampleRate;

      sig = obj.Sinks.getData(timeIncSamples);
      obj.Sinks.removeData(timeIncSamples);
    end
  end

%   %% misc.
%   methods
%     function draw(obj,id)
%       % function draw(obj)
%       % plot walls, sources, sinks + image sources/sinks
%       if nargin < 2
%         id = figure;
%       else
%         figure(id);
%       end
%
%       head_pos = [obj.Sinks.Position];
%       img_head_pos = [obj.ImageSinks.Position];
%       src_pos = [obj.Sources(obj.mirroredSourcesDx).Position];
%       if obj.NumberOfImageSources > 0
%         img_pos = [obj.ImageSources.Position];
%         img_mute = [obj.ImageSources.Mute];
%       end
%
%       % Draw Walls
%       for i=1:length(obj.Walls)
%         obj.Walls(i).draw(id);
%       end
%
%       hold on;
%       % Draw Head-Position
%       h(1) = plot3(head_pos(1), head_pos(2), head_pos(3),'kx');
%       % Draw Image-Head-Positions
%       h(2) = plot3(img_head_pos(1,:), ...
%         img_head_pos(2,:), ...
%         img_head_pos(3,:), ...
%         'go');
%
%       if obj.NumberOfImageSources > 0
%         % Draw Source-Position
%         h(3) = plot3(src_pos(1,:), src_pos(2,:), src_pos(3,:),'rx');
%         % Draw Active/Valid Sources
%         if min(img_mute) == 0
%           h(4) = plot3(img_pos(1,~img_mute), ...
%             img_pos(2,~img_mute), ...
%             img_pos(3,~img_mute),  ...
%             'bo');
%         end
%         % Draw Inactive/Invalid Sources
%         if max(img_mute) == 1
%           h(5) = plot3(img_pos(1,img_mute), ...
%             img_pos(2,img_mute), ...
%             img_pos(3,img_mute), ...
%             'b.');
%         end
%       end
%
%       hold off;
%       axis equal;
%       legend(h, ...
%         {'Head', ...
%         'Image-Heads', ...
%         'Sources', ...
%         'Active Image-Sources', ...
%         'Inactive Image-Sources'} ...
%         );
%     end
%   end
end
