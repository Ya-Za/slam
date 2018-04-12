classdef Slam
    % Simultaneous Localization and Mapping
    
    properties
    end
    
    % Input
    methods (Static)
        function samplesDir = makeAndSaveRandomWalks(...
                std, ...
                noiseStd, ...
                maxDistance, ...
                numberOfPoints, ...
                numberOfDimensions, ...
                rootDir, ...
                numberOfSamples ...
        )
            % Make and save random-walks
            %
            % Parameters
            % - std: double
            %   Standard deviation
            % - noiseStd: double
            %   Standard deviation of noise
            % - maxDistance: double
            %   Maximum distance from origin
            % - numberOfPoints: int
            %   Number of points
            % - numberOfDimensions: int
            %   Number of dimenstions
            % - rootDir: char vector
            %   Root directory
            % - N: int
            %   Number of samples
            
            % make
            rw = RandomWalk(std, maxDistance, numberOfPoints, numberOfDimensions);
            % save
            samplesDir = rw.saveSamples(rootDir, numberOfSamples);
            
            % add orientations and noises
            filenames = Viz.getFilenames(samplesDir);
            for i = 1:numel(filenames)
                filename = filenames{i};
                sample = load(filename);
                input = sample.input;
                
                % - orientations
                input.orientations = rw.getPoints();
                
                % - noise
                %   - locations
                input.locationNoises = makeNoises(noiseStd, numberOfPoints, numberOfDimensions);
                %   - orientations
                input.orientationNoises = makeNoises(noiseStd, numberOfPoints, numberOfDimensions);
                %   - config
                input.config.noiseStd = noiseStd;
                
                save(filename, 'input');
            end
            
            % Local functions
            function noises = makeNoises(std, n, d)
                noises = zeros(n, n, d);
                for dimension = 1:d
                    noises(:, :, dimension) = tril(std * randn(n), -1);
                end
            end
        end
        function plotAndSaveResults(rootDir)
            % Make `results` folder in `roodDir` folder, then plot and save
            % results in it
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
            %   - random walk
            Slam.plotCameraRandomWalksFromDir(rootDir, outDir);
            %   - drift
            %       - icp
            Slam.plotDriftOfMethodFromDir(rootDir, 'icp', outDir);
            %       - picp
            Slam.plotDriftOfMethodFromDir(rootDir, 'picp', outDir);
        end
    end
    
    % Output
    methods (Static)
        % icp
        function estimatedLocations = icpLocations(actualLocations, noises)
            % Get estimated-locations of `icp`
            
            [d, n] = size(actualLocations);
            estimatedLocations = zeros(d, n);
            
            for i = 2:n
                estimatedLocations(:, i) = ...
                    estimatedLocations(:, i - 1) + ...
                    actualLocations(:, i) - actualLocations(:, i - 1) + ...
                    getNoiseVector(i);
            end
            
            % Local functions
            function noiseVector = getNoiseVector(i)
                noiseVector = zeros(d, 1);
                for j = 1:d
                    noiseVector(j) = noises(i, i - 1, j);
                end
            end
        end
        function estimatedOrientations = icpOrientations(actualOrientations, noises)
            % Get estimated-orientations of `icp`
            
            estimatedOrientations = Slam.icpLocations(...
                actualOrientations, ...
                noises ...
            );
%             estimatedOrientations = Slam.pointsToOrientations(...
%                 estimatedOrientations ...
%             );
        end
        function [estimatedLocations, estimatedOrientations] = icp(...
                locations, locationNoises, ...
                orientations, orientationNoises ...
        )
            % Get estimated-locations and estimated-orientations of `icp`
            
            estimatedLocations = Slam.icpLocations(...
                locations, ...
                locationNoises ...
            );
            estimatedOrientations = Slam.icpOrientations(...
                orientations, ...
                orientationNoises ...
            );
        end
        % picp (probabilistic icp)
        function estimatedLocations = picpLocations(actualLocations, noises)
            % Get estimated-locations of `picp`
            r = 2;
            rr = 2 * r;
            eps = 1e-3;
            
            [d, n] = size(actualLocations);
            estimatedLocations = zeros(d, n);
            V = zeros(1, n); % variance of each position
            
            for i = 2:n
                firstGuess = getNoisyTranslation(i, i - 1);
                
                predictions = [];
                variances = [];
                for j = 1:(i - 1)
                    dist = norm(firstGuess - estimatedLocations(:, j));
                    if dist < rr
                        predictions(:, end + 1) = ...
                            estimatedLocations(:, j) + ...
                            getNoisyTranslation(i, j);
                        
                        var = V(j) + (1.5 * dist / r)^2;
                        if var < eps
                            var = eps;
                        end
                        variances(end + 1) = var;
                    end
                end
                
                if isempty(predictions)
                    estimatedLocations(:, i) = firstGuess;
                else
                    [estimatedLocations(:, i), V(i)] = update(predictions, variances);
                end
            end
            
            % Local functions
            function noiseVector = getNoiseVector(i, j)
                noiseVector = zeros(d, 1);
                for dimenstionIndex = 1:d
                    noiseVector(dimenstionIndex) = noises(i, j, dimenstionIndex);
                end
            end
            function translation = getTranslation(i, j)
                translation = ...
                    actualLocations(:, i) - actualLocations(:, j);
            end
            function noisyTranslation = getNoisyTranslation(i, j)
                noisyTranslation = ...
                    getTranslation(i, j)+ ...
                    getNoiseVector(i, j);
            end
            function [location, V] = update(predictions, variances)
                variances = 1 ./ variances;
                V =  1 / sum(variances);
                variances = V * variances;
                location = sum(variances .* predictions, 2);
            end
        end
        function estimatedOrientations = picpOrientations(actualOrientations, noises)
            % Get estimated-orientations of `picp`
            
            estimatedOrientations = Slam.picpLocations(...
                actualOrientations, ...
                noises ...
            );
