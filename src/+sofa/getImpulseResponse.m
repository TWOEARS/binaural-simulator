function [impulseResponse, fs] = getImpulseResponse(sofa, azimuth, ...
                                    idxLoudspeaker, idxListener)
%getImpulseResponse returns a single impulse response for the desired azimuth from a
%SOFA data set using nearest neighbour search
%
%   USAGE
%       impulseResponse = getImpulseResponse(sofa, azimuth, ...
%                                            [idxLoudspeaker, [idxListener]])
%
%   INPUT PARAMETERS
%       sofa            - impulse response data set (sofa struct/file)
%       azimuth         - direction of incident sound
%       idxLoudspeaker  - index of loudspeaker to use (default: 1)
%       idxListener     - index of listener position (default: 1)
%
%   OUTPUT PARAMETERS
%       impulseResponse - impulse response (length of impulse response x 2)
%       fs              - sampling frequency of impulse response
%
if nargin == 2
    idxLoudspeaker = 1;
    idxListener = 1;
elseif nargin == 3
    idxListener = 1;
end
header = getHeader(sofa);

switch header.GLOBAL_SOFAConventions
case 'SimpleFreeFieldHRIR'
    %
    % http://www.sofaconventions.org/mediawiki/index.php/SimpleFreeFieldHRIR
    %
    loudspeakerPositions = getLoudspeakerPositions(header, 'spherical');
    availableAzimuths = wrapTo360( loudspeakerPositions(:,1) );

    % difference between available Azimuths and query azimuth
    diff = bsxfun(@minus, azimuth(:), availableAzimuths(:).');
    % wrap around
    diff = mod(diff, 360);
    % absolute distance taking wrap-around into account
    dist = min( abs(diff), abs(360-diff) );
    % get nearest neighbor with closes distances
    [~, idxMeasurement] = min(dist, [], 2);
    %
    [impulseResponse, fs] = getDataFir(sofa, idxMeasurement);
    %
case {'MultiSpeakerBRIR', 'SingleRoomDRIR'}
    %
    % http://www.sofaconventions.org/mediawiki/index.php/MultiSpeakerBRIR
    % http://www.sofaconventions.org/mediawiki/index.php/SingleRoomDRIR
    %
    if strcmp(header.GLOBAL_SOFAConventions, 'SingleRoomDRIR')
        idxLoudspeaker = 1;
        idxListener = 1;
    end
    % Find nearest azimuth from listener perspective for the selected loudspeaker and
    % listener position
    loudspeakerPosition = ...
        getLoudspeakerPositions(header, idxLoudspeaker, 'cartesian');
    [listenerPosition, idxIncludedMeasurements] = ...
        getListenerPositions(header, idxListener, 'cartesian');
    listenerAzimuths = getHeadOrientations(header, idxIncludedMeasurements);
    listenerOffset = SOFAconvertCoordinates(loudspeakerPosition - listenerPosition, ...
                                           'cartesian', 'spherical');
    availableAzimuths = wrapTo360( listenerOffset(1) - listenerAzimuths );

    % difference between available Azimuths and query azimuth
    diff = bsxfun(@minus, azimuth(:), availableAzimuths(:).');
    % wrap around
    diff = mod(diff, 360);
    % absolute distance taking wrap-around into account
    dist = min( abs(diff), abs(360-diff) );
    % get nearest neighbor with closes distances
    [~, idxNeighbour] = min(dist, [], 2);
    % Map to absolute measurement index
    idxActive = find(idxIncludedMeasurements==1);
    idxMeasurement = idxActive(idxNeighbour);
    % Get the impulse responses and reshape
    [impulseResponse, fs] = ...
	  	getDataFire(sofa, idxMeasurement, idxLoudspeaker);
    impulseResponse = reshape(impulseResponse, ... % [M R E N] => [M R N]
                              [size(impulseResponse, 1) ...
                               size(impulseResponse, 2) ...
                               size(impulseResponse, 4)]);
    %
otherwise
    error('%s: %s convention is currently not supported.', ...
        upper(mfilename),header.GLOBAL_SOFAConventions);
end

% [Nphi 2 N] => [N 2 Nphi]
impulseResponse = permute(impulseResponse,[3 2 1]);
% [N 2 Nphi] => [N 2*Nphi]
impulseResponse = reshape(impulseResponse,size(impulseResponse,1),[]);

% vim: sw=4 ts=4 et tw=90:
