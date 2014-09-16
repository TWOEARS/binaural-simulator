function ApparentPositionVector = SOFAcalculateAPV(Obj)
%SOFAcalculateAPV
%   APV = SOFAcalculateAPV(Obj) calculates the apparent position vector
%   (APV) which represents the position of the source relative to the
%   listener's position and view. APV is in the format [azi ele radius] 
%   with units [deg deg m].
%   Note that ListenerUp is not considered and the APV can be considered as
%   the HRTF direction usually used in HRTF databases

% SOFA API - function SOFAcalculateAPV
% Copyright (C) 2012-2013 Acoustics Research Institute - Austrian Academy of Sciences;
% Licensed under the EUPL, Version 1.1 or � as soon they will be approved by the European Commission - subsequent versions of the EUPL (the "License")
% You may not use this work except in compliance with the License.
% You may obtain a copy of the License at: http://joinup.ec.europa.eu/software/page/eupl
% Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" basis, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
% See the License for the specific language governing  permissions and limitations under the License. 


% listener position, view, up
ListenerPosition = ...
    SOFAconvertCoordinates(Obj.ListenerPosition,Obj.ListenerPosition_Type,'cartesian');
ListenerView = ...
    SOFAconvertCoordinates(Obj.ListenerView,Obj.ListenerView_Type,'spherical');
% source position
SourcePosition = ...
    SOFAconvertCoordinates(Obj.SourcePosition,Obj.SourcePosition_Type,'cartesian');
% get distance in cartesian coordinates between listener and source
Distance = bsxfun(@minus, SourcePosition, ListenerPosition);
% convert to spherical and include head movements of the listener
Distance = SOFAconvertCoordinates(Distance,'cartesian','spherical');
ApparentPositionVector = correctAzimuth(bsxfun(@minus, Distance(:,1),ListenerView(:,1)));%spherical
% convert to horizontal-polar coordinates FIXME: this breaks the azimuth angle,
% it is disabled temporarly. The correct inclusion of elevation is still
% missing.
%APV = SOFAconvertCoordinates(APV,'spherical','horizontal-polar');
%APV(:,2) = bsxfun(@minus, APV(:,2),ListenerView(:,2));%horizontal-polar
% convert back to spherical
%APV = SOFAconvertCoordinates(APV,'horizontal-polar','spherical');
end

function phi = correctAzimuth(phi)
    % Ensure -360 <= phi <= 360
    phi = rem(phi,360);
    % Ensure -180 <= phi < 180
    phi(phi<-180) = phi(phi<-180) + 360;
    phi(phi>=180) = phi(phi>=180) - 360;
end

% TODO: check what convetion we are using for delta!
function delta = correctElevation(delta)
    % Ensure -180 <= delta <= 180
    delta = correct_azimuth(delta);
    % Ensure -90 <= delta <= 90
    delta(delta<-90) = -delta(delta<-90) - 180;
    delta(delta>90) = -delta(delta>90) + 180;
end
