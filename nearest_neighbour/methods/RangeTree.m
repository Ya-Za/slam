classdef RangeTree < BaseNN
    %Kd-Tree
    
    properties
        % Properties
        % ----------
        % - r: number
        %   Search radius
        % - root: RangeTreeNode[]
        %   Root of tree
        % - D: number
        %   Number of dimensions
        r
        root
        D
    end
    
    methods
        function obj = RangeTree(intersectionObj, info, params)
            % Constructor

            obj = obj@BaseNN(intersectionObj, info);
            obj.r = 2 * intersectionObj.radius;
            
            obj.root = [];
            obj.D = info.numberOfDimensions;
        end 
        function output = query(obj, point)
            output = obj.range(pointToLimits());
            output = obj.filter(point, output);
            
            % add `point` to `points`
            obj.add(point);
            
            % Local Functions
            function limits = pointToLimits()
                limits = zeros(obj.D, 2);
                for i = 1:obj.D
                    limits(i, 1) = point(i) - obj.r - eps;
                    limits(i, 2) = point(i) + obj.r + eps;
                end
            end
        end
    end
    
    methods
        function add(obj, point)
            % add `point` to `points`
            obj.addPointToPoints(point);
            idx = length(obj.points);
            
            if isempty(obj.root)
                obj.root = RangeTreeNode(idx, 1);
            else
                addR(obj.root);
            end
            % Local Functions
            function addR(nodes)
                for node = nodes
                    index = node.index;
                    if point(index) < obj.points{node.idx}(index)
                        if isempty(node.left)
                            for i = index:obj.D
                                node.left = [node.left, RangeTreeNode(idx, i, node)];
                            end
                        else
                            addR(node.left)
                        end
                    else
                        if isempty(node.right)
                            for i = index:obj.D
                                node.right = [node.right, RangeTreeNode(idx, i, node)];
                            end
                        else
                            addR(node.right)
                        end 
                    end
                end
            end
        end
        function idxs = range(obj, limits)
            idxs = [];
            rangeR(obj.root);
            
            % Local Functions
            function rangeR(node)
                if isempty(node)
                    return;
                end
                a = limits(node.index, 1);
                b = limits(node.index, 2);
                
                % find A
                % - A.point(index) >= a
                A = obj.ge(node, a);
                if isempty(A)
                    return;
                end
                % find B
                % - B.point(index) <= b
                B = obj.le(node, b);
                if isempty(B)
                    return;
                end
                % find P
                % - spliting parent for a, b
                P = getSplittingParent(node);
                if isempty(P)
                    return;
                end
                % up right from A until P
                upRight(A);
                % add P.point
                if inRange(P.idx)
                    idxs(end + 1) = P.idx;
                end
                % up left from B until P
                upLeft(B);
                
                % Local Functions
                function P = getSplittingParent(node)
                    if isempty(node)
                        P = [];
                        return;
                    end
                    v = obj.points{node.idx}(node.index);
                    if v >= a
                        if v <= b
                            P = node;
                            return;
                        else
                            P = getSplittingParent(node.left(1));
                            return;
                        end
                    end
                    P = getSplittingParent(node.right(1));
                end
                function up(node, side)
                    if node == P
                        return;
                    end
                    
                    other = 'left';
                    if strcmp(side, 'left')
                        other = 'right';
                    end
                    
                    checkNode(node);
                    parent = node.parent;
                    
                    while parent ~= P
                        if parent.(other)(1) == node
                            checkNode(parent);
                        end
                        node = parent;
                        parent = parent.parent;
                    end
                    
                    % Local Functions
                    function checkNode(node)
                        if inRange(node.idx)
                            idxs(end + 1) = node.idx;
                        end
                        pointers = node.(side);
                        if isempty(pointers)
                            return;
                        end
                        if length(pointers) == 1
                            for idx = RangeTree.points(pointers(1))
                                if inRange(idx)
                                    idxs(end + 1) = idx;
                                end
                            end
                        else
                            rangeR(pointers(2));
                        end
                    end
                end
                function upRight(node)
                    up(node, 'right');
                end
                function upLeft(node)
                    up(node, 'left');
                end
            end
            function tf = inRange(idx)
                point = obj.points{idx};
                tf = true;
                for i = 1:length(point)
                    v = point(i);
                    a = limits(i, 1);
                    b = limits(i, 2);

                    if v < a || v > b
                        tf = false;
                        return
                    end
                end
            end
        end
    end
    
    methods
        function res = ge(obj, root, v)
            res = [];
            geR(root);
            
            % Local Functions
            function geR(node)
                u = obj.points{node.idx}(node.index);
                if u == v
                    res = node;
                elseif u > v
                    res = node;
                    if ~isempty(node.left)
                        geR(node.left(1));
                    end
                else
                    if ~isempty(node.right)
                        geR(node.right(1));
                    end
                end
            end
        end
        function res = le(obj, root, v)
            res = [];
            leR(root);
            
            % Local Functions
            function leR(node)
                u = obj.points{node.idx}(node.index);
                if u == v
                    res = node;
                elseif u < v
                    res = node;
                    if ~isempty(node.right)
                        leR(node.right(1));
                    end
                else
                    if ~isempty(node.left)
                        leR(node.left(1));
                    end
                end
            end
        end
    end
    
    methods (Static)
        % todo: rename `points` to `idxs`
        function res = points(root)
            res = [];
            pointsR(root);
            
            % Local Functions
            function pointsR(node)
                if ~isempty(node.left)
                    pointsR(node.left(1));
                end
                res = [res, node.idx];
                if ~isempty(node.right)
                    pointsR(node.right(1));
                end
            end
        end
    end
    
end

