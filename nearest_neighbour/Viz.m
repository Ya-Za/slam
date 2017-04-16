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
            % - name: char vector
            %   Name of figure
            %
            % Return
            % - h: matlab.ui.Figure

            h = figure(...
                'Name', name, ...
                'NumberTitle', 'off', ...
                'Units', 'normalized', ...
                'OuterPosition', [0, 0, 1, 1] ...
            );
        end
        
        function filenames = getFilenames(folder, format)
            % Get filenames with specified `format` in given `foler` 
            %
            % Parameters
            % ----------
            % - foler: char vector
            %   Target folder
            % - format: char vector = 'mat'
            %   File foramt
            
            % default values
            if ~exist('format', 'var')
                format = 'mat';
            end
            
            format = ['*.', format];
            filenames = dir(fullfile(folder, format));
            filenames = arrayfun(...
                @(x) fullfile(x.folder, x.name), ...
                filenames, ...
                'UniformOutput', false ...
            );
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
            
            meanElapsedTimes = mean(stackOfElapsedTimes);
            stdElapsedTimes = std(stackOfElapsedTimes);
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

        function plotSomeRandomWalks(filenames)
            % Plot grid of random walks
            %
            % Parameters
            % ----------
            % - filenames: cell array of char vector
            %   Filenames of random-walks samples

            Viz.figure('Plot Grid of Random-Walks');

            numberOfFilenames = numel(filenames);
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
            
            % config plot
            legend('show');
            grid('on');
            grid('minor');
        end
        
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
            end
        end
        
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
    end

    % Unit test
    methods (Static)
        function test()
            % Test methods of `Viz` class
            runtests('./tests/TestViz.m');
        end
    end
    
end

