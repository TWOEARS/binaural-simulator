classdef ISMShoeBox < simulator.source.ISMGroupBase
  % Class for mirror source objects used for the mirror image model
  
  methods
    function obj = ISMShoeBox(sim)
      obj = obj@simulator.source.ISMGroupBase(sim);
    end
    function init(obj)
      
      % re-initialize image objects
      obj.SubSources = simulator.source.Image.empty();
      
      % some lengths and sizes
      NWalls = length(obj.Simulator.Walls);
      NImg = obj.NumberOfSubSources;
      
      for idx=1:NImg
        obj.SubSources(idx) = simulator.source.Image(obj);
      end
      
      if (NImg == 0 || NWalls == 0)
        return;
      end
      
      idx_range = 1;
      obj.parentSourcesDx = zeros(1,NImg);
      obj.sucSinksDx = zeros(NWalls, NImg);
      obj.parentWallsDx = zeros(1,NImg);
      
      for odx=1:obj.Simulator.ReverberationMaxOrder
        idx_end = idx_range(end);  % image source idx for odx
        rdx = idx_end;
        for pdx=1:NWalls
          % idx selects sources from the previous odx loop (without the
          % sources which have been mirrored at the current Wall pdx before)
          for idx=idx_range(obj.parentWallsDx(idx_range) ~= pdx)            
            rdx = rdx + 1;
            if rdx > NImg
              break;
            end
            % set Parent Object
            obj.SubSources(rdx).ParentObject = obj.SubSources(idx);
            % set Parent Wall
            obj.SubSources(rdx).ParentPolygon = obj.Simulator.Walls(pdx);
            % set index of parent source
            obj.parentSourcesDx(rdx) = idx;
            % set index of parent wall
            obj.parentWallsDx(rdx) = pdx;
            
            % test if there is already an image source at this position
            obj.SubSources(rdx).mirror();  % test mirroring
            srcPos = repmat(obj.SubSources(rdx).Position,[1 rdx-1]);
            otherPos = [obj.SubSources(1:rdx-1).Position];
            if any(sum( (srcPos - otherPos).^2, 1) < eps)
              rdx = rdx - 1;
            end
          end
        end
        idx_range = (idx_end+1):rdx;
      end
    end
    function refresh(obj,T)
      if nargin==2
        obj.refresh@simulator.source.GroupBase(T);
      else
        obj.refresh@simulator.source.GroupBase();
      end
      obj.refreshPositions(obj, obj.SubSources);
      
      obj.refreshAmplitude(obj.SubSources);
    end
  end
  
  %%
  methods
    function v = NumberOfSubSources(obj)
      n = obj.Simulator.ReverberationMaxOrder;
      
      switch length(obj.Simulator.Walls)
        case 0
          v = 1;
        case 4
          tmp = triu(ones(n));
          v = (2*n + 1).^2 - 4*sum(tmp(:));
        case 6
          error('3D is not yet supported for shoebox rooms');
        otherwise
          error('unsupported number of walls!');
      end
    end
  end
end
