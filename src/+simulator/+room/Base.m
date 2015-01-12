classdef (Abstract) Base < simulator.Object
  %BASE Summary of this class goes here
  %   Detailed explanation goes here
  
  properties
    % order of image source model (number of subsequent reflections)
    % @type integer
    % @default 0
    ReverberationMaxOrder = 0;
  end
  
  methods
    function obj = Base()
      obj.addXMLAttribute('ReverberationMaxOrder', 'double');
    end
  end
  
  methods (Abstract)
    init(obj)
    v = NumberOfSubSources(obj)
    refreshSubSources(obj, source)
  end  
end