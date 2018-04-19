%% Initialize
%%
close('all');
clear();
clc();
%% Parameters
%%
std = 4;
maxDistance = 1000;
numberOfPoints = 10000;
numberOfDimensions = 2;
numberOfSamples = 1;
radius = 1; % alwasy is 1!
gridResolution = 4;

addpath('./methods'); 
methods_ = [...
    struct(...
        'handler', @LNN, ...
        'params', [] ...
    ), ...
    struct(...
        'handler', @KDT, ...
        'params', [] ...
    ), ...
    struct(...
        'handler', @KDTree, ...
        'params', [] ...
    ), ...
    struct(...
        'handler', @RangeTree, ...
        'params', [] ...
    ), ...
    struct(...
        'handler', @Grid, ...
        'params', struct('gridResolution', gridResolution) ...
    ), ...
    struct(...
        'handler', @FilteredGrid, ...
        'params', struct('gridResolution', gridResolution) ...
    ) ...
];

info = struct(...
    'numberOfDimensions', numberOfDimensions, ...
    'maxDistance', maxDistance ...
);

configsDir = './assets/configs';
configFilename = '2d';
%% Config
%%
% add `methods` to `path`
addpath('./methods');
% make `config`
config = struct(...
    'std', std, ...
    'maxDistance', maxDistance, ...
    'numberOfPoints', numberOfPoints, ...
    'numberOfDimensions', numberOfDimensions, ...
    'numberOfSamples', numberOfSamples, ...
    'radius', radius, ...
    'methods', methods_, ...
    'info', info...
);
% save config
if ~exist(configsDir, 'dir')
    mkdir(configsDir)
end
save(...
    fullfile(configsDir, configFilename), ...
    '-struct', ...
    'config' ...
);

% print `end` message
fprintf(...
    'Make `%s.mat` config file.\n', ...
    fullfile(configsDir, configFilename) ...
);
clear();
