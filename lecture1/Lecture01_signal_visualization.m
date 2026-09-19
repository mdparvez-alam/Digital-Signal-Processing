%% Assignment 01 - Signal Visualization with MATLAB
% Digital Signal Processing
% This script creates and visualizes sine-wave signals, compares frequency
% and amplitude, adds random noise, and saves the required figures.

clear;
clc;
close all;

%% Common settings
fs = 1000;                 % Sampling frequency in Hz
T = 1;                     % Duration in seconds
t = 0:1/fs:T-1/fs;         % Time vector (exactly 1 second)

%% Task 1: Create a Sine Wave
A = 1;                     % Amplitude
f = 5;                     % Frequency in Hz
x = A * sin(2*pi*f*t);

figure('Name', 'Task 1 - Sine Wave');
plot(t, x, 'LineWidth', 1.3);
title('5 Hz Sine Wave');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

%% Task 2: Compare Different Frequencies
frequencies = [2 5 10];

figure('Name', 'Task 2 - Frequency Comparison');
for k = 1:length(frequencies)
    fk = frequencies(k);
    xk = sin(2*pi*fk*t);

    subplot(3,1,k);
    plot(t, xk, 'LineWidth', 1.2);
    title(sprintf('%d Hz Sine Wave', fk));
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
    ylim([-1.2 1.2]);
end

sgtitle('Frequency Comparison');
saveas(gcf, 'frequency_comparison.png');

%% Task 3: Compare Different Amplitudes
amplitudes = [0.5 1 2];
commonFrequency = 5;       % Same frequency for all signals

figure('Name', 'Task 3 - Amplitude Comparison');
for k = 1:length(amplitudes)
    Ak = amplitudes(k);
    xk = Ak * sin(2*pi*commonFrequency*t);

    subplot(3,1,k);
    plot(t, xk, 'LineWidth', 1.2);
    title(sprintf('Amplitude = %.1f, Frequency = %d Hz', ...
        Ak, commonFrequency));
    xlabel('Time (s)');
    ylabel('Amplitude');
    grid on;
    ylim([-2.2 2.2]);
end

sgtitle('Amplitude Comparison');
saveas(gcf, 'amplitude_comparison.png');

%% Task 4: Add Noise
rng(1);                    % Makes the random noise repeatable
cleanSignal = sin(2*pi*5*t);
noise = 0.30 * randn(size(t));
noisySignal = cleanSignal + noise;

figure('Name', 'Task 4 - Clean vs Noisy Signal');

subplot(2,1,1);
plot(t, cleanSignal, 'LineWidth', 1.2);
title('Clean 5 Hz Sine Wave');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

subplot(2,1,2);
plot(t, noisySignal, 'LineWidth', 1.0);
title('Noisy 5 Hz Sine Wave');
xlabel('Time (s)');
ylabel('Amplitude');
grid on;

sgtitle('Clean vs Noisy Signal');
saveas(gcf, 'clean_vs_noisy_signal.png');

%% Completion message
disp('Assignment figures created successfully:');
disp('frequency_comparison.png');
disp('amplitude_comparison.png');
disp('clean_vs_noisy_signal.png');