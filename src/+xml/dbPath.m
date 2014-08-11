function newpath = dbPath(newpath)
% function newpath = dbPath(newpath) 
%
% defines root path to local copy of twoears database.
%
% Parameters:
%   newpath:  path to local copy of twoears database, optional @type char[]
%
% Return values:
%   newpath:  current path to database
%
% defines root path to local copy of twoears database. Calling this function
% without an argument just returns the current path. Taken from SOFA
% (http://www.sofaconventions.org/).
%
% See also: http://sourceforge.net/p/sofacoustics/code/HEAD/tree/trunk/API_MO/SOFAdbPath.m

f=filesep;

persistent CachedPath;

if exist('newpath','var')
  CachedPath=newpath;
elseif isempty(CachedPath)
  basepath=fileparts(mfilename('fullpath'));
  CachedPath=fullfile(basepath, '..', f, '..', f, '..', f, 'twoears-data', f);
end
newpath=CachedPath;