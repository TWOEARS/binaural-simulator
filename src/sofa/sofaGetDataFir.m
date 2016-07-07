function impulseResponses = sofaGetDataFir(sofa, idx)
%sofaGetDataFir returns impulse responses from a SOFA file or struct
%
%   USAGE
%       impulseResponses = sofaGetDataFir(sofa, [idx])
%
%   INPUT PARAMETERS
%       sofa    - impulse response data set (SOFA struct/file)
%       idx     - index of the single impulse responses that should be returned
%                 idx could be a single value, then only one impulse response
%                 will be returned, or it can be a vector then all impulse
%                 responses for the corresponding index positions will be
%                 returned.
%                 If no index is specified all data will be returned.
%
%   OUTPUT PARAMETERS
%       ir      - impulse response (M,2,N), where
%                   M ... number of impulse responses
%                   N ... samples
%
if nargin == 1, idx = []; end
if length(idx) == 0
    if sofaIsFile(sofa)
        sofa = SOFAload(sofa);
    end
    impulseResponses = sofa.Data.IR;
else
    header = sofaGetHeader(sofa);
    if sofaIsFile(sofa)
        impulseResponses = zeros(length(idx), 2, header.API.N);
        for ii = 1:length(idx)
            tmp = SOFAload(sofa, [idx(ii) 1]);
            impulseResponses(ii,:,:) = tmp.Data.IR;
        end
    else
        impulseResponses = sofa.Data.IR(idx, :, :);
    end
end
% vim: sw=4 ts=4 et tw=90:
