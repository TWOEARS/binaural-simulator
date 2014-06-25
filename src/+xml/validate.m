function validate(filename, schema)
% validate(filename, schema)
% validate xml-file against schema
%
% Parameters:
%   filename: filename of xml-schema (*.xml)
%   schema: filename of xml-schema (*.xsd)
  import java.io.*;
  import javax.xml.transform.Source;
  import javax.xml.transform.stream.StreamSource;
  import javax.xml.validation.*;
  
  filename = which(filename);
  schema = which(schema);

  factory = SchemaFactory.newInstance('http://www.w3.org/2001/XMLSchema');
  schemaLocation = File(schema);
  schema = factory.newSchema(schemaLocation);
  validator = schema.newValidator();
  source = StreamSource(filename);
  validator.validate(source);
end