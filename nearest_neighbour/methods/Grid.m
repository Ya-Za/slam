classdef Grid < BaseNN
    %Linear nearest neighbour method
    
    properties
        grid
        girdResolution
    end
    
    methods
        function obj = Grid(intersectionObj, info)
            % Constructor

            obj = obj@BaseNN(intersectionObj, info);
            
            % init
            obj.gridResolution = sqrt(2);
            maxDistance = obj.info.maxDistance;
            gridLength = ceil(2 * maxDistance / obj.gridResolution);
            obj.grid = cell(gridLength);
        end
        
        function output = query(obj, point)
            % todo: `getNeighbours`
            bottomLeft = floor(point / obj.gridResolution);
            output = [];
            output = [output, obj.grid{bottomLeft(1), bottomLeft(1)}];
            output = [output, obj.grid{bottomLeft(1) + 1, bottomLeft(1)}];
            output = [output, obj.grid{bottomLeft(1), bottomLeft(1) + 1}];
            output = [output, obj.grid{bottomLeft(1) + 1, bottomLeft(1) + 1}];
            
            
            % add `point` to `points`
            obj.points{end + 1} = point;
            % add index to `grid`
            obj.addPointToGrid(point);
        end
        
        function addPointToGrid(obj, point)
            % get position of nearest node in `grid`
            position = floor(...
                point + (obj.gridResolution / 2) / ...
                obj.gridResolution ...
            );
            
            % todo: `sub2ind`
            obj.gird{position(1), position(2)}(end + 1) = ...
                numel(obj.points);
        end
    end
    
end
