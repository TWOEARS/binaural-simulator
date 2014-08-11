function filename = dbGetFile(filename)
  
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
end