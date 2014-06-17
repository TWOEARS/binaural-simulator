classdef PropertyDescription
  
  properties
    Alias@char;
    Name@char;
    Class@char;
  end
  
  methods
    function obj = PropertyDescription(Name, Class, Alias)
      obj.Name = Name;
      obj.Alias = Alias;
      obj.Class = Class;
    end
  end  
end