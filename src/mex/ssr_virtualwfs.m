function [varargout] = ssr_virtualwfs(varargin)

isargchar(varargin{1})

varargout = {};

switch varargin{1}
  case 'init'
    if nargin > 3
      error('too much input arguments for "%s"', varargin{1});
    end
    isargpositivescalar(varargin{2});
    
    params = varargin{3};
    
    % init wfs renderer
    params.reproduction_setup = '8channels.asd';
    params.prefilter_file = 'wfs_prefilter_100_1300_44100.wav';    
    ssr_wfs('init', varargin{2}, rmfield(params,'hrir_file'));
    
    % get number and positions of loudspeakers
    num = ssr_wfs('out_channels');
    pos = ssr_wfs('loudspeaker_position');
    
    % remove some fields from the params (just for convenience)
    params = rmfield(params, {'prefilter_file', 'reproduction_setup'});

    % init binaural renderer
    ssr_binaural('init', num, params);  
    ssr_binaural('source_position', pos); 
  case 'clear'
    if nargin > 1
      error('too much input arguments for "%s"', varargin{1});
    end
    ssr_wfs('clear');
    ssr_binaural('clear');
  otherwise
    if any(strcmp('process',varargin))
      varargout{1} = ssr_wfs(varargin{:});
      varargout{1} = ssr_binaural('process', varargout{1});
    else
      ssr_wfs(varargin{:});
    end
end