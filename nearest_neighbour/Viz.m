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
        function animateRandomWalk(filename)
            % Properties
            lineColor = Viz.color.lightGray;
            firstPointColor = Viz.color.darkRed;
            lastPointColor = Viz.color.darkBlue;
            pointsColor = Viz.color.gray;
            
            sample = load(filename);
            points = sample.input.points;
            numberOfPoints = size(points, 2);
            maxDistance = sample.input.config.maxDistance;
            
            % first point at origin
            Viz.plotPoint(points(:, 1), firstPointColor);
            hold('on');
            
            % todo: create funciton `plotRandomWalk` and call it in to the
            % following for
            for indexOfPoint = 2:numberOfPoints
                previousPoint = points(:, indexOfPoint - 1);
                currentPoint = points(:, indexOfPoint);
                
                line(...
                    [previousPoint(1), currentPoint(1)], ...
                    [previousPoint(2), currentPoint(2)], ...
                    'Color', lineColor ...
                );
            
                scatter(currentPoint(1), currentPoint(2), ...
                    'MarkerFaceColor', pointsColor, ...
                    'MarkerEdgeColor', pointsColor ...
                );
                
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
                
                pause(Viz.delay);
            end
            
            % last point
            Viz.plotPoint(points(:, end), lastPointColor);
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
    
end

