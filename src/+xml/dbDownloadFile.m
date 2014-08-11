function outfile = dbDownloadFile(filename, outfile)

if nargin < 2  
  dirs = regexp(filename, filesep, 'split');
  
  dir_path = fileparts(mfilename('fullpath'));
  dir_path = [dir_path, filesep, '..', filesep, 'tmp'];
  for idx=1:length(dirs)-1
    dir_path = [dir_path, filesep, dirs{idx}];
    [~, ~] = mkdir(dir_path);
  end
  outfile = [dir_path, filesep, dirs{end}];
end

url = fullfile(xml.dbURL(), filename);
fprintf('Downloading file %s\n', url);

[~, status] = urlwrite(url, outfile);

if ~status
  error('Download failed (url=%s), url');
end