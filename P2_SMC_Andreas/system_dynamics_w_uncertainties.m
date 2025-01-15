function dxdt = system_dynamics_w_uncertainties(t, x, u, params)
    % State variables
    x1 = x(1); x2 = x(2); x3 = x(3);
    
    % System parameters with uncertainties
    delta = params.uncertainties;  % Parametric uncertainties
    d_ext = external_disturbance(t, params);  % External disturbance

    x1 = (1 + delta(1))* x1;
    x2 = (1 + delta(2))* x2;
    x3 = (1 + delta(3))* x3;
    
    % System equations with uncertainties
    dxdt = zeros(3,1);
    dxdt(1) = (x2 + x1*x2 - x2^2 + u) + d_ext;
    dxdt(2) = (x1*x2 - x2^2 + u) + d_ext;
    dxdt(3) = (x1 + x1*x2 - x2^2 - (x3 - x1)^3 + u) + d_ext;
end

