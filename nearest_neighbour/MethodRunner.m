classdef MethodRunner < handle
    %Run given nearest neighbours methods on input data and save results

    properties
        % Properties
        % ----------
        % - methods_: cell array of function_handle
        %   Input nearest neighbours methods
        % - rootDir: char vector
        %   Path of root of output directory
        % - intersectionObj: Intersection
        %   Has `haveIntersection` method
        % - info: struct
        %   Extra information such as `maxDistance`, `numberOfPoints`,
        %   ...

        methods_
        rootDir
        intersectionObj
        info
        % todo: add `overwrite` property
    end
    
    methods
        function run(obj)
            % Run

            % list all of input files
            filenames = dir(fullfile(...
                obj.rootDir, ...
                '*.mat' ...
            ));

            parfor indexOfFilenames = 1:numel(filenames)
                filename = fullfile(...
                    obj.rootDir, ...
                    filenames(indexOfFilenames).name ...
                );

                % load input pionts
                sample = load(filename);
                points = sample.input.points;
                numberOfPoints = size(points, 2);

                for indexOfMethod = 1:numel(obj.methods_)
                    % init time
                    % - begin time
                    beginTime = cputime();
                    methodHnadler = obj.methods_(indexOfMethod).handler;
                    method = methodHnadler(...
                        obj.intersectionObj, ...
                        obj.info, ...
                        obj.methods_(indexOfMethod).params ...
                    );
                    % - end time
                    initTime = cputime() - beginTime;

                    methodName = func2str(methodHnadler);
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

                    % `save(filename, '-struct', 'sample')` can not be call
                    % in `parfor` loop
                    MethodRunner.safeSave(filename, sample);
                end
            end
        end
    end
    
    methods (Static)
        function safeSave(filename, value)
            % Save end of `parloop`
            %
            % Parameters
            % ----------
            % - filename: char vector
            %   Filename of output file
            % - value: struct
            %   Value have to be saved
            
            save(filename, '-struct', 'value');
        end
    end
end
