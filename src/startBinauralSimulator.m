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
      warning(['%s: Could not find any entry for ''data'' in the ', ...
        '''TwoEarsPaths.xml''.'], upper(mfilename));
      warn = true;
    case 1
      xml.dbPath( char( eleList.item(0).getFirstChild.getData ) );
    otherwise
      warning(['%s: Found more than one entry for ''data'' in the ', ...
      '''TwoEarsPaths.xml''.'], upper(mfilename));
      warn = true;
  end
else
  warning('%s: Could not find any file named ''TwoEarsPaths.xml''', ...
    upper(mfilename));
  warn = true;
end

if warn
  warning(['%s: Continuing without setting the path of the local ', ...
    'database. Use xml.dbPath(''awesome/string/for/the/path/'') to ', ...
    'configure the path manually, if necessary!'], upper(mfilename));
end

clear docNode eleList warn;  % Clear used variables

%% add necessary paths
basePath = [fileparts(mfilename('fullpath')) filesep];

addpath([basePath 'mex']);

clear basePath;  % Clear used variables