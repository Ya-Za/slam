classdef MethodRunner < handle
    %Run given nearest neighbours methods on input data and save results

    properties
        % Properties
        % ----------
        % - methods_: cell array of function_handle
        %   Input nearest neighbours methods
        % - rootDir: char vector
        %   Path of root of output directory
        % - inputDirs: cell array of char vector
        %   Path of input directories with respect to `rootDir`
        % - intersectionObj: Intersection
        %   Has `haveIntersection` method

        methods_
        rootDir = './assets';
        inputDirs
        intersectionObj = Intersection();
        % todo: add `overwrite` property
        config
    end
    
    methods
        function init(obj)
            % Initilize properties
            
            % inputDirs
            % - if `inputDirs` is empty put name of sub-folders of `rootDir`
            %   in it
            if isempty(obj.inputDirs)
                obj.inputDirs = dir(obj.rootDir);
                % remove `.` and `..`
                obj.inputDirs(1:2) = [];
                % select just directories not files
                obj.inputDirs = obj.inputDirs([obj.inputDirs.isdir]);
                % select name of directories
                obj.inputDirs = {obj.inputDirs.name};
            end
        end

        function run(obj)
            % Run
            
            % init
            obj.init();
            
            for indexOfMethod = 1:numel(obj.methods_)
                % init time
                % - begin time
                beginTime = cputime();
                methodHnadler = obj.methods_{indexOfMethod};
                method = methodHnadler(...
                    obj.intersectionObj, ...
                    obj.config ...
                );
                % - end time
                initTime = cputime() - beginTime;
                
                methodName = func2str(methodHnadler);
                
                for indexOfInputDir = 1:numel(obj.inputDirs)
                    inputDir = fullfile(...
                        obj.rootDir, ...
                        obj.inputDirs{indexOfInputDir} ...
                    );
                    
                    % list all of input files
                    listing = dir(fullfile(...
                        inputDir, ...
                        '*.mat' ...
                    ));
                    
                    for indexOfInputFile = 1:numel(listing)
                        inputFile = fullfile(...
                            listing(indexOfInputFile).folder, ...
                            listing(indexOfInputFile).name ...
                        );
                    
                        % load input pionts
                        sample = load(inputFile);
                        points = sample.input.points;
                        numberOfPoints = size(points, 2);
                        
                        % compute output
                        outputs = cell(1, numberOfPoints);
                        elapsedTimes = zeros(1, numberOfPoints);
                        for indexOfPoint = 1:numberOfPoints
                            point = points(:, indexOfPoint);
                            % elapsed time
                            % - begin time
                            beginTime = cputime();
                            outputs{indexOfPoint} = method.query(point);
                            % - end time
                            elapsedTimes(indexOfPoint) = ...
                                cputime() - beginTime;
                        end
                        
                        % save
                        sample.output.(methodName).initTime = initTime;
                        sample.output.(methodName).outputs = outputs;
                        sample.output.(methodName).elapsedTimes = elapsedTimes;

                        save(inputFile, '-struct', 'sample');
                    end
                end
            end
        end
    end
    
end
