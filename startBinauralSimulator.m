% Workaround for Bug in Matlab R2012b and higher
% 'BLAS loading error: dlopen: cannot load any more object with static TLS'
ones(10)*ones(10);

BinauralSimulatorPath = fileparts(mfilename('fullpath'));
BinauralSimulatorPath = [BinauralSimulatorPath, filesep];

addpath(BinauralSimulatorPath);
addpath([BinauralSimulatorPath, 'mex']);
addpath([BinauralSimulatorPath, 'tools']);

% Clear used variables
clear BinauralSimulatorPath;
