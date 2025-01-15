function u = smc_controller(t, x, params, yd, dyd, ddyd)
    % Extract states
    x1 = x(1); x2 = x(2);
    
    % Calculate sliding surface
    e = (x1 - x2) - yd(t);
    de = (x2 + x1*x2 - x2^2) - (x1*x2 - x2^2) - dyd(t);
    s = de + params.lambda * e;
    
    % Equivalent control
    ueq = x2^2 - x1*x2 - params.lambda*x2 + params.lambda*dyd(t) + ddyd(t);
    
    % Switching control
    un = -params.Phi * sat(s/params.phi);
    
    % Total control
    u = ueq + un;
end