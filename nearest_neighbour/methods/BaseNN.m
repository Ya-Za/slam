classdef BaseNN < handle
    %Base class of nearest neighbour methods
    
    properties
        % Properties
        % ----------
        % - points: double matrix
        %   [p1, p2, ...]
        % - intersectionObj: Intersection
        %   Has `haveIntersection` method
        % - info: struct
        %   Extra information such as `maxDistance`, `numberOfPoints`,
        %   ...

        points
        intersectionObj
        info
    end
    
    methods
        function obj = BaseNN(intersectionObj, info)
            % Constructor

            obj.points = {};
            obj.intersectionObj = intersectionObj;
            obj.info = info;
        end
        
        function addPointToPoints(obj, point)
            % Add `point` to `points`
            %
            % Parameters
            % ----------
            % - point: double vector
            %   Input point

            obj.points{end + 1} = point;
        end
    end
    
    methods (Abstract)
        output = query(obj, point)
        %   Parameters
        %   ----------
        %   - point: double vector
        %     Input point
        %
        %   Returns
        %   -------
        %   - output: int array
        %     Array of indexes which determines neighbours of input `point`
    end
    
end
