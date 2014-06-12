% Workaround for Bug in Matlab R2012b and higher
% 'BLAS loading error: dlopen: cannot load any more object with static TLS'
ones(10)*ones(10);

basepath=which('test_startup');
basepath=basepath(1:end-14);

addpath([basepath, '../src/tools']);
addpath([basepath, '../../../ssr/mex']); 
addpath([basepath, '../src']);  
database_path = [basepath, '../../database/'];

import simulator.*