%% Lecture 6 - In-class task: Inspect and filter a WAV file
% Choose an audio file you are permitted to use.
% Inspect waveform and spectrogram BEFORE selecting a filter.
% Requires Signal Processing Toolbox for butter, filtfilt and spectrogram.
clear; close all; clc;

% STEP 1: Select a WAV file. Leave this script in its project folder.
[file, filePath] = uigetfile({'*.wav','WAV audio (*.wav)'}, 'Select your WAV recording');
if isequal(file,0)
    error('No WAV file selected. Run again and choose a file.');
end
inputFile = fullfile(filePath,file);
[xOriginal, Fs] = audioread(inputFile);
numChannels = size(xOriginal,2);
numSamples = size(xOriginal,1);
durationSeconds = numSamples/Fs;
fprintf('File: %s\nSample rate: %.0f Hz\nDuration: %.3f seconds\nChannels: %d\n', ...
    file, Fs, durationSeconds, numChannels);

% Mono analysis signal for easy comparison. Stereo original is retained above.
% Filtering uses the mono signal below; the report must state any conversion.
if numChannels > 1
    x = mean(xOriginal,2);
    fprintf('Stereo/multichannel recording converted to mono by channel averaging for this analysis.\n');
else
    x = xOriginal;
end
if numel(x) < 64
    error('Recording too short for the selected analysis.');
end

% STEP 2: Inspect BEFORE filtering. Set inspectFromSeconds to any valid start.
inspectFromSeconds = 0;
sectionDurationSeconds = min(0.5, durationSeconds);
startIdx = min(numel(x), max(1, floor(inspectFromSeconds*Fs)+1));
endIdx = min(numel(x), startIdx+max(1,round(sectionDurationSeconds*Fs))-1);
t = (0:numel(x)-1)'/Fs;

nwin = min(1024,numel(x));
nwin = max(32,2^floor(log2(nwin)));
noverlap = floor(0.75*nwin);
nfft = max(1024,2^nextpow2(nwin));

fig1 = figure('Color','w','Name','Before filtering: inspection');
subplot(2,1,1);
plot(t(startIdx:endIdx), x(startIdx:endIdx),'b'); grid on;
xlabel('Time (s)'); ylabel('Amplitude');
title('Original WAV: short waveform section');
subplot(2,1,2);
spectrogram(x,nwin,noverlap,nfft,Fs,'yaxis');
title('Original WAV: spectrogram (inspect noise frequency)');
colorbar;

% STEP 3: After inspecting Figure 1, select a filter matching the noise.
% Valid choices: 'bandstop' (steady hum), 'lowpass' (high hiss),
%                'highpass' (low rumble).
filterType = 'bandstop';   % EDIT based on what you actually observe
stopBandHz = [49 51];     % EDIT for hum; edges in Hz
lowpassHz = 3000;         % EDIT for high-frequency hiss
highpassHz = 80;         % EDIT for low-frequency rumble
filterOrder = 4;          % Butterworth prototype order

nyquist = Fs/2;
switch lower(filterType)
    case 'bandstop'
        if numel(stopBandHz)~=2 || stopBandHz(1)<=0 || stopBandHz(2)>=nyquist || stopBandHz(1)>=stopBandHz(2)
            error('Stop band must satisfy 0 < lower < upper < Fs/2 = %.1f Hz.',nyquist);
        end
        [b,a] = butter(2, stopBandHz/nyquist, 'stop');
        settingsText = sprintf('Butterworth band-stop: %.1f-%.1f Hz (prototype order 2)',stopBandHz);
    case 'lowpass'
        if lowpassHz<=0 || lowpassHz>=nyquist
            error('Low-pass cutoff must lie between 0 and %.1f Hz.',nyquist);
        end
        [b,a] = butter(filterOrder, lowpassHz/nyquist,'low');
        settingsText = sprintf('Butterworth low-pass: %.1f Hz (order %d)',lowpassHz,filterOrder);
    case 'highpass'
        if highpassHz<=0 || highpassHz>=nyquist
            error('High-pass cutoff must lie between 0 and %.1f Hz.',nyquist);
        end
        [b,a] = butter(filterOrder, highpassHz/nyquist,'high');
        settingsText = sprintf('Butterworth high-pass: %.1f Hz (order %d)',highpassHz,filterOrder);
    otherwise
        error('Choose bandstop, lowpass, or highpass.');
