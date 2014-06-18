classdef (Abstract) MetaObject < hgsetget
  %METAOBJECT Summary of this class goes here
  %   Detailed explanation goes here
  
  properties (SetAccess=protected)
    % Cell-Array of Strings defining Properties which can be configured via XML
    XMLAttributes@xml.PropertyDescription
    XMLElements@xml.PropertyDescription
  end
  
  methods
    function XML(obj, xmlnode)
      obj.configureXMLAttributes(xmlnode);
      obj.configureXMLSpecific(xmlnode);
      obj.configureXMLElements(xmlnode);
    end
  end
    
  methods (Access=protected)    
    function configureXMLAttributes(obj, xmlnode)      
      for kdx = 1:length(obj.XMLAttributes)
        value = char(xmlnode.getAttribute(obj.XMLAttributes(kdx).Alias));
        
        if ~isempty(value)
          obj.(obj.XMLAttributes(kdx).Name) ...
            = obj.XMLAttributes(kdx).Constructor(value);
        end
      end
    end
    function configureXMLElements(obj, xmlnode)
      for kdx = 1:length(obj.XMLElements)
        eleList = xmlnode.getElementsByTagName(obj.XMLElements(kdx).Alias);
        eleNum = eleList.getLength;

        if eleNum > 0
          obj.(obj.XMLElements(kdx).Name)(eleNum:end) = [];
          for idx=1:eleNum;
            ele = eleList.item(idx-1);
            obj.(obj.XMLElements(kdx).Name)(idx) ...
              = obj.XMLElements(kdx).Constructor();
            obj.(obj.XMLElements(kdx).Name).XML(ele);
          end
        end
      end
    end

    function configureXMLSpecific(obj, xmlnode)
    end
    function addXMLAttribute(obj, Name, Class, Alias, Constructor)
      if nargin < 4
        Alias = Name;
      end
      if nargin < 5
        switch Class
          case 'char'
            Constructor = @(x)char(x);
          case 'logical'
            Constructor = @(x)str2num(x);
          case 'double'
            Constructor = @(x)str2num(x).';
          otherwise
            Constructor = str2func(['@(x)' Class '(x)']);
        end
      end
      obj.XMLAttributes = [obj.XMLAttributes, ...
        xml.PropertyDescription(Name, Class, Alias, Constructor)];
    end
    function addXMLElement(obj, Name, Class, Alias, Constructor)
      if nargin < 4
        Alias = Name;
      end
      if nargin < 5
        Constructor = str2func(['@(x)' Class '()']);
      end
      obj.XMLElements = [obj.XMLElements, ...
        xml.PropertyDescription(Name, Class, Alias, Constructor)];
    end
  end
end