function filename = dbGetFile(filename)
% filename = dbGetFile(filename)
% search for file locally and in database
%
% Parameters:
%   filename: filename
% Parameters:
%   filename: filename of file found locally or in database
%
% search for file specified by filename relative to current directory.
% Filenames starting with '/' will interpreted as absolute paths. If the file
% is not found, searching will be extended to the local copy of the
% twoears-database (database path defined via xml.dbPath()).
%
% See also: xml.dbPath

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