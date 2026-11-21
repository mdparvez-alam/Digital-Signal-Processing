% Lecture 02 - Sampling and Aliasing Investigation
% Run in MATLAB. Creates original_signal.png and five sampling PNGs.
% All figures are saved beside this script.
clear; close all; clc;

f0 = 10;                 % Signal frequency (Hz)
T = 1;                   % Duration (s)
dt = 1/10000;            % Fine time step for reference waveform (s)
tFine = 0:dt:T;
xFine = sin(2*pi*f0*tFine);
FsList = [15 20 25 50 100];

scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end

% Task 1: Fine-time reference
fig0 = figure('Color','w','Name','Original 10 Hz sine wave');
plot(tFine,xFine,'b','LineWidth',1.3);
grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('Original 10 Hz sine wave (1 second)');
legend('Fine-time reference','Location','best');
xlim([0 T]); ylim([-1.2 1.2]);
exportgraphics(fig0,fullfile(scriptFolder,'original_signal.png'),'Resolution',200);

% Task 2: Create and save one figure for each sampling frequency.
% Sample at t = 0, 1/Fs, ... excluding t = T so there are exactly Fs samples.
figSummary = figure('Color','w','Name','Sampling comparison');
tl = tiledlayout(figSummary,5,1,'TileSpacing','compact','Padding','compact');
for i = 1:numel(FsList)
    Fs = FsList(i);
    Ts = 1/Fs;
    ts = 0:Ts:T-Ts/2;  % Fs integer samples for a one-second record
    xs = sin(2*pi*f0*ts);

    fig = figure('Color','w','Name',sprintf('Sampling at %d Hz',Fs));
    plot(tFine,xFine,'b-','LineWidth',1.2); hold on;
    stem(ts,xs,'r','filled','LineWidth',1.0,'MarkerSize',4);
    grid on; xlim([0 T]); ylim([-1.2 1.2]);
    xlabel('Time (s)'); ylabel('Amplitude');
    title(sprintf('10 Hz sine wave sampled at Fs = %d Hz (Ts = %.4f s)',Fs,Ts));
    legend('Fine-time reference','Sampled values','Location','best');
    filename = sprintf('sampling_%dHz.png',Fs);
    exportgraphics(fig,fullfile(scriptFolder,filename),'Resolution',200);

    nexttile(tl);
    plot(tFine,xFine,'b-','LineWidth',0.9); hold on;
    stem(ts,xs,'r','filled','LineWidth',0.8,'MarkerSize',2.5);
    grid on; xlim([0 T]); ylim([-1.2 1.2]);
    title(sprintf('Fs = %d Hz | Ts = %.4f s | %d samples',Fs,Ts,numel(ts)));
    ylabel('Amplitude');
    if i==numel(FsList), xlabel('Time (s)'); end

    fprintf('Fs = %3d Hz: Ts = %.5f s, samples = %d, min/max sample = %.4f / %.4f\n', ...
       Fs,Ts,numel(ts),min(xs),max(xs));
    close(fig);
end

title(tl,'Sampling a 10 Hz sine wave: fine-time reference and samples');
exportgraphics(figSummary,fullfile(scriptFolder,'sampling_comparison.png'),'Resolution',200);

% Task 3: Nyquist threshold
fprintf('\nNyquist threshold: Fs >= 2*fmax = 2*10 = 20 Hz.\n');
fprintf('At Fs=20 Hz, sin(2*pi*10*n/20) is zero at all sample instants (phase-sensitive case).\n');
fprintf('At Fs=15 Hz, the 10 Hz sinusoid aliases to 5 Hz in magnitude.\n');
fprintf('Saved original_signal.png, five sampling_*Hz.png files, and sampling_comparison.png.\n');
