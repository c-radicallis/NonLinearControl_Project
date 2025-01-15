clear all
close all

s = tf('s');
tf_G = zpk(-1, [-4, -2, 1], 10);

A_1 = 0.5; % delta
S_1 = A_1;
k = 2;

A_2 = 1; % delta
S_2 = A_2;
M_2 = 1;

A_3 = 2;
h = A_3;
B_3 = 0.5;
M_3 = B_3;

ic = 0;
Freq = logspace(-0.5, 1.2, 4); % Frequency range (1 Hz to ~30 Hz logarithmically spaced)
Amps = [2,4];         % Different amplitude values to test

% Specify the folder to save plots
save_folder = 'Sim_Results'; % Change this to your desired folder
if ~exist(save_folder, 'dir')
    mkdir(save_folder); % Create the folder if it doesn't exist
end


% Loop through each combination of Amp and Freq
for i = 1:length(Amps)
    for j = 1:length(Freq)
        Amp = Amps(i);
        freq = Freq(j);
        t_end = 2*2*pi/freq;

        % Run Simulink model
        assignin('base', 'StopTime', t_end);
        out = sim("problem1_model.slx",'StopTime', num2str(t_end));
        
        % Plot simulation results
        figure;
        hold on;
        for k = 1:4
            plot(out.simout.Time, out.simout.Data(:,k), 'LineWidth', 1.5);
            end
        xlabel('Time (s)');
        ylabel('Output');
        title(sprintf('System Response: u = %.1f sin( %.2f t)', Amp, freq));  
        legend('Input','Dead zone',' Saturation w/ dead zone', 'Hysteresis', 'Location', 'best');
        axis([0 t_end -(Amps(i)+2) Amps(i)+2])
        hold off;

        % Construct file path and save plot as PNG
        filename = sprintf('Amp%.1f_Freq%.2f.png', Amp, freq);
        filepath = fullfile(save_folder, filename);
        saveas(gcf, filepath);
    end
end
