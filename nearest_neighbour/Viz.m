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
        function plotRandomWalk(points, maxDistance)
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
            scatter(...
                x, y, ...
                'MarkerFaceColor', pointsColor, ...
                'MarkerEdgeColor', pointsColor ...
            );
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
            numberOfFilenames = numel(filenames);
            rows = ceil(sqrt(numberOfFilenames));
            cols = rows;
            
            for indexOfFilename = 1:numberOfFilenames
                filename = filenames{indexOfFilename};
                sample = load(filename);
                points = sample.input.points;
                numberOfPoints = size(points, 2);
                maxDistance = sample.input.config.maxDistance;
                
                subplot(rows, cols, indexOfFilename);
                Viz.plotRandomWalk(points, maxDistance);
            end
        end
        
        function animateRandomWalk(filename)
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
    end
    
    methods (Static)
        function test()
            % Test methods of `Viz` class
            runtests('./tests/TestViz.m');
        end
    end
    
end

