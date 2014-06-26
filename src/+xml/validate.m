function validate(filename)
  if exist('dbvalidate', 'file') == 2
    dbvalidate(filename);
  else
    xml.nodbfound();
  end
end