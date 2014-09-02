classdef Object < simulator.vision.Meta & xml.MetaObject
  % Base class for scene-objects
  
  % Some MetaData
  properties
    % unique identifier for this objects
    % @type char[]
    Name;
    % some labels (TODO: define possible labels)
    % @type char{}
    Labels;
  end
  
  % Geometry
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
    Position;
    % front vector
    % @type double[]
    % @default [1; 0; 0]
    UnitFront;
    
    % radius (spherical coordinates) of Position in degree
    % @type double
    % @default 0
    Radius;
    % azimuth angle (spherical coordinates) of Position in degree
    % @type double
    % @default 0
    Azimuth;
    % polar angle (spherical coordinates) of Position in degree
    % @type double
    % @default 0
    Polar;
  end
  properties (Dependent, SetAccess=private)
    % vector resulting of UnitUp x UnitFront
    % @type double[]
    % @default [0; 1; 0]
    UnitRight;
    % xy-coordinates of Position
    % @type double[]
    % @default [0; 0]
    PositionXY;
    % azimuth of UnitFront in degree
    % @type double
    % @default 0
    OrientationXY;
    % RotationMatrix resulting of [obj.UnitRight, obj.UnitUp, obj.UnitFront]
    % @type double[][]
    % @default eye(3)
    RotationMatrix;
  end
  
  % Dynamic Stuff
  properties (SetAccess = private)
    PositionDynamic = simulator.dynamic.AttributeLinear([0; 0; 0]);
    UnitFrontDynamic = simulator.dynamic.AttributeAngular([1; 0; 0]);
  end
  
  % Hierarchical Stuff
  properties
    % Parent Object used for grouping Objects
    % @type simulator.Object
    % using the Grouping Object will lead to the following behaviour:
    % setting Object.Position or Object.Unit... will define the parameters
    % inside the coordinates system of the GroupObject:
    %
    % Object.Positon := Object.GroupObject.RotationMatrix
    %   *(Object.Position - Object.GroupObject.Position)
    %
    % Object.Unit... := Object.GroupObject.RotationMatrix*Object.Unit...
    GroupObject;
  end
  properties (Dependent, Access=private)
    GroupTranslation;
    GroupRotation;
  end
  
  %% Constructor
  methods
    function obj = Object()
      obj = obj@simulator.vision.Meta();
      obj.addXMLAttribute('UnitUp', 'double');
      obj.addXMLAttribute('UnitFront', 'double');
      obj.addXMLAttribute('Position', 'double');
      obj.addXMLAttribute('Radius', 'double');
      obj.addXMLAttribute('Name', 'char');
      obj.addXMLAttribute('Labels', 'cell');
    end
  end
  
  methods
    %% Rotation
    function rotateAroundFront(obj, alpha)
      % function rotateAroundFront(obj, alpha)
      % rotate object around its UnitFront vector
      %
      % Parameters:
      %   alpha:  rotation angle in degree @type double
      obj.rotateAroundAxis(obj.UnitFront, alpha);
    end
    function rotateAroundUp(obj, alpha)
      % function rotateAroundUp(obj, alpha)
      % rotate object around its UnitUp vector
      %
      % Parameters:
      %   alpha:  rotation angle in degree @type double
      obj.rotateAroundAxis(obj.UnitUp, alpha);
    end
    function rotateAroundRight(obj, alpha)
      % function rotateAroundRight(obj, alpha)
      % rotate object around its UnitRight vector
      %
      % Parameters:
      %   alpha:  rotation angle in degree @type double
      obj.rotateAroundAxis(obj.UnitRight, alpha);
    end
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
      % refresh properties with finite-speed modification
      %
      % Parameters:
      %   T: time difference in seconds @type double
      %
      % Properties with finite-speed modification speed will change over time to
      % its target value. This functions refreshes this properties to a new
      % timestamp which has a difference to the old timestamp of T
      %
      % See also: simulator.dynamic.AttributeLinear
      obj.PositionDynamic = obj.PositionDynamic.refresh(T);
      obj.UnitFrontDynamic = obj.UnitFrontDynamic.refresh(T);
    end
    % extended setter, getter for dynamic extension
    function setDynamic(obj, name, prop, value)
      % set settings of certain property for finite-speed modification
      %
      % Parameters:
      %   name: name of the property @type char[]
      %   prop: name of the limited speed parameter @type char[]
      %   value: value for the limited speed parameter
      %
      % supported properties (name)
      % - Position
      % - UnitFront
      %
      % supported limited speed parameters (prop)
      % - Velocity
      %
      % See also: simulator.dynamic.AttributeLinear
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
      % set settings of certain property for limited speed motion
      %
      % Parameters:
      %   name: name of the property @type char[]
      %   prop: name of the dynamic property @type char[]
      %
      % Return Values:
      %   v: value for the limited speed parameter
      %
      % See also: setDynamic simulator.dynamic.AttributeLinear
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
      v = isargunitvectorOrCorrect(v);
      v = v{1};
      obj.UnitUp = v;
    end
    %
    function set.UnitFront(obj,v)
      isargcoord(v);
      v = isargunitvectorOrCorrect(v);
      v = v{1};
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
    function v = get.Radius(obj)
      x = obj.Position;
      v = sqrt(sum(x.^2,1));
    end
    function set.Radius(obj, r)
      isargscalar(r);
      phi = obj.Azimuth;
      theta = obj.Polar;
      obj.Position = r.*[cosd(phi).*sind(theta); ...
        sind(phi).*sind(theta); ...
        cosd(theta)];
    end
    %
    function v = get.Azimuth(obj)
      v = atan2d(obj.Position(2,:), obj.Position(1,:));
    end
    function set.Azimuth(obj, v)
      isargscalar(v);
      x = obj.Position;
      r = sqrt(x(2).^2 + x(1).^2);
      obj.Position = [r.*cosd(v); r.*sind(v); x(3)];
    end
    %    
    function v = get.Polar(obj)
      v = acosd(obj.Position(3,:));
    end
    function set.Polar(obj, theta)
      isargscalar(theta);
      phi = obj.Azimuth;
      r = obj.Radius;
      obj.Position = r.*[cosd(phi).*sind(theta); ...
        sind(phi).*sind(theta); ...
        cosd(theta)];
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
end
