%% Nearest Neighbour
%% Initialize
%%
close('all');
clear();
clc();
addpath('./methods');
%% Load and Run `Config` files
%%
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
    rw = RandomWalk();
    rw.std = config.std;
    rw.maxDistance = config.maxDistance;
    rw.numberOfPoints = config.numberOfPoints;
    rw.numberOfDimensions = config.numberOfDimensions;
    
    rootDir = rw.saveSamples(config.rootDir, config.numberOfSamples);
    
    % copy `config` file
    [parentOfRootDir, ~, ~] = fileparts(rootDir);
    copyfile(filename, fullfile(parentOfRootDir, 'config.mat'));
    
    % run methods
    % - intersection object
    intersectionObj = Intersection();
    intersectionObj.radius = config.radius;

    % - MethodRunner
    mr = MethodRunner();
    mr.methods_ = config.methods;
    mr.rootDir = rootDir;
    mr.intersectionObj = intersectionObj;
    mr.info = config.info;

    mr.run();
    
    % save results
    Viz.saveResults(rootDir);
    
    toc();
end

%% End
%%
disp('End.');
