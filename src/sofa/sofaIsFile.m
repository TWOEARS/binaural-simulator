function bSofaFile = sofaIsFile(sofa)
%sofaIsFile returns 1 for a sofa file, 0 for a sofa struct or an error otherwise
%
%   USAGE
%       bSofaFile = sofaIsFile(sofa)
%
%   INPUT PARAMETERS
%       sofa        - sofa struct or file name
%
%   OUTPUT PARAMETERS
%       bSofaFile   - true for sofa is a file and false for sofa is a struct

if ~isstruct(sofa) && exist(sofa,'file')
    bSofaFile = true;
elseif isstruct(sofa) && isfield(sofa,'GLOBAL_Conventions') && ...
       strcmp('SOFA',sofa.GLOBAL_Conventions)
    bSofaFile = false;
else
    error('%s: sofa has to be a file or a SOFA struct.',upper(mfilename));
end
