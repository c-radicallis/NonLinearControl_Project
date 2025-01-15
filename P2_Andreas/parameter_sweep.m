function results = parameter_sweep()
    % Define parameter ranges
    lambda_range = [1, 3, 8, 20];
    Phi_range = [1, 5, 20, 50];
    phi_range = [0.1, 1, 5];
    
    % Initialize results structure
    num_tests = length(lambda_range) * length(Phi_range) * length(phi_range);
    results = struct('lambda', [], 'Phi', [], 'phi', [], 'metrics', []);
    results = repmat(results, num_tests, 1);
    
    % Reference trajectory
    yd = @(t) sin(t);
    dyd = @(t) cos(t);
    ddyd = @(t) -sin(t);
    
    % Initial conditions and simulation time
    x0 = [0.5; 0.3; 0.2];
    tspan = [0 5];  % Reduced simulation time
    
    % Run parameter sweep
    idx = 1;
    fprintf('Running parameter sweep...\n');
    for lambda = lambda_range
        for Phi = Phi_range
            for phi = phi_range
                fprintf('Testing lambda=%.2f, Phi=%.2f, phi=%.3f\n', lambda, Phi, phi);
                params = struct('lambda', lambda, 'Phi', Phi, 'phi', phi);
                
                % Evaluate performance
                metrics = evaluate_performance(params, tspan, x0, yd, dyd, ddyd);
                
                % Store results
                results(idx).lambda = lambda;
                results(idx).Phi = Phi;
                results(idx).phi = phi;
                results(idx).metrics = metrics;
                
                idx = idx + 1;
            end
        end
    end
end