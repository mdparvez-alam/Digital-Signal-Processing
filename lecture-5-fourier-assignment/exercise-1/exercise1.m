% Lecture 5 - Exercise 1: Fourier series square-wave approximation
% Run this script in MATLAB. It saves a comparison figure to this folder.
clear; close all; clc;

folder = fileparts(mfilename('fullpath'));
if isempty(folder), folder = pwd; end

t = linspace(-1, 1, 4000);
harmonics = [1 3 9 25];

fig = figure('Color','w','Position',[100 100 1000 680]);
for i = 1:numel(harmonics)
    H = harmonics(i);
    x = zeros(size(t));
    for k = 1:2:H
        x = x + (4/pi) * sin(2*pi*k*t) / k;
    end

    subplot(2,2,i);
    plot(t, x, 'b', 'LineWidth', 1.2);
    grid on;
    xlabel('Time (s)'); ylabel('Amplitude');
    title(sprintf('Odd harmonics up to H = %d', H));
    xlim([-1 1]); ylim([-1.5 1.5]);
end
sgtitle('Exercise 1: Square wave from odd harmonics');
exportgraphics(fig, fullfile(folder, 'square-wave-comparison.png'), 'Resolution', 200);
fprintf('Saved: %s\n', fullfile(folder, 'square-wave-comparison.png'));