end

% Zero-phase offline filtering; filtfilt has edge effects and is not live.
if numel(x) <= 3*(max(length(a),length(b))-1)
    error('Recording too short for filtfilt.');
end
y = filtfilt(b,a,x);
fprintf('Applied: %s\n',settingsText);

% STEP 4: Fair time comparison: identical axis limits and playback gain.
fig2 = figure('Color','w','Name','Original and filtered comparison');
subplot(2,2,1);
plot(t(startIdx:endIdx),x(startIdx:endIdx),'b'); grid on;
xlabel('Time (s)'); ylabel('Amplitude'); title('Original waveform');
subplot(2,2,2);
plot(t(startIdx:endIdx),y(startIdx:endIdx),'r'); grid on;
xlabel('Time (s)'); ylabel('Amplitude'); title('Filtered waveform');
segmentLim = max(abs([x(startIdx:endIdx);y(startIdx:endIdx)]));
segmentLim = max(segmentLim,eps)*1.05;
subplot(2,2,1); ylim([-segmentLim segmentLim]);
subplot(2,2,2); ylim([-segmentLim segmentLim]);

% Use the same color scale for the two spectrograms.
[Sx,Fx,Tx] = spectrogram(x,nwin,noverlap,nfft,Fs);
[Sy,Fy,Ty] = spectrogram(y,nwin,noverlap,nfft,Fs);
dbx = 20*log10(abs(Sx)+eps);
dby = 20*log10(abs(Sy)+eps);
cl = [max(-120,min([dbx(:);dby(:)])), max([dbx(:);dby(:)])];
if cl(2)<=cl(1), cl(2)=cl(1)+1; end
subplot(2,2,3);
imagesc(Tx,Fx,dbx); axis xy; ylim([0 nyquist]); caxis(cl);
xlabel('Time (s)'); ylabel('Frequency (Hz)'); title('Original spectrogram'); colorbar;
subplot(2,2,4);
imagesc(Ty,Fy,dby); axis xy; ylim([0 nyquist]); caxis(cl);
xlabel('Time (s)'); ylabel('Frequency (Hz)'); title('Filtered spectrogram'); colorbar;
sgtitle(['Comparison - ' settingsText]);

% STEP 5: Save figure and key information alongside the script.
projectFolder = fileparts(mfilename('fullpath'));
if isempty(projectFolder), projectFolder = pwd; end
exportgraphics(fig1,fullfile(projectFolder,'inspection-before-filtering.png'),'Resolution',180);
exportgraphics(fig2,fullfile(projectFolder,'original-vs-filtered.png'),'Resolution',180);
fid = fopen(fullfile(projectFolder,'measurement_summary.txt'),'w');
if fid<0, error('Could not save measurement_summary.txt.'); end
fprintf(fid,'Original file: %s\nSample rate: %.0f Hz\nDuration: %.3f s\nOriginal channels: %d\n',file,Fs,durationSeconds,numChannels);
fprintf(fid,'Analysis channels: 1 (mono)\nFilter: %s\n',settingsText);
fprintf(fid,'Original RMS: %.6f\nFiltered RMS: %.6f\n',sqrt(mean(x.^2)),sqrt(mean(y.^2)));
fprintf(fid,'Listening observations: [FILL IN AFTER LISTENING]\n');
fclose(fid);
fprintf('Saved: inspection-before-filtering.png, original-vs-filtered.png, measurement_summary.txt\n');

% STEP 6: Listen at same gain. Uncomment and run ONE line at a time.
% sound(x,Fs);  % original mono
% sound(y,Fs);  % filtered mono
% Do not normalize each separately: that changes playback gain.
