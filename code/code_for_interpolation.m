%% =========================================================
%  MATLAB PROJECT: Interpolation of Experimental Data
%  Topic: Stress-Strain Data Interpolation
%  Numerical Methods Course
%% =========================================================
%  Methods Implemented:
%   1. Lagrange Interpolation
%   2. Newton's Divided Difference Interpolation
%   3. MATLAB built-in interp1 (Linear)
%   4. MATLAB built-in interp1 (Spline / Cubic)
%% =========================================================

clc; clear; close all;

%% ---- EXPERIMENTAL DATA (Stress-Strain, e.g. Copper alloy) ----
% x = Strain (dimensionless)
% y = Stress (MPa)

x_data = [0.00, 0.02, 0.05, 0.08, 0.12, 0.16, 0.20, 0.25, 0.30];
y_data = [0,   50,  110,  160,  200,  230,  250,  265,  275];

n = length(x_data);   % Number of data points

% Fine grid for smooth interpolation curves
x_fine = linspace(x_data(1), x_data(end), 500);

% Query points for comparison table
x_query = [0.01, 0.03, 0.06, 0.10, 0.14, 0.18, 0.22, 0.27];

fprintf('==========================================================\n');
fprintf('  INTERPOLATION OF EXPERIMENTAL STRESS-STRAIN DATA\n');
fprintf('==========================================================\n\n');

%% ====================================================
%  METHOD 1: LAGRANGE INTERPOLATION
%% ====================================================

fprintf('--- Method 1: Lagrange Interpolation ---\n');

% --- Function for Lagrange basis polynomial ---
lagrange = @(xd, yd, xq) arrayfun(@(xi) ...
    sum(yd .* arrayfun(@(k) prod((xi - xd([1:k-1, k+1:end])) ./ ...
    (xd(k) - xd([1:k-1, k+1:end]))), 1:length(xd))), xq);

y_lagrange_fine   = lagrange(x_data, y_data, x_fine);
y_lagrange_query  = lagrange(x_data, y_data, x_query);

fprintf('  Query Points & Lagrange Results:\n');
fprintf('  %-10s  %-15s\n', 'Strain', 'Stress (MPa)');
for i = 1:length(x_query)
    fprintf('  %-10.4f  %-15.4f\n', x_query(i), y_lagrange_query(i));
end

%% ====================================================
%  METHOD 2: NEWTON'S DIVIDED DIFFERENCE INTERPOLATION
%% ====================================================

fprintf('\n--- Method 2: Newton Divided Difference ---\n');

% Build divided difference table
dd = zeros(n, n);
dd(:,1) = y_data(:);

for j = 2:n
    for i = j:n
        dd(i,j) = (dd(i,j-1) - dd(i-1,j-1)) / (x_data(i) - x_data(i-j+1));
    end
end

% Print divided difference table
fprintf('\n  Divided Difference Table (coefficients on diagonal):\n');
fprintf('  %-8s  %-12s', 'x', 'f[x]');
for j = 2:n
    fprintf('  %-14s', sprintf('Order-%d', j-1));
end
fprintf('\n');
for i = 1:n
    fprintf('  %-8.4f  %-12.4f', x_data(i), dd(i,1));
    for j = 2:i
        fprintf('  %-14.6f', dd(i,j));
    end
    fprintf('\n');
end

% Newton coefficients = diagonal of dd table
coeff = diag(dd);

% Newton interpolation evaluation function
function y = newton_eval(x_data, coeff, xq)
    n = length(coeff);
    y = zeros(size(xq));
    for qi = 1:length(xq)
        xi = xq(qi);
        val = coeff(1);
        prod_term = 1;
        for k = 2:n
            prod_term = prod_term * (xi - x_data(k-1));
            val = val + coeff(k) * prod_term;
        end
        y(qi) = val;
    end
end

y_newton_fine  = newton_eval(x_data, coeff, x_fine);
y_newton_query = newton_eval(x_data, coeff, x_query);

fprintf('\n  Query Points & Newton Results:\n');
fprintf('  %-10s  %-15s\n', 'Strain', 'Stress (MPa)');
for i = 1:length(x_query)
    fprintf('  %-10.4f  %-15.4f\n', x_query(i), y_newton_query(i));
end

%% ====================================================
%  METHOD 3: MATLAB interp1 - LINEAR
%% ====================================================

fprintf('\n--- Method 3: Linear Interpolation (MATLAB interp1) ---\n');

y_linear_fine  = interp1(x_data, y_data, x_fine,  'linear');
y_linear_query = interp1(x_data, y_data, x_query, 'linear');

fprintf('  Query Points & Linear Results:\n');
fprintf('  %-10s  %-15s\n', 'Strain', 'Stress (MPa)');
for i = 1:length(x_query)
    fprintf('  %-10.4f  %-15.4f\n', x_query(i), y_linear_query(i));
end

%% ====================================================
%  METHOD 4: MATLAB interp1 - SPLINE (Cubic)
%% ====================================================

fprintf('\n--- Method 4: Spline (Cubic) Interpolation ---\n');

