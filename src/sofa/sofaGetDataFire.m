function impulseResponses = sofaGetDataFire(sofa, idxM, idxE)
%sofaGetDataFire returns impulse responses from a SOFA file or struct
%
%   USAGE
%       impulseResponses = sofaGetDataFire(sofa, [idxM, [idxE]])
%
%   INPUT PARAMETERS
%       sofa    - impulse response data set (SOFA struct/file)
%       idxM    - index of the measurements for which the single impulse
%                 responses should be returned.
%                 idxM could be a single value, then only one impulse response
%                 will be returned, or it can be a vector then all impulse
%                 responses for the corresponding index positions will be
%                 returned.
%                 If no index is specified all measurements will be returned.
%       idxE    - index of the emitter for which the single impulse
%                 responses should be returned. The rest is identical to idxM.
%
%   OUTPUT PARAMETERS
%       impulseResponses - impulse response (M,2,E,N), where
%                           M ... number of impulse responses
%                           E ... number of emitters (loudspeakers)
%                           N ... samples
%
if nargin == 2
    idxE = ':';
elseif nargin == 1
    idxE = ':';
    idxM = ':';
end

if sofaIsFile(sofa)
    header = sofaGetHeader(sofa);
    if isnumeric(idxE) && isnumeric(idxM)
        ir = zeros(length(idxM), header.API.R, length(idxE), header.API.N);
        for ii = 1:length(idxM)
            for jj = 1:length(idxE)
                tmp = SOFAload(sofa, [idxM(ii) 1], 'M', [idxE(jj) 1], 'E');
                impulseResponses(ii,:,jj,:) = tmp.Data.IR;
            end
        end
    elseif isnumeric(idxE)
        ir = zeros(header.API.M, header.API.R, length(idxE), header.API.N);
        for jj = 1:length(idxE)
            tmp = SOFAload(sofa, [idxE(jj) 1], 'E');
            impulseResponses(:,:,jj,:) = tmp.Data.IR;
        end
    elseif isnumeric(idxM)
        ir = zeros(length(idxM), header.API.R, header.API.E, header.API.N);
        for ii = 1:length(idxM)
            tmp = SOFAload(sofa, [idxM(ii) 1], 'M');
            impulseResponses(ii,:,:,:) = tmp.Data.IR;
        end
    else
        tmp = SOFAload(sofa);
        impulseResponses = tmp.Data.IR;
    end
else
    impulseResponses = sofa.Data.IR(idxM, :, idxE, :);
end
% vim: sw=4 ts=4 et tw=90:
