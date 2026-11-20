%% Lecture 6 - Practical Digital Filtering (Parts A and B)
% Requires MATLAB and Signal Processing Toolbox.
% Run the entire script. Figures and measurements are saved next to this file.
clear; close all; clc;
root = fileparts(mfilename('fullpath'));
if isempty(root), root = pwd; end
out = fullfile(root,'figures');
if ~exist(out,'dir'), mkdir(out); end
fprintf('MATLAB version: %s\n', version);
if exist('fir1','file')~=2 || exist('butter','file')~=2 || ...
        exist('freqz','file')~=2 || exist('filtfilt','file')~=2
    error('Signal Processing Toolbox functions are unavailable.');
end
fprintf('Signal Processing Toolbox functions: available\n\n');

%% Part A - Reproducible synthetic sensor signal
Fs = 1000;
t = (0:1/Fs:2-1/Fs)';
rng(7);
clean = sin(2*pi*5*t) + 0.35*sin(2*pi*12*t);
noise = 0.35*sin(2*pi*50*t) + 0.20*sin(2*pi*137*t) + 0.25*randn(size(t));
x = clean + noise;
fc = 20;
bFIR = fir1(60, fc/(Fs/2), 'low');
[bIIR,aIIR] = butter(4, fc/(Fs/2), 'low');
yFIR = filtfilt(bFIR, 1, x);
yIIR = filtfilt(bIIR, aIIR, x);

% Figure A1: identical time axis, all four sensor traces
fig = figure('Color','w','Name','A1 Sensor time comparison');
segment = t <= 0.2;
plot(t(segment),clean(segment),'k-','LineWidth',1.4); hold on;
plot(t(segment),x(segment),'Color',[.65 .65 .65]);
plot(t(segment),yFIR(segment),'b-','LineWidth',1.2);
plot(t(segment),yIIR(segment),'r--','LineWidth',1.2);
legend('Clean reference','Noisy input','FIR + filtfilt','IIR + filtfilt','Location','best');
xlabel('Time (s)'); ylabel('Amplitude (sensor units)');
title('Part A: Sensor time-domain comparison (0–0.2 s)'); grid on;
exportgraphics(fig,fullfile(out,'A1_sensor_time.png'),'Resolution',180);

% Figure A2: one-pass frequency responses (filtfilt squares magnitude)
[HF,fResp] = freqz(bFIR,1,8192,Fs);
[HI,~] = freqz(bIIR,aIIR,8192,Fs);
fig = figure('Color','w','Name','A2 Filter responses');
plot(fResp,20*log10(max(abs(HF),eps)),'b','LineWidth',1.4); hold on;
plot(fResp,20*log10(max(abs(HI),eps)),'r--','LineWidth',1.4);
xline(fc,'k:','20 Hz nominal cutoff');
xlim([0 180]); ylim([-110 5]); grid on;
xlabel('Frequency (Hz)'); ylabel('One-pass magnitude (dB)');
title('Part A: FIR vs Butterworth IIR frequency responses');
legend('FIR order 60 (61 taps)','IIR Butterworth order 4','Location','southwest');
exportgraphics(fig,fullfile(out,'A2_filter_responses.png'),'Resolution',180);

% Figure A3: single-sided amplitude spectra (same N and amplitude scaling)
[fSensor,ampX] = singleSidedSpectrum(x,Fs);
[~,ampF] = singleSidedSpectrum(yFIR,Fs);
[~,ampI] = singleSidedSpectrum(yIIR,Fs);
fig = figure('Color','w','Name','A3 Sensor spectra');
plot(fSensor,ampX,'Color',[.55 .55 .55],'LineWidth',1.1); hold on;
plot(fSensor,ampF,'b','LineWidth',1.3);
plot(fSensor,ampI,'r--','LineWidth',1.3);
xlim([0 170]); grid on;
xlabel('Frequency (Hz)'); ylabel('Single-sided amplitude (sensor units)');
title('Part A: Spectrum before and after filtering');
legend('Noisy input','FIR output','IIR output','Location','northeast');
exportgraphics(fig,fullfile(out,'A3_sensor_spectra.png'),'Resolution',180);

rmseNoisy = sqrt(mean((x-clean).^2));
rmseFIR = sqrt(mean((yFIR-clean).^2));
rmseIIR = sqrt(mean((yIIR-clean).^2));
rmseTable = table({'Noisy input';'FIR (filtfilt)';'IIR (filtfilt)'}, ...
    [rmseNoisy;rmseFIR;rmseIIR], 'VariableNames',{'Signal','RMSE'});
disp('PART A RMSE versus clean reference:'); disp(rmseTable);
writetable(rmseTable,fullfile(root,'sensor_rmse.csv'));
for target = [5 12 50 137]
    [~,idx] = min(abs(fSensor-target));
    fprintf('Part A @ %3d Hz: noisy %.5f; FIR %.5f; IIR %.5f (spectrum bin %.2f Hz)\n', ...
        target,ampX(idx),ampF(idx),ampI(idx),fSensor(idx));
end

%% Part B - Handel recording with a controlled 50 Hz hum
% The assignment text contains a broken symbol in the supplied y(:) line.
% MATLAB's built-in Handel example provides y and Fs in the workspace.
load handel;  % provides y and Fs
xClean = double(y(:));
FsAudio = Fs;  % keep audio sample rate separate from sensor sample rate
if FsAudio <= 102, error('Audio sampling rate must exceed 102 Hz.'); end

tAudio = (0:numel(xClean)-1)'/FsAudio;
xHum = xClean + 0.15*sin(2*pi*50*tAudio);
[bN,aN] = butter(2,[49 51]/(FsAudio/2),'stop');
[bWide,aWide] = butter(2,[45 55]/(FsAudio/2),'stop');
yAudio = filtfilt(bN,aN,xHum);
yWide = filtfilt(bWide,aWide,xHum);

% Figure B1: same section and common y-axis limits
sel = tAudio >= 1 & tAudio <= 1.20;
fig = figure('Color','w','Name','B1 Audio time comparison');
plot(tAudio(sel),xClean(sel),'k','LineWidth',1); hold on;
plot(tAudio(sel),xHum(sel),'Color',[.6 .6 .6]);
plot(tAudio(sel),yAudio(sel),'b','LineWidth',1.1);
legend('Clean Handel','Hum added','Filtered 49–51 Hz','Location','best');
xlabel('Time (s)'); ylabel('Audio sample amplitude');
title('Part B: Handel audio waveforms (same playback-scale reference)'); grid on;
exportgraphics(fig,fullfile(out,'B1_audio_waveforms.png'),'Resolution',180);

% Figure B2: comparable one-sided amplitude spectra, close-up around 50 Hz
[fAudio,sClean] = singleSidedSpectrum(xClean,FsAudio);
[~,sHum] = singleSidedSpectrum(xHum,FsAudio);
[~,sNarrow] = singleSidedSpectrum(yAudio,FsAudio);
[~,sWide] = singleSidedSpectrum(yWide,FsAudio);
fig = figure('Color','w','Name','B2 Audio spectra');
plot(fAudio,sClean,'k','LineWidth',1.2); hold on;
plot(fAudio,sHum,'Color',[.65 .65 .65],'LineWidth',1.1);
plot(fAudio,sNarrow,'b','LineWidth',1.2);
plot(fAudio,sWide,'r--','LineWidth',1.2);
xlim([35 65]); grid on;
xlabel('Frequency (Hz)'); ylabel('Single-sided amplitude (audio units)');
title('Part B: Audio spectrum near 50 Hz');
legend('Clean','Hum added','49–51 Hz filtered','45–55 Hz filtered','Location','best');
exportgraphics(fig,fullfile(out,'B2_audio_spectra.png'),'Resolution',180);

