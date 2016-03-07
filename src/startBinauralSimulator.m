%% workaround for bug in Matlab R2012b and higher
% 'BLAS loading error: dlopen: cannot load any more object with static TLS'
ones(10)*ones(10);

%% workaround for bug related to fftw library
fftw('swisdom');

%% search for TwoEarsPaths.xml and get path to local database
warn = false;

if exist('TwoEarsPaths.xml', 'file') == 2
  docNode = xmlread('TwoEarsPaths.xml');
  eleList = docNode.getDocumentElement.getElementsByTagName('data');
  switch eleList.getLength
    case 0
    case 1
      xml.dbPath( char( eleList.item(0).getFirstChild.getData ) );
    otherwise
      warning(['%s: Found more than one entry for ''data'' in the ', ...
      '''TwoEarsPaths.xml''.'], upper(mfilename));
  end
end

% Add necessary paths
basePath = [fileparts(mfilename('fullpath')) filesep];

addpath(fullfile(basePath, 'mex'));

% Add SOFA HRTF handling
addpath(fullfile(basePath, 'sofa'));
SOFAstart(0);

% Clear used variables
clear basePath;
clear docNode eleList
