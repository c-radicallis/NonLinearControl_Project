% Main script for parameter testing
clear all; close all; clc;

%% Run parameter sweep
results = parameter_sweep();

%% Debug information
fprintf('\nChecking results structure:\n');
disp(results(1));
fprintf('\nChecking metrics content:\n');
disp(results(1).metrics);

% Check size of all fields
for i = 1:length(results)
    fprintf('\nResults %d:\n', i);
    fprintf('ISE size: %s\n', mat2str(size(results(i).metrics.ISE)));
    fprintf('ITAE size: %s\n', mat2str(size(results(i).metrics.ITAE)));
    fprintf('Control effort size: %s\n', mat2str(size(results(i).metrics.control_effort)));
end

% Only proceed if all looks good
if any(~isfield(results(1).metrics, {'ISE', 'ITAE', 'control_effort'}))
    error('Missing metrics fields');
end

%% Visualize results with error handling
try
    visualize_parameter_sweep(results);
catch ME
    fprintf('Error in visualization: %s\n', ME.message);
end

%% Find best parameters
% Define weights for different metrics
weights.ISE = 0.4;
weights.ITAE = 0.3;
weights.control_effort = 0.3;

% Extract metrics with explicit size checking
n = length(results);
ISE = zeros(n, 1);
ITAE = zeros(n, 1);
control_effort = zeros(n, 1);

for i = 1:n
    ISE(i) = double(results(i).metrics.ISE);
    ITAE(i) = double(results(i).metrics.ITAE);
    control_effort(i) = double(results(i).metrics.control_effort);
end

% Normalize each metric
ISE_norm = (ISE - min(ISE)) / (max(ISE) - min(ISE));
ITAE_norm = (ITAE - min(ITAE)) / (max(ITAE) - min(ITAE));
control_effort_norm = (control_effort - min(control_effort)) / (max(control_effort) - min(control_effort));

% Compute weighted sum
total_score = weights.ISE * ISE_norm + ...
              weights.ITAE * ITAE_norm + ...
              weights.control_effort * control_effort_norm;

% Find best parameter set
[~, best_idx] = min(total_score);
best_params = results(best_idx);

% Display best parameters
fprintf('\nBest overall parameters found:\n');
fprintf('lambda = %.2f\n', best_params.lambda);
fprintf('Phi = %.2f\n', best_params.Phi);
fprintf('phi = %.3f\n', best_params.phi);
fprintf('\nMetrics:\n');
fprintf('ISE = %.4e\n', best_params.metrics.ISE);
fprintf('ITAE = %.4e\n', best_params.metrics.ITAE);
fprintf('Control Effort = %.4e\n', best_params.metrics.control_effort);