classdef Wall < simulator.Polygon
  % Class for wall objects used for mirror image model

  properties
    % amount of acoustic pressure which is reflected by the wall
    % @type double
    % @default 1.0
    ReflectionCoeff = 1.0;
  end

  properties (Dependent)
    % amount of acoustic energy which is absorbed by the wall
    %
    % @default 0.0
    % @type double
    AbsorptionCoeff;
  end

  %% Constructor
  methods
    function obj = Wall()
      obj = obj@simulator.Polygon();
      obj.addXMLAttribute('ReflectionCoeff', 'double');
      obj.addXMLAttribute('AbsorptionCoeff', 'double');
    end
  end

  %%
  methods
    function prism = createUniformPrism(obj, height, mode, RT60)
      % function prism = createUniformPrism(obj, height, mode)
      % extrudes Polygon orthogonaly to a uniform prism
      %
      % Parameters:
      %  height:  height of resulting prism @type double
      %  mode:    optional mode for '2D' or '3D' @type string @default '2D'
      %
      % Return values:
      %  obj:   array of 4('2D') or 6('3D') Walls @type Wall[]

      if nargin < 2 || isempty(height)
        error('too few arguments');
      else
        isargpositivescalar(height);
      end
      if nargin < 3 || isempty(mode)
        mode = '2D';
      else
        isargchar(mode);
      end
      if nargin >= 4 && ~isempty(RT60)
        isargpositivescalar(RT60);
        if size(obj.Vertices, 2) ~=4
          error('RT60 can only be defined for a rectangular room');
        end
        a = norm(obj.Vertices(:,1) - obj.Vertices(:,2));
        b = norm(obj.Vertices(:,2) - obj.Vertices(:,3));
        c = height;

        V = a*b*c;
        A = 2*( a*c + b*c );
        if strcmp(mode, '3D')
          A = A + 2*a*b;
        end
        % Sabine formula for the reverberation time of rectangular rooms
        obj.AbsorptionCoeff = 24*log(10.0)*V / (343*A*RT60);
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
        prism(idx).ReflectionCoeff = obj.ReflectionCoeff;
        prism(idx).Name = [obj.Name, '#', num2str(idx)];
      end

      switch mode
        case '2D'
        case '3D'
          ground = edges+1;
          ceiling = edges+2;
          prism(ceiling) = simulator.Wall();
          prism(ceiling).Position = obj.Position + obj.UnitFront*height;
          prism(ceiling).UnitUp = -obj.UnitUp;
          prism(ceiling).UnitFront = -obj.UnitFront;
          prism(ceiling).Vertices = [obj.Vertices(1,:); -obj.Vertices(2,:)];

          prism(ceiling).ReflectionCoeff = obj.ReflectionCoeff;
          prism(ceiling).Name = [obj.Name, '#ceiling'];

          prism(ground) = obj;
          prism(ground).Name = [obj.Name, '#ground'];
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
      if nargin < 3
        rho = 1.0;
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
        room(idx).ReflectionCoeff = rho;
      end
    end
  end
  %% setter/getter
  methods
    function set.ReflectionCoeff(obj, v)
      isargscalar(v);
      if abs(v) > 1
        error('ReflectionCoeff must be between -1 and +1');
      end
      obj.ReflectionCoeff = v;
    end
    function v = get.AbsorptionCoeff(obj)
      v = 1 - obj.ReflectionCoeff.^2;
    end
    function set.AbsorptionCoeff(obj, v)
      isargpositivescalar(v);
      if v > 1
        error('AbsorptionCoeff must be smaller equal 1');
      end
      obj.ReflectionCoeff = - sqrt(1 - v);
    end
  end
end
