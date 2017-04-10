classdef MethodRunner
    %Run given nearest neighbours methods on input data and save results

    properties
        % Properties
        % ----------
        % - methods_: cell array of function_handle
        %   Input nearest neighbours methods
        % - inputDirs: cell array of char vector
        %   Path of input directories
        % - rootDir: char vector
        %   Path of root of output directory
        % - intersectionObj: Intersection
        %   Has `haveIntersection` method

        methods_ = {@nn};
        inputDirs = {};
        rootDir = './assets/outputs';
        intersectionObj = [];
    end
    
    methods
        function run(obj)
            % Run
            
            for indexOfMethod = 1:numel(obj.methods_)
                method = obj.methods_{indexOfMethod};
                
                for indexOfInputDir = 1:numel(obj.inputDirs)
                    inputDir = obj.inputDirs{indexOfInputDir};
                    
                    % list all of input files
                    listing = dir(fullfile(...
                        inputDir, ...
                        '*.mat' ...
                    ));
                
                    % path of output directory
                    [~, inputDirName, ~] = fileparts(inputDir);
                    outputDir = fullfile(...
                        obj.rootDir, ...
                        inputDirName, ...
                        func2str(method) ...
                    );

                    if ~exist(outputDir, 'dir')
                        mkdir(outputDir)
                    end
                    
                    for indexOfInputFile = 1:numel(listing)
                        inputFile = fullfile(...
                            listing(indexOfInputFile).folder, ...
                            listing(indexOfInputFile).name ...
                        );
                    
                        % load input pionts
                        points = getfield(load(inputFile), 'points');
                        
                        % elapsed time
                        % - begin time
                        beginTime = cputime();
                        % compute output
                        output = method(points, obj.intersectionObj);
                        % - end time
                        elapsedTime = cputime() - beginTime;
                        
                        % save
                        outputFile = fullfile(...
                            outputDir, ...
                            listing(indexOfInputFile).name ...
                        );
                    
                        save(outputFile, 'elapsedTime', 'output');
                    end
                end
            end
        end
    end
    
end
