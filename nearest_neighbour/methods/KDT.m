classdef KDT < BaseNN
    %Kd-Tree
    
    properties
        % Properties
        % ----------
        % - r: nonnegative scalar
        %   Search radius
        r
    end
    
    methods
        function obj = KDT(intersectionObj, info, params)
            % Constructor

            obj = obj@BaseNN(intersectionObj, info);
            obj.r = 2 * intersectionObj.radius;
        end
        
        function output = query(obj, point)
            X = cell2mat(obj.points)';
            q = point';
            
            if (~isempty(X))
                output = rangesearch(...
                    KDTreeSearcher(X), ...
                    q, ...
                    obj.r ...
                );

                output = output{1};
            else
                output = [];
            end
            
            % add `point` to `points`
            obj.addPointToPoints(point);
        end
    end
    
end
