classdef FilteredGrid < Grid
    %Filter the result of `Grid`
    
    properties
    end
    
    methods
        function obj = FilteredGrid(intersectionObj, info, params)
            % Constructor

            % super-class constructor
            obj = obj@Grid(intersectionObj, info, params);
        end
        
        function output = query(obj, point)
            neighbours = query@Grid(obj, point);
            
            % filter
            point = point + obj.info.maxDistance + obj.gridResolution;
            output = neighbours(...
                arrayfun(...
                    @(x) obj.intersectionObj.haveIntersection(point, obj.points{x}), ...
                    neighbours ...
                ) ...
            );
        end
    end
    
    methods (Static)
    end
end
