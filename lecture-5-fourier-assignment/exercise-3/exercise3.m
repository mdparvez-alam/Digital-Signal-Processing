% Lecture 5 - Exercise 3: Spectral leakage and zero-padding
% IMPORTANT: Change d to the last digit of YOUR student number (0 to 9).
% Run this script in MATLAB. It saves three spectra and a comparison image.
clear; close all; clc;

folder = fileparts(mfilename('fullpath'));
if isempty(folder), folder = pwd; end

d = 4;  % PLACEHOLDER ONLY: replace with your own last digit.
assert(isscalar(d) && d == floor(d) && d >= 0 && d <= 9, ...
    'd must be an integer between 0 and 9.');
fs = 200;
f1 = 15; f2 = 13.2 + 0.17*d;
a1 = 0.8; a2 = 0.4;

% One-second observation
T1 = 1;
t1 = 0:1/fs:T1-1/fs;
x1 = a1*sin(2*pi*f1*t1) + a2*sin(2*pi*f2*t1);
[fOne,pOne] = singleSidedSpectrum(x1,fs,length(x1));

% Four-second observation: same sampling frequency and signal frequencies
T4 = 4;
t4 = 0:1/fs:T4-1/fs;
x4 = a1*sin(2*pi*f1*t4) + a2*sin(2*pi*f2*t4);
[fFour,pFour] = singleSidedSpectrum(x4,fs,length(x4));

% Zero-pad the ONE-SECOND observation (not the four-second one)
Npad = 4*length(x1);
[fPad,pPad] = singleSidedSpectrum(x1,fs,Npad);

fAll = {fOne,fFour,fPad};
pAll = {pOne,pFour,pPad};
labels = {'1 second (N = 200, 1 Hz bins)', ...
          '4 seconds (N = 800, 0.25 Hz bins)', ...
          '1 second, zero-padded to 800 FFT points'};
files = {'one-second-spectrum.png','four-second-spectrum.png', ...
         'zero-padded-spectrum.png'};

for j = 1:3
    fig = figure('Color','w');
    plot(fAll{j},pAll{j},'LineWidth',1.2); grid on;
    xlabel('Frequency (Hz)'); ylabel('Single-sided amplitude');
    title(sprintf('Exercise 3: %s',labels{j}));
    xlim([8 20]); ylim([0 1.15]);
    xline(f1,'--','15 Hz','LabelVerticalAlignment','bottom');
    xline(f2,':',sprintf('f2 = %.2f Hz',f2), ...
        'LabelVerticalAlignment','top');
    exportgraphics(fig,fullfile(folder,files{j}),'Resolution',200);
end

figCompare = figure('Color','w','Position',[100 100 1000 850]);
for j = 1:3
    subplot(3,1,j);
    plot(fAll{j},pAll{j},'LineWidth',1.2); grid on;
    xlim([8 20]); ylim([0 1.15]);
    xlabel('Frequency (Hz)'); ylabel('Amplitude'); title(labels{j});
    xline(f1,'--'); xline(f2,':');
end
sgtitle(sprintf('Exercise 3: Leakage comparison (d = %d, f2 = %.2f Hz)',d,f2));
exportgraphics(figCompare,fullfile(folder,'leakage-comparison.png'),'Resolution',200);

fprintf('d = %d, f2 = %.2f Hz\n',d,f2);
fprintf('1 s: %.3f Hz bins; 4 s: %.3f Hz bins\n',fs/length(x1),fs/length(x4));
fprintf('1 s with zero-padding: %.3f Hz plotted FFT grid; actual observation still 1 s\n',fs/Npad);

function [f,P1] = singleSidedSpectrum(x,fs,nfft)
    % Normalize by the number of OBSERVED samples, not padded FFT length.
    N = length(x);
    Y = fft(x,nfft);
    P2 = abs(Y/N);
    P1 = P2(1:nfft/2+1);
    P1(2:end-1) = 2*P1(2:end-1);
    f = fs*(0:nfft/2)/nfft;
end
