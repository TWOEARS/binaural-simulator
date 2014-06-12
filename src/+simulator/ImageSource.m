classdef ImageSource < simulator.ImageObject
  %UNTITLED2 Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    Mute = false;
  end
  
  properties (Access = private)
    DistanceCorrectionWeight = 1.0; 
  end   
  
  methods
    function obj = ImageSource(OriginalSource)
      if nargin < 1
        OriginalSource = [];
      end
      obj = obj@simulator.ImageObject(OriginalSource);
    end
    function data = getData(obj, length)
      % function = getData(obj, length)
      % get weighted data from original source
      %
      % Get audio data from original source, which is weighted by
      % obj.Weight and obj.DistanceCorrectionWeight
      %
      % Parameters:
      %  length: number of samples @default all @type uint[]
      if nargin < 2
        data = obj.OriginalObject.getData;
      else
        data = obj.OriginalObject.getData(length);
      end
      data = obj.Weight.*obj.DistanceCorrectionWeight.*data;
    end
    function correctDistance(obj, RefPosition)
      % function correctDistance(obj, RefPosition)
      % corrects distance attenuation for point sources in 3D
      %
      % Since the SoundScape Renderer only supports 2D scenarios, distance
      % correction of images sources in 3D has to be applied.
      %
      % Parameters:
      %  RefPosition: reference  @type double[]
      isargcoord(RefPosition);
      
      RefPosition = (obj.Position - RefPosition).^2;
      distanceXY = max(0.5, sqrt(RefPosition(1) + RefPosition(2)));
      distanceXYZ = max(0.5, sqrt(sum(RefPosition)));
      obj.DistanceCorrectionWeight = distanceXY./distanceXYZ;
    end
  end  
end