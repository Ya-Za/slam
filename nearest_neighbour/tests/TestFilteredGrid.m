classdef TestFilteredGrid < matlab.unittest.TestCase
    methods (Test)
        function testQuery(testCase)
            % arrange
            point = [0; 0];
            points = {[1; 1], [-1; 1], [2; 2], [-2; 2]};
            
            maxDistance = 10;
            numberOfDimensions = 2;
            gridResolution = 4;
            
            info = struct(...
                'numberOfDimensions', numberOfDimensions, ...
                'maxDistance', maxDistance ...
            );
            params = struct('gridResolution', gridResolution);
            
            obj = FilteredGrid(Intersection(), info, params);
            for i = 1:length(points)
                obj.query(points{i});
            end
            
            expected = [2, 1];
            % act
            actual = obj.query(point);
            % assert
            testCase.assertEqual(actual, expected);
        end
    end
end
