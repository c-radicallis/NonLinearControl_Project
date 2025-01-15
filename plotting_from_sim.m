clear all
close all

s=tf('s');
tf_G= zpk(-1 , [-4 , -2 , 1] , 10 );


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


ic = 0;
Freq = logspace(0, 1.5, 4); % Frequency range (1 Hz to 100 Hz logarithmically spaced)
Amps = [0.5,1,2];       % Different amplitude values to test
t_end=10;

% Loop through each combination of Amp and Freq
for i = 1:length(Amps)
    for j = 1:length(Freq)
        Amp = Amps(i);
        freq = Freq(j);
        
        % % Generate sinusoidal input signal
        % t = 0:0.001:t_end; % Time vector (5 seconds, 1 ms resolution)
        % u = Amp * sin( freq * t); % Sinusoidal input
        
        % % Assign input to Simulink model workspace
        % assignin('base', 'u', u);
        % assignin('base', 't', t);
        
        % Run Simulink model
        out = sim("problem1_model.slx");
        
        % Plot simulation results
        figure;
        hold on;
        plot(out.simout)%, 'DisplayName', sprintf('Freq=%.1f Hz, Amp=%.1f', freq, Amp));
        hold off;
        xlabel('Time (s)');
        ylabel('Output');
        title(sprintf('System Response for u = %.1f sin(%.1f t)', Amps(i),Freq(i)));
        legend('show');
    end
end