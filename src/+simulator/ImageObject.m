classdef ImageObject < simulator.Object
  % Class for mirror image objects used for the mirror image model
  
  properties
    % parent object from which this object was mirrored
    % @type simulator.Object
    ParentObject
    % parent polygon which was used to mirror the ParentObject
    % @type simulator.Polygon
    ParentPolygon
  end
  
  properties
    % flag indicating if the image object is valid by means of the mirror image
    % model
    %
    % @type logical
    Valid = true;
  end
  
  methods
    function mirror(obj)
      % function mirror(obj)
      % Compute objects position by mirroring ParentObject at ParentPolygon
      [obj.Position, distance] = ...
        obj.ParentPolygon.mirrorPoints(obj.ParentObject.Position);
      obj.Valid = (distance >= 0);
    end
    function b = checkVisibility(obj, p)
      % function b = checkVisibility(obj, p)
      % checks visibility of ImageObject "through" ParentPolygon from reference
      % position
      %
      % Parameters:
      %   p: coordinate of reference position @type double[]
      %
      % Return values:
      %   b: boolean indicates whether ImageObject is visible from p @type logical
      isargcoord(p);
      lambda = obj.ParentPolygon.intersectLine(p,obj.Position-p);
      b = ~isempty(lambda);
    end
    %% setter, getter
    function set.ParentObject(obj, ParentObject)
      isargclass('simulator.Object', ParentObject);
      obj.ParentObject = ParentObject;
    end
    function set.ParentPolygon(obj, ParentPolygon)
      isargclass('simulator.Polygon', ParentPolygon);
      obj.ParentPolygon = ParentPolygon;
    end
  end
end