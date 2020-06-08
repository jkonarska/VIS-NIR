% Basic idea from https://www.mathworks.com/matlabcentral/answers/46884-is-there-something-like-a-struct-pointer-in-matlab
classdef hstruct < handle
  properties
      data = struct;
  end
  
  methods
    function obj = hstruct()
    end
  end
end