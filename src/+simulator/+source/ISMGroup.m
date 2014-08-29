classdef ISMGroup < simulator.source.GroupBase
  % Class for mirror source objects used for the mirror image model

  properties (Access=private, Dependent)
    NumberOfSubSource;
  end

  properties (Access = private)
    Simulator;
    ImageSinks;
    mirroredSourcesDx;  % index for original sources for ism
    parentSourcesDx;  % index for 'mother' source of images sources
    parentWallsDx;  % index for 'mother' wall of images sources
    sucSinksDx;  % index for 'child' images sinks of sinks
  end

  methods
    function obj = ISMGroup(sim)
      obj = obj@simulator.source.GroupBase();
      obj.Simulator = sim;
    end
    function init(obj)

      % re-initialize image objects
      obj.SubSources = simulator.source.Image.empty();
      obj.ImageSinks = simulator.ImageObject.empty();

      % some lengths and sizes
      NWalls = length(obj.Simulator.Walls);
      NImg = obj.NumberOfSubSource;

      for idx=1:NImg
        obj.SubSources(idx) = simulator.source.Image(obj);
        obj.ImageSinks(idx) = simulator.ImageObject();
      end

      if (NImg == 0 || NWalls == 0)
        return;
      end

      idx_range = 1;
      obj.parentSourcesDx = zeros(1,NImg);
      obj.sucSinksDx = zeros(NWalls, NImg);
      obj.parentWallsDx = zeros(1,NImg);

      for odx=1:obj.Simulator.ReverberationMaxOrder
        rdx = idx_range(end);  % image source idx for odx
        for pdx=1:NWalls
          % idx selects sources from the previous odx loop (without the
          % sources which have been mirrored at the current Wall pdx before)
          for idx=idx_range(obj.parentWallsDx(idx_range) ~= pdx)
            rdx = rdx + 1;

            % set Parent Object
            obj.SubSources(rdx).ParentObject = obj.SubSources(idx);
            obj.ImageSinks(rdx).ParentObject = obj.ImageSinks(idx);

            obj.parentSourcesDx(rdx) = idx;
            % set successing Object
            obj.sucSinksDx(pdx,idx) = rdx;
            % set Parent Wall
            obj.SubSources(rdx).ParentPolygon = obj.Simulator.Walls(pdx);
            obj.ImageSinks(rdx).ParentPolygon = obj.Simulator.Walls(pdx);
            % set index of Walls
            obj.parentWallsDx(rdx) = pdx;
          end
        end
        idx_range = (idx_range(end)+1):rdx;
      end
    end
    function refresh(obj,T)
      if nargin==2
        obj.refresh@simulator.source.GroupBase(T);
      else
        obj.refresh@simulator.source.GroupBase();
      end
      obj.refreshPositions(obj, obj.SubSources);
      obj.refreshPositions(obj.Simulator.Sinks, obj.ImageSinks);

      obj.refreshVisibility(obj.SubSources);
      obj.refreshAmplitude(obj.SubSources);
    end
  end

  %% Image Source Model
  methods (Access = private)
    function refreshPositions(obj, Objects, Images)

      % Copy Positions of real N Objects to the first N Images
      DummyObject = simulator.ImageObject();  % just a dummy object for testing
      for idx=1:length(Objects)
        % set Position of Image by copying Position of real Object
        Images(idx).Position = Objects(idx).Position;
        Images(idx).Valid = true;  % Image is initially valid
        % set Image as Parent Object of Dummy
        DummyObject.ParentObject = Images(idx);
        for pdx=1:length(obj.Simulator.Walls)
          DummyObject.ParentPolygon = obj.Simulator.Walls(pdx);

          % check whether real source is behind a wall
          DummyObject.mirror;
          if (~DummyObject.Valid)
            Images(idx).Valid = false;
            break;
          end
        end
      end

      % For the rest of the Images, do the ISM algorithm
      for idx=length(Objects)+1:length(Images)
        % set Position of Image by mirroring Position of parent Image at
        % parent Walls
        Images(idx).mirror;  %
        Images(idx).Valid = Images(idx).Valid && Images(idx).ParentObject.Valid;
      end
    end

    function refreshVisibility(obj, Images)
      % initialize visibility
      visible = [Images.Valid];
      % select image sources which are valid after position computation
      src_range = find(visible);
      for srcdx=src_range % for each of these image sources
        DummySource = Images(srcdx);
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
        Images(srcdx).Valid = false;
      end
    end
    function refreshAmplitude(obj, SubSources)
      for idx=1:length(SubSources)
        % mute invalid image sources and sources with muted OriginalObject
        SubSources(idx).Mute = ~SubSources(idx).Valid;
        % correct distance for 3D to 2D
        SubSources(idx).correctDistance(obj.Simulator.Sinks.Position);
      end
    end
  end

  %% MISC
  methods
    function [h, leg] = plot(obj, figureid)
      if nargin < 2
        figureid = figure;
      else
        figure(figureid);
      end

      [h, leg] = obj.plot@simulator.source.GroupBase(figureid);
      set(h(1),'Marker','square');
    end
  end

  %% setter/getter
  methods
    function set.Simulator(obj, s)
      isargclass('simulator.SimulatorInterface',s);
      obj.Simulator = s;
    end
    function v = get.NumberOfSubSource(obj)
      q = length(obj.Simulator.Walls);
      n = obj.Simulator.ReverberationMaxOrder;

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
  end
end
