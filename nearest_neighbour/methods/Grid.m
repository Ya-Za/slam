classdef Grid < BaseNN
    %Grid based nearest neighbour method
    
    properties
        % Properties
        % ----------
        % - steps: int matrix
        %   Each column is a possible step
        % - numberOfNeighbourPositions: int
        %   Number of neighbours positions in grid (2 ^ number of
        %   dimensions)
        % - gridResolution: int
        %   Resolution of grid quantization
        % - grid: cell matrix of int vectors
        %   Data container of index of points
        steps
        numberOfNeighbourPositions
        gridResolution
        grid
    end
    
    methods
        function obj = Grid(intersectionObj, info, params)
            % Constructor

            % super-class constructor
            obj = obj@BaseNN(intersectionObj, info);
            
            % init
            obj.initSteps();
            
            obj.numberOfNeighbourPositions = size(obj.steps, 2);
            
            obj.gridResolution = params.gridResolution;
            
            maxDistance = obj.info.maxDistance;
            gridLength = ceil(2 * maxDistance / obj.gridResolution);
            % todo: write comment for following line
            gridLength = gridLength + 1;
            obj.grid = cell(gridLength);
        end
        
        function initSteps(obj)
            % Get all steps for going to neighbours

            zeroOne = [0, 1];
            % number of dimensions of each point
            numberOfDimensions = obj.info.numberOfDimensions;

            setOfZeroOnes = cell(1, numberOfDimensions);
            for indexOfDimension = 1:numberOfDimensions
                setOfZeroOnes{indexOfDimension} = zeroOne;
            end

            obj.steps = cell(1, numberOfDimensions);
            [obj.steps{:}] = ndgrid(setOfZeroOnes{:});

            obj.steps = cell2mat(...
                cellfun(@(x) x(:), ...
                obj.steps, ...
                'UniformOutput',false) ...
            );

            obj.steps = obj.steps';
        end
        
        function output = query(obj, point)
            point = point + obj.info.maxDistance + obj.gridResolution;
            % all neighbours
            neighbours = obj.getNeighbours(point);
            
            % filter
            % todo
            output = neighbours(...
                arrayfun(...
                    @(x) obj.intersectionObj.haveIntersection(point, obj.points{x}), ...
                    neighbours ...
                ) ...
            );
            
            % note: 9:20 PM 4/16/2017 Me and Hamed after boaring debug :)
%             output = [];
%             for indexOfPoint = neighbours
%                 if obj.intersectionObj.haveIntersection(point, obj.points{indexOfPoint})
%                     output = [output, indexOfPoint];
%                 end
%             end
            
            % add `point` to `points`
            obj.addPointToPoints(point);
            % add index to `grid`
            obj.addPointToGrid(point);
        end
        
        function addPointToGrid(obj, point)
            % Add index of point to `grid`
            %
            % Parameters
            % ----------
            % - point
            %   Target point

            % get position of nearest node in `grid`
            point = point + (obj.gridResolution / 2);
            position = floor(point / obj.gridResolution);

            position = num2cell(position);
            obj.grid{position{:}} = ...
                [obj.grid{position{:}}, numel(obj.points)];
        end
        
        function neighbours = getNeighbours(obj, point)
            % Get index of neighbours of given point
            %
            % Parameters
            % ----------
            % - point: double vector
            %   Target point

            bottomLeftPosition = floor(point / obj.gridResolution);
            % neighbourPositions = bottomLeftPosition + obj.steps;
            % < 2017
            neighbourPositions = ...
                repmat(bottomLeftPosition, 1, obj.numberOfNeighbourPositions) + ...
                obj.steps;

            % todo: replace concatenation with `import
            % java.util.LinkedList`
            neighbours = [];
            for indexOfNeighbourPosition = 1:obj.numberOfNeighbourPositions
                position = num2cell(...
                    neighbourPositions(:, indexOfNeighbourPosition) ...
                );
                neighbours = [neighbours, obj.grid{position{:}}];
            end
        end
    end
    
    methods (Static)
    end
end
