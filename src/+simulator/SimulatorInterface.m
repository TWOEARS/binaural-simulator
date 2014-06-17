classdef (Abstract) SimulatorInterface < xml.MetaObject
  %SIMULATORINTERFACE is the base class for all configurations for the simulator
  
  properties
    BlockSize;  % blocksize for binaural renderer @type uint
    SampleRate;  % sample rate of audio input signals in Hz @type uint
    NumberOfThreads;  % threads used for computing ear signals @type uint    
    % rendering mex-function @type function_handle
    Renderer@function_handle = @ssr_binaural;  
    HRIRDataset@simulator.DirectionalIR;  % hrirs @type DirectionalIR
    
    % maximum delay in seconds caused by distance @type double
    MaximumDelay = 0.0; %
    
    Sources@simulator.AudioSource  % array of sources @type AudioSource[]
    Sinks@simulator.AudioSink;  % sinks @type AudioSink
    Walls@simulator.Wall;  % array of walls @type Wall[]
    
    ReverberationMaxOrder = 0.0;  % order of image source model @type uint
  end  
  
  %% Constructor
  methods
    function obj = SimulatorInterface()
      obj.addXMLProperty('BlockSize', 'double');
      obj.addXMLProperty('SampleRate', 'double');
      obj.addXMLProperty('NumberOfThreads', 'double');
      obj.addXMLProperty('MaximumDelay', 'double');
      obj.addXMLProperty('ReverberationMaxOrder', 'double');
      obj.addXMLProperty('HRIRDataset', 'simulator.DirectionalIR', 'HRIRs');      
    end
  end  
  
  %% XML
  methods (Access=protected)
    function XMLChilds(obj, xmlnode)
      
      % Sources
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
      
      % Walls
      wallList = xmlnode.getElementsByTagName('wall');
      wallNum = wallList.getLength;      
      for idx=1:wallNum
        wall = wallList.item(idx-1);
        obj.Walls(idx) = simulator.Wall();
        obj.Walls(idx).XML(wall);
      end
    
      % Sink
      sink = xmlnode.getElementsByTagName('sink').item(0);   
      obj.Sinks = simulator.AudioSink(2);
      obj.Sinks.XML(sink);     
    end
  end  
  
  %% some functionalities for controlling the Simulator
  % this properties can be used to invoke some of the abstract functions
  
  properties
    Init;
  end
  properties (Dependent, GetAccess=private)
    Refresh;
    Process;
    ClearMemory;
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