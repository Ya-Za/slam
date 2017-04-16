classdef LNN < BaseNN
    %Linear nearest neighbour method
    
    properties
    end
    
    methods
        function obj = LNN(intersectionObj, info)
            % Constructor

            obj = obj@BaseNN(intersectionObj, info);
        end
        
        function output = query(obj, point)
            output = [];
            % for each point from `t=0` to `t=Now - 1`
            for indexOfPoint = 1:(numel(obj.points) - 1)
                if obj.intersectionObj.haveIntersection(...
                        point, ...
                        obj.points{indexOfPoint} ...
                    )
                    output(end + 1) = indexOfPoint;
                end
            end
            
            % add `point` to `points`
            obj.addPointToPoints(point);
        end
    end
    
end
