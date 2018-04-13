classdef TestKDTree < matlab.unittest.TestCase
    methods (Test)
        function testAdd(testCase)
            % arrange
            points = {[1; 1], [-1; 1], [2; 2], [-2; 2]};
            numberOfDimensions = 2;
            info = struct('numberOfDimensions', numberOfDimensions);
            
            expected = KDTree(Intersection(), info, []);
            expected.root = KDTreeNode(...
                1, ...
                KDTreeNode(...
                    2, ...
                    [], ...
                    KDTreeNode(4) ...
                ), ...
                KDTreeNode(3) ...
            );
            expected.points = points;
            % act
            actual = KDTree(Intersection(), info, []);
            for i = 1:length(points)
                actual.add(points{i});
            end
            % assert
            testCase.assertEqual(actual, expected);
        end
        function testRange(testCase)
            % arrange
            points = {[1; 1], [-1; 1], [2; 2], [-2; 2]};
            limits = [0, 3; 0, 3];
            numberOfDimensions = 2;
            info = struct('numberOfDimensions', numberOfDimensions);
            
            obj = KDTree(Intersection(), info, []);
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
            
            obj = KDTree(Intersection(), info, []);
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
