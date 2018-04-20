%%
close('all');
clear();
clc();

%% Add path
originalPath = path;
addpath('.');
addpath('./methods');

%% Run the last `unit test`
% suite = testsuite('./tests/TestIntersection.m');
% suite = testsuite('./tests/TestBaseNN.m');
% suite = testsuite('./tests/TestLNN.m');
% suite = testsuite('./tests/TestFilteredGrid.m');
% suite = testsuite('./tests/TestKDTree.m');
suite = testsuite('./tests/TestRangeTree.m');
run(suite);

%% Restore path
path(originalPath);
