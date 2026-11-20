% Lecture 5 - Exercise 2: Two sinusoidal frequencies with FFT
% Run this script in MATLAB. It saves time-domain and spectrum plots.
clear; close all; clc;

folder = fileparts(mfilename('fullpath'));
if isempty(folder), folder = pwd; end

fs = 200; T = 1;
t = 0:1/fs:T-1/fs;
x = 0.8*sin(2*pi*15*t) + 0.4*sin(2*pi*40*t);
N = length(x);

fig1 = figure('Color','w');
plot(t,x,'LineWidth',1.2); grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('Exercise 2: Time-domain signal (15 Hz and 40 Hz)');
exportgraphics(fig1,fullfile(folder,'two-frequency-time-domain.png'),'Resolution',200);

Y = fft(x);
P2 = abs(Y/N);
P1 = P2(1:N/2+1);
P1(2:end-1) = 2*P1(2:end-1);
f = fs*(0:N/2)/N;

fig2 = figure('Color','w');
stem(f,P1,'filled','MarkerSize',3); grid on;
xlabel('Frequency (Hz)'); ylabel('Single-sided amplitude');
title('Exercise 2: Single-sided FFT amplitude spectrum');
xlim([0 100]); ylim([0 0.95]);
exportgraphics(fig2,fullfile(folder,'two-frequency-spectrum.png'),'Resolution',200);

binSpacing = fs/N;
idx15 = find(abs(f-15) < 1e-10,1);
idx40 = find(abs(f-40) < 1e-10,1);
fprintf('N = %d, fs = %.1f Hz, bin spacing = %.3f Hz\n',N,fs,binSpacing);
fprintf('At %.1f Hz: measured amplitude %.6f (expected 0.8)\n',f(idx15),P1(idx15));
fprintf('At %.1f Hz: measured amplitude %.6f (expected 0.4)\n',f(idx40),P1(idx40));
