% Workaround for Bug in Matlab R2012b and higher
% 'BLAS loading error: dlopen: cannot load any more object with static TLS'
ones(10)*ones(10);

basepath = fileparts(mfilename('fullpath'));
addpath(genpath(basepath));