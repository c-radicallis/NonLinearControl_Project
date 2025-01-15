%clear all
close all

% consider the output feedback control of a given LTI system
s=tf('s')
tf_G= zpk(-1 , [-4 , -2 , 1] , 10 )

% Display numerator and denominator separately
[num, den] = tfdata(tf_G, 'v'); % Extract numerator and denominator as vectors

disp('Numerator (polynomial form):');
disp(poly2str(num, 's'));  % Converts to a human-readable string

disp('Denominator (polynomial form):');
disp(poly2str(den, 's'));  % Converts to a human-readable string


figure
hold on
nyquist(tf_G)
grid on
%axis equal;


w=0:1e-5:2;
H = (10 + 10i .* w) ./ (-8 - 5 .* w.^2 + 1i .* (2 .* w - w.^3));


%% Outter Circle
% Compute the magnitude of H(w)
% magnitude_H = abs(H);
% 
% [M,w_max] = max(magnitude_H,[],'linear')
% [imag_max,idx_imag] = max(abs(imag(H)),[],'linear');
% imag_max
% w_imag = w(idx_imag)
% [real_max , idx_real]= max(abs(real(H)),[],'linear');
% real_max
% w_real = w(idx_real)


% % Parameters for the circle
% center = real(H(idx_imag)) % Center of the circle (complex number, e.g., 2 + 3j)
% radius = imag_max      % Radius of the circle

%% Inner Circle
center=-0.73
radius=0.5

% Generate points for the circle
theta = linspace(0, 2*pi, 500); % Parameter for the circle
x = real(center) + radius * cos(theta); % Real part of the circle
y = imag(center) + radius * sin(theta); % Imaginary part of the circle

% Plot the circle
plot(x, y, 'b', 'LineWidth', 1.5,"DisplayName","C=-0.73   R=0.5"); % Circle in blue


% Add labels and grid
% xlabel('Real Axis');
% ylabel('Imaginary Axis');
% title('Circle in the Complex Plane');

% Show the circle
legend()%'Circle', 'Center');


a=-1/(center-radius)
b=-1/(center+radius)

% Define the x-axis range
x_range = linspace(-1, 1, 1000); % Adjust range as needed

% Define the lines
y_a = a * x_range; % Line with gradient 'a'
y_b = b * x_range; % Line with gradient 'b'

% Combine points for filling the region
x_fill = [x_range, fliplr(x_range)];
y_fill = [y_a, fliplr(y_b)];

% Plot the lines 
figure;
hold on;

% Fill the region between the lines
fill(x_fill, y_fill, [0.9, 0.9, 0.9], 'EdgeColor', 'none'); % Light gray fill

plot(x_range, y_a, 'r-', 'LineWidth', 1.5); % Line with gradient 'a'
plot(x_range, y_b, 'b-', 'LineWidth', 1.5); % Line with gradient 'b'

% Add the origin
plot(0, 0, 'ko', 'MarkerFaceColor', 'k'); % Mark the origin

% Annotate the plot
title(['Region containning the unknown nonlinearity' ...
    ' for which the system is GAS']);
xlabel('x');
ylabel('y');
legend("region",sprintf('a = %.2f ', a), sprintf('b = %.2f ', b), 'Origin');
grid on;
hold off;