y_spline_fine  = interp1(x_data, y_data, x_fine,  'spline');
y_spline_query = interp1(x_data, y_data, x_query, 'spline');

fprintf('  Query Points & Spline Results:\n');
fprintf('  %-10s  %-15s\n', 'Strain', 'Stress (MPa)');
for i = 1:length(x_query)
    fprintf('  %-10.4f  %-15.4f\n', x_query(i), y_spline_query(i));
end

%% ====================================================
%  COMPARISON TABLE (All Methods at Query Points)
%% ====================================================

fprintf('\n==========================================================\n');
fprintf('  COMPARISON TABLE AT QUERY POINTS\n');
fprintf('==========================================================\n');
fprintf('  %-8s  %-12s  %-12s  %-12s  %-12s\n', ...
    'Strain', 'Lagrange', 'Newton', 'Linear', 'Spline');
fprintf('  %s\n', repmat('-',1,60));
for i = 1:length(x_query)
    fprintf('  %-8.4f  %-12.4f  %-12.4f  %-12.4f  %-12.4f\n', ...
        x_query(i), y_lagrange_query(i), y_newton_query(i), ...
        y_linear_query(i), y_spline_query(i));
end

%% ====================================================
%  ERROR ANALYSIS (vs Spline as reference)
%% ====================================================

fprintf('\n==========================================================\n');
fprintf('  ERROR ANALYSIS (Absolute Difference vs Spline Reference)\n');
fprintf('==========================================================\n');
fprintf('  %-8s  %-14s  %-14s  %-14s\n', 'Strain','|Err_Lagrange|', ...
    '|Err_Newton|','|Err_Linear|');
fprintf('  %s\n', repmat('-',1,56));
for i = 1:length(x_query)
    fprintf('  %-8.4f  %-14.6f  %-14.6f  %-14.6f\n', ...
        x_query(i), ...
        abs(y_lagrange_query(i) - y_spline_query(i)), ...
        abs(y_newton_query(i)   - y_spline_query(i)), ...
        abs(y_linear_query(i)   - y_spline_query(i)));
end

%% ====================================================
%  PLOTTING
%% ====================================================

colors = struct('lagrange', [0.85 0.15 0.15], ...
                'newton',   [0.10 0.45 0.80], ...
                'linear',   [0.20 0.70 0.30], ...
                'spline',   [0.75 0.30 0.85], ...
                'data',     [0.10 0.10 0.10]);

%% -- Figure 1: Lagrange (Individual) --
figure('Name','Lagrange Interpolation','NumberTitle','off', ...
       'Position',[50 550 560 400]);
plot(x_fine, y_lagrange_fine, '-', 'Color', colors.lagrange, 'LineWidth', 2.2); hold on;
plot(x_data, y_data, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', colors.data, ...
     'DisplayName', 'Data Points');
xlabel('Strain (dimensionless)', 'FontSize', 12);
ylabel('Stress (MPa)', 'FontSize', 12);
title('Method 1: Lagrange Interpolation', 'FontSize', 13, 'FontWeight', 'bold');
legend({'Lagrange Curve','Experimental Data'}, 'Location', 'northwest', 'FontSize', 10);
grid on; box on;

%% -- Figure 2: Newton (Individual) --
figure('Name','Newton Divided Difference','NumberTitle','off', ...
       'Position',[620 550 560 400]);
