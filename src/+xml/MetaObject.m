classdef (Abstract) MetaObject < hgsetget
  %METAOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (SetAccess=protected)
    % Cell-Array of Strings defining Properties which can be configured via XML
    XMLProperties@xml.PropertyDescription
  end
  
  methods
    function XMLsetProperties(obj, xmlnode)
      if xmlnode.hasAttributes
        attrs = xmlnode.getAttributes;
        num_attrs = attrs.getLength;
        for idx =1:num_attrs
          attrib = attrs.item(idx-1);
          name = char(attrib.getName);
          value = char(attrib.getValue);
          found = false;
          for kdx = find([obj.XMLProperties.Childs] == false)
            if strcmp(obj.XMLProperties(kdx).Name,name)
              obj.(obj.XMLProperties(kdx).Name) ...
                = obj.conversion(value,obj.XMLProperties(kdx).Class);
              found = true;
              break;
            end
          end
          if ~found
            warning(['Name of attribute (\"%s\") does not match any ', ...
              'configurable property of Object'], name);
          end
        end
      end
    end
    function XMLsetChilds(obj, xmlnode)
      
    end
  end
  
  methods (Access = protected)
    function addXMLProperty(obj, Name, Class, Childs)
      if nargin < 3
        Childs = false;
      end
      obj.XMLProperties = [obj.XMLProperties, ...
        xml.PropertyDescription(Name, Class, Childs)];
    end
    function out = conversion(obj, in, Class)
      switch Class
        case 'double'
          out = str2double(in).';
        case 'char'
          out = in;
        otherwise
          error('Class(%s) of XMLProperty is not supported', Class);
      end
    end
  end
  

end