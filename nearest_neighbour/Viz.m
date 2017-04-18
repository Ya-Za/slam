classdef Viz < handle
    %Visualizer
    
    properties (Constant)
        delay = 0.01;
        color = struct(...
            'gray', [0.5, 0.5, 0.5], ...
            'lightGray', [0.8, 0.8, 0.8], ...
            'darkRed', [0.5, 0, 0], ...
            'darkGreen', [0, 0.5, 0], ...
            'darkBlue', [0, 0, 0.5] ...
        );
    end
    
    % Utils
    methods (Static)
        function h = figure(name)
            % Create `full screen` figure
            %
            % Parameters
            % ----------
            % - name: char vector = ''
            %   Name of figure
            %
            % Return
            % - h: matlab.ui.Figure

            % default values
            if ~exist('name', 'var')
                name = '';
            end
            
            h = figure(...
                'Name', name, ...
                'NumberTitle', 'off', ...
                'Units', 'normalized', ...
                'OuterPosition', [0, 0, 1, 1] ...
            );
        end
        
        function filenames = getFilenames(rootDir, format)
            % Get filenames with specified `format` in given `foler` 
            %
            % Parameters
            % ----------
            % - rootDir: char vector
            %   Target folder
            % - format: char vector = 'mat'
            %   File foramt
            
            % default values
            if ~exist('format', 'var')
                format = 'mat';
            end
            
            format = ['*.', format];
            filenames = dir(fullfile(rootDir, format));
            filenames = arrayfun(...
                @(x) fullfile(rootDir, x.name), ...
                filenames, ...
                'UniformOutput', false ...
            );
        end
        
        function subdirs = getSubdirs(rootDir)
            % Get sub directories
            % Parameters
            % ----------
            % - rootDir: char vector
            %   Root directory
            
            % `rootDir` is given
            subdirs = dir(rootDir);
            % remove `.` and `..`
            subdirs(1:2) = [];
            % select just directories not files
            subdirs = subdirs([obj.dirs.isdir]);
            % select name of directories
            subdirs = {subdirs.name};
        end
        
        % todo: output for all `method`
        function stackOfElapsedTimes = ...
                getStackOfElapsedTimes(filenames, methodName)
            % Get stack of `elapsed times` of a some 
            % random-walk samples for specified `methods`
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walks samples
            % - methodName: char vector
            %   Name of target method
            %
            % Returns
            % -------
            % - stackOfElapsedTimes = double matrix
            %   For each `elapsed times` vector there is a row
            
            numberOfFilenames = numel(filenames);
            stackOfElapsedTimes = [];
            
            for indexOfFilename = 1:numberOfFilenames
                filename = filenames{indexOfFilename};
                
                sample = load(filename);
                
                stackOfElapsedTimes = [...
                    stackOfElapsedTimes; ...
                    sample.output.(methodName).elapsedTimes ...
                ];
            end
        end
        
        function [meanElapsedTimes, stdElapsedTimes] = ...
                getAveragedElapsedTimes(filenames, methodName)
            % Get mean and std of `elapsed times` of a some 
            % random-walk samples for specified `methods`
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walks samples
            % - methodName: char vector
            %   Name of target method
            %
            % Returns
            % -------
            % - meanElapsedTimes = double vector
            %   Mean of elapsed times of specified method
            % - stdElapsedTimes = double vector
            %   Standard deviation of elapsed times of specified method
            
            stackOfElapsedTimes = ...
                Viz.getStackOfElapsedTimes(filenames, methodName);
            
            meanElapsedTimes = mean(stackOfElapsedTimes, 1);
            stdElapsedTimes = std(stackOfElapsedTimes, 1);
        end
        
        function matrixOfOutputs = getMatrixOfOutputs(filename, methodName)
            % Plot `outputs` of a specified `method`
            %
            % Parameters
            % ----------
            % - filename: char vector
            %   Filename of random-walks sample
            % - methodName: char vector
            %   Name of target method
            %
            % Returns
            % ------
            % - matrixOfOutputs = logical matrix
            %   Each entry shows if there is an intersection
            
            % load `outputs`
            sample = load(filename);
            outputs = sample.output.(methodName).outputs;
            numberOfPoints = numel(outputs);
            
            % crate `matrix of outputs`
            matrixOfOutputs = zeros(numberOfPoints, 'logical');
            for indexOfPoint = 1:numberOfPoints
                matrixOfOutputs(indexOfPoint, outputs{indexOfPoint}) = true;
            end
        end
        
        function lowerTriangleElements = getLowerTriangleElements(X)
            % Get lower triangle elements of a given square matrix
            %
            % Parameters
            % ----------
            % - X: double matrix
            %   Input matrix
            %
            % Returns
            % -------
            % - lowerTriangleElements: double vector
            %   Elements of lower trianle of given matrix
            
            lowerTriangleElements = X(tril(ones(size(X), 'logical')));
        end
        
        function confusionMatrix = getConfusionMatrix(filename, methodName)
            % Get `confusion matrix` of specified `method`
            %
            % Parameters
            % ----------
            % - filename: char vector
            %   Filename of random-walks sample
            % - methodName: char vector
            %   Name of target method
            %
            % Returns
            % ------
            % - confusionMatrix: int 2x2 matrix
            %   Confusion matrix. Groundtruth is `LNN` method
            
            % load `method`
            sample = load(filename);
            method = sample.output.(methodName);
            
            % check if `confusion matrix` is computed
            if isfield(method, 'confusionMatrix')
                confusionMatrix = method.confusionMatrix;
                return
            end
            
            % compute `computatin matrix`
            %   - load `matrix of outpus` of `LNN`
            lnnMatrixOfOutputs = ...
                Viz.getMatrixOfOutputs(filename, 'LNN');
            %   - load `matrix of outputs` of target `method`
            methodMatrixOfOutputs = ...
                Viz.getMatrixOfOutputs(filename, methodName);
            
            %   - confusion matrix
            confusionMatrix = confusionmat(...
                Viz.getLowerTriangleElements(lnnMatrixOfOutputs), ...
                Viz.getLowerTriangleElements(methodMatrixOfOutputs) ...
            );
        end
        
        function confusionMatrix = getOverallConfusionMatrix(filenames, methodName)
            % Get `confusion matrix` of specified `method`
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walks samples
            % - methodName: char vector
            %   Name of target method
            %
            % Returns
            % ------
            % - confusionMatrix: int 2x2 matrix
            %   Confusion matrix. Groundtruth is `LNN` method
            
            numberOfFilenames = numel(filenames);
            confusionMatrix = zeros(2);
            
            for indexOfFilename = 1:numberOfFilenames
                filename = filenames{indexOfFilename};
                confusionMatrix = ...
                    confusionMatrix + ...
                    Viz.getConfusionMatrix(filename, methodName);
            end
        end 
        
        % todo: I think it should be better to change the `Viz` to
        % non-static class because `filenames` are common between some
        % methods
        function addConfusionMatrixes(filenames)
            % Add `confusion matrixes` to samples
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walks samples
            
            numberOfFilenames = numel(filenames);

            for indexOfFilename = 1:numberOfFilenames
                filename = filenames{indexOfFilename};
                sample = load(filename);
                
                methodNames = fieldnames(sample.output);
                numberOfMethods = numel(methodNames);

                % for each `method`
                for indexOfMethodName = 1:numberOfMethods
                    methodName = methodNames{indexOfMethodName};

                    sample.output.(methodName).confusionMatrix = ...
                        Viz.getConfusionMatrix(filename, methodName);
                end
                
                % save sample
                save(filename, '-struct', 'sample');
            end
        end
        
        function [targetValues, outputValues] = ...
                getTargetOutputValues(confusionMatrix)
            % Get `target`, `output` values from `confusion matrix`
            %
            % Parameters
            % ----------
            % - confusionMatrix: int 2x2 matrix
            %   Confusion matrix. Groundtruth is `LNN` method
            
            numberOfPoints = sum(confusionMatrix(:));
            numberOfTrueZeros = sum(confusionMatrix(1, :));
            
            % target values
            targetValues = ones(1, numberOfPoints, 'logical');
            targetValues(1:numberOfTrueZeros) = false;
            
            % output values
            outputValues = ones(1, numberOfPoints, 'logical');
            % true negative
            outputValues(1:confusionMatrix(1, 1)) = false;
            % false negative
            outputValues(end + 1 - confusionMatrix(2, 1):end) = false;
        end
    end
    
    % Plots
    methods (Static)
        function plotPoint(point, color)
            % Plot one point
            %
            % Parameters
            % ----------
            % - point: double vector
            %   Input point
            % - color: color
            %   Point color

            scatter(point(1), point(2), ...
                'MarkerFaceColor', color, ...
                'MarkerEdgeColor', color ...
            );
        end

        function plotRandomWalk(points, maxDistance, showPoints)
            % Plot random walk
            %
            % Parameters
            % ----------
            % - points: double matrix
            %   [p1, p2, ...]
            % - maxDistance: double
            %   Maximum distance. Axes limits is [-maxDistance, maxDistance]
            % - showPoints: logical = true
            %   If show intermediate points
            
            if ~exist('showPoints', 'var')
                showPoints = true;
            end
            
            % Properties
            lineColor = Viz.color.lightGray;
            firstPointColor = Viz.color.darkRed;
            lastPointColor = Viz.color.darkBlue;
            pointsColor = Viz.color.gray;
            
            % plot
            x = points(1, :);
            y = points(2, :);
            %   - line
            line(...
                'XData', x, ...
                'YData', y, ...
                'Color', lineColor ...
            );
            hold('on');
            %   - scatter
            if showPoints
                scatter(...
                    x, y, ...
                    'MarkerFaceColor', pointsColor, ...
                    'MarkerEdgeColor', pointsColor ...
                );
            end
            %   - first point(at origin)
            Viz.plotPoint(points(:, 1), firstPointColor);
            %   - last point
            Viz.plotPoint(points(:, end), lastPointColor);
            hold('off');
            %   - config
            set(gca, ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [], ...
                'XTickLabel', [], ...
                'YTickLabel', [] ...
            );
            axis([...
                -maxDistance, maxDistance, ...
                -maxDistance, maxDistance ...
            ])
            axis('equal');
        end

        function plotSomeRandomWalks(filenames, maxNumberOfSamples)
            % Plot grid of random walks
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walks samples
            % - maxNumberOfSamples: int = 100
            %   Maximum number of sample reandom-walks
            
            % default values
            if ~exist('maxNumberOfSamples', 'var')
                maxNumberOfSamples = 100;
            end

            % figure
            Viz.figure('Plot Grid of Random-Walks');

            numberOfFilenames = min(...
                numel(filenames), ...
                maxNumberOfSamples ...
            );
            rows = ceil(sqrt(numberOfFilenames));
            cols = rows;
            
            for indexOfFilename = 1:numberOfFilenames
                filename = filenames{indexOfFilename};
                sample = load(filename);
                points = sample.input.points;
                maxDistance = sample.input.config.maxDistance;
                
                subplot(rows, cols, indexOfFilename);
                Viz.plotRandomWalk(points, maxDistance, false);
            end
        end

        function animateRandomWalk(filename)
            % Animate random walk
            %
            % Parameters
            % ----------
            % - filename: char vector
            %   Filename of random-walks sample

            % figure
            Viz.figure(['Animate Random-Walk: ', filename]);
            
            sample = load(filename);
            points = sample.input.points;
            numberOfPoints = size(points, 2);
            maxDistance = sample.input.config.maxDistance;
            
            for indexOfPoint = 1:numberOfPoints
                Viz.plotRandomWalk(...
                    points(:, 1:indexOfPoint), ...
                    maxDistance ...
                );
                
                pause(Viz.delay);
            end
        end
        
        function plotTimeOfRandomWalk(filename)
            % Plot `elapsed times` of a random-walk sample for all
            % `methods`
            %
            % Parameters
            % ----------
            % - filename: char vector
            %   Filename of random-walks sample
            
            % properties
            lineWidth = 2;
            
            % figure
            Viz.figure(['Elapsed Times: ', filename]);
            
            % load
            sample = load(filename);
            methodNames = fieldnames(sample.output);
            numberOfMethods = numel(methodNames);
            
            % for each `method`
            for indexOfMethodName = 1:numberOfMethods
                methodName = methodNames{indexOfMethodName};
                elapsedTimes = sample.output.(methodName).elapsedTimes;
                
                plot(...
                    elapsedTimes, ...
                    'DisplayName', methodName, ...
                    'LineWidth', lineWidth ...
                );
            end
            
            % config plot
            legend('show');
            grid('on');
            grid('minor');
        end
        
        % todo: rename `plotTime` to `plotElapsedTimes`
        function plotTimeOfSomeRandomWalks(filenames, showErrorBars)
            % Plot averaged `elapsed times` with error bar of a some 
            % random-walk samples for all `methods`
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walks samples
            % - showErrorBars: logical = false
            %   Show erorr bars or not
            
            % default values
            if ~exist('showErrorBars', 'var')
                showErrorBars = false;
            end
            
            % properties
            lineWidth = 1;
            
            % figure
            Viz.figure('Averaged Elapsed Times');

            % method names
            sample = load(filenames{1});
            methodNames = fieldnames(sample.output);
            numberOfMethods = numel(methodNames);
            
            % for each `method`
            hold('on');
            for indexOfMethodName = 1:numberOfMethods
                methodName = methodNames{indexOfMethodName};
                [meanElapsedTimes, stdElapsedTimes] = ...
                    Viz.getAveragedElapsedTimes(filenames, methodName);
                
                if showErrorBars
                    errorbar(...
                        meanElapsedTimes, stdElapsedTimes, ...
                        'DisplayName', methodName, ...
                        'LineWidth', lineWidth ...
                    );
                else
                    plot(...
                        meanElapsedTimes, ...
                        'DisplayName', methodName, ...
                        'LineWidth', lineWidth ...
                    );
                end
            end
            hold('off');
            
            % config plot
            legend('show');
            grid('on');
            grid('minor');
        end
        
        % todo: rename `plotBox` to `boxPlot`
        function plotBoxOfElapsedTimes(filenames)
            % Box plot of `elapsed times` of a some 
            % random-walk samples for all `methods`
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walks samples
            
            % figure
            Viz.figure('Box Plot of Elapsed-Times');
            
            % method names
            % todo: [methodNames, numberOfMethos] = function
            % getMethodNames(filename)
            sample = load(filenames{1});
            methodNames = fieldnames(sample.output);
            numberOfMethods = numel(methodNames);
            
            for indexOfMethodName = 1:numberOfMethods
                methodName = methodNames{indexOfMethodName};
                
                stackOfElapsedTimes = Viz.getStackOfElapsedTimes(filenames, methodName);
                
                subplot(numberOfMethods, 1, indexOfMethodName);
                boxplot(...
                    stackOfElapsedTimes', ...
                    'PlotStyle', 'traditional' ...
                );
                title(methodName);
                ylabel('Time (sec)');
                grid('on');
                grid('minor');
            end
        end
        
        % todo: rename `plotBox` to `boxPlot`
        function plotBoxOfOverallElapsedTimes(filenames)
            % Box plot of overall `elapsed times` of a some 
            % random-walk samples for all `methods`
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walks samples
            
            % figure
            Viz.figure('Box Plot of Overall Elapsed-Times');
            
            % method names
            % todo: [methodNames, numberOfMethos] = function
            % getMethodNames(filename)
            sample = load(filenames{1});
            methodNames = fieldnames(sample.output);
            numberOfMethods = numel(methodNames);
            
            overall = [];
            for indexOfMethodName = 1:numberOfMethods
                methodName = methodNames{indexOfMethodName};
                
                stackOfElapsedTimes = Viz.getStackOfElapsedTimes(filenames, methodName);
                overall = [overall, stackOfElapsedTimes(:)];
            end
            
            % box plot
            boxplot(...
                overall, ...
                'Labels', methodNames, ...
                'PlotStyle', 'traditional' ...
            );
            title('Elapsed Times');
            ylabel('Time (sec)');
            grid('on');
            grid('minor');
        end
        
        function plotOutputsOfMethod(filenames, methodName, maxNumberOfSamples)
            % Plot `outputs` of a specified `method`
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walks samples
            % - methodName: char vector
            %   Name of target method
            % - maxNumberOfSamples: int = 100
            %   Maximum number of sample reandom-walks

            % default values
            if ~exist('maxNumberOfSamples', 'var')
                maxNumberOfSamples = 100;
            end

            % figure
            Viz.figure(['Outputs of ', methodName]);
            
            numberOfFilenames = min(...
                numel(filenames), ...
                maxNumberOfSamples ...
            );
            rows = ceil(sqrt(numberOfFilenames));
            cols = rows;
            
            for indexOfFilename = 1:numberOfFilenames
                filename = filenames{indexOfFilename};
            
                % matrix of outputs
                matrixOfOutputs = ...
                    Viz.getMatrixOfOutputs(filename, methodName);

                % show image
                subplot(rows, cols, indexOfFilename);
                imagesc(matrixOfOutputs);
                % colormap('hot');
                axis('equal');
                axis('off');
            end
        end
        
        function plotErrorMatrixOfMethod(filename, methodName)
            % Plot `error matrix` of a specified `method`
            %
            % Parameters
            % ----------
            % - filename: char vector
            %   Filename of random-walks sample
            % - methodName: char vector
            %   Name of target method

            % figure
            Viz.figure(sprintf(...
                'Error Matrix of Method - %s: %s', ...
                methodName, ...
                filename ...
            ));
            
            % error matrix
            errorMatrix = ...
                Viz.getMatrixOfOutputs(filename, 'LNN') - ...
                Viz.getMatrixOfOutputs(filename, methodName);
            
            % show image
            % imshow(matrixOfOutputs);
            imagesc(errorMatrix);
            colormap('hot');
            axis('equal');
            axis('off');
        end
        
        function plotConfusionMatrixOfMethods(filenames)
            % Plot `confusion matrix` for each `method`
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walks samples
            
            % load method names
            sample = load(filenames{1});
            methodNames = fieldnames(sample.output);
            numberOfMethods = numel(methodNames);
            
            % `target`, `output`, `name` array
            data = {};
            for indexOfMethodName = 1:numberOfMethods
                methodName = methodNames{indexOfMethodName};
                confusionMatrix = ...
                    Viz.getOverallConfusionMatrix(filenames, methodName);
                
                % `targe` and `output` values
                [targetValues, outputValues] = ...
                    Viz.getTargetOutputValues(confusionMatrix);
                
                data{end + 1} = targetValues;
                data{end + 1} = outputValues;
                data{end + 1} = methodName;
            end
            
            % plot
            plotconfusion(data{:});
        end
    end
    
    % Save
    methods (Static)
        function saveResults(rootDir)
            % Make `results` folder in `roodDir` folder and save some
            % `results` in it
            %
            % Parameters
            % ----------
            % - rootDir: char vector
            %   Path of input directory
            
            % `results` folder
            outDir = fullfile(rootDir, 'results');
            if ~exist(outDir, 'dir')
                mkdir(outDir);
            end
            
            % filenames
            filenames = Viz.getFilenames(rootDir);
            
            % random-walks
            Viz.plotSomeRandomWalks(filenames);
            savefig(fullfile(outDir, 'random_walks'));
            
            % elapsed-times
            Viz.plotTimeOfSomeRandomWalks(filenames);
            savefig(fullfile(outDir, 'elapsed_times'));
            
            % box-plot of ellapsed-times
            Viz.plotBoxOfElapsedTimes(filenames);
            savefig(fullfile(outDir, 'box_plot_elapsed_times'));
            
            % overall box-plot of ellapsed-times
            Viz.plotBoxOfOverallElapsedTimes(filenames);
            savefig(fullfile(outDir, 'box_plot_overall_elapsed_times'));
            
            % outputs matrices of `LNN`
            Viz.plotOutputsOfMethod(filenames, 'LNN');
            savefig(fullfile(outDir, 'outputs_matrices_lnn'));
            
            % confusion-matrices
            Viz.plotConfusionMatrixOfMethods(filenames);
            savefig(fullfile(outDir, 'confusion_matrices'));
        end
    end

    % Unit test
    methods (Static)
        function test()
            % Test methods of `Viz` class
            runtests('./tests/TestViz.m');
        end
    end
    
end

