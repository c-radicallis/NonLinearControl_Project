close all

% consider the output feedback control of a given LTI system
s=tf('s')
tf_G= zpk(-1 , [-4 , -2 , 1] , 10 )

%rlocus(tf_G)

% %%
% figure
% bode(tf_G)
% 
% figure
% n = nyquistplot(tf_G);
% setoptions(n,'ShowFullContour', 'off')
% grid on
% 

% %%
% figure
% t = 0:0.01:3;
% u= 0.01*sin(t);
% lsim( tf_G , u , t)
% 
% figure
% impulse(tf_G,[1,5])
% 
% figure
% step(tf_G,[1,5])

%%

%initial condition for simulink model
ic=0


%% Actuator 1 - Dead zone
%close all

A_1 = 0.5; % delta
S_1=A_1;
k = 2;

% Define X, ensuring no division by zero
X = A_1:1e-2:1e5; %-2:0.1:1;
A_X = zeros(size(X)); % Preallocate to match X size

% Calculate A_X only for X ~= 0 to avoid division by zero
non_zero_indices = X ~= 0; % Logical array where X is non-zero
A_X(non_zero_indices) = A_1 ./ X(non_zero_indices);

% Calculate N_deadzone for X >= A_1, else set it to 0
N_deadzone = zeros(size(X)); % Initialize with zeros
valid_indices = X > A_1; % Logical array for valid X values

% Only calculate N_deadzone for valid indices and X ~= 0
valid_and_non_zero = valid_indices & non_zero_indices; % Combine conditions
N_deadzone(valid_and_non_zero) = k - 2*k/pi * ( ...
    asin(A_X(valid_and_non_zero)) + ...
    A_X(valid_and_non_zero) .* sqrt(1 - (A_X(valid_and_non_zero)).^2) ...
);


inv_N_deadzone = -1./N_deadzone;

figure
hold on
n = nyquistplot(tf_G);
setoptions(n,'ShowFullContour', 'off')
grid on
plot( real(inv_N_deadzone) , imag(inv_N_deadzone), '*-',"DisplayName", "-1/N" )
xlabel('Real');
ylabel('Imaginary');
title('Nyquist plot of G  and  $\frac{-1}{N(X)}$ for Actuator 1 - Dead zone','interpreter', 'latex');
legend(["G","$\frac{-1}{N(X)}$"],'interpreter', 'latex');

% %%
% 
% syms G(w)  N(x)
% 
% 
% G(w) = 10*(1i*w+1)/((1i*w+4)*(1i*w+2)*(1i*w-1))
% assume(w,"real")
% 
% 
% N(x) = k - 2*k/pi*( asin(S_1/x) + S_1/x.*sqrt( 1-(S_1/x).^2 ) )
% assume(x,"real")
% 
% 
% 
% eq1= imag(G(w))==0
% sol1 = vpasolve(eq1,w,[0.1,100])
% 
% eq2= N(x)*real(G(w)) == 1



%% Actuator 2 - Saturation with Dead Zone
A_2 = 1; % delta
S_2=A_2;
M_2 = 1;

% Define X, ensuring no division by zero
X = A_2:1e-2:2; %-2:0.1:1;
A_X = zeros(size(X)); % Preallocate to match X size

% Calculate A_X only for X ~= 0 to avoid division by zero
non_zero_indices = X ~= 0; % Logical array where X is non-zero
A_X(non_zero_indices) = A_2 ./ X(non_zero_indices);

% Calculate N_saturation only for X > A_2
N_saturation = zeros(size(X)); % Initialize with zeros
valid_indices = X > A_2; % Logical array for valid X values

% Only calculate N_saturation for valid and non-zero indices
valid_and_non_zero = valid_indices & non_zero_indices; % Combine conditions
N_saturation(valid_and_non_zero) = ...
    4 * M_2 * sqrt(1 - (A_X(valid_and_non_zero)).^2) ./ (pi * X(valid_and_non_zero));

% Calculate -1/N_saturation for valid indices
inv_N_saturation = zeros(size(X)); % Initialize with zeros
inv_N_saturation(valid_and_non_zero) = -1 ./ N_saturation(valid_and_non_zero);

% Plot results
figure;
hold on;
n = nyquistplot(tf_G); % Assuming tf_G is defined elsewhere
setoptions(n, 'ShowFullContour', 'off');
grid on;
plot(real(inv_N_saturation), imag(inv_N_saturation), '*', "DisplayName", "-1/N");
xlabel('Real');
ylabel('Imaginary');
title('Nyquist plot of G  and  $\frac{-1}{N(X)}$ for Actuator 2 - Saturation with Dead zone','interpreter', 'latex');
legend(["G","$\frac{-1}{N(X)}$"],'interpreter', 'latex');
axis([-1.8 0.03 -0.9 0.3])

%% Actuator 3 - Hysteresis relay
%close all

A_3=2;
h=A_3;
B_3=0.5;
M_3=B_3;

X=A_3:1e-5:2.3; %-2:0.1:1;

% N_histeresis= 4*M*sqrt(1-(A_3/X)^2)/(pi*X)-i*4*A_3*M/(*pi*X^2) % if X>A_3 , else =0
% inv_N_histeresis = -1./N_histeresis;

% Calculate N_histeresis for X >= A_3, else set it to 0
N_histeresis = zeros(size(X)); % Initialize with zeros
valid_indices =  X > A_3; % Logical array where X is within [-A_3, A_3]
N_histeresis(valid_indices) = 4 * B_3 * sqrt(1 - (A_3 ./ X(valid_indices)).^2) ./ (pi * X(valid_indices)) ...
                              - 1i * 4 * A_3 * B_3 ./ (pi * X(valid_indices).^2); % Only calculate for X within the range

% figure
% plot(X,N_histeresis)

% Inverse of N_histeresis (handle division by zero)
inv_N_histeresis = zeros(size(N_histeresis)); % Initialize with zeros
non_zero_indices = N_histeresis ~= 0; % Avoid division by zero
inv_N_histeresis(non_zero_indices) = -1 ./ N_histeresis(non_zero_indices);

figure
hold on
n = nyquistplot(tf_G);
setoptions(n,'ShowFullContour', 'off')
grid on
plot( real(inv_N_histeresis) , imag(inv_N_histeresis), '*',"DisplayName", "-1/N" ) %,'o-'
xlabel('Real');
ylabel('Imaginary');
title('Nyquist plot of G  and  $\frac{-1}{N(X)}$ for Actuator 3 - Hysteresis','interpreter', 'latex');
legend(["G","$\frac{-1}{N(X)}$"],'interpreter', 'latex');
axis([-1.3 0.03 -3.3 0.5])
% %%
% pause
% 
% sol = vpasolve([eq1,eq2],[w,x])
% 
% G(sol.w)
% N(sol.x)

% %% Nyquist
% 
% figure
% hold on
% n = nyquistplot(tf_G);
% setoptions(n,'ShowFullContour', 'off')
% grid on
% legend()
% plot( real(inv_N_deadzone) , imag(inv_N_deadzone),'*-',"DisplayName", "Dead zone" );
% plot(real(inv_N_saturation), imag(inv_N_saturation), '*',"DisplayName", "Saturation w/Dead zone");
% plot( real(inv_N_histeresis) , imag(inv_N_histeresis),'*',"DisplayName", "Histeresis" );
% axis([-1.8 0.03 -3.3 0.6])
% ylabel('Imaginary');
% title('Nyquist plot of G  and  $\frac{-1}{N(X)}$','interpreter', 'latex');
% legend(["G","$\frac{-1}{N(X)}$"],'interpreter', 'latex');

%%
% %% On-Off
% 
% M=1
% 
% X=-1e1:1e-1:1e1; %-2:0.1:1;
% 
% N_on_off= 4*M./(pi*X);
% 
% figure
% plot(X,N_on_off)
