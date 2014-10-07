function outfile = dbDownloadFile(filename, outfile)
% download file from remote database
%
% Parameters:
%   filename: filename @type char[]
%   outfile: relative or absolute filename where download should be saved, optional @type char[]
%
% Return values:
%   outfile: absolute filename
%
% Download file specified by filename relative to root directory of the remote
% database. The root directory is defined via xml.dbURL().
%
% See also: xml.dbGetFile xml.dbURL

if nargin < 2
  dirs = regexp(filename, filesep, 'split');

  dir_path = xml.dbTmp();
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
