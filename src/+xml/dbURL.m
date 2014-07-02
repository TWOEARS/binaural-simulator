function url = dbURL(url)
% function url = dbURL(url) 
%
% taken from SOFA acoustics (see SOFAdbURL www.sofacoustics.org)

persistent CachedURL;

if exist('url','var')
  CachedURL=url;
elseif isempty(CachedURL)
  CachedURL= ['https://dev.qu.tu-berlin.de/projects/twoears-data/' ...
        'repository/revisions/master/raw/'];
end
url=CachedURL;