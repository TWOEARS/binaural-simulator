classdef Polygon < simulator.Object
  % Polygon Class
  
  properties
    % array of 2D vertices (ordered)
    % @type double[]
    Vertices = [1.0, 1.0, -0.0, -0.0; 1.0, -0.0, 0.0, 1.0];
    % tolerance criterion for intersectLine
    % @type double
    eps = 1.0e-5;
  end
  
  %% Constructor
  methods
    function obj = Polygon()
      obj = obj@simulator.Object();
      obj.addXMLProperty('Vertices', 'double');
    end
  end
  
  methods
    function [p, d] = mirrorPoints(obj, p)
      % function [p, d] = mirrorPoints(obj, p)
      % mirror point in polygon
      %
      % Parameters:
      %  p: 3D coordinate @type double[]
      %
      % Return values:
      %  p: 3D coordinate of mirrored point @type double[]
      %  d: orthogonal distance of point to polygon @type double
      
      d = zeros(1,size(p,2));
      for i=1:size(p,2)
        d(i) = (p(:,i) - obj.Position)'*obj.UnitFront;
        p(:,i) = p(:,i) - 2*d(i)*obj.UnitFront;
      end
    end
    function lambda = intersectLine(obj, lo, ld)
      % function lambda = intersectLine(obj, lo, ld)
      % intersection of line and polygon
      %
      % line parameter equation: @f$x = l_o + \lambda l_d @f$
      %
      % Parameters:
      %  lo: base point @f$l_o@f$ @type double[]
      %  ld: direction vector @f$l_d@f$ @type  double[]
      %
      % Return values:
      %  lambda: value of @f$ \lambda @f$ for intersection
      
      % compute lambda parameter of line
      lambda = ((obj.Position-lo)'*obj.UnitFront)./ (ld'*obj.UnitFront);
      
      % compute intersection point ri3D
      ri3D = (lo + lambda*ld);
      
      % project ri3D in coordinate system of polygon
      ri2D = [obj.UnitRight, obj.UnitUp]'*(ri3D - obj.Position);
      
      % x and y component of difference vector between ri2D and vertices
      dx = obj.Vertices(1,:) - ri2D(1);
      dy = obj.Vertices(2,:) - ri2D(2);
      
      % check whether intersection point is inside the polygon
      
      n1 = dx(1)*dy(2) - dy(1)*dx(2);  % normal of 1st and 2nd difference vector
      l = length(dx);
      for i = 2:l
        ipp = mod(i,l) + 1;
        n2 = dx(i)*dy(ipp) - dy(i)*dx(ipp);
        if (sign(n1) ~= sign(n2) && abs(n2) > obj.eps && abs(n1) > obj.eps)
          lambda = [];
          break;
        end
        n1 = n2;
      end
    end
    function draw(obj, id)
      % function draw(obj, id)
      % draw polygon
      %
      % Parameters:
      %  id: figure id @type uint @default 1
      if nargin < 2
        id = figure;
      else
        figure(id);
      end
      
      v3D = [obj.UnitRight, obj.UnitUp]*obj.Vertices + repmat(obj.Position,[1 size(obj.Vertices,2)]);
      figure(id);
      hold on;
      p = patch(v3D(1,:),v3D(2,:),v3D(3,:),'b');
      set(p,'FaceColor','b','FaceAlpha',0.2);
      hold off;
    end
    %% setter, getter
    function set.Vertices(obj, Vertices)
%       if (size(Vertices,1) ~= 2)
%         error('%s need to be a matrix with size(%s,1) = 2.', ...
%           inputname(2), inputname(2));
%       end
      obj.Vertices = reshape(Vertices,2,[]);      
    end
  end
end