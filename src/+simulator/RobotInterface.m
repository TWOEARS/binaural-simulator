classdef (Abstract) RobotInterface < hgsetget
  %ROBOTINTERFACE is a wrapper class for the actual robot functionality
  
  %% Constructor
  methods (Abstract)
    rotateHead(obj, angleIncDeg, vargin)
      % function rotateHead(obj, angleIncDeg, vargin)
      % rotate about an incremental angle in degrees
      %
      % Parameters:
      %   angleIncDeg: angle increment in degree
      %
      % negative angle result in rotation to the right
      % positive angle result in rotation to the left
    [sig, timeIncSec, timeIncSamples] = getSignal(obj, timeIncSec)
      % function [sig, timeIncSec, timeIncSamples] = getSignal(obj, timeIncSec)
      % get binaural of specified length
      %
      % Parameters:
      %   timeIncSec: length of signal in seconds
      %
      % Return Values:
      %   timeIncSec: length of signal in seconds
      %   timeIncSamples: length of signal in samples      
      %
      % Due to the frame-wise processing length of the output signal can
      % vary from specified signal length. This is indicated by the 2nd and
      % 3rd return value.
  end  
end