function [metrics] = evaluate_performance(params, tspan, x0, yd, dyd, ddyd)
    % Fixed time step
    dt = 0.01;  % 10ms time step
    t = tspan(1):dt:tspan(2);
    
    % Initialize metrics structure with default values
    metrics = struct('ISE', 1e10, 'ITAE', 1e10, 'control_effort', 1e10, ...
        'settling_time', 1e10, 'max_error', 1e10, 'overshoot', 1e10, ...
        'total_var_control', 1e10);
    
    % Simulation options
    options = odeset('RelTol', 1e-3, 'AbsTol', 1e-3);
    
    try
        % Simulate system with given parameters
        [t, X] = ode45(@(t,x) system_dynamics(t, x, ...
            smc_controller(t, x, params, yd, dyd, ddyd), params), ...
            t, x0, options);
        
        % Ensure t is a column vector
        t = t(:);
        
        % Calculate error and reference
        yd_values = yd(t);  % Calculate reference trajectory
        e = (X(:,1) - X(:,2)) - yd_values;
        y = X(:,1) - X(:,2);  % System output
        
        % Calculate control input
        u = zeros(size(t));
        for i = 1:length(t)
            u(i) = smc_controller(t(i), X(i,:)', params, yd, dyd, ddyd);
        end
        
        if ~any(isnan(e)) && ~any(isinf(e))
            % Original metrics
            metrics.ISE = double(sum(e.^2) * dt);
            metrics.ITAE = double(sum(t .* abs(e)) * dt);
            metrics.max_error = double(max(abs(e)));
            
            % Maximum Overshoot calculation
            ref_max = max(abs(yd_values));
            if ref_max > 0
                overshoot = max(0, (max(abs(y)) - ref_max)/ref_max * 100);
            else
                overshoot = max(0, max(abs(y))*100);
            end
            metrics.overshoot = double(overshoot);
            
            % Settling Time calculation (2% criterion)
            final_value = yd_values(end);
            settling_band = 0.02 * abs(final_value);
            if settling_band == 0
                settling_band = 0.02;  % Default band if reference is zero
            end
            
            for i = length(t):-1:1
                if abs(y(i) - final_value) > settling_band
                    metrics.settling_time = double(t(i));
                    break;
                end
            end
            if i == 1  % If loop completed without breaking
                metrics.settling_time = double(t(1));
            end
        end
        
        % Control-related metrics
        if ~any(isnan(u)) && ~any(isinf(u))
            % Control effort (energy)
            metrics.control_effort = double(sum(u.^2) * dt);
            
            % Total Variation of Control (smoothness)
            metrics.total_var_control = double(sum(abs(diff(u))));
        end
        
    catch ME
        fprintf('Warning: Simulation failed for parameters lambda=%.2f, Phi=%.2f, phi=%.3f\n', ...
            params.lambda, params.Phi, params.phi);
        fprintf('Error message: %s\n', ME.message);
    end
    
    % Final validation - replace any remaining inf/nan with large number
    metric_fields = fieldnames(metrics);
    for i = 1:length(metric_fields)
        if isinf(metrics.(metric_fields{i})) || isnan(metrics.(metric_fields{i}))
            metrics.(metric_fields{i}) = 1e10;
        end
    end
end