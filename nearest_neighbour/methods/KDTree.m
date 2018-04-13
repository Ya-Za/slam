classdef KDTree < BaseNN
    %Kd-Tree
    
    properties
        % Properties
        % ----------
        % - r: number
        %   Search radius
        % - root: KDTreeNode | null
        %   Root of tree
        % - D: number
        %   Number of dimensions
        r
        root
        D
    end
    
    methods
        function obj = KDTree(intersectionObj, info, params)
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
                obj.root = KDTreeNode(idx);
            else
                addR(obj.root, 1);
            end
            % Local Functions
            function addR(node, d)
                dd = mod(d, obj.D) + 1;
                if point(d) < obj.points{node.idx}(d)
                    if isempty(node.left)
                        node.left = KDTreeNode(idx);
                    else
                        addR(node.left, dd);
                    end
                else
                    if isempty(node.right)
                        node.right = KDTreeNode(idx);
                    else
                        addR(node.right, dd);
                    end
                end
            end
        end
        function idxs = range(obj, limits)
            idxs = [];
            rangeR(obj.root, 1);
            
            % Local Functions
            function rangeR(node, d)
                if isempty(node)
                    return;
                end
                
                point = obj.points{node.idx};
                v = point(d);
                a = limits(d, 1);
                b = limits(d, 2);
                dd = mod(d, obj.D) + 1;
                
                if v < a
                    rangeR(node.right, dd);
                elseif v > b
                    rangeR(node.left, dd);
                else
                    if inRange(point)
                        idxs(end + 1) = node.idx;
                    end
                    rangeR(node.left, dd);
                    rangeR(node.right, dd);
                end
            end
            function tf = inRange(point)
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
    
end

