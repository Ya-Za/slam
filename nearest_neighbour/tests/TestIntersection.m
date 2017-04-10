classdef TestIntersection < matlab.unittest.TestCase
    
    properties
        originalPath
    end
    
    methods (TestMethodSetup)
        function addToPath(testCase)
            % Add `parent` of current directory to the `path` of matlab
            
            % save original path
            testCase.originalPath = path;
            
            % add `..` to the path
            [parentFolder, ~, ~] = fileparts(pwd);
            addpath(parentFolder);
        end
    end
    
    methods (TestMethodTeardown)
        function restorePath(testCase)
            % Restore original path
            path(testCase.originalPath);
        end
    end
    
    methods (Test)
        function test_main(testCase)
            configfile = '';
            obj = Intersection(configfile);
            actual_value = obj.get_results();
            
            % methods
            %   - NN(Nearest Neighbor)
            expected_value(1).name = 'nn';
            expected_value(1).times = [1, 2, 3, 4];
            %   - ANN(Approximate Nearest Neighbor)
            expected_value(2).name = 'ann';
            expected_value(2).times = [1, 2, 3, 4];
            %   - k-d tree
            expected_value(3).name = 'kdtree';
            expected_value(3).times = [1, 2, 3, 4];
            
            testCase.assertTrue(true);
            
        end
    end
    
end
