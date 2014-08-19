classdef Image < simulator.ImageObject & simulator.source.Point
  % Class for mirror source objects used for the mirror image model

  methods
    function obj = Image(OriginalSource)
      if nargin < 1
        OriginalSource = [];
      else
        isargclass('simulator.source.ISMGroup', OriginalSource);
      end
      obj = obj@simulator.ImageObject();
      obj = obj@simulator.source.Point();
      obj.AudioBuffer = simulator.buffer.PassThrough(1, OriginalSource.AudioBuffer);
    end
    function mirror(obj)
      % function mirror(obj)
      % Compute objects position by mirroring ParentObject at ParentPolygon
      obj.mirror@simulator.ImageObject();
      obj.Volume = obj.ParentPolygon.ReflectionCoeff * obj.ParentObject.Volume;
    end
  end
end
