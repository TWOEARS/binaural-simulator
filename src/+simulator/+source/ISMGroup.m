classdef ISMGroup < simulator.source.GroupBase
  % Class for mirror source objects used for the mirror image model

  properties (Access = protected)
    Room;
  end

  methods
    function init(obj)
      % re-initialize image objects
      obj.SubSources = simulator.source.Image.empty();
      for idx=1:obj.Room.NumberOfSubSources()
        obj.SubSources(idx) = simulator.source.Image(obj);
      end
    end
    
    function refresh(obj, T)
      if nargin==2
        obj.refresh@simulator.source.GroupBase(T);
      else
        obj.refresh@simulator.source.GroupBase();
      end
      
      obj.Room.refreshSubSources(obj);
      
      for idx=1:length(obj.SubSources)
        % mute invalid image sources and sources with muted OriginalObject
        obj.SubSources(idx).Mute = ~SubSources(idx).Valid;
        % correct distance for 3D to 2D
        % obj.SubSources(idx).correctDistance(obj.Simulator.Sinks.Position);
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
    function set.Room(obj, r)
      isargclass('simulator.room.Base',r);
      obj.Room = r;
    end
  end
end
