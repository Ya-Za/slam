classdef RangeTreeNode < handle
    %Kd-Tree Node
    
    properties
        % Properties
        % ----------
        % - idx: number
        %   Index of point in set of points
        % - parent: RangeTreeNode | null
        %   Left child
        % - left: RangeTreeNode
        %   Left child
        % - right: RangeTreeNode
        %   Right child
        % - aux: RangeTreeNode
        %   Root of auxiliary tree
        idx
        parent
        left
        right
        aux
    end
    
    methods
        function obj = RangeTreeNode(idx, parent, left, right, aux)
            % Constructor
            
            % default values
%             if ~exist('parent', 'var')
%                 parent = [];
%             end
%             if ~exist('left', 'var')
%                 left = [];
%             end
%             if ~exist('right', 'var')
%                 right = [];
%             end
%             if ~exist('aux', 'var')
%                 aux = [];
%             end
            
            obj.idx = idx;
            obj.parent = parent;
            obj.left = left;
            obj.right = right;
            obj.aux = aux;
        end
    end
    
end

