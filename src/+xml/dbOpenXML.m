function [RootNode, DocumentNode] = dbOpenXML(filename)
% [RootNode, DocumentNode] = dbOpenXML(filename)
% 
% Parameters:
%   filename: filename of the XML-file (either locally or in the database)
%
% Return values:
%   RootNode: DOM-Node of root element in XML-Document
%   DocumentNode: DOM-Node of XML-Document
%
% See also: xml.dbGetFile xmlread

  filename = xml.dbValidate(filename);

  DocumentNode = xmlread(filename);
  RootNode = DocumentNode.getDocumentElement;
end