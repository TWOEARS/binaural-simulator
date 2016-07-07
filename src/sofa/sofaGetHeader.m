function header = sofaGetHeader(sofa)
%sofaGetHeader returns the header of a SOFA file or struct
%
%   USAGE
%       header = sofaGetHeader(sofa)
%
%   INPUT PARAMETERS
%       sofa    - impulse response data set (SOFA struct/file)
%
%   OUTPUT PARAMETERS
%       header  - SOFA header

if sofaIsFile(sofa)
    header = SOFAload(sofa, 'nodata');
else
    header = sofa;
    if isfield(sofa.Data, 'IR')
        header.Data = rmfield(sofa.Data, 'IR');
    end
end
% vim: sw=4 ts=4 et tw=90:
