classdef DirectionalIR < hgsetget
  % Class for HRIRs-Datasets

  properties (SetAccess=private)
    % Number of directions of HRIR-Dataset
    % @type integer
    % @default 0
    NumberOfDirections = 0;
    % Number of samples of HRIR-Dataset
    % @type integer
    % @default 0
    NumberOfSamples = 0;
    % Angular Resolution of HRIR-Dataset
    % @type double
    % @default inf
    AzimuthResolution = inf;
    % Sample Rate of HRIR-Dataset in Hz
    % @type double
    SampleRate;
    % location of original wav-file
    % @type char[]
    Filename;
  end

  properties (Access=private)
    Data = [];
  end

  methods
    function obj = DirectionalIR(filename)
      % function obj = DirectionalIR(filename)
      % constructor for DirectionIR objects
      %
      % Parameters:
      %   filename: optional filename of HRTF dataset @type char[]
      if nargin == 1
        isargfile(filename);
        obj.open(filename);
      end
    end
    function delete(obj)
      try
        isargfile(obj.Filename);
        delete(obj.Filename);
      catch
      end      
    end
    function open(obj, filename)
      % function open(obj, filename)
      % open WAV-File for HRTFs
      %
      % Parameters:
      %   filename: name of WAV- or SOFA-file @type char[]
      isargfile(filename);

      [~,name,ext] = fileparts(filename);
      if strcmp('.wav', ext)
        [d, fs] = audioread(filename);
      elseif strcmp('.sofa', ext)
        [d, fs]= obj.convertSOFA(filename);
      else
        error('file extension (%s) not supported (only .wav and .sofa)', ext);
      end

      % check whether the number of channels is even
      s = size(d, 2);
      if (mod(s,2) ~= 0)
        error('number of channels of input file has to be an integer of 2!');
      end

      % create local copy of data for the SSR MEX-Code
      filename = [name, '_tmp.wav'];
      wavwrite(d, fs, filename);

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
  methods (Static)
    function [d, fs] = convertSOFA(filename)
      isargfile(filename);
      warning('SOFA HRTF support is still very experimental');
      data = SOFAload(filename);
      if strcmp(data.GLOBAL_SOFAConventions,'SimpleFreeFieldHRIR')
        [~, ind] = sort(data.SourcePosition(:,1));
        d = data.Data.IR(ind,:,:);
        d = permute(d,[3 2 1]);
        d = reshape(d,size(d,1),[]);

        fs = data.Data.SamplingRate;
      else
        error('SOFA Conventions (%s) not supported', ...
          data.GLOBAL_SOFAConventions);
      end
    end
  end
end
