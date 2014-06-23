classdef PropertyDescription
  
  properties (SetAccess=immutable)
    Alias@char;
    Name@char;
    Class@char;
    Constructor@function_handle;
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