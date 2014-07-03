function filename = dbGetFile(filename)
  
  import xml.*;

  try
    isargfile(filename);
    warning('INFO: local file (%s) found, will not search in db', filename);
    filename = which(filename);
  catch    
    try
      isargfile(fullfile(dbPath(),filename));
    catch
      error('file (%s) not found in database (dbPath=%s)', filename, dbPath());
    end
    filename = fullfile(dbPath(),filename);
  end
end