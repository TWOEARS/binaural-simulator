classdef BRSGroup < simulator.source.GroupBase

  properties
    % Object containg reference position
    % @type simulator.Object
    % @default @ssr_binaural
    Reference@simulator.Object;
  end  
  
  methods
    function refresh(obj, T)
      if nargin==2
        obj.refresh@simulator.source.GroupBase(T);
      else
        obj.refresh@simulator.source.GroupBase();
      end
      
      [~, idx] = min(sqrt(sum( bsxfun(@minus, [obj.SubSources.Position], ...
        obj.Reference.Position).^2, 1)));
      for wdx=1:length(obj.SubSources)
        obj.SubSources(wdx).Mute = true;
      end
      obj.SubSources(idx).Mute = false;
    end
    
    %%
    function loadBRSFile(obj, filename, srcidx)
      
      if nargin < 3
        srcidx = 1;
      end      
      header = SOFAload(db.getFile(filename), 'nodata');  % filename
      % convert listener position to cartesian coordinates
      positions = SOFAconvertCoordinates(...
        header.ListenerPosition, header.ListenerPosition_Type, 'cartesian');
      positions = unique(positions, 'rows', 'stable');
      
      obj.SubSources = simulator.source.Point.empty();        
      for wdx=1:size(positions,1)
        obj.SubSources(wdx) = simulator.source.Point();
        obj.SubSources(wdx).Position = positions(wdx,:).';
        obj.SubSources(wdx).GroupObject = obj;
        obj.SubSources(wdx).IRDataset = ...
            simulator.DirectionalIR(filename, srcidx, wdx);   
      end
    end    
  end 
  
  %% SSR compatible stuff
  methods
    function v = ssrData(obj, BlockSize)
      v = obj.getData(BlockSize);
      v = repmat(v, 1, length(obj.SubSources));
    end
  end
  
  %% MISC
  methods
    function [h, leg] = plot(obj, figureid)
      if nargin < 2
        figure;
      else
        figure(figureid);
      end

      [h, leg] = obj.plot@simulator.source.GroupBase(figureid);
      set(h(1),'Marker','^');
    end
  end

  %% getter/setter
  methods

  end
end
