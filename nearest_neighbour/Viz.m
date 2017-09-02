classdef Viz < handle
    %Visualizer
    
    properties (Constant)
        delay = 0.01;
        color = struct(...
            'gray1', [0.1, 0.1, 0.1], ...
            'gray2', [0.2, 0.2, 0.2], ...
            'gray3', [0.3, 0.3, 0.3], ...
            'gray4', [0.4, 0.4, 0.4], ...
            'gray5', [0.5, 0.5, 0.5], ...
            'gray6', [0.6, 0.6, 0.6], ...
            'gray7', [0.7, 0.7, 0.7], ...
            'gray8', [0.8, 0.8, 0.8], ...
            'gray9', [0.9, 0.9, 0.9], ...
            'lightGray', [0.8, 0.8, 0.8], ...
            'gray', [0.5, 0.5, 0.5], ...
            'lightRed', [0.8, 0, 0], ...
            'darkRed', [0.5, 0, 0], ...
            'lightGreen', [0, 0.8, 0], ...
            'darkGreen', [0, 0.5, 0], ...
            'lightBlue', [0, 0, 0.8], ...
            'darkBlue', [0, 0, 0.5] ...
        );
        fontSize = struct(...
            'axis', 14, ...
            'label', 16, ...
            'legend', 16 ...
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
        
        function setLatexInterpreter(ax)
            % Set interpreter to `latex`
            %
            % Parameters
            % ----------
            % - ax: Axes = gca
            % Input `axes`
            
            % default
            if ~exist('ax', 'var')
                ax = gca;
            end
            
            ax.TickLabelInterpreter = 'latex';
            ax.XLabel.Interpreter = 'latex';
            ax.YLabel.Interpreter = 'latex';
            ax.ZLabel.Interpreter = 'latex';
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
            %   Filenames of random-walk samples
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
            %   Filenames of random-walk samples
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
            
            % compute `confusion matrix`
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
            %   Filenames of random-walk samples
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
            %   Filenames of random-walk samples
            
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

            % number of dimensions
            d = size(point, 1);
            
            if d == 2
                scatter(point(1), point(2), ...
                    'MarkerFaceColor', color, ...
                    'MarkerEdgeColor', color ...
                );
            elseif d == 3
                scatter3(point(1), point(2), point(3), ...
                    'MarkerFaceColor', color, ...
                    'MarkerEdgeColor', color ...
                );
            end
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
            
            % number of dimensions
            d = size(points, 1);
            if d > 3
                return
            end
            if d == 1
                points = [...
                    0:(size(points, 2) - 1); ...
                    points(1, :) ...
                ];
            end
            
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
            if d == 3
                z = points(3, :);
            end
            %   - line
            if d < 3
                line(...
                    'XData', x, ...
                    'YData', y, ...
                    'Color', lineColor ...
                );
            else
                line(...
                    'XData', x, ...
                    'YData', y, ...
                    'ZData', z, ...
                    'Color', lineColor ...
                );
                view(3);
            end
            hold('on');
            %   - scatter
            if showPoints
                if d < 3
                    scatter(...
                        x, y, ...
                        'MarkerFaceColor', pointsColor, ...
                        'MarkerEdgeColor', pointsColor ...
                    );
                else
                    scatter3(...
                        x, y, z, ...
                        'MarkerFaceColor', pointsColor, ...
                        'MarkerEdgeColor', pointsColor ...
                    );
                end
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
                'XLim', [-maxDistance, maxDistance], ...
                'YLim', [-maxDistance, maxDistance] ...
            );
            
            % three-dimensional
            if d == 3
                set(gca, ...
                    'ZTick', [], ...
                    'ZLim', [-maxDistance, maxDistance] ...
                );
            end
            
            axis('square');
        end

        function plotRandomWalkFromFile(filename)
            % Plot random-walk from file
            %
            % Parameters
            % ----------
            % - filename: char vector
            %   Filename of random-walk sample
            
            sample = load(filename);
            points = sample.input.points;
            maxDistance = sample.input.config.maxDistance;

            Viz.plotRandomWalk(points, maxDistance, false);
        end
        
        function plotSomeRandomWalks(filenames, maxNumberOfSamples)
            % Plot grid of random walks
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walk samples
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
                
                subplot(rows, cols, indexOfFilename);
                Viz.plotRandomWalkFromFile(filename);
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
            %   Filenames of random-walk samples
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
                    % cumulative time
                    meanElapsedTimes = cumsum(meanElapsedTimes);
                    plot(...
                        meanElapsedTimes, ...
                        'DisplayName', methodName, ...
                        'LineWidth', lineWidth ...
                    );
                    set(gca, 'YScale', 'log');
                end
            end
            hold('off');
            
            % config plot
            legend('show');
            xlabel('Number of query points');
            ylabel('Elapsed time (sec)');
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
            %   Filenames of random-walk samples
            
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
            %   Filenames of random-walk samples
            
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
        
        function plotOutputOfMethod(filename, methodName)
            % Plot `outputs` of a specified `method`
            %
            % Parameters
            % ----------
            % - filename: char vector
            %   Filename of random-walk sample
            % - methodName: char vector
            %   Name of target method
            
            % matrix of outputs
            matrixOfOutputs = ...
                Viz.getMatrixOfOutputs(filename, methodName);

            imagesc(matrixOfOutputs);
            % colormap('hot');
            axis('square');
            axis('off'); 
        end
        
        function plotOutputsOfMethod(filenames, methodName, maxNumberOfSamples)
            % Plot `outputs` of a specified `method`
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walk samples
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
                % show image
                subplot(rows, cols, indexOfFilename);
                Viz.plotOutputOfMethod(filename, methodName);
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
            %   Filenames of random-walk samples
            
            % figure
            figure();
            
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
        
        function configTable = getConfigTable(filename)
            % Get table of `configuration`
            %
            % Parameters
            % ----------
            % - filename: char vector
            %   Filename of `config` file
            %
            % Returns
            % -------
            % - configTable: table
            %   Table of configuration
            
            % load
            config = load(filename);

            params = {...
                'Max Distance'; ...
                'Standard Deviation'; ...
                'Number of Dimensions'; ...
                'Number of Samples'; ...
                'Number of Points' ...
            };
        
            values = [...
                config.maxDistance; ...
                config.std; ...
                config.numberOfDimensions; ...
                config.numberOfSamples; ...
                config.numberOfPoints ...
            ];
        
            configTable = table(...
                params, ...
                values, ...
                'VariableNames', {'Params', 'Values'} ...
            );
        
            configTable.Properties.Description = 'Config';
        end
        
        function elapsedTimesTable = getelapsedTimesTable(filenames)
            % Get table of `configuration`
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walk samples
            %
            % Returns
            % -------
            % - elapsedTimesTable: table
            %   Table of elapsed-times (sec) [mean, std]
            
            % load method names
            sample = load(filenames{1});
            methodNames = fieldnames(sample.output);
            numberOfMethods = numel(methodNames);
            
            % `target`, `output`, `name` array
            elapsedTimes = zeros(numberOfMethods, 2);
            for indexOfMethodName = 1:numberOfMethods
                methodName = methodNames{indexOfMethodName};
                [meanElapsedTimes, stdElapsedTimes] = ...
                    Viz.getAveragedElapsedTimes(filenames, methodName);
                
                elapsedTimes(indexOfMethodName, :) = ...
                    [sum(meanElapsedTimes), sum(stdElapsedTimes)];
            end
            
            % load
            elapsedTimesTable = table(...
                methodNames, ...
                elapsedTimes, ...
                'VariableNames', {'Method', 'Elapsed_Times'} ...
            );
        
            elapsedTimesTable.Properties.Description = 'Elapsed-Times';
        end
    end
    
    % Geometry
    methods (Static)
        function [x, y, z] = sphere(center, radius)
            % Sphere with given `center` and `radius`
            %
            % Parameters
            % - center: 3-by-1 double vector
            %   Center of sphere
            % - radius: double
            %   Radius of sphere
            %
            % Returns
            % -------
            % - [x, y, z]: [20-by-20, 20-by-20, 20-by-20]
            %   x-, y-, and z-coordinates of a unit sphere for use with
            %   surf and mesh
            
            [x, y, z] = sphere(20);
            x = radius * x + center(1);
            y = radius * y + center(2);
            z = radius * z + center(3);
        end
        
        function plotLine(p1, p2, color, lineWidth, lineStyle)
            % Plot a 3d line between `p1` and `p2`
            
            p = [p1, p2];
            line(...
                'XData', p(1, :), ...
                'YData', p(2, :), ...
                'ZData', p(3, :), ...
                'Color', color, ...
                'LineWidth', lineWidth, ...
                'LineStyle', lineStyle ...
            );
        end
        
        function plotVector(p1, p2, color, lineWidth, lineStyle)
            % Plot a 3d vector between `p1` and `p2`
            
            u = p2 - p1;
            quiver3(...
                p1(1, :), p1(2, :), p1(3, :), ...
                u(1, :), u(2, :), u(3, :), ...
                'MaxHeadSize', 0.15, ...
                'Color', color, ...
                'LineWidth', lineWidth, ...
                'LineStyle', lineStyle ...
            );
        end
        
        function points = cube(s, t)
            % Generate a cube and `scale` and `translate` it
            %
            % Parameters
            % ----------
            % - s: double = 1
            %   Scale factor
            % - t: 3-by-1 double vector = [0, 0, 0]
            %   Movement distance for `x`, `y` and `z`
            %
            % Returns
            % -------
            % - points: 3-by-3 double matrix
            %   Constructing points of cube
            
            % default values
            if ~exist('s', 'var')
                s = 1;
            end
            if ~exist('t', 'var')
                t = [0, 0, 0]';
            end
            
            % unit cube
            points = [
                0 0 0
                1 0 0
                1 0 1
                0 0 1
                0 1 0
                1 1 0
                1 1 1
                0 1 1
            ]';
            % scale
            points = s * points;
            % translate
            points = points + t;
            
            % transpose
            points = points';
        end
    end
    
    % Paper: GridNN
    methods (Static)
        % fig:rw
        function plotClassifiedRandomWalk(points)
            % Plot classified random walk based on range search
            %
            % Parameters
            % ----------
            % - points: 2-by-n double matrix
            %   [p1, p2, ...]
            
            % default values
            if ~exist('points', 'var')
                points = load(...
                    './assets/data/paper/gridnn/fig_rw.mat', ...
                    'points' ...
                );
                points = points.points;
            end
            
            % Properties
            radius = 1;
            
            circleLineStyle = '--';
            
            lineColor = Viz.color.lightGray;
            positivePointsColor = Viz.color.darkRed;
            negativePointsColor = Viz.color.darkBlue;
            lastPointColor = Viz.color.lightRed;
            circleColor = Viz.color.lightRed;
            
            firstPointMarker = 's';
            lastPointMarker = '*';
            negativePointsMarker = 'o';
            positivePointsMarker = 'o';
            
            firstPointArea = 144;
            lastPointArea = 144;
            negativePointsArea = 100;
            positivePointsArea = 100;
            
            % figure
            Viz.figure('Classified Random Walks (fig:rw)');

            % line plot
            x = points(1, :);
            y = points(2, :);
            %   - line
            line(...
                'XData', x, ...
                'YData', y, ...
                'Color', lineColor ...
            );
            hold('on');
            
            % cluster points
            % - first point
            firstPoint = points(:, 1);
            % - last point
            lastPoint = points(:, end);
            % - positive and negative points
            points(:, [1, end]) = [];
            numberOfPoints = size(points, 2);
            positivePointIndexes = zeros(1, numberOfPoints, 'logical');
            for indexOfPoint = 1:numberOfPoints
                point = points(:, indexOfPoint);
                if norm(lastPoint - point) <= radius
                    positivePointIndexes(indexOfPoint) = true;
                end
            end
            positivePoints = points(:, positivePointIndexes);
            % - negative points
            negativePoints = points(:, ~positivePointIndexes);
            
            % scatter plot
            % - negative points
            plotPoints(...
                negativePoints, ...
                negativePointsMarker, ...
                negativePointsArea, ...
                negativePointsColor ...
            );
            % - positive points
            plotPoints(...
                positivePoints, ...
                positivePointsMarker, ...
                positivePointsArea, ...
                positivePointsColor ...
            );
            % - first point(at origin)
            firstPointColor = negativePointsColor;
            if norm(lastPoint - firstPoint) <= radius
                firstPointColor = positivePointsColor;
            end
            plotPoints(...
                firstPoint, ...
                firstPointMarker, ...
                firstPointArea, ...
                firstPointColor ...
            );
            % - last point
            plotPoints(...
                lastPoint, ...
                lastPointMarker, ...
                lastPointArea, ...
                lastPointColor ...
            );
            % - circle
            plotCircle(lastPoint, radius, circleColor, circleLineStyle);

            hold('off');
            %   - config
            set(gca, ...
                'Visible', 'off', ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [] ...
            );
            axis('tight');
            axis('equal');
            
            % Local Functions
            function plotPoints(points, marker, markerArea, color)
                scatter(...
                    points(1, :), points(2, :), markerArea, ...
                    'Marker', marker, ...
                    'MarkerFaceColor', color, ...
                    'MarkerEdgeColor', color ...
                );
            end
            function plotCircle(center, radius, edgeColor, lineStyle)
                topLeft = [...
                    center(1) - radius, ...
                    center(2) - radius, ...
                    2 * radius, ...
                    2 * radius ...
                ];
                rectangle(...
                    'Position', topLeft, ...
                    'Curvature',[1 1], ...
                    'EdgeColor', edgeColor, ...
                    'LineStyle', lineStyle ...
                );
            end
            
        end
        
        function plotGrid(n, s, t)
            % Plot scaled and translated n-by-n grid
            %
            % Parameters
            % ----------
            % - n: int
            %   n-by-n grid
            % - s: double = 1
            %   Scale factor
            % - t: 3-by-1 double vector = [0, 0, 0]
            %   Movement distance for `x`, `y` and `z`
            
            % default values
            if ~exist('s', 'var')
                s = 1;
            end
            if ~exist('t', 'var')
                t = [0, 0, 0]';
            end
            
            % Parameters
            color = Viz.color.gray7;
            lineWidth = 1;
            lineStyle = '--';
            
            z = t(3);
            % horizontal lines
            x0 = t(1);
            x1 = x0 + n * s;
            y0 = t(2);
            for i = 0:n
                y = y0 + i * s;
                p0 = [x0, y, z]';
                p1 = [x1, y, z]';
                Viz.plotLine(p0, p1, color, lineWidth, lineStyle);
            end
            % vertical lines
            x0 = t(1);
            y0 = t(2);
            y1 = y0 + n * s;
            for i = 0:n
                x = x0 + i * s;
                p0 = [x, y0, z]';
                p1 = [x, y1, z]';
                Viz.plotLine(p0, p1, color, lineWidth, lineStyle);
            end
        end
        
        function points = plotCube(color, s, t)
            % default values
            if ~exist('s', 'var')
                s = 1;
            end
            if ~exist('t', 'var')
                t = [0, 0, 0]';
            end

            points = Viz.cube(s, t);
            faces = [
                1, 2, 3, 4 % front
                5, 6, 7, 8 % back
                1, 2, 6, 5 % bottom
                2, 6, 7, 3 % right
                4, 3, 7, 8 % top
                1, 4, 8, 5 % left
            ];
            patch(...
                'Vertices', points, ...
                'Faces', faces, ...
                'LineWidth', 1.5, ...
                'EdgeColor', 'none', ...
                'EdgeAlpha', 1, ...
                'FaceColor', color, ...
                'FaceAlpha', 0.1 ...
            );
            lineWidth = 2.5;
            lineStyle = '--';
            Viz.plotLine(points(1, :)', points(2, :)', color, lineWidth, '-');
            Viz.plotLine(points(2, :)', points(6, :)', color, lineWidth, lineStyle);
            Viz.plotLine(points(6, :)', points(5, :)', color, lineWidth, lineStyle);
            Viz.plotLine(points(5, :)', points(1, :)', color, lineWidth, '-');
            
            Viz.plotLine(points(4, :)', points(3, :)', color, lineWidth, '-');
            Viz.plotLine(points(3, :)', points(7, :)', color, lineWidth, '-');
            Viz.plotLine(points(7, :)', points(8, :)', color, lineWidth, '-');
            Viz.plotLine(points(8, :)', points(4, :)', color, lineWidth, '-');
            
            Viz.plotLine(points(1, :)', points(4, :)', color, lineWidth, '-');
            Viz.plotLine(points(2, :)', points(3, :)', color, lineWidth, '-');
            Viz.plotLine(points(6, :)', points(7, :)', color, lineWidth, lineStyle);
            Viz.plotLine(points(5, :)', points(8, :)', color, lineWidth, '-');
        end
        
        function plotCubeWithVertices()
            % Plot a unit cube with its vertices
            
            % Parameters
            
            
            % Plot
            Viz.figure('3D Neighburs');
            hold('on');
            % - grid
            Viz.plotGrid(3, 1, [-1, -1, 0]');
            % - cube
            points = Viz.plotCube([0.04, 0.5, 0.04]);
            % - points
            scatter3(points(:, 1), points(:, 2), points(:, 3), 49, ...
                'MarkerFaceColor', [0.7, 0.06, 0.2], ...
                'MarkerEdgeColor', [0.7, 0.06, 0.2] ...
            );
            % - point lables
            d = 0.02;
            for i = 1:size(points, 1)
                x = points(i, 1);
                y = points(i, 2);
                z = points(i, 3);
                txt = sprintf('(%d, %d, %d)', x, y, z);
                text(...
                    x + d, y - d, z + 0.05, ...
                    txt, ...
                    'Color', [0.7, 0.06, 0.2]);
            end
            
            hold('off');
            % Config
            view(3);
            view([-60, 15]);
            axis('equal');
            set(gca, ...
                'Visible', 'off', ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [], ...
                'ZTick', [] ...
            );
        end
        
        function plotGridNN3D()
            % Plot a unit cube with its vertices
            
            % Parameters
            color = [1, 0.3, 0.4];
            faceColor = color;
            edgeColor = color;
            
            % Plot
            Viz.figure('3D Neighburs');
            hold('on');
            % - grid
            Viz.plotGrid(3, 1, [-1, -1, -0.5]');
            % - green cube
            Viz.plotCube([0.04, 0.5, 0.04]);
            % red cube
            Viz.plotCube([1, 0.3, 0.4], 2, [-0.5, -0.5, -0.5]');
            % sphere
            center = [0.7, 0.7, 0.7];
            radius = 1.3;
            [x, y, z] = Viz.sphere(center, radius);
            surf(...
                x, y, z, ...                    
                'FaceColor', faceColor,  ...
                'FaceAlpha', 0.1,  ...
                'EdgeColor', edgeColor, ...
                'EdgeAlpha', 0.2, ...
                'LineStyle', '-', ...
                'LineWidth', 0.1 ...
            );
            % - radius
            p = center + [0, -radius, 0];
            Viz.plotLine(center', p', Viz.color.gray4, 2, '--');
            % - center
            plotPoint(center, 49, Viz.color.gray1);
            
            
            hold('off');
            % Config
            view(3);
            view([-60, 15]);
            axis('equal');
            set(gca, ...
                'Visible', 'off', ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [], ...
                'ZTick', [] ...
            );
        
            function plotPoint(p, markerArea, color)
                scatter3(...
                    p(1), p(2), p(3), markerArea, ...
                    'LineWidth', 1, ...
                    'MarkerFaceColor', color, ...
                    'MarkerEdgeColor', color ...
                );
            end
        end
    end
    
    % Paper: Frustum-Frustum Intersection
    % - Figures
    methods (Static)
        % fig:2d_random_walk
        function plotClassifiedRandomWalk2D(points)
            % Plot classified random walk based on range search
            %
            % Parameters
            % ----------
            % - points: 2-by-n double matrix
            %   [p1, p2, ...]
            
            % default values
            if ~exist('points', 'var')
                points = load(...
                    './assets/data/paper/gridnn/fig_rw.mat', ...
                    'points' ...
                );
                points = points.points;
            end
            
            % Properties
            radius = 0.5;
            markerArea = 9;
            
            lineColor = Viz.color.lightGray;
            
            positivePointColor = Viz.color.darkRed;
            negativePointColor = Viz.color.darkBlue;
            lastPointColor = Viz.color.darkGreen;
            
            firstPointLineStyle = '--';
            lastPointLineStyle = '-';
            positivePointLineStyle = '-';
            negativePointLineStyle = '-';
            
            % figure
            Viz.figure('Classified Random Walks (fig:2d_random_walk)');

            % line plot
            line(...
                'XData', points(1, :), ...
                'YData', points(2, :), ...
                'Color', lineColor ...
            );
            hold('on');
            
            % cluster points
            % - first point
            firstPoint = points(:, 1);
            % - last point
            lastPoint = points(:, end);
            % - positive and negative points
            points(:, [1, end]) = [];
            numberOfPoints = size(points, 2);
            positivePointIndexes = zeros(1, numberOfPoints, 'logical');
            for indexOfPoint = 1:numberOfPoints
                point = points(:, indexOfPoint);
                if norm(lastPoint - point) <= 2 * radius
                    positivePointIndexes(indexOfPoint) = true;
                end
            end
            positivePoints = points(:, positivePointIndexes);
            % - negative points
            negativePoints = points(:, ~positivePointIndexes);
            
            % scatter plot
            % - negative points
            plotPoints(negativePoints, markerArea, negativePointColor, ...
                radius, negativePointLineStyle);
            % - positive points
            plotPoints(positivePoints, markerArea, positivePointColor, ...
                radius, positivePointLineStyle);
            % - first point(at origin)
            firstPointColor = negativePointColor;
            if norm(lastPoint - firstPoint) <= 2 * radius
                firstPointColor = positivePointColor;
            end
            plotPoints(firstPoint, markerArea, firstPointColor, ...
                radius, firstPointLineStyle);
            % - last point
            plotPoints(lastPoint, markerArea, lastPointColor, ...
                radius, lastPointLineStyle);
            
            hold('off');
            %   - config
            set(gca, ...
                'Visible', 'off', ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [] ...
            );
            axis('tight');
            axis('equal');
            
            % Local Functions
            function plotPoints(points, markerArea, color, radius, style)
                % centers
                scatter(...
                    points(1, :), points(2, :), markerArea, ...
                    'MarkerFaceColor', color, ...
                    'MarkerEdgeColor', color ...
                );
                % circles
                drawCircles(...
                    points, radius, ...
                    color, ...
                    style ...
                );
            end
            
            function drawCircles(centers, radius, color, style)
                for center = centers
                    % top left corner of bounding-box
                    position = [...
                        center(1) - radius, ...
                        center(2) - radius, ...
                        2 * radius, ...
                        2 * radius ...
                    ];
                    % draw circle with its bounding-box rectangle
                    rectangle(...
                        'Position', position, ...
                        'Curvature',[1 1], ...
                        'EdgeColor', color, ...
                        'LineStyle', style ...
                    );
                end
            end
        end
        
        % fig:3d_random_walk
        function plotClassifiedRandomWalk3D(points)
            % Plot classified random walk based on range search
            %
            % Parameters
            % ----------
            % - points: double matrix
            %   [p1, p2, ...]
            
            % default values
            if ~exist('points', 'var')
                points = load(...
                    './assets/data/paper/intersection/fig_3d_random_walk.mat', ...
                    'points' ...
                );
                points = points.points;
            end
            
            % Properties
            radius = 1.5;
            markerArea = 36;
            
            lineColor = Viz.color.gray;
            lineWidth = 1;
            
            positivePointColor = Viz.color.lightRed;
            negativePointColor = Viz.color.lightBlue;
            lastPointColor = Viz.color.lightGreen;
            
            firstPointLineStyle = ':';
            lastPointLineStyle = '-';
            positivePointLineStyle = '-';
            negativePointLineStyle = '-';

            % figure
            Viz.figure('Classified Random Walks (fig:3d_random_walk)');

            % line plot
            line(...
                'XData', points(1, :), ...
                'YData', points(2, :), ...
                'ZData', points(3, :), ...
                'LineWidth', lineWidth, ...
                'Color', lineColor ...
            );
            view(3);
            hold('on');
            
            % cluster points
            % - first point
            firstPoint = points(:, 1);
            % - last point
            lastPoint = points(:, end);
            % - positive and negative points
            points(:, [1, end]) = [];
            numberOfPoints = size(points, 2);
            positivePointIndexes = zeros(1, numberOfPoints, 'logical');
            for indexOfPoint = 1:numberOfPoints
                point = points(:, indexOfPoint);
                if norm(lastPoint - point) <= 2 * radius
                    positivePointIndexes(indexOfPoint) = true;
                end
            end
            positivePoints = points(:, positivePointIndexes);
            % - negative points
            negativePoints = points(:, ~positivePointIndexes);
            
            % scatter plot
            % - negative points
            plotPoints(negativePoints, markerArea, negativePointColor, ...
                radius, negativePointLineStyle);
            % - positive points
            plotPoints(positivePoints, markerArea, positivePointColor, ...
                radius, positivePointLineStyle);
            % - first point(at origin)
            firstPointColor = negativePointColor;
            if norm(lastPoint - firstPoint) <= 2 * radius
                firstPointColor = positivePointColor;
            end
            plotPoints(firstPoint, markerArea, firstPointColor, ...
                radius, firstPointLineStyle);
            % - last point
            plotPoints(lastPoint, markerArea, lastPointColor, ...
                radius, lastPointLineStyle);
            hold('off');
            %   - config
            set(gca, ...
                'Visible', 'on', ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [], ...
                'ZTick', [] ...
            );
            axis('tight');
            axis('equal');
            
            % Local Functions
            function plotPoints(points, markerArea, color, radius, style)
                % centers
                scatter3(...
                    points(1, :), points(2, :), points(3, :), markerArea, ...
                    'MarkerFaceColor', color, ...
                    'MarkerEdgeColor', color ...
                );
                % spheres
                plotSpheres(...
                    points, radius, ...
                    color, ...
                    style ...
                );
            end
            
            function plotSpheres(centers, radius, color, style)
                % Plot spheres
                %
                % Parameters
                % ----------
                % - centers: 3-by-n double matrix
                %   Centers of spheres
                % - radius: double
                %   Radius of spheres
                % - color: EdgeColor
                %   Color of edges
                % - Style: LineStyle
                %   Style of lines

                for center = centers
                    [x, y, z] = Viz.sphere(center, radius);
                    surf(...
                        x, y, z, ...                    
                        'FaceColor', 'none',  ...
                        'FaceAlpha', 0.1,  ...
                        'EdgeColor', color, ...
                        'EdgeAlpha', 0.2, ...
                        'LineStyle', style, ...
                        'LineWidth', 0.01 ...
                    );
                end
            end
        end
        
        function plotClassifiedRandomWalk3DFromFiles(rootDir)
            filenames = Viz.getFilenames(rootDir);
            numberOfFilenames = numel(filenames);
            for indexOfFilename = 1:numberOfFilenames
                filename = filenames{indexOfFilename};
                sample = load(filename);
                points = sample.input.points;
                
                Viz.plotClassifiedRandomWalk3(points);
            end
        end
        
        % fig:loop_closure
        function plotLoopClosure(filename)
            % default values
            if ~exist('filename', 'var')
                filename = ...
                    './assets/data/paper/intersection/loop_closure.mat';
            end
            
            % Plot
            % - figure
            Viz.figure('Loop Closure (fig:loop_closure)');
            % - matrix
            subplot(1, 2, 1);
            Viz.plotOutputOfMethod(filename, 'LNN');
            % - random-walk
            subplot(1, 2, 2);
            Viz.plotRandomWalkFromFile(filename);
            axis('tight');
            axis('equal');
        end
        
        % fig:s_volume
        function plotIntersectionOfSpheres()
            % Plot sphere-sphere intersection
            
            % Parameters
            % radius
            r = 1;
            % distance between two centers
            d = 1.5;
            d2 = d / 2;
            % centers
            c1 = [0, 0, 0]';
            c2 = [d, 0, 0]';
            centers = [c1, c2];
            % intersection points
            h = sqrt(r * r - d2 * d2);
            p1 = [d2, 0, h]';
            p2 = [d2, 0, -h]';
            % styles
            faceColor = Viz.color.lightGray;
            edgeColor = Viz.color.gray;
            
            distanceColor = [0.4, 0.4, 0.4];
            radiusColor = [0.5, 0.5, 0.5];
            
            distanceLineWidth = 2.2;
            radiusLineWidth = 2;
            
            distanceLineStyle = '--';
            radiusLineStyle = ':';
            
            centerArea = 49;
            pointArea = 25;
            
            % Plot
            % - figure
            Viz.figure('Sphere-Sphere Intersection (fig:sphere_sphere_intersection)');
            hold('on');
            % - spheres
            for center = centers
                plotSphere(center, r, faceColor, edgeColor);
            end
            % - lines
            Viz.plotLine(c1, c2, distanceColor, distanceLineWidth, distanceLineStyle);
            Viz.plotLine(c1, p1, radiusColor, radiusLineWidth, radiusLineStyle);
            Viz.plotLine(c2, p2, radiusColor, radiusLineWidth, radiusLineStyle);
            % - points
            plotPoint(c1, centerArea);
            plotPoint(c2, centerArea);
            plotPoint(p1, pointArea);
            plotPoint(p2, pointArea);
            
            hold('off');
            
            % - config
            view(3);
            view([0, -15]);
            axis('equal');
            set(gca, ...
                'Visible', 'off', ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [], ...
                'ZTick', [] ...
            );
            
            % Local Functions
            function plotSphere(center, radius, faceColor, edgeColor)
                [x, y, z] = Viz.sphere(center, radius);
                surf(...
                    x, y, z, ...                    
                    'FaceColor', faceColor,  ...
                    'FaceAlpha', 0.1,  ...
                    'EdgeColor', edgeColor, ...
                    'EdgeAlpha', 0.2, ...
                    'LineStyle', '-', ...
                    'LineWidth', 0.1 ...
                );
            end
            function plotPoint(p, markerArea)
                scatter3(...
                    p(1), p(2), p(3), markerArea, ...
                    'LineWidth', 1, ...
                    'MarkerFaceColor', [0.6, 0.6, 0.6], ...
                    'MarkerEdgeColor', [0.3, 0.3, 0.3] ...
                );
            end
        end
        
        % fig:3d_frustum
        function plotFrustum()
            % Plot frusum of a camera
            
            % Parameters
            near = 2;
            far = 6;
            fov = pi / 6;
            aspect = 16 / 9;
            
            pointColor = [0.3, 0.3, 0.3];
            pointArea = 25;
            
            % Points
            % - origin
            O = [0, 0, 0];
            % - near plane
            x = near;
            z = near * tan(fov / 2);
            y = aspect * z;
            A = [
                x,  y,  z
                x, -y,  z
                x, -y, -z
                x, y, -z
            ];
            % - far plane
            x = far;
            z = far * tan(fov / 2);
            y = aspect * z;
            % radius of circumsphere
            r = (x^2 + y^2 + z^2) / (2 * x);
            B = [
                x,  y,  z
                x, -y,  z
                x, -y, -z
                x, y, -z
            ];
        
            % Plot
            % - figure
            Viz.figure('3D Frustum (fig:3d_frustum)');
            hold('on');
            % - pyramid
            color = [0.3, 0.3, 0.3];
            Viz.plotLine(O', A(1, :)', color, 1, '--');
            Viz.plotLine(O', A(2, :)', color, 1, '--');
            Viz.plotLine(O', A(3, :)', color, 1, '--');
            Viz.plotLine(O', A(4, :)', color, 1, '--');
            % - principal axis
            %   - principal point
            pp = [far + 3, 0, 0];
            Viz.plotVector(O', pp', Viz.color.gray5, 1.5, '-');
            ppA = sum(A) / size(A, 1);
            ppB = sum(B) / size(B, 1);
            ppAB = [ppA', ppB'];
            scatter3(ppAB(1, :), ppAB(2, :), ppAB(3, :), 64, ...
                'Marker', '+', ...
                'MarkerFaceColor', Viz.color.gray2, ...
                'MarkerEdgeColor', Viz.color.gray2 ...
            );
            
            % - frustum
            faces = [
                1, 2, 3, 4 % near
                5, 6, 7, 8 % far
                1, 5, 6, 2 % top
                2, 6, 7, 3 % right
                4, 8, 7, 3 % bottom
                1, 5, 8, 4 % left
            ];
            patch(...
                'Vertices', [A; B], ...
                'Faces', faces, ...
                'LineWidth', 1, ...
                'EdgeColor', [0.2, 0.2, 0.2], ...
                'EdgeAlpha', 1, ...
                'FaceColor', [0.6, 0.2, 0], ...
                'FaceAlpha', 0.1 ...
            );
            % - points
            % points = [O', A', B'];
            points = O';
            scatter3(points(1, :), points(2, :), points(3, :), pointArea, ...
                'MarkerFaceColor', pointColor, ...
                'MarkerEdgeColor', pointColor ...
            );
            % - circumsphere
%             [x, y, z] = Viz.sphere([r, 0, 0]', r);
%             surf(...
%                 x, y, z, ...                    
%                 'FaceColor', Viz.color.gray2,  ...
%                 'FaceAlpha', 0.1,  ...
%                 'EdgeColor', Viz.color.gray1, ...
%                 'EdgeAlpha', 0.2, ...
%                 'LineStyle', '-', ...
%                 'LineWidth', 0.2 ...
%             );
        
            hold('off');
            % Config
            view(3);
            view([-45, 45]);
            axis('square');
            axis('equal');
            set(gca, ...
                'Visible', 'on', ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [], ...
                'ZTick', [] ...
            );
        end
        
        % fig:spheres
        function plotSpheres()
            % Plot frusum of a camera and its spheres
            
            % Parameters
            near = 2;
            far = 6;
            fov = pi / 6;
            aspect = 16 / 9;
            
            pointColor = [0.3, 0.3, 0.3];
            pointArea = 25;
            
            % Points
            % - origin
            O = [0, 0, 0];
            % - near plane
            x = near;
            z = near * tan(fov / 2);
            y = aspect * z;
            A = [
                x,  y,  z
                x, -y,  z
                x, -y, -z
                x, y, -z
            ];
            % - far plane
            x = far;
            z = far * tan(fov / 2);
            y = aspect * z;
            % radius of circumsphere
            r = (x^2 + y^2 + z^2) / (2 * x);
            B = [
                x,  y,  z
                x, -y,  z
                x, -y, -z
                x, y, -z
            ];
        
            % Plot
            % - figure
            Viz.figure('3D Frustum (fig:3d_frustum)');
            hold('on');
            % - pyramid
            color = [0.3, 0.3, 0.3];
            Viz.plotLine(O', A(1, :)', color, 1, '--');
            Viz.plotLine(O', A(2, :)', color, 1, '--');
            Viz.plotLine(O', A(3, :)', color, 1, '--');
            Viz.plotLine(O', A(4, :)', color, 1, '--');
            % - principal axis
            %   - principal point
            pp = [far + 3, 0, 0];
            Viz.plotVector(O', pp', Viz.color.gray5, 1.5, '-');
            ppA = sum(A) / size(A, 1);
            ppB = sum(B) / size(B, 1);
            ppAB = [ppA', ppB'];
            scatter3(ppAB(1, :), ppAB(2, :), ppAB(3, :), 64, ...
                'Marker', '+', ...
                'MarkerFaceColor', Viz.color.gray2, ...
                'MarkerEdgeColor', Viz.color.gray2 ...
            );
            % - frustum
            faces = [
                1, 2, 3, 4 % near
                5, 6, 7, 8 % far
                1, 5, 6, 2 % top
                2, 6, 7, 3 % right
                4, 8, 7, 3 % bottom
                1, 5, 8, 4 % left
            ];
            patch(...
                'Vertices', [A; B], ...
                'Faces', faces, ...
                'LineWidth', 1, ...
                'EdgeColor', [0.2, 0.2, 0.2], ...
                'EdgeAlpha', 1, ...
                'FaceColor', [0.6, 0.2, 0], ...
                'FaceAlpha', 0.1 ...
            );
            % - points
            points = [O', A', B'];
            scatter3(points(1, :), points(2, :), points(3, :), pointArea, ...
                'MarkerFaceColor', pointColor, ...
                'MarkerEdgeColor', pointColor ...
            );
%             % - circumsphere of pyramid
%             [x, y, z] = Viz.sphere([r, 0, 0]', r);
%             c = [r, 0, 0];
%             surf(...
%                 x, y, z, ...                    
%                 'FaceColor', Viz.color.gray2,  ...
%                 'FaceAlpha', 0.1,  ...
%                 'EdgeColor', Viz.color.gray1, ...
%                 'EdgeAlpha', 0.2, ...
%                 'LineStyle', '-', ...
%                 'LineWidth', 0.2 ...
%             );
%             %   - center
%             plotPoint(c, 36, 1.5, 'none', Viz.color.gray5);
%             %   - radius
%             P = [0, 0, 0];
%             Viz.plotLine(c', P', Viz.color.gray5, 1, '--');

            % - circumsphere of frustum
            [x, r] = sircumsphereOfFrustum(fov, near, far, aspect);
            c = [x, 0, 0];
            [x, y, z] = Viz.sphere(c, r + 0.2);
            surf(...
                x, y, z, ...                    
                'FaceColor', Viz.color.gray2,  ...
                'FaceAlpha', 0.1,  ...
                'EdgeColor', Viz.color.gray1, ...
                'EdgeAlpha', 0.2, ...
                'LineStyle', '-', ...
                'LineWidth', 0.2 ...
            );
            %   - center
            plotPoint(c, 36, 1, Viz.color.gray4, Viz.color.gray3);
            %   - radius
            P = A(1, :);
            Viz.plotLine(c', P', Viz.color.gray2, 1, '--');
            P = B(1, :);
            Viz.plotLine(c', P', Viz.color.gray2, 1, '--');
            
%             % - insphere of frustum
%             [x, r] = insphereOfFrustum(fov, far);
%             c = [x, 0, 0];
%             [x, y, z] = Viz.sphere(c, r);
%             surf(...
%                 x, y, z, ...                    
%                 'FaceColor', Viz.color.gray2,  ...
%                 'FaceAlpha', 0.1,  ...
%                 'EdgeColor', Viz.color.gray1, ...
%                 'EdgeAlpha', 0.2, ...
%                 'LineStyle', '-', ...
%                 'LineWidth', 0.2 ...
%             );
%             %   - center
%             plotPoint(c, 16, 1, Viz.color.gray5, Viz.color.gray4);
%             %   - radius
%             P = c + [0, 0, r];
%             Viz.plotLine(c', P', Viz.color.gray5, 1, '-');

            hold('off');
            % Config
            view(3);
            view([-45, 45]);
            axis('square');
            axis('equal');
            set(gca, ...
                'Visible', 'off', ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [], ...
                'ZTick', [] ...
            );
        
            % Local Functions
            function [x, r] = sircumsphereOfFrustum(fov, f, F, a)
                % Parameters
                % ----------
                % - fov: double
                %   Field of view
                % - f: double
                %   Near (focal length)
                % - F: double
                %   Far
                % - a: double
                %   Aspect ratio
                x = (1/2)*(f+F)*(-a^2+(1+a^2)*sec(fov/2)^2);
                r = sqrt((f+(1/2)*(f+F)*(a^2-(2*((1+a^2))/(1+cos(fov))))^2+f^2*tan(fov/2)^2*(1+a^2)));
            end
            
            function [x, r] = insphereOfFrustum(fov, F)
                x = F/(1+sin(fov/2));
                r = F - x;
            end
            
            function plotPoint(p, markerArea, lineWidth, faceColor, edgeColor)
                scatter3(...
                    p(1), p(2), p(3), markerArea, ...
                    'LineWidth', lineWidth, ...
                    'MarkerFaceColor', faceColor, ...
                    'MarkerEdgeColor', edgeColor ...
                );
            end
        end
    end
    
    % - Equations
    methods (Static)
        function eq_cc()
            % Variables
            % - radius and distance
            syms('r', 'd', 'positive');
            % - intersection
            %   - length
            l(r, d) = 1 - (d/(2*r));
            %   - area
            % a(r, d) = (2*r^2*acos(d/(2*r))-(1/2)*d*sqrt(4*r^2-d^2))/(sym(pi)*r^2);
            a(r, d) = (2/sym(pi))*acos(d/(2*r))-(d/(2*sym(pi)*r*r))*sqrt(4*r*r-d*d);
            %   - volume
            v(r, d) = ((d-2*r)^2)*(d+4*r)/(16*r^3);
            
            
            % Plot
            lineWidth = 1;
            % - figure
            Viz.figure('Intersection (eq:cc, eq:ss)');
            % r is `1` because the ratio between r and d is important
            % - length
            fplot(...
                l(1, d), [0, 2], ...
                'LineWidth', lineWidth ...
            );
            hold('on');
            % - area
            fplot(...
                a(1, d), [0, 2.05], ...
                'LineWidth', lineWidth ...
            );
            % - volume
            fplot(...
                v(1, d), [0, 2], ...
                'LineWidth', lineWidth ...
            );
            
            hold('off');
            
            % Config
            % '$\frac{2}{\pi}\arccos(\frac{d}{2r}) - \frac{d}{2\pi r^2}\sqrt{4r^2 - d^2}$'
            % '$\frac{2 r^2 \cos ^{-1}\left(\frac{d}{2 r}\right)-\frac{1}{2} d \sqrt{4 r^2-d^2}}{\pi  r^2}$'
            legend(...
                {
                    ['$', latex(l), '$']
                    '$\frac{2 r^2 \cos ^{-1}\left(\frac{d}{2 r}\right)-\frac{1}{2} d \sqrt{4 r^2-d^2}}{\pi  r^2}$'
                    ['$', latex(v), '$']
                }, ...
                'FontSize', 16, ...
                'Interpreter', 'latex' ...
            );
            xlabel('$d$', 'FontSize', 14);
            set(gca, ...
                'XTick', [0, 2], ...
                'XTickLabel', {...
                    '$0$', ...
                    '$2\,r$' ...
                }, ...
                'YTick', [0, 1], ...
                'YTickLabel', {...
                    '$0$', ...
                    '$1$' ...
                }, ...
                'FontSize', 12, ...
                'Box', 'off' ...
            );

            Viz.setLatexInterpreter();

            axis('equal');
        end
        
        function eq_ratio(fcn, xlabelTxt, ylabelTxt, lengendTxt, figureTitle)
            % Plot ratio
            %
            % Parameters
            % - fcn: sym
            %   Symbolic function to plot
            % - txt: char vector
            %   Latex definition of function
            % - title: char vector
            %   Title of figure

            % Plot
            lineWidth = 2;
            xticks = [pi/6, pi/3, 2*pi/3];
            yticks = sort(double([
                1
                fcn(xticks(2))
                fcn(xticks(3))
            ]));
            % - figure
            Viz.figure(figureTitle);
            % - circumcircle
            fplot(...
                fcn, [xticks(1), xticks(end)], ...
                'LineWidth', lineWidth ...
            );
            
            % Config
            legend(...
                {
                    lengendTxt
                }, ...
                'FontSize', Viz.fontSize.legend, ...
                'Interpreter', 'latex' ...
            );
            xlabel(xlabelTxt, 'FontSize', Viz.fontSize.label);
            ylabel(ylabelTxt, 'FontSize', Viz.fontSize.label);
            set(gca, ...
                'XTick', xticks, ...
                'XTickLabel', {
                    ['$', latex(sym(xticks(1))), '$']
                    ['$', latex(sym(xticks(2))), '$']
                    ['$', latex(sym(xticks(3))), '$']
                }, ...
                'XLim', [xticks(1), xticks(end)], ...
                'XGrid', 'on', ...
                'YTick', yticks, ...
                'YTickLabel', {...
                    ['$', num2str(round(yticks(1), 1)), '$']
                    ['$', num2str(round(yticks(2), 1)), '$']
                    ['$', num2str(round(yticks(3), 1)), '$']
                }, ...
                'YLim', [yticks(1), yticks(end)], ...
                'YGrid', 'on', ...
                'FontSize', Viz.fontSize.axis, ...
                'Box', 'off' ...
            );
            Viz.setLatexInterpreter();
%             axis('square');
        end
        
        function eq_cf_ratio()
            % Variables
            % - radius and distance
            syms('a', 'positive');
            assume(0 < a & a < sym(pi));
            % - ratio of outcircle
            fcn(a) = (sym(pi)*csc(a))/(1+cos(a));
            xlabelTxt = 'fov (rad)';
            ylabelTxt = 'area ratio';
            legendTxt = '$$\frac{\pi  \csc (\mathrm{fov})}{1+\cos (\mathrm{fov})}$$';
            figureTitle = 'Circumcircle-Frustum Ratio (eq:c_f_ratio)';
            
            % Plot
            Viz.eq_ratio(fcn, xlabelTxt, ylabelTxt, legendTxt, figureTitle);
        end
        
        function eq_icf_ratio()
            % Variables
            % - radius and distance
            syms('a', 'positive');
            assume(0 < a & a < sym(pi));
            % - ratio of incircle
            fcn(a) = (sym(pi)*sin(a))/(2*(1+sin(a/2))^2);
            txt = '$\frac{\pi \sin (\mathrm{fov})}{2(1+\sin (\frac{\mathrm{fov}}{2}))^2}$';
            title = 'Incircle-Frustum Ratio (eq:ic_f_ratio)';
            
            % Plot
            Viz.eq_ratio(fcn, txt, title);
        end
        
        function eq_sf_ratio()
            % Variables
            % - radius and distance
            syms('a', 'positive');
            assume(0 < a & a < sym(pi));
            % - ratio of outcircle
            fcn(a) = (sym(pi)*(3-cos(a))^3*cot(a/2)^2)/(8*(1+cos(a))^3);
            xlabelTxt = 'fov (rad)';
            ylabelTxt = 'volume ratio';
            legendTxt = '$$\frac{\pi  (3-\cos (\mathrm{fov}))^3 \cot ^2\left(\frac{\mathrm{fov}}{2}\right)}{8 (\cos (\mathrm{fov})+1)^3}$$';
            figureTitle = 'Circumsphere-Frustum Ratio (eq:s_f_ratio)';
            
            % Plot
            Viz.eq_ratio(fcn, xlabelTxt, ylabelTxt, legendTxt, figureTitle);
%             text(...
%                 0.927295, ...
%                 5.30144, ...
%                 '\downarrow' ...
%             );
            annotation(...
                'textarrow', ...
                [0.33 0.33], ...
                [0.3 0.19], ...
                'String',{'$(53.1^{o},\,5.3)$'}, ...
                'Interpreter', 'latex', ...
                'FontSize', Viz.fontSize.label ...
            );
        end
        
        function eq_isf_ratio()
            % Variables
            % - radius and distance
            syms('a', 'positive');
            assume(0 < a & a < sym(pi));
            % - ratio of incircle
            fcn(a) = (sym(pi)*cot(a/2)^2)/((1+csc(a/2))^3);
            txt = '$\frac{\pi  \cot ^2\left(\frac{\mathrm{fov}}{2}\right)}{\left(1+\csc \left(\frac{\mathrm{fov}}{2}\right)\right)^3}$';
            title = 'Incircle-Frustum Ratio (eq:ic_f_ratio)';
            
            % Plot
            Viz.eq_ratio(fcn, txt, title);
%             text(...
%                 0.679674, ...
%                 0.392699, ...
%                 '\downarrow' ...
%             );
            annotation(...
                'textarrow', ...
                [0.21 0.21], ...
                [0.49 0.37], ...
                'String',{'$(38.9^{o},\,0.4)$'}, ...
                'Interpreter', 'latex' ...
            );
        end
        
        function eq_cf_ratio_2d()
            % Variables
            % - radius and distance
            syms('f', 'a', 'positive');
            assume(f > 1);
            assume(0 < a & a < sym(pi));
            % - intersection
            %   - ratio
            r(f, a) = (2*sym(pi)*(f + 1)*cot(a/2))/((f-1)*(1+cos(a))^2);
            
            % Plot
            lineWidth = 1;
            % - figure
            Viz.figure('Circle-Frustum Ratio (eq:c_f_ratio)');
            % - circumcircle
            fsurf(...
                r(f, a), [100, 10000, pi/6, 2*pi/3], ...
                'LineWidth', lineWidth ...
            );
            hold('on');
            
            hold('off');
            
            % Config
            % '$\frac{2}{\pi}\arccos(\frac{d}{2r}) - \frac{d}{2\pi r^2}\sqrt{4r^2 - d^2}$'
            % '$\frac{2 r^2 \cos ^{-1}\left(\frac{d}{2 r}\right)-\frac{1}{2} d \sqrt{4 r^2-d^2}}{\pi  r^2}$'
            legend(...
                {
                    ['$', latex(r(f, a)), '$']
                }, ...
                'FontSize', 16, ...
                'Interpreter', 'latex' ...
            );
            xlabel('$\frac{F}{f}$', 'FontSize', 14);
            ylabel('$fov$', 'FontSize', 14);
%             set(gca, ...
%                 'XTick', [0, 2], ...
%                 'XTickLabel', {...
%                     '$0$', ...
%                     '$2\,r$' ...
%                 }, ...
%                 'YTick', [0, 1], ...
%                 'YTickLabel', {...
%                     '$0$', ...
%                     '$1$' ...
%                 }, ...
%                 'FontSize', 12, ...
%                 'Box', 'off' ...
%             );

            Viz.setLatexInterpreter();

%             axis('equal');
        end
        
        function eq_similarity()
            % Variables
            % - radius and distance
            syms('r', 'd', 'positive');
            % - intersection
            %   - length
            l(r, d) = 1 - (d/(2*r));
            %   - area
            % a(r, d) = (2*r^2*acos(d/(2*r))-(1/2)*d*sqrt(4*r^2-d^2))/(sym(pi)*r^2);
            a(r, d) = (2/sym(pi))*acos(d/(2*r))-(d/(2*sym(pi)*r*r))*sqrt(4*r*r-d*d);
            %   - volume
            v(r, d) = ((d-2*r)^2)*(d+4*r)/(16*r^3);
            %   - probabilistic
            p(r, d) = exp(-((3/4)*(d/r))^2);
            
            
            % Plot
            lineWidth = 1;
            % - figure
            Viz.figure('Intersection (eq:cc, eq:ss)');
            % r is `1` because the ratio between r and d is important
            % - length
            fplot(...
                l(1, d), [0, 2], ...
                'LineStyle', '--', ...
                'LineWidth', lineWidth ...
            );
            hold('on');
            % - area
            fplot(...
                a(1, d), [0, 2.05], ...
                'LineStyle', ':', ...
                'LineWidth', lineWidth + 0.5 ...
            );
            % - volume
            fplot(...
                v(1, d), [0, 2], ...
                'LineStyle', '-.', ...
                'LineWidth', lineWidth ...
            );
            % - probabilistic
            fplot(...
                p(1, d), [0, 2], ...
                'LineStyle', '-', ...
                'LineWidth', lineWidth ...
            );
            
            hold('off');
            
            % Config
            % '$\frac{2}{\pi}\arccos(\frac{d}{2r}) - \frac{d}{2\pi r^2}\sqrt{4r^2 - d^2}$'
            % '$\frac{2 r^2 \cos ^{-1}\left(\frac{d}{2 r}\right)-\frac{1}{2} d \sqrt{4 r^2-d^2}}{\pi  r^2}$'
            legend(...
                {
                    ['$$', latex(l), '$$']
                    '$$\frac{2 r^2 \cos ^{-1}\left(\frac{d}{2 r}\right)-\frac{1}{2} d \sqrt{4 r^2-d^2}}{\pi  r^2}$$'
                    ['$$', latex(v), '$$']
                    '$$e^{-(\frac{3}{2}\frac{d}{r})^2}$$'
                }, ...
                'FontSize', Viz.fontSize.legend, ...
                'Interpreter', 'latex' ...
            );
            xlabel('$d$', 'FontSize', Viz.fontSize.label);
            ylabel('similarity', 'FontSize', Viz.fontSize.label);
            set(gca, ...
                'XTick', [0, 2], ...
                'XTickLabel', {...
                    '$0$', ...
                    '$2\,r$' ...
                }, ...
                'YTick', [0, 1], ...
                'YTickLabel', {...
                    '$0$', ...
                    '$1$' ...
                }, ...
                'YGrid', 'on', ...
                'FontSize', Viz.fontSize.axis, ...
                'Box', 'off' ...
            );

            Viz.setLatexInterpreter();

            axis('equal');
        end
        
        function eq_mvn_prod()
            % Parameters
            d = 1.5;
            s = 1/3; % r = 1
            r = 3*s;
            m1 = [0, 0, 0];
            m2 = m1 + [d, 0, 0];
            
            edgeColor = Viz.color.gray;
            faceColor = Viz.color.lightGray;
            circleColor = Viz.color.gray8;
            
            % Plot
            % - figure
            Viz.figure('MVN Product (eq:mvn_prod)');
            % - first circle
            circle(m1, r, circleColor);
            hold('on');
            % - second circle
            circle(m2, r, circleColor);
            % - first mvn
            mvn(m1, s, edgeColor, faceColor);
            % - second mvn
            mvn(m2, s, edgeColor, faceColor);
            % - first radius
            p = [d/2, sqrt(r^2-(d/2)^2), 0];
            Viz.plotLine(m1', p', Viz.color.gray, 2, ':');
            plotPoint(p', 25); 
            % - second radius
            p = [d/2, -sqrt(r^2-(d/2)^2), 0];
            Viz.plotLine(m2', p', Viz.color.gray, 2, ':');
            plotPoint(p', 25);
            % - distance
            Viz.plotLine(m1', m2', Viz.color.gray, 2, '--');
            hold('off');
            
            % Config
            % view([0, 37]);
            set(gca, ...
                'Visible', 'off', ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [], ...
                'ZTick', [] ...
            );
            axis('tight');
            axis('equal');
            
            % Local Functions
            function plotPoint(p, markerArea)
                scatter3(...
                    p(1), p(2), p(3), markerArea, ...
                    'LineWidth', 1, ...
                    'MarkerFaceColor', Viz.color.gray6, ...
                    'MarkerEdgeColor', Viz.color.gray3 ...
                );
            end
            function circle(c, r, color)
                % Parameters
                lineWidth = 2;
                markerArea = 36;

                a = linspace(0, 2*pi, 360);
                x = r * cos(a) + c(1);
                y = r * sin(a) + c(2);
                z = zeros(size(x));

                % Plot
                % - circle
                plot3(...
                    x, y, z, ...
                    'Color', color, ...
                    'LineWidth', lineWidth ...
                );
                hold('on');
                % - center
                plotPoint(c, markerArea);
            end
            function mvn(m, s, edgeColor, faceColor)
                x = linspace(m(1) - 3*s, m(1) + 3*s, 30);
                y = linspace(m(2) - 3*s, m(2) + 3*s, 30);
                [X, Y] = meshgrid(x, y);
                Z = (1/(2*pi*s^2))*exp(-((X-m(1)).^2+(Y-m(2)).^2)/(2*s^2));

                % Plot
                % - gaussian
                surf(...
                    X, Y, Z, ...
                    'EdgeColor', edgeColor, ...
                    'EdgeAlpha', 0.2, ...
                    'FaceColor', faceColor, ...
                    'FaceAlpha', 0.1 ...
                );
            end
        end
    end
    
    % Paper: SLAM
    methods (Static)
        
    end
    
    % Summary
    methods (Static)
        function printSummary(rootDir)
            % Print summary of results
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walk samples
            
            % config
            % todo: Add `disp` method to print `dash-line` after displaying
            % message
            disp('Config Table');
            configFilename = fullfile(rootDir, 'config');
            configTable = Viz.getConfigTable(configFilename);
            disp(configTable);
            
            % elapsed-times
            disp('Elapsed-Times Table');
            filenames = Viz.getFilenames(fullfile(rootDir, 'samples'));
            elapsedTimesTable = Viz.getelapsedTimesTable(filenames);
            disp(elapsedTimesTable);
        end

        function saveResults(rootDir)
            % Make `results` folder in `roodDir` folder and save some
            % `results` in it
            %
            % Parameters
            % ----------
            % - rootDir: char vector
            %   Path of input directory
            
            % `results` folder
            [parentOfRootDir, ~, ~] = fileparts(rootDir);
            outDir = fullfile(parentOfRootDir, 'results');
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

