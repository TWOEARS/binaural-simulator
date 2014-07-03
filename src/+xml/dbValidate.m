function dbValidate(filename)
% dbValidate(filename)
% validate xml-file against schema ('tef.xsd')
%
% Parameters:
%   filename: filename of xml-schema (*.xml)

  import java.io.*;
  import javax.xml.transform.Source;
  import javax.xml.transform.stream.StreamSource;
  import javax.xml.validation.*;

  filename = xml.dbGetFile(filename);

  thisfilepath = fileparts(mfilename('fullpath'));
  schema = fullfile(thisfilepath, 'tef.xsd');

  factory = SchemaFactory.newInstance('http://www.w3.org/2001/XMLSchema');
  schemaLocation = File(schema);
  schema = factory.newSchema(schemaLocation);
  validator = schema.newValidator();
  source = StreamSource(filename);
  validator.validate(source);
end