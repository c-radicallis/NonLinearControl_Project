function visualize_parameter_sweep(results)
    % Extract data with validation
    n = length(results);
    lambda = zeros(n, 1);
    Phi = zeros(n, 1);
    phi = zeros(n, 1);
    
    % Initialize metrics arrays
    metrics_names = {'ISE', 'ITAE', 'control_effort', 'overshoot', ...
        'settling_time', 'total_var_control'};
    metrics_data = zeros(n, length(metrics_names));
    
    % Data extraction with validation
    for i = 1:n
        lambda(i) = results(i).lambda;
        Phi(i) = results(i).Phi;
        phi(i) = results(i).phi;
        
        % Extract all metrics
        for j = 1:length(metrics_names)
            if isfield(results(i).metrics, metrics_names{j}) && ...
                    isfinite(results(i).metrics.(metrics_names{j}))
                metrics_data(i,j) = results(i).metrics.(metrics_names{j});
            else
                metrics_data(i,j) = 1e10;
            end
        end
    end
    
    % Get valid indices (where all metrics are valid)
    valid_idx = all(metrics_data < 1e10, 2);
    
    if ~any(valid_idx)
        error('No valid results to plot');
    end
    
    % Calculate global min and max for each metric
    metric_limits = zeros(length(metrics_names), 2); % [min, max]
    for i = 1:length(metrics_names)
        valid_metric = metrics_data(valid_idx, i);
        metric_limits(i,1) = min(valid_metric);
        metric_limits(i,2) = max(valid_metric);
    end
    
    % Get unique phi values
    unique_phi = unique(phi);
    num_phi = length(unique_phi);
    metrics_per_plot = 3;
    
    % Parameter sweep visualization - First set of metrics
    figure('Name', 'Parameter Sweep Results - Part 1', 'Position', [100 100 1200 800]);
    
    % First set of metrics
    for i = 1:num_phi
        phi_idx = phi == unique_phi(i);
        current_data = phi_idx & valid_idx;
        
        for j = 1:metrics_per_plot
            subplot(metrics_per_plot, num_phi, (j-1)*num_phi + i)
            scatter_h = scatter(lambda(current_data), Phi(current_data), 100, ...
                metrics_data(current_data,j), 'filled');
            xlabel('\lambda')
            ylabel('\Phi')
            title(sprintf('%s (\\phi = %.3f)', metrics_names{j}, unique_phi(i)))
            colorbar
            % Set consistent color limits for this metric
            clim([metric_limits(j,1), metric_limits(j,2)])
            grid on
        end
    end
    
    % Second set of metrics
    figure('Name', 'Parameter Sweep Results - Part 2', 'Position', [100 100 1200 800]);
    for i = 1:num_phi
        phi_idx = phi == unique_phi(i);
        current_data = phi_idx & valid_idx;
        
        for j = 1:metrics_per_plot
            subplot(metrics_per_plot, num_phi, (j-1)*num_phi + i)
            scatter_h = scatter(lambda(current_data), Phi(current_data), 100, ...
                metrics_data(current_data,j+3), 'filled');
            xlabel('\lambda')
            ylabel('\Phi')
            title(sprintf('%s (\\phi = %.3f)', metrics_names{j+3}, unique_phi(i)))
            colorbar
            % Set consistent color limits for this metric
            clim([metric_limits(j+3,1), metric_limits(j+3,2)])
            grid on
        end
    end
    
    % Performance Summary - Table
    figure('Name', 'Performance Summary - Table', 'Position', [100 100 800 400]);
    
    % Find best parameters for each metric
    best_params = zeros(length(metrics_names), 4); % [lambda, Phi, phi, value]
    for i = 1:length(metrics_names)
        valid_metric = metrics_data(valid_idx, i);
        [min_val, idx] = min(valid_metric);
        valid_indices = find(valid_idx);
        idx = valid_indices(idx);
        
        best_params(i,:) = [lambda(idx), Phi(idx), phi(idx), min_val];
    end
    
    % Create table
    cdata = num2cell(best_params);
    t = uitable('Data', cdata, ...
        'RowName', metrics_names, ...
        'ColumnName', {'Lambda', 'Phi', 'phi', 'Value'}, ...
        'Units', 'normalized', ...
        'Position', [0.1 0.1 0.8 0.8]);
    
    % Performance Summary - Normalized Comparison
    figure('Name', 'Performance Summary - Normalized Comparison', 'Position', [100 100 800 400]);
    
    % Normalize metrics for comparison
    norm_metrics = zeros(length(metrics_names), 1);
    for i = 1:length(metrics_names)
        valid_metric = metrics_data(valid_idx, i);
        norm_metrics(i) = min(valid_metric)/max(valid_metric);
    end
    
    % Plot normalized metrics
    b = bar(norm_metrics);
    set(gca, 'XTickLabel', metrics_names)
    ylabel('Normalized Value')
    title('Normalized Minimum Values')
    grid on
    xtickangle(45)
    
    % Print best parameters to console
    fprintf('\nBest parameters for each metric:\n');
    for i = 1:length(metrics_names)
        fprintf('%s: lambda=%.2f, Phi=%.2f, phi=%.3f, value=%.4e\n', ...
            metrics_names{i}, best_params(i,1), best_params(i,2), ...
            best_params(i,3), best_params(i,4));
    end
end