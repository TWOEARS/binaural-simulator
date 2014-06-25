classdef AudioSourceType
  % Enumeration for audio source types
  %
  % Enumeration contains the following labels
  %   - POINT for point source emitting spherical waves
  %   - PLANE for plane waves
  %   - DIRECT for a direct binaural input (e.g. binaural recordings)
  %   - PWD for a distributed plane wave containing plane waves arriving
  %   from different directions
  %
  % See also: simulator.AudioSource
  enumeration
    POINT,
    PLANE,
    DIRECT,
    PWD
  end
end

