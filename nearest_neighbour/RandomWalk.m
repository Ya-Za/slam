classdef RandomWalk < handle
    %Gaussian random walk process

    properties
        % Properties
        % ----------
        % - std: double = 1
        %   Standard deviation of normally distributed pseudorandom number
        %   generator
        % - maxDistance: double = 10
        %   Maximum distance. Axes limits is [-maxDistance, maxDistance]
        % - numberOfPoints: int = 100
        %   Number of output points
        % - numberOfDimensions: int = 2
        %   Number of dimensions of each points. Either `2` or `3`
        
        std = 1;
        maxDistance = 10;
        numberOfPoints = 100;
        numberOfDimensions = 2;
    end
    
    methods
        function obj = RandomWalk(...
                std, ...
                maxDistance, ...
                numberOfPoints, ...
                numberOfDimensions ...
            )
            % Construtor
            
            obj.std = std;
            obj.maxDistance = maxDistance;
            obj.numberOfPoints = numberOfPoints;
            obj.numberOfDimensions = numberOfDimensions;
        end
        function points = getPoints(obj)
            % Get points of gaussian random walk
            %
            % Returns
            % -------
            % - points: d-by-n double matrix
            %   Ouput pionts. [p1, p2, ...] 
            
            % points
            % - initialize
            points = zeros(obj.numberOfDimensions, obj.numberOfPoints);
            
            % - generate
            % the first point is zero
            for indexOfPoint = 2:obj.numberOfPoints
                for indexOfDimension = 1:obj.numberOfDimensions
                    value = points(indexOfDimension, indexOfPoint - 1);
                    step = obj.std * randn();
                    
                    if obj.isValid(value + step)
                        value = value + step;
                    elseif obj.isValid(value - step)
                        value = value - step;
                    end
                    
                    points(indexOfDimension, indexOfPoint) = value;
                end
            end
        end
        
        function tf = isValid(obj, value)
            % Check if input `value` is in valid range
            %
            % Returns
            % -------
            % - tf: logical
            %   True or faluse result

            tf =  ...
                value >= -obj.maxDistance && ...
                value <= obj.maxDistance;
        end
        
        function outDir = saveSamples(obj, outDir, numberOfSamples)
            % Generate and save random walk samples
            %
            % Parameters
            % ----------
            % - outDir: char vector = './assets'
            %   Path of output directory
            % - numberOfSamples: int = 100
            %   Number of random walk samples
            %
            % Returns
            % -------
            % - outDir: char vector
            %   Maked output directory
            
            % default values
            % - outDir
            if ~exist('outDir', 'var')
                outDir = './assets';
            end
            if ~exist('numberOfSamples', 'var')
                numberOfSamples = 100;
            end
            
            % specify name of output folder
            % format string
            %     s -> std
            %     m -> maxDistance
            %     d -> numberOfDimensions
            %     n -> numberOfPoints
            outDir = fullfile(...
                outDir, ...
                sprintf('s%dm%dd%dn%d', ...
                    obj.std, ...
                    obj.maxDistance, ...
                    obj.numberOfDimensions, ...
                    obj.numberOfPoints ...
                ), ...
                'samples' ...
            );
            if ~exist(outDir, 'dir')
                mkdir(outDir);
            else
                return
            end
        
            % save generated random walks
            % - get number of previous saved samples
            lastNumberOfSamples = numel(dir(fullfile(outDir, '*.mat')));
            
            % `parfor` parallel for
            for indexOfSample = (lastNumberOfSamples + 1):numberOfSamples
                points = obj.getPoints();
                outFile = fullfile(...
                    outDir, ...
                    num2str(indexOfSample) ...
                );
                
                obj.saveSample(outFile, points);
            end
        end
        
        function saveSample(obj, filename, points)
            % Save generated random walk with its config
            %
            % Parameters
            % ----------
            % - filename: char vector
            %   Path of output file
            % - points: d-by-n double matrix
            %   Ouput pionts. [p1, p2, ...]
            
            config = struct(...
                'std', obj.std, ...
                'maxDistance', obj.maxDistance, ...
                'numberOfPoints', obj.numberOfPoints, ...
                'numberOfDimensions', obj.numberOfDimensions ...
            );
        
            input = struct(...
                'config', config, ...
                'points', points ...
            );
        
            save(filename, 'input');
        end
    end
end