% Figure B3: one-pass stop-filter responses, note filtfilt applies twice
[HN,ff] = freqz(bN,aN,16384,FsAudio);
[HW,~] = freqz(bWide,aWide,16384,FsAudio);
fig = figure('Color','w','Name','B3 Notch responses');
plot(ff,20*log10(max(abs(HN),eps)),'b','LineWidth',1.3); hold on;
plot(ff,20*log10(max(abs(HW),eps)),'r--','LineWidth',1.3);
xlim([35 65]); ylim([-100 5]); grid on;
xlabel('Frequency (Hz)'); ylabel('One-pass magnitude (dB)');
title('Part B: Narrow vs wide band-stop frequency responses');
legend('49–51 Hz notch','45–55 Hz notch','Location','southwest');
exportgraphics(fig,fullfile(out,'B3_notch_responses.png'),'Resolution',180);

% State measurement method explicitly: strongest FFT bin near 50 Hz.
% This includes any original music present in that bin; it is not a pure
% estimate of injected hum. Avoid claiming it measures only injected hum.
searchBins = abs(fAudio-50) <= 0.3;
peakBefore = max(sHum(searchBins));
peakAfter = max(sNarrow(searchBins));
peakWide = max(sWide(searchBins));
attenMeasured = 20*log10(max(peakAfter,realmin)/max(peakBefore,realmin));
attenWide = 20*log10(max(peakWide,realmin)/max(peakBefore,realmin));
fprintf('\nPART B (audio Fs = %.0f Hz, length %.2f s)\n',FsAudio,numel(xClean)/FsAudio);
fprintf('Peak spectrum amplitude within 50 +/- 0.3 Hz: before %.6g, narrow %.6g, wide %.6g\n', ...
    peakBefore,peakAfter,peakWide);
fprintf('Measured near-50 Hz bin-peak change: narrow %.2f dB, wide %.2f dB\n', ...
    attenMeasured,attenWide);
resultsFile = fullfile(root,'measured_results.txt');
fid = fopen(resultsFile,'w');
fprintf(fid,'MATLAB %s\nSignal Processing Toolbox functions available\n',version);
fprintf(fid,'Part A: Fs = 1000 Hz, N = %d, fc = 20 Hz\n',numel(x));
fprintf(fid,'RMSE noisy = %.8f\nRMSE FIR = %.8f\nRMSE IIR = %.8f\n',rmseNoisy,rmseFIR,rmseIIR);
fprintf(fid,'Part B: Fs = %g Hz, N = %d\n',FsAudio,numel(xClean));
fprintf(fid,'50 Hz spectral bin peak +/-0.3 Hz before = %.8g\n',peakBefore);
fprintf(fid,'Narrow peak = %.8g (change %.3f dB)\n',peakAfter,attenMeasured);
fprintf(fid,'Wide peak = %.8g (change %.3f dB)\n',peakWide,attenWide);
fprintf(fid,'Method: max single-sided FFT amplitude within +/-0.3 Hz of 50 Hz, full recording.\n');
fclose(fid);

% Listen manually at equal playback gain (avoid soundsc automatic rescaling):
% gain = max([1; abs(xHum); abs(yAudio)]);
% sound(xHum/gain, FsAudio);      % Listen to hum-added example
% sound(yAudio/gain, FsAudio);    % After playback finishes, listen to filtered
% sound(yWide/gain, FsAudio);     % Optional wide-band comparison
fprintf('\nPlots and measured_results.txt saved. Listen using the commented sound() lines, one at a time.\n');

%% Local helper - single-sided amplitude spectrum (even or odd lengths)
function [f,P1] = singleSidedSpectrum(z,Fs)
    z = z(:); N = numel(z);
    Y = fft(z);
    nHalf = floor(N/2);
    P1 = abs(Y(1:nHalf+1))/N;
    if mod(N,2)==0
        if numel(P1)>2, P1(2:end-1) = 2*P1(2:end-1); end
    else
        if numel(P1)>1, P1(2:end) = 2*P1(2:end); end
    end
    f = Fs*(0:nHalf)'/N;
end
