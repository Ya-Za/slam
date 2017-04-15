classdef TestViz < matlab.unittest.TestCase
    
    properties
        originalPath
    end
    
    % todo: Add `Setup` and `Teardown` to a `TestBase` class
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
        function test_plotRandomWalk(testCase)
            % arrange
            filename = './data/1.mat';
            sample = load(filename);
            points = sample.input.points;
            maxDistance = sample.input.config.maxDistance;

            % act
            Viz.plotRandomWalk(points, maxDistance);
            
            % assert
            testCase.assertTrue(true);
        end
    end
    
end
