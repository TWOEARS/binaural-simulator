function filename = dbGetFile(filename)
% function filename = dbGetFile(filename)
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
% twoears-database (database path defined via xml.dbPath()). Again,
% searching will be extended to the remote database (defined via
% xml.dbURL). If the download was successfull, the file will be cached in
% 'src/tmp'. The cache can be cleared via xml.dbClearTmp()
%
% See also: xml.dbPath xml.dbURL xml.dbClearTmp

import xml.*;

try
  % try relative or absolute path
  isargfile(filename);
  fprintf('INFO: local file (%s) found, will not search in db\n', filename);
  filename = which(filename);
catch
  try
    % try local database
    isargfile(fullfile(dbPath(),filename));
    filename = fullfile(dbPath(),filename);
  catch
    fprintf(['INFO: file (%s) not found in local database (dbPath=%s),', ... 
      'trying remote database\n'], filename, dbPath());
    
    % try cache of remote database
    try
      tmppath = fileparts(mfilename('fullpath')); 
      tmppath = [tmppath, filesep, '..', filesep, 'tmp'];
      isargfile(fullfile(tmppath,filename));
      filename = fullfile(tmppath,filename);
      fprintf('INFO: file (%s) found in cache of remote database\n', filename);
    catch
      % try download from remote database
      filename = dbDownloadFile(filename);
    end      
  end    
end