%% Lab 3: Frequency-Domain Filtering with fft2
% Mathematical Algorithms (DSP) - Image Processing Labs
% Run the entire script with MATLAB and Image Processing Toolbox.
% Saves five PNG figures and lab3_measurements.txt beside this script.
close all; clear; clc;

scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end

%% 0) Load source image
if exist('peppers.png','file') == 2
    sourceName = 'peppers.png';
    I0 = imread(sourceName);
elseif exist('cameraman.tif','file') == 2
    sourceName = 'cameraman.tif (grayscale fallback)';
    I0 = imread('cameraman.tif');
else
    error('Neither peppers.png nor cameraman.tif was found. Upload an image.');
end
if size(I0,3) == 3
    I = im2double(rgb2gray(I0));
else
    I = im2double(I0);
end
[M,N] = size(I);

%% 1) Centered log-magnitude spectrum
F = fft2(I);
Fshift = fftshift(F);
S = log1p(abs(Fshift));
fig1 = figure('Color','w','Name','Lab 3 - Spectrum');
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
nexttile; imshow(I,[]); title('Grayscale image');
nexttile; imshow(S,[]); title('Centered log-magnitude spectrum');
exportgraphics(fig1,fullfile(scriptFolder,'01_log_magnitude_spectrum.png'),'Resolution',160);

%% 2) Ideal and Gaussian low-pass frequency masks
[u,v] = meshgrid(-floor(N/2):(ceil(N/2)-1), ...
                 -floor(M/2):(ceil(M/2)-1));
D = hypot(u,v);
D0 = 40;
sigmaFrequency = 20;
H_ideal_LP = double(D <= D0);
H_gauss_LP = exp(-(D.^2)/(2*sigmaFrequency^2));

fig2 = figure('Color','w','Name','Lab 3 - Frequency masks');
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
nexttile; imshow(H_ideal_LP,[]); title('Ideal LP mask (radius 40 bins)');
nexttile; imshow(H_gauss_LP,[]); title('Gaussian LP mask (sigma 20 bins)');
exportgraphics(fig2,fullfile(scriptFolder,'02_lowpass_masks.png'),'Resolution',160);

%% 3) Apply low-pass filters in the frequency domain
G_ideal = real(ifft2(ifftshift(H_ideal_LP.*Fshift)));
G_gauss = real(ifft2(ifftshift(H_gauss_LP.*Fshift)));
fig3 = figure('Color','w','Name','Lab 3 - Low-pass filters');
tiledlayout(1,3,'TileSpacing','compact','Padding','compact');
nexttile; imshow(I,[]); title('Original');
nexttile; imshow(G_ideal,[]); title('Ideal LP (possible ringing)');
nexttile; imshow(G_gauss,[]); title('Gaussian LP (smooth)');
exportgraphics(fig3,fullfile(scriptFolder,'03_lowpass_comparison.png'),'Resolution',160);

%% 4) Gaussian high-pass using the complementary mask
H_gauss_HP = 1-H_gauss_LP;
G_hp_raw = real(ifft2(ifftshift(H_gauss_HP.*Fshift)));
G_hp_display = mat2gray(G_hp_raw); % display only; raw HP has signed values
fig4 = figure('Color','w','Name','Lab 3 - High-pass filter');
tiledlayout(1,2,'TileSpacing','compact','Padding','compact');
nexttile; imshow(I,[]); title('Original');
nexttile; imshow(G_hp_display,[]); title('Gaussian HP (display rescaled)');
exportgraphics(fig4,fullfile(scriptFolder,'04_highpass_comparison.png'),'Resolution',160);

%% 5) Fair spatial vs FFT comparison using SAME 7x7 Gaussian kernel
% Frequency Gaussian mask above (sigma=20 frequency bins) is not the same
% filter as a 7x7 Gaussian with spatial sigma 1.2. They need not match.
% A valid convolution-theorem test uses the identical spatial kernel and
% circular boundary handling in both approaches.
sigmaSpatial = 1.2;
g1d = fspecial('gaussian',[1 7],sigmaSpatial);
h_spatial = g1d'*g1d;  % 7x7 separable, normalized filter
I_spatial_gauss = imfilter(I,h_spatial,'circular','conv');
H_matched = psf2otf(h_spatial,[M N]);
I_fft_matched = real(ifft2(fft2(I).*H_matched));
maxMatchedDifference = max(abs(I_spatial_gauss(:)-I_fft_matched(:)));
rmseMatchedDifference = sqrt(mean((I_spatial_gauss(:)-I_fft_matched(:)).^2));
% This is for contrast only: two DIFFERENT Gaussian filters from starter.
I_spatial_replicate = imfilter(I,h_spatial,'replicate','conv');
rmseDifferentGaussian = sqrt(mean((I_spatial_replicate(:)-G_gauss(:)).^2));

fig5 = figure('Color','w','Name','Lab 3 - Convolution theorem');
tiledlayout(1,3,'TileSpacing','compact','Padding','compact');
nexttile; imshow(I_spatial_gauss,[]); title('Spatial Gaussian (circular)');
nexttile; imshow(I_fft_matched,[]); title('FFT Gaussian (same kernel)');
nexttile; imshow(abs(I_spatial_gauss-I_fft_matched),[]);
title('Absolute difference (autoscaled)');
exportgraphics(fig5,fullfile(scriptFolder,'05_spatial_vs_frequency.png'),'Resolution',160);

%% 6) Save measured results (do not claim listening or visual observations)
fid = fopen(fullfile(scriptFolder,'lab3_measurements.txt'),'w');
if fid < 0, error('Could not create lab3_measurements.txt'); end
fprintf(fid,'Lab 3: Frequency-Domain Filtering with fft2\n');
fprintf(fid,'Source image: %s\n',sourceName);
fprintf(fid,'Image dimensions: %d rows x %d columns\n',M,N);
fprintf(fid,'Image intensity min/max (normalized): %.6f / %.6f\n',min(I(:)),max(I(:)));
fprintf(fid,'Ideal LP cutoff radius: %.1f frequency bins\n',D0);
fprintf(fid,'Gaussian frequency LP sigma: %.1f frequency bins\n',sigmaFrequency);
fprintf(fid,'Matched spatial/FFT Gaussian kernel: 7x7, sigma=%.2f pixels\n',sigmaSpatial);
fprintf(fid,'Boundary mode for matched comparison: circular\n');
fprintf(fid,'Matched comparison max absolute difference: %.12g\n',maxMatchedDifference);
fprintf(fid,'Matched comparison RMSE: %.12g\n',rmseMatchedDifference);
fprintf(fid,'Different-filter comparison RMSE (spatial 7x7 replicate vs frequency Gaussian): %.12g\n',rmseDifferentGaussian);
fprintf(fid,'NOTE: Different-filter RMSE is not a numerical-equivalence test.\n');
fclose(fid);

fprintf('Source: %s | Image: %d x %d\n',sourceName,M,N);
fprintf('Spatial vs FFT SAME Gaussian, max abs difference: %.12g\n',maxMatchedDifference);
fprintf('Spatial vs FFT SAME Gaussian, RMSE: %.12g\n',rmseMatchedDifference);
fprintf('Different Gaussian definitions, RMSE: %.12g (not an equivalence test)\n',rmseDifferentGaussian);
fprintf('Saved five PNG figures and lab3_measurements.txt in:\n%s\n',scriptFolder);
fprintf('Review all plots and write your own observations in README.md.\n');
