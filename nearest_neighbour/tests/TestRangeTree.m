classdef TestRangeTree < matlab.unittest.TestCase
    methods (Test)
        function testAdd(testCase)
            % arrange
            points = {[1; 1], [-1; 1], [2; 2], [-2; 2]};
            numberOfDimensions = 2;
            info = struct('numberOfDimensions', numberOfDimensions);
            
            expected = RangeTree(Intersection(), info, []);
            expected.root = RangeTreeNode(...
                1, ...
                1, ...
                [], ...
                [...
                    RangeTreeNode(...
                        2, ...
                        1, ...
                        [], ...
                        [RangeTreeNode(4, 1), RangeTreeNode(4, 2)], ...
                        [] ...
                    ), ...
                    RangeTreeNode(2, 2, [], [], RangeTreeNode(4, 2)) ...
                ], ...
                [RangeTreeNode(3, 1), RangeTreeNode(3, 2)] ...
            );
            expected.points = points;
            % act
            actual = RangeTree(Intersection(), info, []);
            for i = 1:length(points)
                actual.add(points{i});
            end
            % assert
            testCase.assertTrue(equalTwoTrees(actual.root, expected.root));
            
            % Local Functions
            function tf = equalTwoTrees(t1, t2)
                tf = true;
                if length(t1) ~= length(t2)
                    tf = false;
                    return;
                end
                for j = 1:length(t1)
                    if t1(j).idx ~= t2(j).idx
                        tf = false;
                        return;
                    end
                    if t1(j).index ~= t2(j).index
                        tf = false;
                        return;
                    end
                    if ~equalTwoTrees(t1(j).left, t2(j).left)
                        tf = false;
                        return;
                    end
                    if ~equalTwoTrees(t1(j).right, t2(j).right)
                        tf = false;
                        return;
                    end
                end
            end
        end
        function testPoints(testCase)
            % arrange
            points = {[1; 1], [-1; 1], [2; 2], [-2; 2]};
            numberOfDimensions = 2;
            info = struct('numberOfDimensions', numberOfDimensions);
            
            obj = RangeTree(Intersection(), info, []);
            for i = 1:length(points)
                obj.add(points{i});
            end
            
            expected = {
                [4, 2, 1, 3]
                [2, 4]
            };
            % act
            actual = {
                RangeTree.points(obj.root)
                RangeTree.points(obj.root.left(2))
            };
            % assert
            testCase.assertEqual(actual, expected);
        end
        function testGe(testCase)
            % arrange
            points = {[1; 1], [-1; 1], [2; 2], [-2; 2]};
            numberOfDimensions = 2;
            info = struct('numberOfDimensions', numberOfDimensions);
            
            obj = RangeTree(Intersection(), info, []);
            for i = 1:length(points)
                obj.add(points{i});
            end
            
            expected = {
                3
                4
                []
            };
            % act
            actual = {
                obj.ge(obj.root, 1.5).idx
                obj.ge(obj.root.left(2), 1.5).idx
                obj.ge(obj.root.left(2), 3)
            };
            % assert
            testCase.assertEqual(actual, expected);
        end
        function testLe(testCase)
            % arrange
            points = {[1; 1], [-1; 1], [2; 2], [-2; 2]};
            numberOfDimensions = 2;
            info = struct('numberOfDimensions', numberOfDimensions);
            
            obj = RangeTree(Intersection(), info, []);
            for i = 1:length(points)
                obj.add(points{i});
            end
            
            expected = {
                3
                4
                []
            };
            % act
            actual = {
                obj.le(obj.root, 2.5).idx
                obj.le(obj.root.left(2), 2.5).idx
                obj.le(obj.root.left(2), 0)
            };
            % assert
            testCase.assertEqual(actual, expected);
        end
        function testRange(testCase)
            % arrange
            points = {[1; 1], [-1; 1], [2; 2], [-2; 2]};
            limits = [0, 3; 0, 3];
            numberOfDimensions = 2;
            info = struct('numberOfDimensions', numberOfDimensions);
            
            obj = RangeTree(Intersection(), info, []);
            for i = 1:length(points)
                obj.add(points{i});
            end
            
            expected = [1, 3];
            % act
            actual = obj.range(limits);
            % assert
            testCase.assertEqual(actual, expected);
        end
        function testQuery(testCase)
            % arrange
            points = {[1; 1], [-1; 1], [2; 2], [-2; 2]};
            point = [1.5; 0.5];
            numberOfDimensions = 2;
            info = struct('numberOfDimensions', numberOfDimensions);
            
            obj = RangeTree(Intersection(), info, []);
            for i = 1:length(points)
                obj.query(points{i});
            end
            
            expected = [1, 3];
            % act
            actual = obj.query(point);
            % assert
            testCase.assertEqual(actual, expected);
        end
    end
end
