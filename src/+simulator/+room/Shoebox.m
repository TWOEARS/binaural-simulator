classdef Shoebox < simulator.room.Base
  %BASE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    % length of room in meter
    % @type double
    % @default 1
    Length = 1;
    % width of room in meter
    % @type double
    % @default 1
    Width = 1;
    % height of room in meter
    % @type double
    % @default 1
    Height = 1;
    % 
    % @type char[]
    % @default '2D'
    ReverberationMode = '2D'
  end
  
  properties (SetAccess = private)
    Q
    M
  end
  
  methods
    function obj = Shoebox()
      obj = obj@simulator.room.Base();
      
      obj.addXMLAttribute('Length', 'double');
      obj.addXMLAttribute('Width', 'double');
      obj.addXMLAttribute('Height', 'double');
      obj.addXMLAttribute('ReverberationMode', 'char');
    end
    
    function init(obj)
      N = ceil(obj.ReverberationMaxOrder/2);
      
      switch obj.ReverberationMode
        case '2D'
          [qq, jj, kk, mx, my, mz] = ...
            ndgrid([0,1], [0,1], 0, 2*(-N:N), 2*(-N:N), 0);
        case '3D'
          [qq, jj, kk, mx, my, mz] = ...
            ndgrid([0,1], [0,1], [0,1], 2*(-N:N), 2*(-N:N), 2*(-N:N));
      end
      
      select = abs(mx - qq) + abs(my - jj) + abs(mz - kk) <= obj.ReverberationMaxOrder;
      
      obj.Q = 1 - 2 * [qq(select), jj(select), kk(select)]';
      obj.M = [obj.Length*mx(select), obj.Width*my(select), obj.Height*mz(select)]';
    end
    
    function refreshSubSources(obj, source)      
      pos = obj.RotationMatrix' * (source.Position - obj.Position);
      
      for idx=1:obj.NumberOfSubSources
        source.SubSources(idx).Position = obj.Position + obj.RotationMatrix ...
        * ( obj.Q(:,idx).*pos + obj.M(:,idx) );
      end
    end
    
    function v = NumberOfSubSources(obj)
      n = obj.ReverberationMaxOrder;
      
      switch obj.ReverberationMode
        case '2D'
          v = 1 + 2*n*(n+1);
        case '3D'
          v = 1 + n*(n+1)*(n+2);
        otherwise
          error('unsupported number of walls!');
      end
    end    
  end
end