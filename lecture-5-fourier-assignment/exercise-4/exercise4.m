% Lecture 5 - Exercise 4: DTFT vs DFT of x = [1 1 1 1]
% Run this script in MATLAB. It saves a comparison plot.
clear; close all; clc;

folder = fileparts(mfilename('fullpath'));
if isempty(folder), folder = pwd; end

x = [1 1 1 1];
n = 0:length(x)-1;
w = linspace(-pi,pi,1000);
X = x * exp(-1j*(n.'*w));

N4 = 4; N64 = 64;
X4 = fftshift(fft(x,N4));
X64 = fftshift(fft(x,N64));
w4 = 2*pi*(-N4/2:N4/2-1)/N4;
w64 = 2*pi*(-N64/2:N64/2-1)/N64;

fig = figure('Color','w','Position',[100 100 1000 850]);
subplot(3,1,1);
plot(w,abs(X),'LineWidth',1.4); grid on;
title('DTFT (1000 evaluated angular frequencies)');
xlabel('Angular frequency (rad/sample)'); ylabel('Magnitude');
xlim([-pi pi]);

subplot(3,1,2);
stem(w4,abs(X4),'filled'); grid on;
title('DFT using fft(x, 4)');
xlabel('Angular frequency (rad/sample)'); ylabel('Magnitude');
xlim([-pi pi]); ylim([0 4.4]);

subplot(3,1,3);
stem(w64,abs(X64),'filled','MarkerSize',3); grid on;
title('DFT using fft(x, 64) (zero-padding)');
xlabel('Angular frequency (rad/sample)'); ylabel('Magnitude');
xlim([-pi pi]); ylim([0 4.4]);
sgtitle('Exercise 4: Continuous DTFT and sampled DFT');
exportgraphics(fig,fullfile(folder,'dtft-dft-comparison.png'),'Resolution',200);

fprintf('Original data samples: %d\n',length(x));
fprintf('DFT length 4 -> %d frequency points\n',numel(X4));
fprintf('DFT length 64 -> %d frequency points (60 zeros padded)\n',numel(X64));
fprintf('DTFT zeros in [-pi, pi]: -pi, -pi/2, pi/2, pi (within numeric precision)\n');
