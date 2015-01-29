% Workaround for Bug in Matlab R2012b and higher
% 'BLAS loading error: dlopen: cannot load any more object with static TLS'
ones(10)*ones(10);

% Workaround for Bug related to fftw library
fftw('swisdom');

basePath = [fileparts(mfilename('fullpath')) filesep];

addpath([basePath 'mex']);

% Clear used variables
clear basePath;
