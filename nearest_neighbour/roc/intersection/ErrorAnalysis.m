classdef ErrorAnalysis
    %Analyze `false positive` and `false negative` errors for `1`, `2` and
    %`3` dimensions `Grid` nearest neighbour method
    
    properties (Constant)
        color = struct(...
            'gray', [0.5, 0.5, 0.5], ...
            'lightGray', [0.8, 0.8, 0.8], ...
            'darkRed', [0.5, 0, 0], ...
            'darkGreen', [0, 0.5, 0], ...
            'darkBlue', [0, 0, 0.5], ...
            'red', [0.8500 0.3250 0.0980], ...
            'blue', [0 0.4470 0.7410] ...
        );
    end
    
    % utils
    methods (Static)
        function setLatexInterpreter(ax)
            % Set interpreter to `latex`
            %
            % Parameters
            % ----------
            % - ax: Axes = gca
            % Input `axes`
            
            % default
            if ~exist('ax', 'var')
                ax = gca;
            end
            
            ax.TickLabelInterpreter = 'latex';
            ax.XLabel.Interpreter = 'latex';
            ax.YLabel.Interpreter = 'latex';
            ax.ZLabel.Interpreter = 'latex';
        end
        
        function createFigure(name)
            % Create full-screen figure
            %
            % Parameters
            % ----------
            % - name: char vector = ''
            %   Name of figure
            
            if ~exist('name', 'var')
                name = '';
            end
            
            figure(...
                'Name', name, ...
                'NumberTitle', 'off', ...
                'Units', 'normalized', ...
                'OuterPosition', [0, 0, 1, 1] ...
            );
        end
    end
    
    % 1d
    methods (Static)
        function error1d()
            % Plot `fp` and `fn`

            %% Define
            % radius
            r = 1;
            % scale & `x` position
            [s, x] = meshgrid(linspace(0, 4*r));
            % false positve & fasle negative
            fp = max(-s/2, x - 2*r) - min((3/2)*s, 2*r + x) + 2*s;
            fn = max(-s/2, x - 2*r) - min((3/2)*s, 2*r + x) + 4*r;
            % - 0 <= x <= s
            fp(tril(ones(size(fp), 'logical'), -1)) = nan;
            fn(tril(ones(size(fn), 'logical'), -1)) = nan;

            %% Plot
            % - fasle positive
            %   - figure
            ErrorAnalysis.createFigure('1d - False Positive');
            %   - mesh
            subplot(121);
            mesh(s, x, fp);
            configAx(gca, r);
            %   - contour
            subplot(122);
            contourf(s, x, fp);
            colorbar('Ticks', []);
            configAx(gca, r);
            %   - colormap
            colormap('copper');

            % - fasle negative
            %   - figure
            ErrorAnalysis.createFigure('1d - False Negative');
            %   - mesh
            subplot(121);
            mesh(s, x, fn);
            view([37.5, 30]);
            configAx(gca, r);
            %   - contour
            subplot(122);
            contourf(s, x, fn);
            colorbar('Ticks', []);
            configAx(gca, r);
            %   - colormap
            colormap('bone');

            % % - fp, fn
            % %   - figure
            % createFigure('FP, FN');
            % %   - mesh
            % subplot(121);
            % hold('on');
            % mesh(s, x, fp);
            % mesh(s, x, fn);
            % hold('off');
            % configAx(gca, r);
            % %   - contour
            % subplot(122);
            % hold('on');
            % contourf(s, x, fp);
            % contourf(s, x, fn);
            % hold('off');
            % configAx(gca, r);
            % %   - colormap
            % colormap('copper');

            % meshc(s, x, fn);

            function configAx(ax, r)
                xlabel('s');
                ylabel('x');
                zlabel('error');

                set(ax, ...
                    'Xtick', [...
                        0, ...
                        (4/3)*r, ...
                        2*r, ...
                        4*r ...
                    ], ...
                    'XTickLabel', {...
                        '$0$', ...
                        '$\frac{4\,r}{3}$', ...
                        '$2\,r$', ...
                        '$4\,r$' ...
                    }, ...
                    'YTick', [], ...
                    'ZTick', [], ...
                    'XGrid', 'on', ...
                    'Box', 'off' ...
                );

                ErrorAnalysis.setLatexInterpreter(ax);

                axis(ax, 'equal');
            end

        end
        
        function expectedError1d()
            % Plot expected `fp` and `fn` 
            
            %% Define
            % - radius
            r = 1;

            % - scale
            minS = 0;
            s1 = (4/3)*r;
            s2 = 4*r;
            maxS = 5*r;
            s = sym('s', 'real');
            assume(s > 0);

            % - false positive
            %   - left
            fp1(s) = sym(0);
            %   - middle
            fp2(s) = (4*r - 3*s)^2 / (4*s);
            %   - right
            fp3(s) = 2*s - 4*r;
            %   - piecewise
            fp(s) = piecewise(...
                (0  <= s) & (s <  s1), fp1(s), ...
                (s1 <= s) & (s < s2), fp2(s), ...
                (s2 <=  s), fp3(s) ...
            );
            % - false negative
            %   - left
            fn1(s) = 4*r - 2*s;
            %   - middle
            fn2(s) = (s - 4*r)^2 / (4*s);
            %   - right
            fn3(s) = sym(0);
            %   - piecewise
            fn(s) = piecewise(...
                (0  <= s) & (s < s1), fn1(s), ...
                (s1 <= s) & (s < s2), fn2(s), ...
                (s2 <= s), fn3(s) ...
            );

            %% Plot
            % - parameters
            lineWidth = 2;
            fpColor = ErrorAnalysis.color.red;
            fnColor = ErrorAnalysis.color.blue;
            hold('on');
            % - false positive
            %   - left
            fp = fplot(...
                fp1(s), [minS, s1], ...
                'Color', fpColor, ...
                'LineWidth', lineWidth, ...
                'DisplayName', 'FP' ...
            );
            %   - middle
            fp_ = fplot(...
                fp2(s), [s1, s2], ...
                'Color', fpColor, ...
                'LineWidth', lineWidth, ...
                'LineStyle', '--' ...
            );
            %   - right
            fplot(...
                fp3(s), [s2, maxS], ...
                'Color', fpColor, ...
                'LineWidth', lineWidth ...
            );

            % - false negative
            %   - left
            fn = fplot(...
                fn1(s), [minS, s1], ...
                'Color', fnColor, ...
                'LineWidth', lineWidth ...
            );
            %   - middle
            fn_ = fplot(...
                fn2(s), [s1, s2], ...
                'Color', fnColor, ...
                'LineWidth', lineWidth, ...
                'LineStyle', '--' ...
            );
            %   - right
            fplot(...
                fn3(s), [s2, maxS], ...
                'Color', fnColor, ...
                'LineWidth', lineWidth ...
            );

            % - conditional lines
            %   - left
            minE = 0;
            maxE = eval(fp3(maxS));
            line([s1, s1], [minE, maxE], 'Color', 'k', 'LineStyle', '--');
            %   - right
            line([s2, s2], [minE, maxE], 'Color', 'k', 'LineStyle', '--');
            % - set axes
            axis([minS, maxS, minE, maxE]);
            xlabel('$s$');
            ylabel('$error$');
            set(gca, ...
                'YTick', [0, 1], ...
                'YTickLabel', {'$0$', '$1$'}, ...
                'Xtick', [s1, s2], ...
                'XTickLabel', {'$\frac{4\,r}{3}$', '$4\,r$'} ...
            );
            ErrorAnalysis.setLatexInterpreter();

            legend(...
                [fp, fp_, fn, fn_], {'$FP$', '$E[FP]$', '$FN$', '$E[FN]$'}, ...
                'Interpreter', 'latex', ...
                'Location', 'northwest' ...
            );
            % - figure
            set(gcf, ...
                'Name', '1D - E[fp], E[fn]', ...
                'NumberTitle', 'off', ...
                'Units', 'normalized', ...
                'OuterPosition', [0, 0, 1, 1] ...
            );
        end
    end
    
    % 2d
    methods (Static)
    end
    
    % 3d
    methods (Static)
    end
    
    % main
    methods (Static)
        function main()
            % Main method
            
            %% Init
            close('all');
            clear();
            clc();
            
            %% 1D
            % expected
            ErrorAnalysis.expectedError1d();
            % fp, fn
            ErrorAnalysis.error1d();
            
        end
    end
    
end

