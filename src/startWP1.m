% Workaround for Bug in Matlab R2012b and higher
% 'BLAS loading error: dlopen: cannot load any more object with static TLS'
ones(10)*ones(10);

wp1path = fileparts(mfilename('fullpath'));
wp1path = [wp1path, filesep];
basepath = [wp1path, '..', filesep, '..', filesep];

addpath(wp1path);
addpath([wp1path, 'mex']);
addpath([wp1path, 'tools']);
addpath([wp1path, 'SOFA']);

xml.dbPath([basepath, 'twoears-data']);
SOFAdbPath(xml.dbPath());
SOFAdbURL(xml.dbURL());
SOFAstart;