function dxdt = system_dynamics(t, x, u, ~)
    % State variables
    x1 = x(1); x2 = x(2); x3 = x(3);
    
    % System equations
    dxdt = zeros(3,1);
    dxdt(1) = x2 + x1*x2 - x2^2 + u;
    dxdt(2) = x1*x2 - x2^2 + u;
    dxdt(3) = x1 + x1*x2 - x2^2 - (x3 - x1)^3 + u;
end