classdef (Abstract) RobotInterface < hgsetget
  % wrapper class for the actual robot functionality
  methods (Abstract)
    %% Grab binaural audio of a specified length
    [sig, timeIncSec, timeIncSamples] = getSignal(obj, timeIncSec)
    % function [sig, timeIncSec, timeIncSamples] = getSignal(obj, timeIncSec)
    % get binaural of specified length
    %
    % Parameters:
    %   timeIncSec: length of signal in seconds @type double
    %
    % Return Values:
    %   timeIncSec: length of signal in seconds @type double
    %   timeIncSamples: length of signal in samples @type integer
    %
    % Due to the frame-wise processing length of the output signal can
    % vary from specified signal length. This is indicated by the 2nd and
    % 3rd return value.

    %% Rotate the head with mode = {?absolute?, ?relative?}
    rotateHead(obj, angleDeg, mode)
    % function rotateHead(obj, angleDeg, mode)
    %
    % 1) mode = ?absolute?
    %    Rotate the head to an absolute angle relative to the base
    %    0  / 360 degrees = dead ahead
    %    90 /-270 degrees = left
    %    270/-90  degrees = right
    %
    % 2) mode = ?relative?
    %    Rotate the head by an angle in degrees
    %    Positive angle = rotation to the left
    %    Negative angle = rotation to the right
    %
    % Head turn will stop when maxLeftHead or maxRightHead is reached
    %
    % Input Parameters
    %     angleDeg : rotation angle in degrees
    %         mode : 'absolute' or 'relative'
    
    %% Get the head orientation relative to the base orientation
    azimuth = getCurrentHeadOrientation(obj)
    % function azimuth = getCurrentHeadOrientation(obj)
    % get current head orientation in degrees
    %
    % Return Values:
    %   azimuth: head-above-torso azimuth in degree @type double
    %
    % look directions:
    %   0/ 360 degree = dead ahead
    %  90/-270 degrees = left
    % 270/- 90 degrees = right
    
    %% Move the robot to a new position
    moveRobot(obj, posX, posY, theta, mode)
    % function moveRobot(obj, posX, posY, theta, mode)
    %
    % All coordinates are in the world frame
    %     0/ 360 degrees = positive x-axis
    %    90/-270 degrees = positive y-axis
    %   180/-180 degrees = negative x-axis
    %   270/- 90 degrees = negative y-axis
    %
    % Input Parameters
    %         posX : x position
    %         posY : y position
    %        theta : robot base orientation in the world frame
    %         mode : 'absolute' or 'relative'
    
    %% Get the current robot position
    [posX, posY, theta] = getRobotPosition(obj)
    % function [posX, posY, theta] = getRobotPosition(obj)
    %
    % All coordinates are in the world frame
    %     0/ 360 degrees = positive x-axis
    %    90/-270 degrees = positive y-axis
    %   180/-180 degrees = negative x-axis
    %   270/- 90 degrees = negative y-axis
    %
    % Output Parameters
    %         posX : x position
    %         posY : y position
    %        theta : robot base orientation in the world frame    
    
  end
end
