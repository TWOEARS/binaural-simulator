function [listenerPositions, idxM] = sofaGetListenerPositions(sofa, idx, coordinateSystem)
%sofaGetListenerPositions returns the listener position from the given SOFA data set
%
%   USAGE
%       listenerPositions = sofaGetListenerPositions(sofa, [idx], [coordinateSystem])
%
%   INPUT PARAMETERS
%       sofa              - impulse response data set (SOFA struct/file)
%       idx               - index of listener positons (default: all)
%       coordinateSystem  - coordinate system the listener position should be
%                           specified in:
%                             'cartesian' (default)
%                             'spherical'
%
%   OUTPUT PARAMETERS
%       listenerPositions - listener positions
%       idxMeasurements   - logical vector, where 1 indicates the measurement positions
%                           that correspond to the selected listening positions.
%
if nargin == 1
    idx = [];
    coordinateSystem = 'cartesian';
elseif nargin == 2
    if ischar(idx)
        coordinateSystem = idx;
        idx = [];
    else
        coordinateSystem = 'cartesian';
    end
end
header = sofaGetHeader(sofa);
listenerPositions = SOFAconvertCoordinates(header.ListenerPosition, ...
                                           header.ListenerPosition_Type, ...
                                           coordinateSystem);
[listenerPositions, ~, idxUnique] = unique(listenerPositions, 'rows', 'stable');
if isempty(idx)
    idx = 1:size(listenerPositions, 1);
end
listenerPositions = listenerPositions(idx, :);
idxM = zeros(size(idxUnique));
for ii = 1:length(idx)
    idxM(idxUnique==idx(ii)) = 1;
end
idxM = logical(idxM);
% vim: sw=4 ts=4 et tw=90:
