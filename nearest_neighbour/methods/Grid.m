classdef Grid < BaseNN
    %Linear nearest neighbour method
    
    properties
    end
    
    methods
        function obj = Grid(intersectionObj, config)
            % Constructor

            obj = obj@BaseNN(intersectionObj, config);
        end
        
        function output = query(obj, point)
            output = [];
            
            % add `point` to `points`
            obj.points{end + 1} = point;
        end
    end
    
end
