classdef PropertyDescription
  
  properties (SetAccess=private)
    Alias;
    Name;
    Class;
    Constructor;
  end
  
  methods
    function obj = PropertyDescription(Name, Class, Alias, Constructor)
      obj.Name = Name;
      obj.Alias = Alias;
      obj.Class = Class;
      if nargin == 4
        obj.Constructor = Constructor;
      end
    end
  end
end