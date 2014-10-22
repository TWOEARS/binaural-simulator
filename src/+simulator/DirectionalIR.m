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
    Filename = '';
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
      filename = xml.dbGetFile(filename);

      [~,name,ext] = fileparts(filename);
      if strcmp('.wav', ext)
        [d, fs] = audioread(filename);
      elseif strcmp('.sofa', ext)
        warning('SOFA HRTF support is still very experimental');
        data = SOFAload(filename);
        [d, fs]= obj.convertSOFA(data);
      else
        error('file extension (%s) not supported (only .wav and .sofa)', ext);
      end

      % check whether the number of channels is even
      s = size(d, 2);
      if (mod(s,2) ~= 0)
        error('number of channels of input file has to be an integer of 2!');
      end

      % create local copy of data for the SSR MEX-Code
      % TODO: include SOFA support into the SSR
      [tmpdir, tmpname] = fileparts(tempname(xml.dbTmp()));
      filename = fullfile(tmpdir, [name, '_', tmpname, '.wav']);
      % MATLAB proposes to replace wavwrite with audiowrite, but this does not
      % work for a high number of channels like in HRTF datasets
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

      tfmax = max(max(abs(tf.left(:)),abs(tf.right(:))));

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
    function [d, fs] = convertSOFA(data)

      switch data.GLOBAL_SOFAConventions
        case 'SimpleFreeFieldHRIR'
          % convert to spherical coordinates
          data.SourcePosition = SOFAconvertCoordinates(...
            data.SourcePosition,data.SourcePosition_Type,'spherical');
          % find entries with zero elevation angle
          select = find(data.SourcePosition(:,2) == 0);
          % sort remaining with respect to azimuth angle
          [azimuths, ind] = sort(data.SourcePosition(select,1));
        case 'SingleRoomDRIR'
          % convert to spherical coordinates
          data.ListenerView = SOFAconvertCoordinates(...
            data.ListenerView, data.ListenerView_Type,'spherical');
          % find entries with zero elevation angle
          select = find(data.ListenerView(:,2) == 0);
          % sort remaining with respect to azimuth angle
          [azimuths, ind] = sort(data.ListenerView(select,1));
        otherwise
          error('SOFA Conventions (%s) not supported', ...
            data.GLOBAL_SOFAConventions);
      end
      % select data
      d = data.Data.IR(select,:,:);
      % sort data
      d = d(ind,:,:);
      % get the minimum distance between two measurements
      resolution = min(...
        simulator.DirectionalIR.angularDistanceMeasure( ...
        azimuths, circshift(azimuths,1)...
        ) ...
        );
      % create regular grid with this distance
      nangle = round(360/resolution);
      azimuth_grid = (0:nangle-1)./nangle*360;
      % determine nearest neighbor between grid and measurements
      knd = ...
        simulator.DirectionalIR.nearestNeighbor(azimuth_grid, azimuths);
      % select nearest neightbor measurements for grid
      d = d(knd, :, :);
      % reshape the array
      d = permute(d,[3 2 1]);
      d = reshape(d,size(d,1),[]);
      % get sampling frequency
      fs = data.Data.SamplingRate;
    end
    function res = angularDistanceMeasure(a, b)
      res = abs(mod(abs(a - b) + 180, 360) - 180);
    end
    function [idx, diff] = nearestNeighbor(grid, b)
      [grid, b] = meshgrid(grid, b);
      diff = simulator.DirectionalIR.angularDistanceMeasure(grid, b);
      [diff, idx] = min(diff,[],1);
    end
  end
end
