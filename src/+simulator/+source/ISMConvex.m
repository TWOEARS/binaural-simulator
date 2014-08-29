classdef ISMConvex < simulator.source.ISMGroupBase
  % Class for mirror source objects used for the mirror image model
  
  methods
    function obj = ISMConvex(sim)
      obj = obj@simulator.source.ISMGroupBase(sim);
    end
    function init(obj)
      
      % re-initialize image objects
      obj.SubSources = simulator.source.Image.empty();
      obj.ImageSinks = simulator.ImageObject.empty();
      
      % some lengths and sizes
      NWalls = length(obj.Simulator.Walls);
      NImg = obj.NumberOfSubSources;
      
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
  
  %%
  methods
    function v = NumberOfSubSources(obj)
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
