classdef ISMGroupBase < simulator.source.GroupBase
  % Class for mirror source objects used for the mirror image model

  properties (Access = protected)
    Simulator;
    ImageSinks;
    mirroredSourcesDx;  % index for original sources for ism
    parentSourcesDx;  % index for 'mother' source of images sources
    parentWallsDx;  % index for 'mother' wall of images sources
    sucSinksDx;  % index for 'child' images sinks of sinks
  end

  methods
    function obj = ISMGroupBase(sim)
      obj = obj@simulator.source.GroupBase();
      obj.Simulator = sim;
    end
  end  
  
  %%
  methods (Abstract)
    v = NumberOfSubSources(obj)
    init(obj)
    refresh(obj)
  end

  %% Image Source Model
  methods (Access = protected)
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
  end
end
