classdef Intersection < handle
    %Intersection
    
    properties
        % Properties
        % ----------
        % - radius: double = 1

        radius
    end
    
    methods
        function obj = Intersection(radius)
            % Constructor
            if ~exist('radius', 'var')
                radius = 1;
            end
            
            obj.radius = radius;
        end
        function tf = haveIntersection(obj, c1, c2)
            % Check two given hyper spheres have intersection
            %
            % Parameters
            % ----------
            % - c1: double vector
            %   Center of first hyper shpere
            % - c2: double vector
            %   Center of second hyper shpere
            %
            % Results
            % -------
            % - tf: logical
            %   True or false result
            
            % euclidean distance between two centers
            d = norm(c1 - c2);
            
            tf = d < 2 * obj.radius;
        end
    end
    
end

