function filename = getfile(filename)
  if exist('dbgetfile', 'file') == 2
    s = filename;
    filename = dbgetfile(filename);
    try
      isargfile(filename);
    catch
      warning('file not found in database (%s). Assuming local file.', ...
        s);
      filename = s;
    end
  else
    xml.nodbfound();
  end
end