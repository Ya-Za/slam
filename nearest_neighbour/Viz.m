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
    end
    
    methods (Static)
        function test()
            % Test methods of `Viz` class
            runtests('./tests/TestViz.m');
        end
    end
    
end

