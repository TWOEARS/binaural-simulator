classdef SimulatorConvexRoom < simulator.SimulatorInterface
  %SIMULATORCONVEXROOM is the core class for simulating acoustic room scenarios
  
  properties (Access=private, Hidden, Dependent)
    reflect_factor;  %
    NumberOfSources;    
    NumberOfSSRSources;
    NumberOfImageSources;
    NumberOfPWDSources;
    NumberOfDirectSources;
  end
  properties (SetAccess=private)
    ImageSources@simulator.ImageSource;
    ImageSinks@simulator.ImageObject;
    mirroredSourcesDx;  % index for original sources for ism
    parentSourcesDx;  % index for 'mother' source of images sources
    parentWallsDx;  % index for 'mother' wall of images sources
    sucSinksDx;  % index for 'child' images sinks of sinks    
    
    pwdSourcesDx;
    PWDSubSources@simulator.AudioSource;
    
    directSourcesDx;
    
    inputArray@single;
  end  
  %% Initialization
  methods
    function obj = init(obj)
      % function init(obj)
      % initialize Simulator
      
      % init direct binaural Sources
      obj.directSourcesDx = ...
        find( [obj.Sources.Type] == simulator.AudioSourceType.DIRECT);     
      
      % init pwd sources
      obj.pwdSourcesDx = ...
        find( [obj.Sources.Type] == simulator.AudioSourceType.PWD);
      if ~isempty(obj.pwdSourcesDx)
        obj.PWDSubSources ...
          = obj.pwdInit(obj.Sources(obj.pwdSourcesDx));
      end
      
      % init images of Sinks and Sources
      obj.mirroredSourcesDx = ...
        find( [obj.Sources.Type] == simulator.AudioSourceType.POINT);      
      [obj.ImageSources, obj.parentSourcesDx, ~, obj.parentWallsDx] ...
        = obj.ismInit(obj.Sources(obj.mirroredSourcesDx));     
      [obj.ImageSinks, ~, obj.sucSinksDx] = obj.ismInit(obj.Sinks);
      
      % init input array for renderer
      obj.inputArray = single(zeros( obj.BlockSize, obj.NumberOfSSRSources));
      
      % SSR initialization
      params.block_size = obj.BlockSize;
      params.sample_rate = obj.SampleRate;
      params.hrir_file = obj.HRIRDataset.Filename;
      params.threads = obj.NumberOfThreads;
      params.delayline_size = ceil(obj.MaximumDelay*obj.SampleRate);
      params.initial_delay = ceil(obj.MaximumDelay*obj.SampleRate);
      obj.Renderer('init', obj.NumberOfSSRSources, params);
      
      % define source types
      source_types = repmat({'point'}, 1, obj.NumberOfImageSources);
      source_types = [source_types, ...
        repmat({'plane'}, 1, length(obj.PWDSubSources))];
      
      obj.Renderer('source_model', source_types{:});    
      
    end
    %% Processing
    function process(obj)
      % function process(obj)
      % process next audio block
      %
      % process next audio block provided by the audio sources of 
      % obj.Sources. Output will be written to the Buffer of obj.Sinks
      
      for idx=1:length(obj.ImageSources)
        obj.inputArray(:,idx) = obj.ImageSources(idx).getData(obj.BlockSize);
      end
      
      % PWD sources
      % NOTE: idx == length(obj.ImageSources)
      for kdx=obj.pwdSourcesDx
        inc = obj.Sources(kdx).RequiredChannels;
        obj.inputArray(:,idx+(1:inc)) = obj.Sources(kdx).getData(obj.BlockSize);
        idx = idx + inc;
      end
      
      out = obj.Renderer(...
        'source_position', ...
        [[obj.ImageSources.PositionXY], [obj.PWDSubSources.PositionXY]],...
        'source_orientation', ...
        [[obj.ImageSources.OrientationXY], [obj.PWDSubSources.OrientationXY]],...
        'source_mute', ...
        logical([[obj.ImageSources.Mute], [obj.PWDSubSources.Mute]]),...
        'reference_position', [obj.Sinks.PositionXY],...
        'reference_orientation', [obj.Sinks.OrientationXY],...
        'process', obj.inputArray);
      
      % add direct Sources
      for idx=find([obj.Sources(obj.directSourcesDx).Mute] == 0)
        out = out + obj.Sources(idx).getData(obj.BlockSize);
      end    
      
      % remove Data for Original Sources
      for idx=1:length(obj.Sources)
        obj.Sources(idx).removeData(obj.BlockSize);
      end 
      
      obj.Sinks.appendData(out);  % append Data to Sinks
    end
    %% Refresh
    function refresh(obj)
      % function refresh(obj)
      % refresh positions of image sources using the image source model 
      
      obj.Sinks.refresh(obj.BlockSize/obj.SampleRate);
      
      obj.ismPositions(obj.Sources(obj.mirroredSourcesDx), obj.ImageSources);
      obj.ismPositions(obj.Sinks, obj.ImageSinks);
      
      obj.ismVisibility();
      
      for idx=1:length(obj.ImageSources)
        % mute invalid image sources and sources with muted OriginalObject
        obj.ImageSources(idx).Mute = ...
          ~obj.ImageSources(idx).Valid || ...
          obj.ImageSources(idx).OriginalObject.Mute;
        % correct distance for 3D to 2D
        obj.ImageSources(idx).correctDistance(obj.Sinks.Position);
      end
    end
    %% Clear Memory
    function clearMemory(obj)
      % function clearMemory(obj)
      % clear memory of renderer
      blocks = ceil( (obj.HRIRDataset.NumberOfSamples + ...
        2*obj.MaximumDelay*obj.SampleRate)/obj.BlockSize ...
        );
      input = single(zeros(obj.BlockSize, obj.NumberOfSSRSources));
      for idx=1:blocks
        [~] = obj.Renderer('process', input);
      end
    end    
    %% Shut Down
    function shutDown(obj)
      % function shutDown(obj)
      % shut down renderer
      obj.clearMemory();
      obj.Renderer('clear');
      % delete ImageSources
      delete(obj.ImageSources);
      delete(obj.ImageSinks);
    end

  end
  %% Image Source Model
  methods (Access = private)
    function [Images, parentObjectsDx, sucObjectsDx, parentWallsDx] ...
        = ismInit(obj, Objects)
      % select a suitable constructor for the Images
      if isa(Objects,'simulator.AudioSource')
        constructor = @(x) simulator.ImageSource(x);
      elseif isa(Objects,'simulator.AudioSink')
        constructor = @(x) simulator.ImageObject(x);
      else
        error('Class not supported');
      end
      
      % some lengths and sizes
      NObj = length(Objects);
      NWalls = length(obj.Walls);
      NImg = NObj * obj.reflect_factor;
      
      % initialize Images
      Images(NImg) = constructor([]);  % TODO: remove workaround
      for idx=1:NObj
        Images(idx) = constructor(Objects(idx));
      end
      
      idx_range = 1:NObj;
      parentObjectsDx = zeros(1,NImg);
      sucObjectsDx = zeros(NWalls, NImg);
      parentWallsDx = zeros(1,NImg);
      for odx=1:obj.ReverberationMaxOrder
        rdx = idx_range(end);  % image source idx for odx
        for pdx=1:NWalls
          % idx selects sources from the previous odx loop (without the
          % sources which have been mirrored at the current Wall pdx before)
          for idx=idx_range(parentWallsDx(idx_range) ~= pdx)
            rdx = rdx + 1;
            
            % constructor sets original Source
            Images(rdx) = constructor(Images(idx).OriginalObject);
            % set Parent Object
            Images(rdx).ParentObject = ...
              Images(idx);
            parentObjectsDx(rdx) = idx;
            % set successing Object
            sucObjectsDx(pdx,idx) = rdx;
            % set Parent Wall
            Images(rdx).ParentPolygon = ...
              obj.Walls(pdx);
            parentWallsDx(rdx) = pdx;  % set index of Walls
            % set Absorption Weight
            Images(rdx).Weight = obj.Walls(pdx).rho.*Images(idx).Weight;
          end
        end
        idx_range = (idx_range(end)+1):rdx;  % set
      end
    end
    function ismPositions(obj, Objects, Images)
      % Copy Positions of real Objects to the first Image
      DummyObject = simulator.ImageObject();  % just a dummy object for testing
      for idx=1:length(Objects)
        % set Position of Image by copying Position of real Object
        Images(idx).Position = Objects(idx).Position;
        Images(idx).Valid = true;  % Image is initially valid
        % set Image as Parent Object of Dummy
        DummyObject.ParentObject = Images(idx);
        for pdx=1:length(obj.Walls)
          DummyObject.ParentPolygon = obj.Walls(pdx);
          
          % check whether real source is behind a wall
          DummyObject.mirror;
          if (~DummyObject.Valid)
            Images(idx).Valid = false;
            break;
          end
        end
      end
      %
      for idx=length(Objects)+1:length(Images)
        % set Position of Image by mirroring Position of parent Image at
        % parent Walls
        Images(idx).mirror;  %
        Images(idx).Valid = Images(idx).Valid && Images(idx).ParentObject.Valid;
      end
    end
    
    function ismVisibility(obj)
      % initialize visibility
      visible = [obj.ImageSources.Valid];
      % select image sources which are valid after position computation
      src_range = find(visible);
      for srcdx=src_range % for each of these image sources
        DummySource = obj.ImageSources(srcdx);
        idx = srcdx;
        sinkdx = 1;
        % iterate recursively
        while ~isempty(DummySource.ParentObject)
          % set new head image
          DummySink = obj.ImageSinks(sinkdx);
          % if any subsequent source or head position is not valid,
          % the original source is not visible
          if (~DummySource.Valid || ~DummySink.Valid)
            visible(srcdx) = false;
            break;
          end
          
          if ~DummySource.checkVisibility(DummySink.Position)
            visible(srcdx) = false;
            break;
          end
          
          pdx = obj.parentWallsDx(idx);
          DummySource = DummySource.ParentObject;
          idx = obj.parentSourcesDx(idx);
          sinkdx = obj.sucSinksDx(pdx, sinkdx);
        end
      end
      % apply visibility
      for srcdx=find(~visible)
        obj.ImageSources(srcdx).Valid = false;
      end
    end
  end
  %% PWD
  methods
    function SubSources = pwdInit(obj, PWDSources)
      
      NObj = length(PWDSources);
      NSub = sum([PWDSources.RequiredChannels]);
      
      wdx = 0;
      for idx=1:NObj
        for kdx=1:PWDSources(idx).RequiredChannels
          wdx = wdx + 1;
          SubSources(wdx) = simulator.AudioSource( ...
            simulator.AudioSourceType.PLANE, simulator.buffer.FIFO());
          SubSources(wdx).GroupObject = PWDSources(idx);
          SubSources(wdx).UnitFront = PWDSources(idx).Directions(:,kdx);
        end
      end
    end
  end  
  
  %% misc.
  methods
    function draw(obj,id)
      % function draw(obj)
      % plot walls, sources, sinks + image sources/sinks
      if nargin < 2
        id = figure;
      else
        figure(id);
      end
      
      head_pos = [obj.Sinks.Position];
      img_head_pos = [obj.ImageSinks.Position];
      src_pos = [obj.Sources(obj.mirroredSourcesDx).Position];
      img_pos = [obj.ImageSources.Position];
      img_mute = [obj.ImageSources.Mute];
      
      % Draw Walls
      for i=1:length(obj.Walls)
        obj.Walls(i).draw(id);
      end
      
      hold on;
      % Draw Head-Position
      h(1) = plot3(head_pos(1), head_pos(2), head_pos(3),'kx');
      % Draw Image-Head-Positions
      h(2) = plot3(img_head_pos(1,:), ...
        img_head_pos(2,:), ...
        img_head_pos(3,:), ...
        'go');
      % Draw Source-Position
      h(3) = plot3(src_pos(1,:), src_pos(2,:), src_pos(3,:),'rx');
      % Draw Active/Valid Sources
      if min(img_mute) == 0
      h(4) = plot3(img_pos(1,~img_mute), ...
        img_pos(2,~img_mute), ...
        img_pos(3,~img_mute),  ...
        'bo');
      end
      % Draw Inactive/Invalid Sources
      if max(img_mute) == 1
        h(5) = plot3(img_pos(1,img_mute), ...
          img_pos(2,img_mute), ...
          img_pos(3,img_mute), ...
          'b.');
      end
      
      hold off;
      axis equal;
      legend(h, ...
        {'Head', ...
        'Image-Heads', ...
        'Sources', ...
        'Active Image-Sources', ...
        'Inactive Image-Sources'} ...
        );
    end
  end
  %% setter, getter
  methods
    function v = get.reflect_factor(obj)
      q = length(obj.Walls);
      n = obj.ReverberationMaxOrder;
      
      if (n == 0 || q == 0)
        v = 1;
      elseif (q == 1)
        v = 2;
      elseif (q == 2)
        v = (1 + 2 * n);
      else
        v = 1 + q * (1 - (q-1).^n) / (2-q);
      end
    end
    function v = get.NumberOfImageSources(obj)
      v = length(obj.mirroredSourcesDx)*obj.reflect_factor;
    end
    function v = get.NumberOfSSRSources(obj)
      v = obj.NumberOfImageSources + obj.NumberOfPWDSources;
    end
    function v = get.NumberOfPWDSources(obj)
      v = sum([obj.Sources(obj.pwdSourcesDx).RequiredChannels]);
    end
    function v = get.NumberOfDirectSources(obj)
      v = length(obj.directSourcesDx);
    end
    function v = get.NumberOfSources(obj)
      v = obj.NumberOfSSRSources + obj.NumberOfDirectSources;
    end    
  end
end