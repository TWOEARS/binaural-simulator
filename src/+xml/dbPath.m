function newpath = dbPath(newpath)
% url = dbPath(newpath) 
%
% taken from SOFA acoustics (see SOFAdbPath www.sofaacoustics.org)

f=filesep;

persistent CachedPath;

if exist('newpath','var')
  CachedPath=newpath;
elseif isempty(CachedPath)
  basepath=fileparts(mfilename('fullpath'));
  CachedPath=fullfile(basepath, '..', f, '..', f, '..', f, 'twoears-data', f);
end
newpath=CachedPath;