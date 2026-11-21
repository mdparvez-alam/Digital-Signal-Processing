%% Lab 4: Noise and Filtering
% Course: Mathematical Algorithms (DSP) - Image Processing Labs
% Requires Image Processing Toolbox.
% Run the entire script to export PNG figures and lab4_measurements.txt.
close all; clear; clc;

scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end

%% 0) Load source image
if exist('peppers.png','file') == 2
    sourceName = 'peppers.png';
    I0 = imread(sourceName);
elseif exist('cameraman.tif','file') == 2
    sourceName = 'cameraman.tif (fallback)';
    I0 = imread('cameraman.tif');
else
    error('No sample image found. Upload peppers.png or cameraman.tif to MATLAB Drive.');
end
if size(I0,3) == 3
    I = im2double(rgb2gray(I0));
else
    I = im2double(I0);
end
rng(7); % Repeatable random Gaussian and salt-and-pepper noise.

%% 1) Noise types
I_gauss = imnoise(I, 'gaussian', 0, 0.01);
I_sp = imnoise(I, 'salt & pepper', 0.05);
fig = figure('Color','w','Name','Lab 4 - Noise types');
subplot(1,3,1); imshow(I); title('Original');
subplot(1,3,2); imshow(I_gauss); title('Gaussian noise (var = 0.01)');
subplot(1,3,3); imshow(I_sp); title('Salt & pepper (density = 0.05)');
sgtitle('Original and two noise models');
exportgraphics(fig,fullfile(scriptFolder,'01_noise_types.png'),'Resolution',160);

%% 2) Noise metrics
% SNR = 10*log10(sum(clean(:).^2)/sum((test(:)-clean(:)).^2)).
% This is reference-based SNR, using the known clean image.

%% 3) Linear and nonlinear filtering
h_avg = fspecial('average',3);
h_gauss = fspecial('gaussian',[3 3],0.7);
I_avg_gauss = imfilter(I_gauss,h_avg,'replicate');
I_avg_sp = imfilter(I_sp,h_avg,'replicate');
I_gauss_gauss = imfilter(I_gauss,h_gauss,'replicate');
I_gauss_sp = imfilter(I_sp,h_gauss,'replicate');
I_med_gauss = medfilt2(I_gauss,[3 3],'symmetric');
I_med_sp = medfilt2(I_sp,[3 3],'symmetric');

fig = figure('Color','w','Name','Lab 4 - Salt and pepper');
subplot(2,2,1); imshow(I); title('Clean reference');
subplot(2,2,2); imshow(I_sp); title('Salt & pepper noisy');
subplot(2,2,3); imshow(I_avg_sp); title('3x3 mean filtered');
subplot(2,2,4); imshow(I_med_sp); title('3x3 median filtered');
sgtitle('Salt-and-pepper noise: mean versus median');
exportgraphics(fig,fullfile(scriptFolder,'02_salt_pepper_filtering.png'),'Resolution',160);

fig = figure('Color','w','Name','Lab 4 - Gaussian noise');
subplot(2,3,1); imshow(I); title('Clean reference');
subplot(2,3,2); imshow(I_gauss); title('Gaussian noisy');
subplot(2,3,3); imshow(I_avg_gauss); title('Mean 3x3');
subplot(2,3,4); imshow(I_gauss_gauss); title('Gaussian 3x3, sigma 0.7');
subplot(2,3,5); imshow(I_med_gauss); title('Median 3x3');
subplot(2,3,6); imshow(abs(I_gauss-I)); title('Absolute noise error', 'Interpreter','none');
sgtitle('Gaussian noise: filter comparison');
exportgraphics(fig,fullfile(scriptFolder,'03_gaussian_filtering.png'),'Resolution',160);

%% 4) Quantitative metrics for all cases
names = {'Gaussian noisy';'Gaussian + mean';'Gaussian + Gaussian LP';'Gaussian + median'; ...
         'Salt-pepper noisy';'Salt-pepper + mean';'Salt-pepper + Gaussian LP';'Salt-pepper + median'};
images = {I_gauss,I_avg_gauss,I_gauss_gauss,I_med_gauss, ...
          I_sp,I_avg_sp,I_gauss_sp,I_med_sp};
MSE = zeros(numel(images),1);
SNR_dB = zeros(numel(images),1);
for idx=1:numel(images)
    testImage = images{idx};
    err = double(testImage)-double(I);
    MSE(idx) = mean(err(:).^2);
    SNR_dB(idx) = 10*log10(sum(I(:).^2)/sum(err(:).^2));
end
results = table(names,MSE,SNR_dB,'VariableNames',{'Signal','MSE','SNR_dB'});
disp(results);

fig = figure('Color','w','Name','Lab 4 - MSE comparison');
bar(MSE);
set(gca,'XTick',1:numel(names),'XTickLabel',names,'XTickLabelRotation',35);
ylabel('MSE (normalized intensity squared)');
title('MSE against original image (lower is better)'); grid on;
exportgraphics(fig,fullfile(scriptFolder,'04_mse_comparison.png'),'Resolution',160);

%% 5) Save measurements
fid = fopen(fullfile(scriptFolder,'lab4_measurements.txt'),'w');
if fid == -1, error('Could not write lab4_measurements.txt'); end
fprintf(fid,'Lab 4: Noise and Filtering\n');
fprintf(fid,'Source image: %s\n',sourceName);
fprintf(fid,'Dimensions: %d rows x %d columns\n',size(I,1),size(I,2));
fprintf(fid,'Random seed: 7\nGaussian variance: 0.01\nSalt-and-pepper density: 0.05\n');
fprintf(fid,'SNR method: 10*log10(sum(clean.^2)/sum((filtered-clean).^2))\n');
fprintf(fid,'All metrics use normalized intensities on [0,1].\n\n');
fprintf(fid,'%-28s %12s %12s\n','Signal','MSE','SNR (dB)');
for idx=1:numel(names)
    fprintf(fid,'%-28s %12.8f %12.4f\n',names{idx},MSE(idx),SNR_dB(idx));
end
fprintf(fid,'\nNOTE: Results are measured after running the script.\n');
fclose(fid);
writetable(results,fullfile(scriptFolder,'lab4_results.csv'));
fprintf('\nSaved four PNG files, lab4_measurements.txt and lab4_results.csv to:\n%s\n',scriptFolder);
fprintf('Open the figures and add your observations to README.md.\n');
