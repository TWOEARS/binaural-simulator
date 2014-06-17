classdef Object < xml.MetaObject
  % OBJECT Base Class for Scene-Objects
  
  properties (SetObservable, AbortSet)
    % view-up vector
    % @type double[]
    % @default [0; 0; 1]
    UnitUp = [0; 0; 1];
  end
  properties (Dependent)
    % 3D-Position
    % @type double[]
    % @default [0; 0; 0]
    Position
    % front vector
    % @type double[]
    % @default [1; 0; 0]
    UnitFront;
    
    PositionXY;  % xy-coordinates of Position @type double[]
    OrientationXY;  % azimuth of UnitFront in degree @type double
    UnitRight;  % vector resulting of UnitUp x UnitFront  @type double[]
    RotationMatrix; % 
  end
  
  % Dynamic Stuff
  properties (SetAccess = private)
    PositionDynamic = simulator.dynamic.AttributeLinear([0; 0; 0]);
    UnitFrontDynamic = simulator.dynamic.AttributeAngular([1; 0; 0]);
  end
  
  % Hierarchical Stuff
  properties
     GroupObject@simulator.Object;
  end
  properties (Dependent, Access=private)
     GroupTranslation;
     GroupRotation;
  end 
  
  %% Constructor 
  methods
    function obj = Object()
      obj.addXMLProperty('UnitUp', 'double');
      obj.addXMLProperty('UnitFront', 'double');
      obj.addXMLProperty('Position', 'double');
    end
  end  
  
  methods
    %% Rotation
    function rotateAroundFront(obj, alpha)
      % function rotateAroundFront(obj, alpha)
      % rotate object around its UnitFront vector
      %
      % Parameters:
      %   angle:  rotation angle in degree @type double
      obj.rotateAroundAxis(obj.UnitFront, alpha);
    end
    function rotateAroundUp(obj, alpha)
      % function rotateAroundUp(obj, alpha)
      % rotate object around its UnitUp vector
      %
      % Parameters:
      %   angle:  rotation angle in degree @type double
      obj.rotateAroundAxis(obj.UnitUp, alpha);
    end
    function rotateAroundRight(obj, alpha)
      % function rotateAroundRight(obj, alpha)
      % rotate object around its UnitRight vector
      %
      % Parameters:
      %   angle:  rotation angle in degree @type double
      obj.rotateAroundAxis(obj.UnitRight, alpha);
    end    
  end
  methods (Access = private)
    function rotateAroundAxis(obj, n, alpha)
      isargcoord(n);
      isargunitvector(n);
      isargscalar(alpha);
      
      c = cosd(alpha);
      omc = 1 - c;
      s = sind(alpha);
      
      R = ((n*n')*omc) + ...
        [ c     , -n(3)*s,  n(2)*s; ...
        n(3)*s,  c     , -n(1)*s; ...
        -n(2)*s,  n(1)*s,  c     ];
      
      obj.UnitFront = R*obj.UnitFront;
      obj.UnitUp = R*obj.UnitUp;
    end
  end
  %% dynamic stuff
  methods
    function refresh(obj, T)
      obj.PositionDynamic = obj.PositionDynamic.refresh(T);
      obj.UnitFrontDynamic = obj.UnitFrontDynamic.refresh(T);
    end
  end
  
  %% setter, getter
  methods
    % 
    function set.Position(obj,v)
      isargcoord(v);
      obj.PositionDynamic.Target = v;
    end
    function v = get.Position(obj)
      v = obj.PositionDynamic.Current;
      v = obj.GroupRotation*(v + obj.GroupTranslation);    
    end
    %
    function set.UnitUp(obj,v)
      isargcoord(v);
      isargunitvector(v);
      obj.UnitUp = v;
    end
    % 
    function set.UnitFront(obj,v)
      isargcoord(v);
      isargunitvector(v);
      obj.UnitFrontDynamic.Target = v;
    end
    function v = get.UnitFront(obj)
      v = obj.UnitFrontDynamic.Current;
      v = obj.GroupRotation*v; 
    end
    %
    function v = get.UnitRight(obj)
      v = cross(obj.UnitUp,obj.UnitFront);
    end
    %
    function v = get.UnitUp(obj)
      v = obj.GroupRotation*obj.UnitUp; 
    end
    %
    function v = get.PositionXY(obj)
      v = obj.Position(1:2,:);
    end
    %
    function v = get.OrientationXY(obj)
      v = atan2d(obj.UnitFront(2,:), obj.UnitFront(1,:));
    end
    %
    function v = get.RotationMatrix(obj)
      v = [obj.UnitRight, obj.UnitUp, obj.UnitFront];
    end
    
    %
    function set.GroupObject(obj, v)
      isargclass('simulator.Object', v);
      if (~isempty(v))
        isargequalsize(1,v);
      end      
      obj.GroupObject = v;
    end
    function v = get.GroupRotation(obj)
      if isempty(obj.GroupObject)
        v = eye(3);
      else
        v = obj.GroupObject.RotationMatrix;
      end
    end
    function v = get.GroupTranslation(obj)
      if isempty(obj.GroupObject)
        v = [0; 0; 0];
      else
        v = obj.GroupObject.Position;
      end
    end
  end  
  
  %% extended setter, getter for dynamic extension
  methods
    function setDynamic(obj, name, prop, value)
      isargchar(prop, name);
      if (~isprop(obj,name))
        error('unknown property: %s', name);
      end
      if (~isprop(obj,[name,'Dynamic']))
        error('%s is a not dynamic property', name);
      end
      obj.([name,'Dynamic']).(prop) = value;
    end
    function v = getDynamic(obj, name, prop)
      isargchar(prop, name);
      if (~isprop(obj,name))
        error('unknown property: %s', name);
      end
      if (~isprop(obj,[name,'Dynamic']))
        error('%s is a not dynamic property', name);
      end
      v = obj.([name,'Dynamic']).(prop);
    end
  end   
end
