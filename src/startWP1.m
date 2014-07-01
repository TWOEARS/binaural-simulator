% Workaround for Bug in Matlab R2012b and higher
% 'BLAS loading error: dlopen: cannot load any more object with static TLS'
ones(10)*ones(10);

basepath = fileparts(mfilename('fullpath'));
basepath = [basepath, filesep, '..', filesep, '..', filesep];

addpath([basepath, 'twoears-wp1', filesep, 'src']);
addpath(genpath([basepath, 'twoears-wp1', filesep, 'src', filesep, 'mex']));
addpath(genpath([basepath, 'twoears-wp1', filesep, 'src', filesep, 'tools']));
addpath([basepath, 'twoears-wp1', filesep, 'src', filesep, 'SOFA']);
SOFAdbPath([basepath, 'twoears-data']);
SOFAstart;

addpath(genpath([basepath, 'twoears-wp2', filesep, 'src']));
addpath(genpath([basepath, 'twoears-wp3', filesep, 'src']));
addpath(genpath([basepath, 'twoears-wp4', filesep, 'src']));
addpath([basepath, 'twoears-data', filesep, 'src']);