classdef (Abstract) SimulatorInterface < xml.MetaObject
  %SIMULATORINTERFACE is the base class for all configurations for the simulator
  
  properties
    % blocksize for binaural renderer
    % @type integer
    BlockSize;
    % sample rate of audio input signals in Hz
    % @type integer
    SampleRate;
    % threads used for computing ear signals
    % @type integer
    % @default 1
    NumberOfThreads = 1;
    % rendering mex-function
    % @type function_handle
    % @default @ssr_binaural
    Renderer = @ssr_binaural;
    % HRIR-dataset
    % @type DirectionalIR
    HRIRDataset;
    
    % maximum delay in seconds caused by distance and finite sound velocity
    % @type double
    MaximumDelay = 0.0;
    
    % array of sources
    % @type AudioSource[]
    Sources = simulator.AudioSource.empty;
    % array of sinks
    % @type AudioSink[]
    Sinks = simulator.AudioSink.empty;
    % array of walls
    % @type Wall[]
    Walls = simulator.Wall.empty;
    
    % order of image source model (number of subsequent reflections)
    % @type integer
    % @default 0
    ReverberationMaxOrder = 0;
  end
  
  %% Constructor
  methods
    function obj = SimulatorInterface()
      obj.addXMLAttribute('BlockSize', 'double');
      obj.addXMLAttribute('SampleRate', 'double');
      obj.addXMLAttribute('NumberOfThreads', 'double');
      obj.addXMLAttribute('MaximumDelay', 'double');
      obj.addXMLAttribute('ReverberationMaxOrder', 'double');
      obj.addXMLAttribute('HRIRDataset', 'simulator.DirectionalIR', 'HRIRs');
      
      obj.addXMLElement('Sinks', 'simulator.AudioSink', 'sink', @(x)simulator.AudioSink(2));
      obj.addXMLElement('Walls', 'simulator.Wall', 'wall');
    end
  end
  
  %% XML
  methods (Access=protected)
    function configureXMLSpecific(obj, xmlnode)
      % function configureXMLSpecific(obj, xmlnode)
      % See also: xml.MetaObject.configureXMLSpecific
      sourceList = xmlnode.getElementsByTagName('source');
      sourceNum = sourceList.getLength;
      
      for idx=1:sourceNum
        source = sourceList.item(idx-1);
        attr = (char(source.getAttribute('Type')));
        switch attr
          case 'point'
            type = simulator.AudioSourceType.POINT;
          case 'plane'
            type = simulator.AudioSourceType.PLANE;
          case 'direct'
            type = simulator.AudioSourceType.DIRECT;
          otherwise
            warning('source type not yet implemented for xml parsing');
        end
        obj.Sources(idx) = simulator.AudioSource(type);
        obj.Sources(idx).XML(source);
      end
    end
  end
  
  %% some functionalities for controlling the Simulator
  % this properties can be used to invoke some of the abstract functions
  
  properties
    % flag indicates if the simulator is initialited
    % @type logical
    % @default false
    Init = false;
  end
  properties (Dependent, GetAccess=private)
    % set to true to process one frame of ear signals
    % @type logical
    Process;
    % set to true to refresh scene geometry
    % @type logical
    Refresh;
    % set to true to clear convolver memory
    % @type logical
    ClearMemory;
    % set to true to shut down the simulator
    % @type logical
    ShutDown;
  end
  
  methods (Abstract)
    init(obj);
    refresh(obj);
    process(obj);
    clearMemory(obj);
    shutDown(obj);
  end
  % special setter and getter for this
  methods
    function set.Init(obj, Init)
      isargclass('logical', Init);
      if (Init)
        obj.init();
      end
      obj.Init = Init;
    end
    function set.Refresh(obj, Refresh)
      isargclass('logical', Refresh);
      if (Refresh)
        obj.refresh();
      end
    end
    function set.Process(obj, Process)
      isargclass('logical', Process);
      if (Process)
        obj.process();
      end
    end
    function set.ClearMemory(obj, ClearMemory)
      isargclass('logical', ClearMemory);
      if (ClearMemory)
        obj.clearMemory();
      end
    end
    function set.ShutDown(obj, ShutDown)
      isargclass('logical', ShutDown);
      if (ShutDown)
        obj.shutDown();
        obj.Init = false;
      end
    end
  end
  
  %% setter, getter
  methods
    function set.BlockSize(obj, BlockSize)
      isargpositivescalar(BlockSize);  % check if positive scalar
      isargnonzeroscalar(BlockSize);  % check if non-zero scalar
      obj.errorIfInitialized;
      obj.BlockSize = BlockSize;
    end
    function set.NumberOfThreads(obj, NumberOfThreads)
      isargpositivescalar(NumberOfThreads);  % check if positive scalar
      isargnonzeroscalar(NumberOfThreads);  % check if non-zero scalar
      obj.errorIfInitialized;
      obj.NumberOfThreads = NumberOfThreads;
    end
    function set.Renderer(obj, Renderer)
      if ~isa(Renderer, 'function_handle')  % check if function_handle
        error('Renderer is not a function handle');
      end
      obj.errorIfInitialized;
      obj.Renderer = Renderer;
    end
    function set.HRIRDataset(obj, HRIRDataset)
      isargclass('simulator.DirectionalIR',HRIRDataset);  % check class
      if numel(HRIRDataset) ~= 1
        error('only one HRIRDataset is allowed');
      end
      obj.errorIfInitialized;
      obj.HRIRDataset = HRIRDataset;
    end
    function set.MaximumDelay(obj, MaximumDelay)
      isargpositivescalar(MaximumDelay)
      obj.errorIfInitialized;
      obj.MaximumDelay = MaximumDelay;
    end
    function set.Sinks(obj, Sinks)
      isargclass('simulator.AudioSink',Sinks);  % check class
      if numel(Sinks) ~= 1
        error('only one sink is allowed');
      end
      if Sinks.NumberOfInputs ~= 2
        error('Sink does not have two channels');
      end
      obj.errorIfInitialized;
      obj.Sinks = Sinks;
    end
    function set.Sources(obj, Sources)
      isargclass('simulator.AudioSource',Sources);  % check class
      isargvector(Sources);  % check if vector
      obj.errorIfInitialized;
      obj.Sources = Sources;
    end
    function set.Walls(obj, Walls)
      isargclass('simulator.Wall',Walls);  % check class
      isargvector(Walls);  % check if vector
      obj.errorIfInitialized;
      obj.Walls = Walls;
    end
    function set.ReverberationMaxOrder(obj, ReverberationMaxOrder)
      isargpositivescalar(ReverberationMaxOrder);  % check if positive scalar
      obj.ReverberationMaxOrder = ReverberationMaxOrder;
    end
  end
  
  %% Misc
  methods (Access = private)
    function errorIfInitialized(obj)
      if obj.Init
        error('Cannot change property while Simulator is initialized');
      end
    end
  end
end