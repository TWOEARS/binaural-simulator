classdef GroupBase < simulator.source.Base

  properties (SetAccess = protected)
    SubSources;
  end

  %% SSR compatible stuff
  methods
    function v = ssrData(obj, BlockSize)
      v = zeros(BlockSize, length(obj.SubSources));
      for idx=1:length(obj.SubSources)
        v(:, idx) = obj.SubSources(idx).getData(BlockSize);
      end
    end
    function v = ssrChannels(obj)
      v = length(obj.SubSources);
    end
    function v = ssrPosition(obj)
      v = [obj.SubSources.PositionXY];
    end
    function v = ssrOrientation(obj)
      v = [obj.SubSources.OrientationXY];
    end
    function v = ssrType(obj)
      v = obj.SubSources.ssrType;
    end
    function v = ssrMute(obj)
      v = obj.Mute | [obj.SubSources.Mute];
    end
    function v = ssrIRFile(obj)
      v = obj.SubSources.ssrIRFile;
    end
  end

  %% setter/getter
  methods
    function set.SubSources(obj, v)
      isargclass('simulator.source.Base', v);
      obj.SubSources = v;
    end
  end
end
