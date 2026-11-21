% Lecture 02 In-Class Assignment: Hearing and Seeing Aliasing
% Run in MATLAB with Signal Processing Toolbox (periodogram).
% All four requested rates are investigated in one reproducible run.
% IMPORTANT: Keep headphone/speaker volume LOW; 7 kHz can be uncomfortable.
clear; close all; clc;

fs_original = 48000;        % Hz
signal_frequency = 7000;   % Hz
duration = 2;              % seconds
amplitude = 0.20;          % amplitude for safe initial playback (lower if needed)
fs_values = [24000 16000 12000 8000];

% Playback is optional. Change to true ONLY after reducing device volume.
playAudio = false;

scriptDir = fileparts(mfilename('fullpath'));
if isempty(scriptDir), scriptDir = pwd; end

t = (0:round(duration*fs_original)-1)'/fs_original;
x = amplitude * sin(2*pi*signal_frequency*t);

% Periodogram frequency axis is in Hz; plot f/1000 for kHz labels.
[pOriginal, fOriginal] = periodogram(x, [], [], fs_original);

if playAudio
    fprintf('Playing original 7 kHz tone at %.0f Hz sample rate. Keep device volume low.\n', fs_original);
    sound(x, fs_original);  % sound() preserves provided scale unlike soundsc()
    pause(duration + 0.5);
end

fprintf('Original signal: %.0f Hz, sample rate %.0f Hz, duration %.1f s\n', ...
    signal_frequency, fs_original, duration);
fprintf('Minimum Nyquist sample rate: %.0f Hz\n\n', 2*signal_frequency);
fprintf('%9s %12s %13s %10s\n', 'Fs (Hz)', 'Nyquist (Hz)', 'Peak (Hz)', 'Aliasing');

fsOut = zeros(numel(fs_values),1);
nyquistOut = zeros(numel(fs_values),1);
peakOut = zeros(numel(fs_values),1);
aliasedOut = false(numel(fs_values),1);

for j = 1:numel(fs_values)
    fs_low = fs_values(j);
    M = fs_original/fs_low;
    if mod(M,1) ~= 0
        error('fs_low must divide 48000 exactly.');
    end

    % No anti-alias filter: intentional, to demonstrate aliasing.
    x_alias = x(1:M:end);
    nyquist_frequency = fs_low/2;
    [pAlias, fAlias] = periodogram(x_alias, [], [], fs_low);
    [~, idx] = max(pAlias);
    observedPeakHz = fAlias(idx);
    hasAliasing = fs_low < 2*signal_frequency;

    fsOut(j) = fs_low;
    nyquistOut(j) = nyquist_frequency;
    peakOut(j) = observedPeakHz;
    aliasedOut(j) = hasAliasing;
    fprintf('%9.0f %12.0f %13.0f %10s\n', fs_low, nyquist_frequency, ...
        observedPeakHz, stringYesNo(hasAliasing));

    fig = figure('Color','w', 'Position',[100 100 950 650]);
    subplot(2,1,1);
    plot(fOriginal/1000, 10*log10(pOriginal + eps), 'b', 'LineWidth',1.2);
    hold on;
    xline(signal_frequency/1000, '--r', 'Original: 7 kHz', ...
        'LineWidth',1.2, 'LabelVerticalAlignment','bottom');
    xlim([0 10]); grid on;
    xlabel('Frequency (kHz)'); ylabel('PSD (dB/Hz)');
    title('Original 7 kHz signal (sampled at 48 kHz)');

    subplot(2,1,2);
    plot(fAlias/1000, 10*log10(pAlias + eps), 'm', 'LineWidth',1.2);
    hold on;
    xline(observedPeakHz/1000, '--k', sprintf('Peak: %.0f kHz',observedPeakHz/1000), ...
        'LineWidth',1.2, 'LabelVerticalAlignment','bottom');
    xlim([0 fs_low/2000]); grid on;
    xlabel('Frequency (kHz)'); ylabel('PSD (dB/Hz)');
    title(sprintf('Downsampled: Fs = %g kHz | Nyquist = %g kHz | Aliasing: %s', ...
        fs_low/1000, nyquist_frequency/1000, stringYesNo(hasAliasing)));
    sgtitle(sprintf('Hearing and Seeing Aliasing: %g kHz sample rate',fs_low/1000));

    filename = sprintf('spectrum_%dkHz.png', round(fs_low/1000));
    exportgraphics(fig, fullfile(scriptDir,filename), 'Resolution',180);
    fprintf('Saved: %s\n',filename);

    if playAudio
        fprintf('Playing signal after downsampling to %g kHz (same sample amplitude).\n', fs_low/1000);
        sound(x_alias, fs_low);
        pause(duration + 0.5);
    end
end

results = table(fsOut, nyquistOut, peakOut, aliasedOut, ...
    'VariableNames',{'SamplingFrequency_Hz','NyquistFrequency_Hz', ...
                     'ObservedPeak_Hz','Aliasing'});
writetable(results,fullfile(scriptDir,'sampling_results.csv'));
disp(' '); disp(results);
fprintf('\nSaved four spectrum figures and sampling_results.csv in the script folder.\n');
fprintf('Listening comparison not performed unless playAudio = true.\n');

function answer = stringYesNo(value)
if value, answer = 'Yes'; else, answer = 'No'; end
end