%             estimatedOrientations = Slam.pointsToOrientations(...
%                 estimatedOrientations ...
%             );
        end
        function [estimatedLocations, estimatedOrientations] = picp(...
                locations, locationNoises, ...
                orientations, orientationNoises ...
        )
            % Get estimated-locations and estimated-orientations of `picp`
            
            estimatedLocations = Slam.picpLocations(...
                locations, ...
                locationNoises ...
            );
            estimatedOrientations = Slam.picpOrientations(...
                orientations, ...
                orientationNoises ...
            );
        end
        % method
        function [estimatedLocations, estimatedOrientations] = methodFromFile(filename, methodName)
            % Get estimated-locations and estimated-orientations of given
            % method from input filename and save them to the
            % `output.icp.locations` and `output.icp.orientations` fields
            
            sample = load(filename); 
            input = sample.input;
            if isfield(sample, 'output')
                output = sample.output;
            end
            

            [estimatedLocations, estimatedOrientations] = Slam.(methodName)(...
                input.points, ...
                input.locationNoises, ...
                input.orientations, ...
                input.orientationNoises ...
            );
        
            output.(methodName).locations = estimatedLocations;
            output.(methodName).orientations = estimatedOrientations;
            
            save(filename, 'output', '-append');
        end
        function methodFromDir(samplesDir, methodName)
            % Iterative closest point
            
            filenames = Viz.getFilenames(samplesDir);
            for i = 1:numel(filenames)
                Slam.methodFromFile(filenames{i}, methodName);
            end
        end
        % error
        function error = locationsError(actualLocations, estimatedLocations)
            % RMSE of locations
            
            error = 0;
            n = size(actualLocations, 2);
            for i = 1:n
                t = actualLocations(:, i);
                t_ = estimatedLocations(:, i);
                error = error + norm(t - t_, 2) ^ 2;
            end
            
            error = sqrt(error / n);
        end
        function error = orientationsError(actualPoints, estimatedPoints)
            % RMSE of locations
            
            error = 0;
            n = size(actualPoints, 2);
            
            actualOrientations = Slam.pointsToOrientations(actualPoints);
            estimatedOrientations = Slam.pointsToOrientations(estimatedPoints);
            for i = 1:n
                R = actualOrientations(:, :, i);
                R_ = estimatedOrientations(:, :, i);
                error = error + norm(R - R_, 'fro') ^ 2;
            end
            
            error = sqrt(error / n);
        end
        function methodErrorFromFile(filename, methodName)
            % RMSE of locations and orientations of specified method from 
            % input filename
            
            sample = load(filename); 
            input = sample.input;
            output = sample.output;

            locationsError = Slam.locationsError(...
                input.points, ...
                output.(methodName).locations ...
            );
            orientationsError = Slam.orientationsError(...
                input.orientations, ...
                output.(methodName).orientations ...
            );
        
            output.(methodName).locationsError = locationsError;
            output.(methodName).orientationsError = orientationsError;
            
            save(filename, 'output', '-append');
        end
        function methodErrorFromDir(samplesDir, methodName)
            % RMSE of locations and orientations of specified method from
            % samples-directory
            
            filenames = Viz.getFilenames(samplesDir);
            for i = 1:numel(filenames)
                Slam.methodErrorFromFile(filenames{i}, methodName);
            end
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
            
            % Local functions
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
        function props = updateProperties(props1, props2)
            % Uupdate fields of `props2` to `props1`
            
            props = props1;
            names = fieldnames(props2);
            for i = 1:numel(names)
                props.(names{i}) = props2.(names{i});
            end
        end
        % camera random-walk
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
                
                Slam.plotCameraRandomWalkFromFile(filenames{i});
                
                % - save
                if ~isempty(outDir)
                    savefig(...
                        fullfile(...
                            outDir, ...
                            sprintf('rw_%d', i) ...
                        ) ...
                    );
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
        function plotCameraRandomWalk(locations, orientations, props)
            % Plot camera random-walk
            
            % default values
            if (~exist('props', 'var'))
                props = struct();
            end
            
            % properties
            P.lineColor = Viz.color.lightGray;
            P.cameraSize = 0.2;
            P.firstCameraColor = [0.2, 0.5, 0.2];
            P.cameraColor = [0.2, 0.2, 0.5];
            P.lastCameraColor = [0.5, 0.2, 0.2];
            P.cameraOpacity = 0;
            P.cameraVisibility = true;
            P.cameraAxesVisibility = false;
            
            P = Slam.updateProperties(P, props);
            
            % Plot
            % - line
            line(...
                'XData', locations(1, :), ...
                'YData', locations(2, :), ...
                'ZData', locations(3, :), ...
                'Color', P.lineColor ...
            );
        
            % - camera
            hold('on');
            
            %   - plot
            n = size(locations, 2);
            %   - first
            i = 1;
            cameraLabel = num2str(i);
            cameraLabel = '';
            plotCamera(...
                'Location', locations(:, i)', ...
                'Orientation', orientations(:, :, i)', ...
                'Size', P.cameraSize, ...
                'Label', cameraLabel, ...
                'Color', P.firstCameraColor, ...
                'Opacity', P.cameraOpacity, ...
                'Visible', P.cameraVisibility, ...
                'AxesVisible', P.cameraAxesVisibility ...
            );
            %   - others
            for i = 2:(n - 1)
                cameraLabel = num2str(i);
                cameraLabel = '';
                plotCamera(...
                    'Location', locations(:, i)', ...
                    'Orientation', orientations(:, :, i)', ...
                    'Size', P.cameraSize, ...
                    'Label', cameraLabel, ...
                    'Color', P.cameraColor, ...
                    'Opacity', P.cameraOpacity, ...
                    'Visible', P.cameraVisibility, ...
                    'AxesVisible', P.cameraAxesVisibility ...
                );
            end
             %   - last
            i = n;
            cameraLabel = num2str(i);
            cameraLabel = '';
            plotCamera(...
                'Location', locations(:, i)', ...
                'Orientation', orientations(:, :, i)', ...
                'Size', P.cameraSize, ...
                'Label', cameraLabel, ...
                'Color', P.lastCameraColor, ...
                'Opacity', P.cameraOpacity, ...
                'Visible', P.cameraVisibility, ...
                'AxesVisible', P.cameraAxesVisibility ...
            );
            
            hold('off');
            
            % - config
            set(gca, ...
                'Box', 'on', ...
                'XTick', [], ...
                'YTick', [], ...
                'ZTick', [] ...
            );
            axis('equal');
            axis('tight');
            view(3);
            view(-45, 30);
        end
        % drift
        function plotDriftOfMethodFromDir(rootDir, methodName, outDir)
            % Plot drift of specific method from dir
            %
            % Parameters
            % ----------
            % - rootDir: char vector
            %   Path of input directory
            % - methodName: char vector
            %   Name of method
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
                    'Plot Drift of %s Method - Sample %d', ...
                    methodName, ...
                    i ...
                );
                Viz.figure(title);
                
                Slam.plotDriftOfMethodFromFile(filenames{i}, methodName);
                
                % - save
                if ~isempty(outDir)
                    savefig(...
                        fullfile(...
                            outDir, ...
                            sprintf('%s_drift_%d', methodName, i) ...
                        ) ...
                    );
                end
            end
        end
        function plotDriftOfMethodFromFile(filename, methodName)
            % Plot drift of specific method from dir
            %
            % Parameters
            % ----------
            % - filename: char vector
            %   Filename of random-walk sample
            % - methodName: char vector
            %   Name of method
            
            sample = load(filename);
            
            actualLocations = sample.input.points;
            actualOrientations = Slam.pointsToOrientations(...
                sample.input.orientations ...
            );
            estimatedLocations = sample.output.(methodName).locations;
            estimatedOrientations = Slam.pointsToOrientations(...
                sample.output.(methodName).orientations ...
            );

            Slam.plotDrift(...
                actualLocations, ...
                actualOrientations, ...
                estimatedLocations, ...
                estimatedOrientations ...
            );
        end
        function plotDrift(...
            actualLocations, ...
            actualOrientations, ...
            estimatedLocations, ...
            estimatedOrientations ...
        )
            % Plot drift
            %
            % Parameters
            % ----------
            % - actualLocations: d-by-n double matrix
            %   Actual camera locations
            % - actualOrientations: d-by-d-by-n duble array
            %   Actual camera orientations
            % - estimatedLocations: d-by-n double matrix
            %   Estimated camera locations
            % - estimatedOrientations: d-by-d-by-n duble array
            %   Estimated camera orientations
            
            % properties
            blue = [0.2, 0.2, 0.5];
            red = [0.5, 0.2, 0.2];
            cameraSize = 0.2;
            actualProps = struct(...
                'lineColor', blue, ...
                'cameraSize', cameraSize, ...
                'firstCameraColor', blue, ...
                'cameraColor', blue, ...
                'lastCameraColor', blue, ...
                'cameraVisibility', true ...
            );
            estimatedProps = struct(...
                'lineColor', red, ...
                'cameraSize', cameraSize, ...
                'firstCameraColor', red, ...
                'cameraColor', red, ...
                'lastCameraColor', red, ...
                'cameraVisibility', true ...
            );
            
            % actual
            Slam.plotCameraRandomWalk(...
                actualLocations, ...
                actualOrientations, ...
                actualProps ...
            );
            hold('on');
            
            % estimated
            Slam.plotCameraRandomWalk(...
                estimatedLocations, ...
                estimatedOrientations, ...
                estimatedProps ...
            );
            hold('off');
        end
        % rmse
        function [numberOfPoints, locationsError, orientationsError] = ...
                getMethodErrorFromFile(filename, methodName)
            
            sample = load(filename);
            
            numberOfPoints = sample.input.config.numberOfPoints;
            locationsError = sample.output.(methodName).locationsError;
            orientationsError = sample.output.(methodName).orientationsError;
        end
        function [numberOfPoints, locationsError, orientationsError] = getMethodErrorFromDir(rootDir, methodName)
            
            % filenames
            filenames = Viz.getFilenames(fullfile(rootDir, '**'));
            n = numel(filenames);
            
            numberOfPoints = zeros(n, 1);
            locationsError = zeros(n, 1);
            orientationsError = zeros(n, 1);
            for i = 1:n
                [
                    numberOfPoints(i), ...
                    locationsError(i), ...
                    orientationsError(i) ...
                ] = Slam.getMethodErrorFromFile(...
                    filenames{i}, ...
                    methodName ...
                );
            end
            
            T = table(...
                numberOfPoints, ...
                locationsError, ...
                orientationsError, ...
                'VariableNames', {
                    'numberOfPoints'
                    'locationsError'
                    'orientationsError'
                } ...
            );
        
            % mean
            M = varfun(@mean, T, 'GroupingVariables', 'numberOfPoints');
            numberOfPoints = M.numberOfPoints;
            locationsError = M.mean_locationsError;
            orientationsError = M.mean_orientationsError;
            
            % mean
            S = varfun(@std, T, 'GroupingVariables', 'numberOfPoints');
            locationsError(:, 2) = S.std_locationsError;
            orientationsError(:, 2) = S.std_orientationsError;
        end
        function plotErrors()
            rootDir = './assets/slam/data';
            
            % errors
            % - icp
            methodName = 'icp';
            [...
                numberOfPoints, ...
                icpLocationsError, ...
                icpOrientationsError ...
            ] = Slam.getMethodErrorFromDir(rootDir, methodName);
            % - picp
            methodName = 'picp';
            [...
                ~, ...
                picpLocationsError, ...
                picpOrientationsError ...
            ] = Slam.getMethodErrorFromDir(rootDir, methodName);
            
            % plot
            % - locations
            plotErrorBar(...
                numberOfPoints, ...
                icpLocationsError, ...
                picpLocationsError, ...
                'Locations' ...
            );
            % - orientations
            plotErrorBar(...
                numberOfPoints, ...
                icpOrientationsError, ...
                picpOrientationsError, ...
                'Orientations' ...
            );
            
            % Local functions
            function plotErrorBar(x, y1, y2, name)
                % - properties
                lineWidth = 1;
                marker = 's';
                % - locations
                Viz.figure(sprintf('Camera %s RMSE', name));
                errorbar(...
                    x, ...
                    y1(:, 1), ...
                    y1(:, 2), ...
                    'Marker', marker, ...
                    'LineWidth', lineWidth ...
                );
                hold('on');
                errorbar(...
                    x, ...
                    y2(:, 1), ...
                    y2(:, 2), ...
                    'Marker', marker, ...
                    'LineWidth', lineWidth ...
                );
                hold('off');
                % - config
                title(...
                    sprintf('Camera %s', name), ...
                    'FontSize', Viz.fontSize.title ...
                );
                xlabel(...
                    'N', ...
                    'FontSize', Viz.fontSize.axis ...
                );
                ylabel(...
                    'RMSE', ...
                    'FontSize', Viz.fontSize.axis ...
                );

                legend(...
                    {'ICP', 'Probabilistic ICP'}, ...
                    'FontSize', Viz.fontSize.legend ...
                );

                box('off');

                x(2) = [];
                set(gca, ...
                    'XTick', x, ...
                    'YGrid', 'on', ...
                    'FontSize', Viz.fontSize.label ...
                );
            end
        end
    end
    
    % Main
    methods (Static)
        function main()
            % Main
            
            % properties
            % - static fields
            std = 1;
            noiseStd = 1;
            numberOfDimensions = 3;
            rootDir = './assets/slam/data';
            numberOfSamples = 10;
            maxDistance = 1000;
            % - dynamic fields
            numberOfPoints = [10, 20, 50, 100, 200, 500, 1000];
            
            % props
            props = struct();
            % - static fields
            props.std = std;
            props.noiseStd = noiseStd;
            props.numberOfDimensions = numberOfDimensions;
            props.rootDir = rootDir;
            props.numberOfSamples = numberOfSamples;    
            props.maxDistance = maxDistance;
                
            for i = 1:numel(numberOfPoints)
                % - dynamic fields
                props.numberOfPoints = numberOfPoints(i);
                
                tic();
                Slam.run(props);
                toc();
            end
            
        end
        function run(props)
            % Run
            
            % input
            samplesDir = Slam.makeAndSaveRandomWalks(...
                props.std, ...
                props.noiseStd, ...
                props.maxDistance, ...
                props.numberOfPoints, ...
                props.numberOfDimensions, ...
                props.rootDir, ...
                props.numberOfSamples ...
            );
            
            % output
            % - icp
            Slam.methodFromDir(samplesDir, 'icp');
            % - picp
            Slam.methodFromDir(samplesDir, 'picp');
            
            % error
            % - icp
            Slam.methodErrorFromDir(samplesDir, 'icp');
            % - picp
            Slam.methodErrorFromDir(samplesDir, 'picp');
            
            % - viz
            % Slam.plotAndSaveResults(samplesDir);
        end
    end
    
end
