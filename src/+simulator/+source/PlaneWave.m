classdef PlaneWave < simulator.source.Base & dynamicprops
  % Class for source-objects in audio scene

  %% SSR compatible stuff
  methods
    function v = ssrType(obj)
      v = repmat({'plane'}, size(obj));
    end
  end
end
