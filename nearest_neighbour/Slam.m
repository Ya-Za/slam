classdef Slam
    % Simultaneous Localization and Mapping
    
    properties
    end
    
    methods (Static)
        function samplesDir = makeAndSaveRandomWalks(s, D, n, d, rootDir, N)
            % Make and save random-walks
            %
            % Parameters
            % - s: double
            %   Standard deviation
            % - D: double
            %   Maximum distance from origin
            % - n: int
            %   Number of points
            % - d: int
            %   Number of dimenstions
            % - rootDir: char vector
            %   Root directory
            % - N: int
            %   Number of samples
            
            % make
            rw = RandomWalk(s, D, n, d);
            % save
            samplesDir = rw.saveSamples(rootDir, N);
            
            % add orientations
            filenames = Viz.getFilenames(samplesDir);
            for i = 1:numel(filenames)
                filename = filenames{i};
                input = getfield(load(filename), 'input');
                input.orientations = rw.getPoints();
                save(filename, 'input');
            end
        end
        function plotAndSaveResults(rootDir)
            % Make `results` folder in `roodDir` folder, then plot and save
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
            
            % plot and save
            Slam.plotCameraRandomWalksFromDir(rootDir, outDir);
        end
    end
    
    % Viz
    methods (Static)
        function orientations = pointsToOrientations(points)
            % Convert 3-by-n points to rotation matrices
            %
            % Parameters
            % ----------
            % - points: 3-by-n double matrix
            %   Random path
            %
            % Returns
            % -------
            % - orientations: 3-by-3-by-n double array
            %   Rotation matrices
            
            n = size(points, 2);
            
            orientations = zeros(3, 3, n);
            for i = 1:n
                orientations(:, :, i) = pointToOrientation(points(:, i));
            end
            
            function R = pointToOrientation(point)
                % Convert 3D point to 3D rotation matrix
                %
                % Parameters
                % ----------
                % - point: 3-by-1 double vector
                %   3D point
                %
                % Returns
                % -------
                % - R: 3-by-3 double matrix
                %   3D rotation matrix
                
                z = [0, 0, 1]';
                eps = 1e-6;
                ax = cross(z, point);
                normAx = norm(ax);
                if normAx < eps
                    R = eye(3);
                    return;
                end
                ax = ax / norm(ax);
                
                a = acos(dot(z, ax));
                
                R = axisAngleToRotationMatrix(ax, a);
            end
            
            function R = axisAngleToRotationMatrix(ax, a)
                % Convert 3D axis and angle to 3D rotation matrix
                %
                % Parameters
                % ----------
                % - ax: 3-by-1 double vector
                %   Axis, a 3D vector
                % - a: double
                %   Angle
                %
                % Returns
                % -------
                % - R: 3-by-3 double matrix
                %   3D rotation matrix

                s = sin(a);
                c = cos(a);
                t = 1 - c;

                normAx = norm(ax);
                if normAx < eps
                    ax = zeros(size(ax));
                else
                    ax = ax / normAx;
                end

                x = ax(1);
                y = ax(2);
                z = ax(3);
                R = [
                    t*x*x + c    t*x*y - s*z  t*x*z + s*y
                    t*x*y + s*z  t*y*y + c    t*y*z - s*x
                    t*x*z - s*y  t*y*z + s*x  t*z*z + c
                ];
            end
        end
        function plotCameraRandomWalksFromDir(rootDir, outDir)
            % Plot camera random-walks from dir
            %
            % Parameters
            % ----------
            % - rootDir: char vector
            %   Path of input directory
            % - outDir: cahr vector
            %   Path of output directory
            
            % default values
            if ~exist('outDir', 'var')
                outDir = [];
            end
            
            % filenames
            filenames = Viz.getFilenames(rootDir);
            
            for i = 1:numel(filenames)
                % figure
                title = sprintf(...
                    'Plot Camera Random-Walk - %d', ...
                    i ...
                );
                Viz.figure(title);
                
                filename = filenames{i};
                
                Slam.plotCameraRandomWalkFromFile(filename);
                
                % - save
                if ~isempty(outDir)
                    savefig(fullfile(outDir, ['rw', num2str(i)]));
                end
            end
        end
        function plotCameraRandomWalkFromFile(filename)
            % Plot camera random-walk from file
            %
            % Parameters
            % ----------
            % - filename: char vector
            %   Filename of random-walk sample
            
            sample = load(filename);
            locations = sample.input.points;
            orientations = Slam.pointsToOrientations(...
                sample.input.orientations...
            );
            maxDistance = sample.input.config.maxDistance;

            Slam.plotCameraRandomWalk(locations, orientations);
        end
        function plotCameraRandomWalk(locations, orientations)
            % Plot camera random-walk
            
            % Plot
            % - line
            %   - properties
            lineColor = Viz.color.lightGray;
            
            %   - plot
            line(...
                'XData', locations(1, :), ...
                'YData', locations(2, :), ...
                'ZData', locations(3, :), ...
                'Color', lineColor ...
            );
        
            % - camera
            hold('on');
            %   - properties
            cameraSize = 0.2;
            firstCameraColor = [0.2, 0.5, 0.2];
            cameraColor = [0.5, 0.2, 0.2];
            lastCameraColor = [0.2, 0.2, 0.5];
            cameraOpacity = 0;
            cameraVisibility = true;
            cameraAxesVisibility = false;
            
            %   - plot
            n = size(locations, 2);
            %   - first
            i = 1;
            cameraLabel = num2str(i);
            cameraLabel = '';
            plotCamera(...
                'Location', locations(:, i)', ...
                'Orientation', orientations(:, :, i)', ...
                'Size', cameraSize, ...
                'Label', cameraLabel, ...
                'Color', firstCameraColor, ...
                'Opacity', cameraOpacity, ...
                'Visible', cameraVisibility, ...
                'AxesVisible', cameraAxesVisibility ...
            );
            %   - others
            for i = 2:(n - 1)
                cameraLabel = num2str(i);
                cameraLabel = '';
                plotCamera(...
                    'Location', locations(:, i)', ...
                    'Orientation', orientations(:, :, i)', ...
                    'Size', cameraSize, ...
                    'Label', cameraLabel, ...
                    'Color', cameraColor, ...
                    'Opacity', cameraOpacity, ...
                    'Visible', cameraVisibility, ...
                    'AxesVisible', cameraAxesVisibility ...
                );
            end
             %   - last
            i = n;
            cameraLabel = num2str(i);
            cameraLabel = '';
            plotCamera(...
                'Location', locations(:, i)', ...
                'Orientation', orientations(:, :, i)', ...
                'Size', cameraSize, ...
                'Label', cameraLabel, ...
                'Color', lastCameraColor, ...
                'Opacity', cameraOpacity, ...
                'Visible', cameraVisibility, ...
                'AxesVisible', cameraAxesVisibility ...
            );
            
            hold('off');
            
            % - config
            set(gca, ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [], ...
                'ZTick', [] ...
            );
            axis('square');
            view(3);
        end
    end
    
    % Main
    methods (Static)
        % todo: change the name of `main` to `randomWalk`
        function main()
            % Random-walk
            
            % - make and save
            s = 1;
            D = 10;
            n = 100;
            d = 3;
            rootDir = './assets/slam/data';
            N = 9;
            
            samplesDir = Slam.makeAndSaveRandomWalks(...
                s, ...
                D, ...
                n, ...
                d, ...
                rootDir, ...
                N ...
            );
            
            
            
            % - plot and save
            %   - camera locations
            Slam.plotAndSaveResults(samplesDir);
            %   - camera poses (location + orientation)
            %   - camera axes
            %   - circumspheres
        end
    end
    
end

