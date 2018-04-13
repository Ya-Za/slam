classdef TestIntersection < matlab.unittest.TestCase
    methods (Test)
        function testDefaultConstructor(testCase)
            % arrange
            obj = Intersection();
            
            expected = 1;
            % act
            actual = obj.radius;
            % assert
            testCase.assertEqual(actual, expected);
        end
        function testConstructor(testCase)
            % arrange
            radius = 2;
            obj = Intersection(radius);
            
            expected = radius;
            % act
            actual = obj.radius;
            % assert
            testCase.assertEqual(actual, expected);
        end
        function testHaveIntersection(testCase)
            % arrange
            radius = 1;
            obj = Intersection(radius);
            expected = [true, false];
            % act
            actual = [
                obj.haveIntersection([0; 0], [1; 1]), ...
                obj.haveIntersection([0; 0], [2; 2]) ...
            ];
                
            % assert
            testCase.assertEqual(actual, expected);
        end
    end
end
