classdef DirectionalIR < hgsetget
  %HRTF Summary of this class goes here
  %   Detailed explanation goes here

  properties (SetAccess=private)
    Data = [];
    NumberOfDirections = 0;
    NumberOfSamples = 0;
    AzimuthResolution = inf;
    SampleRate = 0;
    Filename = [];    
  end
  
  methods
    function obj = DirectionalIR(filename)
      if nargin == 1
        isargfile(filename);
        obj.open(filename);
      end
    end
    function open(obj, filename)
  % function open(obj, filename)
  % open WAV-File for HRTFs
  %
  % Parameters:
  %   filename:  name of HRTF dataset @type char[]
      [d, fs] = audioread(filename);
      s = size(d, 2);
      if (mod(s,2) ~= 0)
        error('number of channels of input file has to be an integer of 2!');
      end

      obj.SampleRate = fs;
      obj.Data = d;
      obj.NumberOfDirections = s/2;
      obj.NumberOfSamples = size(d,1);
      obj.AzimuthResolution = 360/obj.NumberOfDirections;
      obj.Filename = filename;
    end
    function tf = getImpulseResponses(obj, azimuth)
  % function tf = getImpulseResponses(obj, azimuth)
  % get HRIR for distinct azimuth angles
  %
  % nearest neighbor interpolation
  %
  % Parameters:
  %   azimuth:  azimuth angle in degree @type double[]
  %
  % Return values:
  %   tf: struct containing left (tf.left) and right (tf.right) irs
      selector = ...
        mod(round(azimuth/obj.AzimuthResolution), obj.NumberOfDirections)*2 + 1;
      tf.left = obj.Data(:,selector);
      tf.right = obj.Data(:,selector+1);
    end

    function plot(obj, id)
  % function plot(obj, id)
  % plot whole HRIR dataset
  %
  % Parameters:
  %   id:  id of figure @type integer @default 1
      if nargin < 2
        id = figure;
      else
        figure(id);
      end

      azimuth = -180:179;

      tf = obj.getImpulseResponses(azimuth);

      tfmax = max(max(abs(tf.left(:)),abs(tf.left(:))));

      tl = 20*log10(abs(tf.left)/tfmax);
      tr = 20*log10(abs(tf.right)/tfmax);

      time = (0:size(tl,1)-1)/obj.SampleRate*1000;

      subplot(1,2,1);
      imagesc(azimuth,time, tl);
      title('Left Ear Channel');
      xlabel('angle (deg)');
      ylabel('time (ms)');
      set(gca,'CLim',[-50 0]);
      colorbar;

      subplot(1,2,2);
      imagesc(azimuth,time, tr);
      title('Right Ear Channel');
      xlabel('angle (deg)');
      ylabel('time (ms)');
      set(gca,'CLim',[-50 0]);
      colorbar;
    end
  end
end