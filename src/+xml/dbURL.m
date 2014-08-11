function url = dbURL(url)
% function url = dbURL(url) 
%
% taken from SOFA acoustics (see SOFAdbURL www.sofacoustics.org)

persistent CachedURL;

if exist('url','var')
  CachedURL=url;
elseif isempty(CachedURL)
  CachedURL= ['https://github.com/TWOEARS/data/raw/master/'];
end
url=CachedURL;