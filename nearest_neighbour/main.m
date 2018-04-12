%% Nearest Neighbour
%% Initialize
%%
close('all');
clear();
clc();
addpath('./methods');
%% Load and Run `Config` files
%%
rootDir = './assets/data';
% todo: make a `static` class `path` and put this path on it. Because we have
% same `configsDir` in `makeConfig` script
configsDir = './assets/configs';
filenames = Viz.getFilenames(configsDir);
numberOfFilenames = numel(filenames);

for indexOfFilename = 1:numberOfFilenames
    filename = filenames{indexOfFilename};
    config = load(filename);
    
    % begin message
    fprintf('(%d/%d) : %s\n', indexOfFilename, numberOfFilenames, filename);
    
    tic();
    % generate and save random-walks
    rw = RandomWalk(...
        config.std, ...
        config.maxDistance, ...
        config.numberOfPoints, ...
        config.numberOfDimensions ...
    );
    
    samplesDir = rw.saveSamples(rootDir, config.numberOfSamples);
    
    % copy `config` file
    [parentOfSamplesDir, ~, ~] = fileparts(samplesDir);
    copyfile(filename, fullfile(parentOfSamplesDir, 'config.mat'));
    
    % run methods
    % - intersection object
    intersectionObj = Intersection();
    intersectionObj.radius = config.radius;

    % - MethodRunner
    mr = MethodRunner();
    mr.methods_ = config.methods;
    mr.rootDir = samplesDir;
    mr.intersectionObj = intersectionObj;
    mr.info = config.info;

    mr.run();
    
    % visualize
    % - print summary
    Viz.printSummary(parentOfSamplesDir);
    % - show and save results
    Viz.saveResults(samplesDir);
    
    toc();
end

%% End
%%
disp('End.');
