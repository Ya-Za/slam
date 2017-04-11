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

        methods_ = {@nn};
        rootDir = './assets';
        % todo: default value if it is null
        inputDirs = {};
        intersectionObj = Intersection();
        % todo: add `overwrite` property
    end
    
    methods
        function init(obj)
            % Initilize properties
            
            % inputDirs
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
                method = obj.methods_{indexOfMethod};
                methodName = func2str(method);
                
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
                        
                        % elapsed time
                        % - begin time
                        beginTime = cputime();
                        % compute output
                        sample.output.(methodName).output = ...
                            method(points, obj.intersectionObj);
                        % - end time
                        sample.output.(methodName).elapsedTime = ...
                            cputime() - beginTime;
                        
                        % save
                        save(inputFile, '-struct', 'sample');
                    end
                end
            end
        end
    end
    
end
