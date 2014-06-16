classdef (Abstract) MetaObject < hgsetget
  %METAOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (SetAccess=protected)
    % Cell-Array of Strings defining Properties which can be configured via XML
    XMLProperties@cell
  end
  
  methods
    function PropertiesFromXMLNode(obj, xmlnode)
      if xmlnode.hasAttributes
        attrs = xmlnode.getAttributes;
        num_attrs = attrs.getLength;
        for idx =1:num_attrs
          attrib = attrs.item(idx-1);
          name = char(attrib.getName);
          value = char(attrib.getValue);
          found = false;
          for kdx = 1:length(obj.XMLProperties)
            if strcmp(obj.XMLProperties{kdx},name)
              obj.(obj.XMLProperties{kdx}) = str2num(value)';
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
  end
end