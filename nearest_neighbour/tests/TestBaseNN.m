classdef TestBaseNN < matlab.unittest.TestCase
    methods (Test)
        function testAddPointToPoints(testCase)
            % arrange
            points = {[0; 0], [1; 1]};
            obj = BaseNN([], []);
            for i = 1:length(points)
                obj.addPointToPoints(points{i});
            end
            
            expected = points;
            % act
            actual = obj.points;
            % assert
            testCase.assertEqual(actual, expected);
        end
        function testFilter(testCase)
            % arrange
            point = [0; 0];
            candidates = [1, 2, 4];
            points = {[0; 0], [1; 1], [-1; 1], [2; 2], [-2; 2]};
            
            obj = BaseNN(Intersection(), []);
            for i = 1:length(points)
                obj.addPointToPoints(points{i});
            end
            
            expected = [1, 2];
            % act
            actual = obj.filter(point, candidates);
            % assert
            testCase.assertEqual(actual, expected);
        end
    end
end
