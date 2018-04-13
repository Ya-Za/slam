classdef RangeTreeNode < handle
    %Kd-Tree Node
    
    properties
        % Properties
        % ----------
        % - idx: number
        %   Index of point in set of points
        % - idx: number
        %   Index of value item in point
        % - parent: RangeTreeNode | null
        %   Left child
        % - left: RangeTreeNode[]
        %   Left child
        % - right: RangeTreeNode[]
        %   Right child
        idx
        index
        parent
        left
        right
    end
    
    methods
        function obj = RangeTreeNode(idx, index, parent, left, right)
            % Constructor
            
            % default values
            if ~exist('parent', 'var')
                parent = [];
            end
            if ~exist('left', 'var')
                left = [];
            end
            if ~exist('right', 'var')
                right = [];
            end
            
            obj.idx = idx;
            obj.index = index;
            obj.parent = parent;
            obj.left = left;
            obj.right = right;
        end
    end
    
end

