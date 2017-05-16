classdef Approx < handle
    %Approximately compute 1d `fp` and `fn` of `grid` method
    
    properties (Constant)
        % Propereties
        % -----------
        % - r: double
        %   Radius of neighbourhood
        % - cr: double
        %   Coefficient of radius -> limits of `s` is [0, cr * r]
        % - ns: int
        %   Number of points in [0, 3r]
        % - nx: int
        %   Number of poitns in [0, s]
        % - np: int
        %   Number of points in [-s/2, 3s/2]
        % - lineWidth: double
        %   Line width
        
        r = 1;
        cr = 8/3;
        ns = 10;
        nx = 10;
        np = 10;
        
        lineWidth = 1.5;
    end
    
    % approx
    methods (Static)
        function P = conditionPositive(d)
            % Condition-Positive = TP + FN
            %
            % Parameters
            % ----------
            % - d: int
            %   Dimension
            % - P: int
            %   Positive
            
            r = Approx.r;
            
            switch d
                case 1
                    P = 2 * r;
                case 2
                    P = pi * r^2;
                case 3
                    P = 4/3 * pi * r^3;
            end
        end
        
        function PP = predictionPositive(s, d)
            % Prediction-Positive = FP + TP
            %
            % Parameters
            % ----------
            % - s: double
            %   Grid scale
            % - d: int
            %   Dimension
            % - P: int
            %   Prediction-Positive

            PP = (2*s)^d;
        end

        function one()
            % 1-dimensional
            
            % r, cr, ns, nx, np
            r = Approx.r;
            cr = Approx.cr;
            % - condition positive
            P = Approx.conditionPositive(1);
            ns = Approx.ns;
            nx = Approx.nx;
            np = Approx.np;
            
            % false-negative & false-positive
            FN = zeros(ns, nx);
            FP = zeros(ns, nx);
            
            % scales
            s = linspace(0, cr*r, ns);
            
            parfor is = 1:ns
                s_ = s(is);
                % prediction positive
                PP = Approx.predictionPositive(s_, 1);
                % position of sample points
                p = linspace(-s_/2, 3*s_/2, np);
                % position of query-points
                x = linspace(0, s_, nx);
                for ix = 1:nx
                    nhits = 0;
                    % compute true-positive
                    for ip = 1:np
                        if norm(p(ip) - x(ix)) <= r
                            nhits = nhits + 1;
                        end
                    end
                    TP = (nhits / np) * PP;
                    FP(is, ix) = PP - TP;
                    FN(is, ix) = P - TP;
                end
            end
            
            % expected false negative & false positive
            E_FN = zeros(1, ns);
            E_FP = zeros(1, ns);
            
            for is = 1:ns
                E_FN(is) = mean(FN(is, :));
                E_FP(is) = mean(FP(is, :));
            end
            
            % save
            save('1d.mat', ...
                'r', 'cr', 'ns', 'nx', 'np', ...
                'FP', 'FN', 'E_FP', 'E_FN' ...
            );
            
            % plot
            Approx.plotfnfp(s, E_FN, E_FP, '1D');
        end
        
        function two()
            % 2-dimensional
            
            % r, cr, ns, nx, np
            r = Approx.r;
            cr = Approx.cr;
            % - condition positive
            P = Approx.conditionPositive(2);
            ns = Approx.ns;
            nx = Approx.nx;
            np = Approx.np;
            np2 = np ^ 2;
            
            % false-negative & false-positive
            FN = zeros(ns, nx, nx);
            FP = zeros(ns, nx, nx);
            
            % scales
            s = linspace(0, cr*r, ns);
            
            parfor is = 1:ns
                s_ = s(is);
                % prediction positive
                PP = Approx.predictionPositive(s_, 2);
                % position of sample points
                p = linspace(-s_/2, 3*s_/2, np);
                % position of query-points
                x = linspace(0, s_, nx);
                for ix1 = 1:nx
                    for ix2 = 1:nx
                        nhits = 0;
                        % compute true-positive
                        for ip1 = 1:np
                            for ip2 = 1:np
                                if norm([p(ip1), p(ip2)] - [x(ix1), x(ix2)]) <= r
                                    nhits = nhits + 1;
                                end
                            end
                        end
                        TP = (nhits / np2) * PP;
                        FP(is, ix1, ix2) = PP - TP;
                        FN(is, ix1, ix2) = P - TP;
                    end
                end
            end
            
            % expected false negative & false positive
            E_FN = zeros(1, ns);
            E_FP = zeros(1, ns);
            
            for is = 1:ns
                E_FN(is) = mean(FN(is, :));
                E_FP(is) = mean(FP(is, :));
            end

            % save
            save('2d.mat', ...
                'r', 'cr', 'ns', 'nx', 'np', ...
                'FP', 'FN', 'E_FP', 'E_FN' ...
            );

            % plot
            Approx.plotfnfp(s, E_FN, E_FP, '2D');
        end
        
        function three()
            % 3-dimensional
            
            % r, cr, ns, nx, np
            r = Approx.r;
            cr = Approx.cr;
            % - condition positive
            P = Approx.conditionPositive(3);
            ns = Approx.ns;
            nx = Approx.nx;
            np = Approx.np;
            np3 = np ^ 3;
            
            % false-negative & false-positive
            FN = zeros(ns, nx, nx, nx);
            FP = zeros(ns, nx, nx, nx);
            
            % scales
            s = linspace(0, cr*r, ns);
            
            parfor is = 1:ns
                s_ = s(is);
                % prediction positive
                PP = Approx.predictionPositive(s_, 3);
                % position of sample points
                p = linspace(-s_/2, 3*s_/2, np);
                % position of query-points
                x = linspace(0, s_, nx);
                for ix1 = 1:nx
                    for ix2 = 1:nx
                        for ix3 = 1:nx
                            nhits = 0;
                            % compute true-positive
                            for ip1 = 1:np
                                for ip2 = 1:np
                                    for ip3 = 1:np
                                        if norm([p(ip1), p(ip2), p(ip3)] - [x(ix1), x(ix2), x(ix3)]) <= r
                                            nhits = nhits + 1;
                                        end
                                    end
                                end
                            end
                            TP = (nhits / np3) * PP;
                            FP(is, ix1, ix2, ix3) = PP - TP;
                            FN(is, ix1, ix2, ix3) = P - TP;
                        end
                    end
                end
            end
            
            % expected false negative & false positive
            E_FN = zeros(1, ns);
            E_FP = zeros(1, ns);
            
            for is = 1:ns
                E_FN(is) = mean(FN(is, :));
                E_FP(is) = mean(FP(is, :));
            end

            % save
            save('3d.mat', ...
                'r', 'cr', 'ns', 'nx', 'np', ...
                'FP', 'FN', 'E_FP', 'E_FN' ...
            );

            % plot
            Approx.plotfnfp(s, E_FN, E_FP, '3D');
        end
    end
    
    % plot
    methods (Static)
        function plotfnfp(s, fn, fp, figname)
            % Plot false-negative and false-positive
            %
            % Parameters
            % ----------
            % - s: double vector
            %   Grid scales
            % - fn: double vector
            %   False negative
            % - fp: double vector
            %   False positive
            % - figname: char vector
            %   Figure name

            r = Approx.r;
            
            figure(...
                'Name', figname, ...
                'NumberTitle', 'off' ...
            );
            plot(...
                s, fn, ...
                s, fp, ...
                'LineWidth', Approx.lineWidth ...
            );
            axis('tight');
            xlabel('$s$', 'Interpreter', 'latex');
            ylabel('$error$', 'Interpreter', 'latex');
            set(gca, ...
                'XTick', [2*r/3, 2*r], ...
                'XTickLabel', {'$\frac{2\,r}{3}$', '$2\,r$'}, ...
                'YTick', 0, ...
                'YTickLabel', '$0$', ...
                'XGrid', 'on', ...
                'YGrid', 'on', ...
                'TickLabelInterpreter', 'latex' ...
            );
            legend(...
                'E[FN]', 'E[FP]', ...
                'Location', 'northwest' ...
            );
        end
    end
    
    % main
    methods (Static)
        function main()
            % Main
            
            % init
            close('all');
            clear();
            clc();
            
            % 1D
            disp('1D');
            tic();
            Approx.one();
            toc();
            
            % 2D
            disp('2D');
            tic();
            Approx.two();
            toc();
            
            % 3D
            disp('3D');
            tic();
            Approx.three();
            toc();
        end
    end
    
end
