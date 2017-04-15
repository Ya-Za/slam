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
        function test_figure(testCase)
            % arrange
            name = 'Test: Viz.figure';

            % act
            h = Viz.figure(name);
            
            % assert
            testCase.assertEqual(h.Name, name);
        end

        function test_plotPoint(testCase)
            % arrange
            point = [0, 0];
            color = 'red';
            
            % act
            Viz.figure('Test: Viz.plotPoint');
            Viz.plotPoint(point, color);
            
            % assert
            testCase.assertTrue(true);
        end

        function test_plotRandomWalk(testCase)
            % arrange
            filename = './data/1.mat';
            sample = load(filename);
            points = sample.input.points;
            maxDistance = sample.input.config.maxDistance;

            % act
            Viz.figure('Test: plotRandomWalk');
            Viz.plotRandomWalk(points, maxDistance);
            
            % assert
            testCase.assertTrue(true);
        end
        
        function test_plotSomeRandomWalks(testCase)
            % arrange
            filenames = dir('./data/*.mat');
            filenames = arrayfun(...
                @(x) fullfile(x.folder, x.name), ...
                filenames, ...
                'UniformOutput', false ...
            );
        
            % act
            Viz.plotSomeRandomWalks(filenames);
            
            % assert
            testCase.assertTrue(true);
        end

        function test_animateRandomWalk(testCase)
            % arrange
            filename = './data/1.mat';
            
            % act
            Viz.animateRandomWalk(filename);
            
            % assert
            testCase.assertTrue(true);
        end
    end
    
end
