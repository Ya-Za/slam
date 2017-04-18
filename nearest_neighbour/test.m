%%
close('all');
clear();
clc();

%% Run the last `unit test`
suite = testsuite('./tests/TestViz.m');
run(suite(end));
