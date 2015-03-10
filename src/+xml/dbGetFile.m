function filename = dbGetFile(filename)
% search for file locally and in database
%
% Parameters:
%   filename: filename
%
% Return values:
%   filename: filename of file found locally or in database
%
% search for file specified by filename relative to current directory.
% Filenames starting with '/' will interpreted as absolute paths. If the file
% is not found, searching will be extended to the local copy of the
% twoears-database (database path defined via xml.dbPath()). Again,
% searching will be extended to the remote database (defined via
% xml.dbURL). If the download was successfull, the file will be cached in
% 'src/tmp'. The cache can be cleared via xml.dbClearTmp()
%
% See also: xml.dbPath xml.dbURL xml.dbClearTmp

import xml.*;

isargchar(filename);
try
  % try relative path
  isargfile(fullfile(pwd,filename));
  %fprintf('INFO: relative local file (%s) found, will not search in db\n', filename);
  filename = fullfile(pwd,filename);
  return;
catch
  try
    % try absolute path
    isargfile(filename);
    %fprintf('INFO: absolute local file (%s) found, will not search in db\n', filename);
    return;
  catch
    try
      % try local database
      isargfile(fullfile(dbPath(),filename));
      %fprintf('INFO: file (%s) found in local database\n', filename);
      filename = fullfile(dbPath(),filename);
      return;
    catch
      %fprintf(['INFO: file (%s) not found in local database (dbPath=%s),', ...
      %  'trying remote database\n'], filename, dbPath());

      % try cache of remote database
      try
        tmppath = xml.dbTmp();
        isargfile(fullfile(tmppath,filename));
        %fprintf('INFO: file (%s) found in cache of remote database\n', filename);
        filename = fullfile(tmppath,filename);
        return;
      catch
        % try download from remote database
        filename = dbDownloadFile(filename);
      end
    end
  end
end
