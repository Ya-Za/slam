%% Nearest Neighbour
%% Initialize
%%
close('all');
clear();
clc();
%% Parameters
%%
std = 1;
maxDistance = 10;
numberOfPoints = 100;
numberOfDimensions = 2;
rootDir = './assets';
numberOfSamples = 10;

radius = 1; % alwasy is 1!

addpath('./methods'), methods_ = {@LNN};
inputDirs = {'s1m10d2n100'};
config = struct(...
    'maxDistance', maxDistance ...
);
%% Generate and Save Random Walks
%%
rw = RandomWalk();
rw.std = std;
rw.maxDistance = maxDistance;
rw.numberOfPoints = numberOfPoints;
rw.numberOfDimensions = numberOfDimensions;

% rw.saveSamples(rootDir, numberOfSamples);
%% Run Methods
%%
% Intersection
intersectionObj = Intersection();
intersectionObj.radius = radius;

% MethodRunner
mr = MethodRunner();
mr.methods_ = methods_;
mr.inputDirs = inputDirs;
mr.rootDir = rootDir;
mr.intersectionObj = intersectionObj;
mr.config = config;

mr.run()
%% End
%%
disp('End.');