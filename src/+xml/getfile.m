function s = getfile(s)
  if exist('dbgetfile', 'file') == 2
    s = dbgetfile(s);
  else
    xml.nodbfound();
  end
end