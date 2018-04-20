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
                obj.root = RangeTreeNode(idx, [], [], [], []);
            else
                addR(obj.root, 1);
            end
            % Local Functions
            function addR(node, index)
                if ~isempty(node.aux)
                    addR(node.aux, index + 1);
                end
                
                if point(index) < obj.points{node.idx}(index)
                    if isempty(node.left)
                        node.left = RangeTreeNode(idx, node, [], [], []);
                        if index < obj.D
                            node.left.aux = RangeTreeNode(idx, [], [], [], []);
                        end
                    else
                        addR(node.left, index)
                    end
                else
                    if isempty(node.right)
                        node.right = RangeTreeNode(idx, node, [], [], []);
                        if index < obj.D
                            node.right.aux = RangeTreeNode(idx, [], [], [], []);
                        end
                    else
                        addR(node.right, index)
                    end
                end
            end
        end
        function idxs = range(obj, limits)
            idxs = [];
            rangeR(obj.root, 1);
            
            % Local Functions
            function rangeR(node, index)
                if isempty(node)
                    return;
                end
                a = limits(index, 1);
                b = limits(index, 2);
                
                % find A
                % - A.point(index) >= a
                A = obj.ge(node, a, index);
                if isempty(A)
                    return;
                end
                % find B
                % - B.point(index) <= b
                B = obj.le(node, b, index);
                if isempty(B)
                    return;
                end
                % find P
                % - spliting parent for a, b
                P = findSplitNode(node);
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
                function tf = inRange(idx)
                    point = obj.points{idx};
                    tf = true;
                    
                    i = index;
                    while i <= obj.D
                        v_ = point(i);
                        a_ = limits(i, 1);
                        b_ = limits(i, 2);
                        
                        if v_ < a_ || v_ > b_
                            tf = false;
                            return
                        end
                        
                        i = i + 1;
                    end
                end
                function P = findSplitNode(node)
                    if isempty(node)
                        P = [];
                        return;
                    end
                    v = obj.points{node.idx}(index);
                    if v >= a
                        if v <= b
                            P = node;
                            return;
                        else
                            P = findSplitNode(node.left);
                            return;
                        end
                    end
                    P = findSplitNode(node.right);
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
                        if ~isempty(parent.(other)) && parent.(other) == node
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
                        child = node.(side);
                        if isempty(child)
                            return;
                        end
                        if isempty(child.aux)
                            for idx = RangeTree.points(child)
                                if inRange(idx)
                                    idxs(end + 1) = idx;
                                end
                            end
                        else
                            rangeR(child.aux, index + 1);
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
        end
    end
    
    methods
        function res = ge(obj, root, v, index)
            res = [];
            geR(root);
            
            % Local Functions
            function geR(node)
                if isempty(node)
                    return;
                end
                
                u = obj.points{node.idx}(index);
                if u == v
                    res = node;
                elseif u > v
                    res = node;
                    geR(node.left);
                else
                    geR(node.right);
                end
            end
        end
        function res = le(obj, root, v, index)
            res = [];
            leR(root);
            
            % Local Functions
            function leR(node)
                if isempty(node)
                    return;
                end
                
                u = obj.points{node.idx}(index);
                if u == v
                    res = node;
                elseif u < v
                    res = node;
                    leR(node.right);
                else
                    leR(node.left);
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
                if isempty(node)
                    return;
                end
                pointsR(node.left);
                res(end + 1) = node.idx;
                pointsR(node.right);
            end
        end
    end
    
end

