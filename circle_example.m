% Linear system G(s)
numerator = 1;                  % Numerator of G(s)
denominator = [1, 2, 0];        % Denominator of G(s)
G = tf(numerator, denominator); % Transfer function G(s)

% Sector bounds for the nonlinearity
a = 0;  % Lower bound
b = 3;  % Upper bound

% Circle parameters (center and radius)
center = (a + b) / 2;           % Center of the circle
radius = (b - a) / 2;           % Radius of the circle

% Plot the Nyquist plot of G(s)
figure;
nyquist(G);                     % Nyquist plot of the linear system
hold on;

% Plot the critical circle for the sector bounds
theta = linspace(0, 2*pi, 500); % Parameter for the circle
x_circle = center + radius * cos(theta); % Real part of the circle
y_circle = radius * sin(theta);          % Imaginary part of the circle

plot(x_circle, y_circle, 'r', 'LineWidth', 1.5); % Circle in red
legend('Nyquist Plot of G(s)', 'Critical Circle');
title('Nyquist Plot with Circle Criterion');
xlabel('Real Axis');
ylabel('Imaginary Axis');
grid on;
axis equal;

% Highlight the center of the circle
plot(center, 0, 'ro', 'MarkerFaceColor', 'r'); % Circle center

% Display stability conclusion
fprintf('Circle Center: %f\n', center);
fprintf('Circle Radius: %f\n', radius);
disp('Check if the Nyquist plot of G(s) stays outside the critical circle.');
