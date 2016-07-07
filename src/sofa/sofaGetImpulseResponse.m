function impulseResponse = sofaGetImpulseResponse(sofa, azimuth, idxLoudspeaker, ...
                                                  idxListener)
%sofaGetImpulseResponse returns a single impulse response for the desired azimuth from a
%SOFA data set using nearest neighbour search
%
%   USAGE
%       impulseResponse = sofaGetImpulseResponse(sofa, azimuth, ...
%                                                [idxLoudspeaker, [idxListener]])
%
%   INPUT PARAMETERS
%       sofa            - impulse response data set (sofa struct/file)
%       azimuth         - direction of incident sound
%       idxLoudspeaker  - index of loudspeaker to use (default: 1)
%       idxListener     - index of listener position (default: 1)
%
%   OUTPUT PARAMETERS
%       impulseResponse - impulse response (length of impulse response x 2)
%
if nargin == 2
    idxLoudspeaker = 1;
    idxListener = 1;
elseif nargin == 3
    idxListener = 1;
end
header = sofaGetHeader(sofa);

switch header.GLOBAL_SOFAConventions
case 'SimpleFreeFieldHRIR'
    %
    % http://www.sofaconventions.org/mediawiki/index.php/SimpleFreeFieldHRIR
    %
    loudspeakerPositions = sofaGetLoudspeakerPositions(header, 'spherical');
    [~, idx] = findNearestNeighbour(loudspeakerPositions(:,1)', azimuth, 1);
    impulseResponse = sofaGetDataFir(sofa, idx);
    %
case 'MultiSpeakerBRIR'
    %
    % http://www.sofaconventions.org/mediawiki/index.php/MultiSpeakerBRIR
    %
    % Find nearest azimuth from listener perspective for the selected loudspeaker and
    % listener position
    loudspeakerPosition = ...
        sofaGetLoudspeakerPositions(header, idxLoudspeaker, 'cartesian');
    [listenerPosition, idxIncludedMeasurements] = ...
        sofaGetListenerPositions(header, idxListener, 'cartesian');
    listenerAzimuths = sofaGetHeadOrientations(header, idxIncludedMeasurements);
    listenerOffset = SOFAconvertCoordinates(loudspeakerPosition - listenerPosition, ...
                                           'cartesian', 'spherical');
    availableAzimuths = listenerOffset(1) - listenerAzimuths;
    [~, idxNeighbour] = findNearestNeighbour(wrapTo360(availableAzimuths'), ...
                                             wrapTo360(azimuth), 1);
    % Map to absolute measurement index
    idxActive = find(idxIncludedMeasurements==1);
    idxMeasurement = idxActive(idxNeighbour);
    % Get the impulse responses and reshape
    impulseResponse = sofaGetDataFire(sofa, idxMeasurement, idxLoudspeaker);
    impulseResponse = reshape(impulseResponse, ... % [M R E N] => [M R N]
                              [size(impulseResponse, 1) ...
                               size(impulseResponse, 2) ...
                               size(impulseResponse, 4)]);
    %
case 'SingleRoomDRIR'
    %
    % http://www.sofaconventions.org/mediawiki/index.php/SingleRoomDRIR
    %
    error(['%s: SingleRoomDRIR is not supported as it should handle ', ...
           'microphone array recordings. If you used it for (multiple) ', ...
           'loudspeakers in a room you should consider to use ', ...
           'MultiSpeakerBRIR instead.'], upper(mfilename));
    %
otherwise
    error('%s: %s convention is currently not supported.', ...
        upper(mfilename),header.GLOBAL_SOFAConventions);
end

impulseResponse = squeeze(impulseResponse)'; % [1 2 N] => [N 2]
% vim: sw=4 ts=4 et tw=90:
