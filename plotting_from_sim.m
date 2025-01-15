clear all
close all

s=tf('s')
tf_G= zpk(-1 , [-4 , -2 , 1] , 10 )

ic=0

Amp = 0
Freq = logspace(0,2,5)

A_1 = 0.5; % delta
S_1=A_1;
k = 2;

A_2 = 1; % delta
S_2=A_2;
M_2 = 1;

A_3=2;
h=A_3;
B_3=0.5;
M_3=B_3;

% plotting from simulink simulation results

out=sim("problem1_model.slx")

%%


plot(out.simout)
% xlabel('Real');
% ylabel('Imaginary');
% title('Nyquist plot of G  and  $\frac{-1}{N(X)}$ for Actuator 1 - Dead zone','interpreter', 'latex');
% legend(["G","$\frac{-1}{N(X)}$"],'interpreter', 'latex');

