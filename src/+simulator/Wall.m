classdef Wall < simulator.Polygon
  % Wall Class

  properties
    rho = 1.0;
  end
  methods
    function prism = createUniformPrism(obj, height, mode)
      % function prism = createUniformPrism(obj, height, mode)
      % extrudes Polygon orthogonaly to a uniform prism
      %
      % Parameters:
      %  height:  height of resulting prism @type double
      %  mode:    optional mode for '2D' or '3D' @type string @default '2D'
      %
      % Return values:
      %  obj:   array of 4('2D') or 6('3D') Walls @type Wall[]

      if nargin < 2
        error('too few arguments');
      end
      if nargin < 3
        mode = '2D';
      end      
      
      edges = size(obj.Vertices,2);
      v3D = [obj.Vertices; zeros(1,edges)];
      up = [0; 0; 1];
      
      prism(edges) = simulator.Wall();
      
      for idx=1:edges
        next = mod(idx,edges) + 1;
        vdiff = v3D(:,idx) - v3D(:,next);
        vdist = norm(vdiff);

        prism(idx).Vertices = [0.0, 0.0, vdist, vdist; 0.0, height, height, 0.0];
        prism(idx).Position = v3D(:,next) + obj.Position;
        
        rot = [obj.UnitRight, obj.UnitUp, obj.UnitFront];
        prism(idx).UnitUp = rot*up;
        prism(idx).UnitFront = rot*(cross(vdiff, up)/vdist);
        prism(idx).rho = obj.rho;
      end      
      
      switch mode
        case '2D'
        case '3D'
         ground = edges+1;
         ceiling = edges+2;
         prism(ground) = obj;
         
         prism(ceiling) = simulator.Wall();
         prism(ceiling).Position = obj.Position + obj.UnitFront*height;
         prism(ceiling).UnitUp = -obj.UnitUp;
         prism(ceiling).UnitFront = -obj.UnitFront;
         prism(ceiling).Vertices = [obj.Vertices(1,:); -obj.Vertices(2,:)];

         prism(ceiling).rho = obj.rho;
        otherwise
         error('unknown mode');
      end
      
    end
  end
  
  methods (Static)
    function room = createRectangularRoom(pos1, pos2, rho, mode)
      % function obj = createRectangularRoom(pos1, pos2, rho, mode)
      % create Walls for a rectangular Room
      %
      % Parameters:
      %  pos1:  first vertex of rectangular cuboid @type double[]
      %  pos2:  second vertex of rectangular cuboid @type double[]
      %  rho:   optional absorption factor for each @type double @default 1.0
      %  mode:  optional mode for '2D' or '3D' @type string @default '2D'
      %
      % Return values:
      %  obj:   array of 4('2D') or 6('3D') Walls @type Wall[]
      
      if nargin < 2
        error('too few arguments');
      end
      if nargin < 4
        mode = '2D';
      end
      
      tmp = max(pos2,pos1);
      pos1 = min(pos2,pos1);
      pos2 = tmp;
      diff = pos2-pos1;
      
      ground = simulator.Wall();
      ground.Position = pos1;
      ground.Vertices = [0.0, diff(1), diff(1), 0.0; 0.0, 0.0, diff(2), diff(2)];
      
      room = ground.createUniformPrism(diff(3),mode);
      
      for idx=1:length(room)
        room(idx).rho = rho;
      end
    end
  end
end