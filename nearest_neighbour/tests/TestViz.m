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
        % todo: put to `methods (Test)` with tag `Utils`
        function test_figure(testCase)
            % arrange
            name = 'Test: Viz.figure';

            % act
            h = Viz.figure(name);
            
            % assert
            testCase.assertEqual(h.Name, name);
        end
        
        function test_getFilenames(testCase)
            % arrange
            folder = './data';

            % act
            actualValue = Viz.getFilenames(folder);
            
            % assert
            expectedValue = arrayfun(...
                @(x) fullfile(x.folder, x.name), ...
                dir(fullfile(folder, '*.mat')), ...
                'UniformOutput', false ...
            );
            
            testCase.assertEqual(actualValue, expectedValue);
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
        
        function test_plotTimeOfRandomWalk(testCase)
            % arrange
            filename = './data/1.mat';
            
            % act
            Viz.plotTimeOfRandomWalk(filename);
            
            % assert
            testCase.assertTrue(true);
        end
        
        function test_getAveragedElapsedTimes(testCase)
            % arrange
            % filenames = Viz.getFilenames('./data');
        
            % act
            % todo: write `act`
            
            % assert
            testCase.assertTrue(true);
        end
        
        function test_plotTimeOfSomeRandomWalks(testCase)
            % arrange
            filenames = Viz.getFilenames('./data');
        
            % act
            Viz.plotTimeOfSomeRandomWalks(filenames);
            
            % assert
            testCase.assertTrue(true);
        end
        
        function test_plotBoxOfElapsedTimes(testCase)
            % arrange
            filenames = Viz.getFilenames('./data');
        
            % act
            Viz.plotBoxOfElapsedTimes(filenames);
            
            % assert
            testCase.assertTrue(true);
        end
        
        function test_plotBoxOfOverallElapsedTimes(testCase)
            % arrange
            filenames = Viz.getFilenames('./data');
        
            % act
            Viz.plotBoxOfOverallElapsedTimes(filenames);
            
            % assert
            testCase.assertTrue(true);
        end
        
        function test_plotOutputsOfMethod(testCase)
            % arrange
            filenames = Viz.getFilenames('./data');
            methodName = 'LNN';
        
            % act
            Viz.plotOutputsOfMethod(filenames, methodName);
            
            % assert
            testCase.assertTrue(true);
        end
        
        function test_addConfusionMatrixes(testCase)
            % arrange
            filenames = Viz.getFilenames('./data');
        
            % act
            Viz.addConfusionMatrixes(filenames);
            
            % assert
            testCase.assertTrue(true);
        end
        
        function test_getTargetOutputValues(testCase)
            % arrange
            confusionMatrix = [1, 2; 3, 4];
            expectedTargetValues = logical([0, 0, 0, 0, 1, 1, 1, 1, 1, 1])';
            expectedOutputValues = logical([0, 1, 1, 1, 1, 1, 1, 1, 0, 0])';
        
            % act
            [actualTargetValues, actualOutputValues] = ...
                Viz.getTargetOutputValues(confusionMatrix);
            
            % assert
            testCase.assertEqual(expectedTargetValues, actualTargetValues);
            testCase.assertEqual(expectedOutputValues, actualOutputValues);
        end
        
        function test_plotConfusionMatrixOfMethods(testCase)
            % arrange
            % filenames = Viz.getFilenames('./data');
            filenames = {'./data/3.mat'};
        
            % act
            Viz.plotConfusionMatrixOfMethods(filenames);
            
            % assert
            testCase.assertTrue(true);
        end
        
        function test_plotErrorMatrixOfMethod(testCase)
            % arrange
            filename = './data/3.mat';
            methodName = 'Grid';
        
            % act
            Viz.plotErrorMatrixOfMethod(filename, methodName);
            
            % assert
            testCase.assertTrue(true);
        end
        
        function test_saveResults(testCase)
            % arrange
            rootDir = './data';
        
            % act
            Viz.saveResults(rootDir);
            
            % assert
            testCase.assertTrue(true);
        end
    end
    
end
