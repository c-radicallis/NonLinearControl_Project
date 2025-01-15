% Parameters
params.lambda = 20;
params.Phi = 50;
params.phi = 1;

% Time vector
t_span = [0 10];
dt = 0.01;
t = t_span(1):dt:t_span(2);

% Initial conditions
x0 = [1; 0.5; 0];

% Desired trajectory and its derivatives
yd = @(t) sin(t);
dyd = @(t) cos(t);
ddyd = @(t) -sin(t);

% ODE solver
[t, X] = ode45(@(t,x) system_dynamics(t, x, ...
    smc_controller(t, x, params, yd, dyd, ddyd), params), t, x0);

% Calculate control inputs and sliding surface
U = zeros(length(t), 1);
S = zeros(length(t), 1);
for i = 1:length(t)
    U(i) = smc_controller(t(i), X(i,:)', params, yd, dyd, ddyd);
    S(i) = (X(i,2) - dyd(t(i)) + params.lambda*(X(i,1) - X(i,2) - yd(t(i))));
end

% First figure - Original plots
figure('Name', 'System Analysis');
subplot(2,2,1);
plot(t, X);
legend('x1', 'x2', 'x3');
title('State Trajectories');
xlabel('Time (s)');
ylabel('States');
grid on;

subplot(2,2,2);
plot(t, S);
title('Sliding Surface');
xlabel('Time (s)');
ylabel('s(t)');
grid on;

subplot(2,2,3);
plot(t, U);
title('Control Input');
xlabel('Time (s)');
ylabel('u(t)');
grid on;

subplot(2,2,4);
plot(X(:,1), X(:,2));
title('Phase Portrait (x₁ vs x₂)');
xlabel('x₁');
ylabel('x₂');
grid on;

% Second figure - Phase Plots
figure('Name', 'Phase Space Analysis');

% x₁-x₂ plane
subplot(2,2,1);
plot(X(:,1), X(:,2), 'b-', 'LineWidth', 1.5);
hold on;
plot(X(1,1), X(1,2), 'go', 'MarkerSize', 10); % Start point
plot(X(end,1), X(end,2), 'ro', 'MarkerSize', 10); % End point
title('Phase Portrait: x₁-x₂ plane');
xlabel('x₁');
ylabel('x₂');
grid on;
legend('Trajectory', 'Start', 'End', 'Location', 'best');

% x₁-x₃ plane
subplot(2,2,2);
plot(X(:,1), X(:,3), 'b-', 'LineWidth', 1.5);
hold on;
plot(X(1,1), X(1,3), 'go', 'MarkerSize', 10);
plot(X(end,1), X(end,3), 'ro', 'MarkerSize', 10);
title('Phase Portrait: x₁-x₃ plane');
xlabel('x₁');
ylabel('x₃');
grid on;
legend('Trajectory', 'Start', 'End', 'Location', 'best');

% x₂-x₃ plane
subplot(2,2,3);
plot(X(:,2), X(:,3), 'b-', 'LineWidth', 1.5);
hold on;
plot(X(1,2), X(1,3), 'go', 'MarkerSize', 10);
plot(X(end,2), X(end,3), 'ro', 'MarkerSize', 10);
title('Phase Portrait: x₂-x₃ plane');
xlabel('x₂');
ylabel('x₃');
grid on;
legend('Trajectory', 'Start', 'End', 'Location', 'best');

% 3D phase space
subplot(2,2,4);
plot3(X(:,1), X(:,2), X(:,3), 'b-', 'LineWidth', 1.5);
hold on;
plot3(X(1,1), X(1,2), X(1,3), 'go', 'MarkerSize', 10);
plot3(X(end,1), X(end,2), X(end,3), 'ro', 'MarkerSize', 10);
title('3D Phase Portrait');
xlabel('x₁');
ylabel('x₂');
zlabel('x₃');
grid on;
legend('Trajectory', 'Start', 'End', 'Location', 'best');
view(45, 30); % Adjust the view angle

% Make the figures look better
set(gcf, 'Position', [100 100 800 600]);