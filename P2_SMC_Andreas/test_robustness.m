% Robustness testing script
clear all; close all; clc;

%% Define test cases
% Base parameters
base_params.lambda = 20;
base_params.Phi = 50;
base_params.phi = 1;

% Uncertainty scenarios (±20%)
uncertainty_cases = [
    0 0 0;      % Nominal case
    0.2 0.2 0.2;    % All +20%
    -0.2 -0.2 -0.2; % All -20%
    0.2 -0.2 0.2;   % Mixed case
    -0.2 0.2 -0.2;  % Mixed case
    -0.5 -0.5 -0.5  % Extreme case
];

% Disturbance parameters
base_params.d_step = 0.1;      % Step disturbance magnitude
base_params.step_time = 2;     % Step disturbance time
base_params.d_sin_amp = 0.05;  % Sinusoidal disturbance amplitude
base_params.d_sin_freq = 2*pi; % Sinusoidal disturbance frequency

% Simulation parameters
tspan = [0 10];
x0 = [0.5; 0.3; 0.2];

% Reference trajectory
yd = @(t) sin(t);
dyd = @(t) cos(t);
ddyd = @(t) -sin(t);

%% Run simulations for each uncertainty case
num_cases = size(uncertainty_cases, 1);
results = cell(num_cases, 1);

for i = 1:num_cases
    % Set current uncertainties
    params = base_params;
    params.uncertainties = uncertainty_cases(i,:);
    
    % Simulate system
    [t, X] = ode45(@(t,x) system_dynamics_w_uncertainties(t, x, ...
        smc_controller(t, x, params, yd, dyd, ddyd), params), tspan, x0);
    
    % In the results storage section:
    results{i}.t = t;
    results{i}.X = X;
    results{i}.y = X(:,1) - X(:,2);  % Output y = x1 - x2
    results{i}.yd = yd(t);
    
    % Calculate control input
    u = zeros(size(t));
    for j = 1:length(t)
        u(j) = smc_controller(t(j), X(j,:)', params, yd, dyd, ddyd);
    end
    results{i}.u = u;
    % Calculate derivatives analytically
    results{i}.dy = X(:,2);  % dy = x2
    results{i}.ddy = zeros(size(t));
    for j = 1:length(t)
        % ddy = x1*x2 - x2^2 + u
        results{i}.ddy(j) = X(j,1)*X(j,2) - X(j,2)^2 + results{i}.u(j);
    end

    % Calculate desired derivatives
    results{i}.dyd = dyd(t);
    results{i}.ddyd = ddyd(t);
end

%% Visualize results - Original plots
figure('Name', 'Robustness Test Results', 'Position', [100 100 1200 800])

% Plot tracking performance
subplot(3,1,1)
hold on
plot(results{1}.t, results{1}.yd, 'k--', 'LineWidth', 2)
colors = {'b', 'r', 'g', 'm', 'c', 'y'};
for i = 1:num_cases
    plot(results{i}.t, results{i}.y, colors{i}, 'LineWidth', 1.5)
end
hold off
grid on
title('Output Tracking Performance')
legend(['Reference', arrayfun(@(i) ['Case ' num2str(i)], 1:num_cases, 'UniformOutput', false)])
ylabel('Output y')

% Plot tracking error
subplot(3,1,2)
hold on
for i = 1:num_cases
    plot(results{i}.t, results{i}.y - results{i}.yd, colors{i}, 'LineWidth', 1.5)
end
hold off
grid on
title('Tracking Error')
ylabel('Error')

% Plot control effort
subplot(3,1,3)
hold on
for i = 1:num_cases
    plot(results{i}.t, results{i}.u, colors{i}, 'LineWidth', 1.5)
end
hold off
grid on
title('Control Input')
ylabel('Control u')
xlabel('Time [s]')

%% Visualize results - Derivative tracking
figure('Name', 'Derivative Tracking Analysis', 'Position', [100 100 1200 800])

% Plot first derivative tracking
subplot(2,1,1)
hold on
plot(results{1}.t, results{1}.dyd, 'k--', 'LineWidth', 2)
for i = 1:num_cases
    plot(results{i}.t, results{i}.dy, colors{i}, 'LineWidth', 1.5)
end
hold off
grid on
title('First Derivative Tracking')
legend(['Reference', arrayfun(@(i) ['Case ' num2str(i)], 1:num_cases, 'UniformOutput', false)])
ylabel('dy/dt')

% Plot second derivative tracking
subplot(2,1,2)
hold on
plot(results{1}.t, results{1}.ddyd, 'k--', 'LineWidth', 2)
for i = 1:num_cases
    plot(results{i}.t, results{i}.ddy, colors{i}, 'LineWidth', 1.5)
end
hold off
grid on
title('Second Derivative Tracking')
ylabel('d²y/dt²')
xlabel('Time [s]')

%% Calculate and display performance metrics
fprintf('\nExtended Performance Metrics:\n')
fprintf('Case\tMax Error\tRMS Error\tMax dy Error\tRMS dy Error\tMax ddy Error\tRMS ddy Error\tControl Effort\n')
fprintf('----------------------------------------------------------------------------------------------------\n')

for i = 1:num_cases
    % Position errors
    e = results{i}.y - results{i}.yd;
    max_error = max(abs(e));
    rms_error = sqrt(mean(e.^2));
    
    % Velocity errors
    e_dy = results{i}.dy - results{i}.dyd;
    max_dy_error = max(abs(e_dy));
    rms_dy_error = sqrt(mean(e_dy.^2));
    
    % Acceleration errors
    e_ddy = results{i}.ddy - results{i}.ddyd;
    max_ddy_error = max(abs(e_ddy));
    rms_ddy_error = sqrt(mean(e_ddy.^2));
    
    % Control effort
    control_effort = sum(abs(results{i}.u)) * (results{i}.t(2) - results{i}.t(1));
    
    fprintf('%d\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\t\t%.4f\n', ...
        i, max_error, rms_error, max_dy_error, rms_dy_error, max_ddy_error, rms_ddy_error, control_effort)
end