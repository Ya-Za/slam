classdef KDTreeNode < handle
    %Kd-Tree Node
    
    properties
        % Properties
        % ----------
        % - index: number
        %   Index of point in set of points
        % - left: KDTreeNode | null
        %   Left child
        % - right: KDTreeNode | null
        %   Right child
        idx
        left
        right
    end
    
    methods
        function obj = KDTreeNode(idx, left, right)
            % Constructor
            
            % default values
            if ~exist('left', 'var')
                left = [];
            end
            if ~exist('right', 'var')
                right = [];
            end
            
            obj.idx = idx;
            obj.left = left;
            obj.right = right;
        end
    end
    
end

