classdef BaseNN < handle
    %Base class of nearest neighbour methods
    
    properties
        % Properties
        % ----------
        % - points: double matrix
        %   [p1, p2, ...]
        % - intersectionObj: Intersection
        %   Has `haveIntersection` method
        % - config: struct
        %   Extra configuration such as `maxDistance`, `numberOfPoints`,
        %   ...

        points
        intersectionObj
        config
    end
    
    methods
        function obj = BaseNN(intersectionObj, config)
            % Constructor

            obj.points = {};
            obj.intersectionObj = intersectionObj;
            obj.config = config;
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
