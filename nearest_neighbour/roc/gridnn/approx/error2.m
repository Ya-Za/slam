% init
close('all');
clear();
clc();

% radius
r = 1;

% scales
maxR = 2 * r;
ns = 10;
scales = linspace(0, maxR, ns);

% expected false positive
% - lower & upper bound of x1
x1min = @(s) s;
x1max = @(s) 2 * s;
% - lower & upper bound of x2
x2min = @(s) s;
x2max = @(s) 2 * s;
% - expression
EFP = zeros(size(scales));
for i = 1:ns
    scale = scales(i);
    EFP(i) = integral2(...
        expr(scale), ...
        x1min(scale), ...
        x1max(scale), ...
        x2min(scale), ...
        x2max(scale) ...
    );
end

plot(scales, EFP);

function res = expr(scale)
     res = @(x1, x2) scale * (x1 + x2);
end