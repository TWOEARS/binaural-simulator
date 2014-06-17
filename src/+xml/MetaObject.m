classdef (Abstract) MetaObject < hgsetget
  %METAOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (SetAccess=protected)
    % Cell-Array of Strings defining Properties which can be configured via XML
    XMLProperties@xml.PropertyDescription
  end
  
  methods
    function XML(obj, xmlnode)
      obj.XMLAttributes(xmlnode);
      obj.XMLChilds(xmlnode);
    end
  end
    
  methods (Access=private)    
    function XMLAttributes(obj, xmlnode)      
      for kdx = 1:length(obj.XMLProperties)
        value = char(xmlnode.getAttribute(obj.XMLProperties(kdx).Alias));
        if ~isempty(value)
          obj.(obj.XMLProperties(kdx).Name) ...
            = obj.conversion(value,obj.XMLProperties(kdx).Class);
        end
      end
    end    
  end
  
  methods (Access=protected)
    function XMLChilds(obj, xmlnode)
    end
  end
  
  methods (Access = protected)
    function addXMLProperty(obj, Name, Class, Alias)
      if nargin < 4
        Alias = Name;
      end
      obj.XMLProperties = [obj.XMLProperties, ...
        xml.PropertyDescription(Name, Class, Alias)];
    end
    function out = conversion(obj, in, Class)
      switch Class
        case 'double'
          out = str2num(in).';
        case 'char'
          out = in;
        case 'simulator.DirectionalIR'
          out = simulator.DirectionalIR(in);
        otherwise
          error('Class(%s) of XMLProperty is not supported', Class);
      end
    end
  end
end