plot(x_fine, y_newton_fine, '-', 'Color', colors.newton, 'LineWidth', 2.2); hold on;
plot(x_data, y_data, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', colors.data);
xlabel('Strain (dimensionless)', 'FontSize', 12);
ylabel('Stress (MPa)', 'FontSize', 12);
title('Method 2: Newton Divided Difference Interpolation', 'FontSize', 13, 'FontWeight', 'bold');
legend({'Newton Curve','Experimental Data'}, 'Location', 'northwest', 'FontSize', 10);
grid on; box on;

%% -- Figure 3: Linear (Individual) --
figure('Name','Linear Interpolation','NumberTitle','off', ...
       'Position',[50 100 560 400]);
plot(x_fine, y_linear_fine, '-', 'Color', colors.linear, 'LineWidth', 2.2); hold on;
plot(x_data, y_data, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', colors.data);
xlabel('Strain (dimensionless)', 'FontSize', 12);
ylabel('Stress (MPa)', 'FontSize', 12);
title('Method 3: Linear Interpolation (interp1)', 'FontSize', 13, 'FontWeight', 'bold');
legend({'Linear Curve','Experimental Data'}, 'Location', 'northwest', 'FontSize', 10);
grid on; box on;

%% -- Figure 4: Spline (Individual) --
figure('Name','Spline Interpolation','NumberTitle','off', ...
       'Position',[620 100 560 400]);
plot(x_fine, y_spline_fine, '-', 'Color', colors.spline, 'LineWidth', 2.2); hold on;
plot(x_data, y_data, 'ko', 'MarkerSize', 8, 'MarkerFaceColor', colors.data);
xlabel('Strain (dimensionless)', 'FontSize', 12);
ylabel('Stress (MPa)', 'FontSize', 12);
title('Method 4: Spline (Cubic) Interpolation', 'FontSize', 13, 'FontWeight', 'bold');
legend({'Spline Curve','Experimental Data'}, 'Location', 'northwest', 'FontSize', 10);
grid on; box on;

%% -- Figure 5: All 4 Methods in ONE subplot page (2x2) --
figure('Name','All Methods - Individual Subplots','NumberTitle','off', ...
       'Position',[50 50 1100 750]);

% Subplot 1 - Lagrange
subplot(2,2,1);
plot(x_fine, y_lagrange_fine, '-', 'Color', colors.lagrange, 'LineWidth', 2); hold on;
plot(x_data, y_data, 'ko', 'MarkerSize', 7, 'MarkerFaceColor', colors.data);
xlabel('Strain','FontSize',11); ylabel('Stress (MPa)','FontSize',11);
title('(a) Lagrange Interpolation','FontSize',12,'FontWeight','bold');
legend({'Lagrange','Data Points'},'Location','northwest','FontSize',9);
grid on; box on; ylim([-20 300]);

% Subplot 2 - Newton
subplot(2,2,2);
plot(x_fine, y_newton_fine, '-', 'Color', colors.newton, 'LineWidth', 2); hold on;
plot(x_data, y_data, 'ko', 'MarkerSize', 7, 'MarkerFaceColor', colors.data);
xlabel('Strain','FontSize',11); ylabel('Stress (MPa)','FontSize',11);
title('(b) Newton Divided Difference','FontSize',12,'FontWeight','bold');
legend({'Newton','Data Points'},'Location','northwest','FontSize',9);
grid on; box on; ylim([-20 300]);

% Subplot 3 - Linear
subplot(2,2,3);
plot(x_fine, y_linear_fine, '-', 'Color', colors.linear, 'LineWidth', 2); hold on;
plot(x_data, y_data, 'ko', 'MarkerSize', 7, 'MarkerFaceColor', colors.data);
xlabel('Strain','FontSize',11); ylabel('Stress (MPa)','FontSize',11);
title('(c) Linear Interpolation','FontSize',12,'FontWeight','bold');
legend({'Linear','Data Points'},'Location','northwest','FontSize',9);
grid on; box on; ylim([-20 300]);

% Subplot 4 - Spline
subplot(2,2,4);
plot(x_fine, y_spline_fine, '-', 'Color', colors.spline, 'LineWidth', 2); hold on;
plot(x_data, y_data, 'ko', 'MarkerSize', 7, 'MarkerFaceColor', colors.data);
xlabel('Strain','FontSize',11); ylabel('Stress (MPa)','FontSize',11);
title('(d) Spline (Cubic) Interpolation','FontSize',12,'FontWeight','bold');
legend({'Spline','Data Points'},'Location','northwest','FontSize',9);
grid on; box on; ylim([-20 300]);

sgtitle('All Interpolation Methods – Individual Plots', ...
        'FontSize', 14, 'FontWeight', 'bold');

%% -- Figure 6: All Methods on ONE Combined Graph --
figure('Name','Combined - All Methods','NumberTitle','off', ...
       'Position',[150 150 900 550]);

plot(x_fine, y_lagrange_fine, '-',  'Color', colors.lagrange, 'LineWidth', 2.2, ...
     'DisplayName', 'Lagrange'); hold on;
plot(x_fine, y_newton_fine,   '--', 'Color', colors.newton,   'LineWidth', 2.2, ...
     'DisplayName', 'Newton Div. Diff.');
plot(x_fine, y_linear_fine,   ':',  'Color', colors.linear,   'LineWidth', 2.5, ...
     'DisplayName', 'Linear (interp1)');
plot(x_fine, y_spline_fine,   '-.', 'Color', colors.spline,   'LineWidth', 2.2, ...
     'DisplayName', 'Cubic Spline');
plot(x_data, y_data, 'ko', 'MarkerSize', 9, 'MarkerFaceColor', 'k', ...
     'DisplayName', 'Experimental Data');

xlabel('Strain (dimensionless)', 'FontSize', 13);
ylabel('Stress (MPa)', 'FontSize', 13);
title('Comparison of All Interpolation Methods – Stress vs. Strain', ...
      'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'northwest', 'FontSize', 11);
grid on; box on;
annotation('textbox',[0.15 0.65 0.25 0.10], ...
    'String', {'Lagrange \approx Newton (both', 'global polynomial methods)'; ...
               'Spline smoothest fit'}, ...
    'FontSize', 9, 'EdgeColor', [0.7 0.7 0.7], 'BackgroundColor', [1 1 0.9]);

fprintf('\n==========================================================\n');
fprintf('  All plots generated successfully!\n');
fprintf('  Figures: 1-Lagrange | 2-Newton | 3-Linear | 4-Spline\n');
fprintf('           5-All Subplots (2x2) | 6-Combined Comparison\n');
fprintf('==========================================================\n');