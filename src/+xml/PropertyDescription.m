classdef PropertyDescription
  
  properties
    Name@char;
    Class@char;
    Childs@logical;
  end
  
  methods
    function obj = PropertyDescription(Name, Class, Childs)
      if nargin < 3
        Childs = false;
      end
      
      obj.Name = Name;
      obj.Class = Class;
      obj.Childs = Childs;
    end
  end  
end

