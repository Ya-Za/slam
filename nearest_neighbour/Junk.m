classdef Junk < handle
    %UNTITLED7 Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
        r = 10
    end
    
    methods
        function foo(obj, x)
            disp(obj.r + x);
        end
    end
    
end

