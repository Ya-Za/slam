%% Random-walks
%% Initialize
%%
close('all');
clear();
clc();
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
    % todo: make constructor for `RandomWalk` which gives `config` as input
    rw = RandomWalk();
    rw.std = config.std;
    rw.maxDistance = config.maxDistance;
    rw.numberOfPoints = config.numberOfPoints;
    rw.numberOfDimensions = config.numberOfDimensions;
    
    samplesDir = rw.saveSamples(rootDir, config.numberOfSamples);
    
    % - show and save results
    % `results` folder
    [parentOfRootDir, ~, ~] = fileparts(samplesDir);
    outDir = fullfile(parentOfRootDir, 'results');
    if ~exist(outDir, 'dir')
        mkdir(outDir);
    end

    % random-walks
    Viz.plotSomeRandomWalks(Viz.getFilenames(samplesDir));
    savefig(fullfile(outDir, 'random_walks'));
    
    toc();
end

%% End
%%
disp('End.');
