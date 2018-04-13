classdef TestLNN < matlab.unittest.TestCase
    methods (Test)
        function testQuery(testCase)
            % arrange
            point = [0; 0];
            points = {[1; 1], [-1; 1], [2; 2], [-2; 2]};
            
            obj = LNN(Intersection(), []);
            for i = 1:length(points)
                obj.query(points{i});
            end
            
            expected = [1, 2];
            % act
            actual = obj.query(point);
            % assert
            testCase.assertEqual(actual, expected);
        end
    end
end
