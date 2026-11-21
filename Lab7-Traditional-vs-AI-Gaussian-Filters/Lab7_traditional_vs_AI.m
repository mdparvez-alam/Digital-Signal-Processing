%% Lab 7 - Traditional vs AI Gaussian Filters
% Mathematical Algorithms (DSP) - Image Processing Labs
% Compare Gaussian-noise removal using mean, median, Gaussian, Wiener and DnCNN.
% Requires Image Processing Toolbox; DnCNN requires Deep Learning Toolbox
% and access to the pretrained DnCNN network.
% Run once in MATLAB Online. Outputs are saved next to this script.
clear; close all; clc;

scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end

%% 1) Reproducible image and Gaussian noise
if exist('cameraman.tif','file') ~= 2
    error('cameraman.tif was not found. Upload it to MATLAB Drive.');
end
originalImage = im2double(imread('cameraman.tif'));
if ndims(originalImage)==3
    originalImage = rgb2gray(originalImage);
end
rng(7);
noiseSigma = 0.04;
noisyImage = imnoise(originalImage,'gaussian',0,noiseSigma^2);

%% 2) Traditional denoisers (all process the SAME noisy image)
meanFiltered = imfilter(noisyImage,ones(3,3)/9,'replicate');
medianFiltered = medfilt2(noisyImage,[3 3],'symmetric');
gaussianFiltered = imgaussfilt(noisyImage,0.7,'Padding','replicate');
wienerFiltered = wiener2(noisyImage,[5 5],noiseSigma^2);

%% 3) DnCNN AI method, if available - NO fabricated fallback
aiAvailable = false;
aiError = '';
aiFiltered = [];
try
    if exist('denoisingNetwork','file')~=2 || exist('denoiseImage','file')~=2
        error('denoisingNetwork or denoiseImage not found. Check Image Processing and Deep Learning Toolboxes.');
    end
    net = denoisingNetwork('DnCNN');
    aiFiltered = double(denoiseImage(noisyImage,net));
    if ~isequal(size(aiFiltered),size(originalImage)) || any(~isfinite(aiFiltered(:)))
        error('DnCNN output size or values are invalid.');
    end
    aiAvailable = true;
catch ME
    aiError = ME.message;
    fprintf('DnCNN was not run successfully: %s\n',aiError);
    fprintf('Traditional comparisons will still be saved. Do not claim AI results.\n');
end

%% 4) Reference-based objective quality metrics
names = {'Noisy';'Mean 3x3';'Median 3x3';'Gaussian sigma 0.7';'Wiener 5x5'};
images = {noisyImage,meanFiltered,medianFiltered,gaussianFiltered,wienerFiltered};
if aiAvailable
    names{end+1,1} = 'AI DnCNN';
    images{end+1} = aiFiltered;
end
n = numel(names);
mseValues = zeros(n,1);
psnrValues = zeros(n,1);
ssimValues = zeros(n,1);
for k=1:n
    img = images{k};
    mseValues(k) = mean((img(:)-originalImage(:)).^2);
    psnrValues(k) = psnr(img,originalImage);
    ssimValues(k) = ssim(img,originalImage);
end
metrics = table(names,mseValues,psnrValues,ssimValues, ...
    'VariableNames',{'Method','MSE','PSNR_dB','SSIM'});
disp(metrics);
writetable(metrics,fullfile(scriptFolder,'lab7_metrics.csv'));

%% 5) Save lossless, directly valid PNG comparisons using imwrite
% Images are tiled without embedded labels; see README for order.
imwrite([originalImage noisyImage],fullfile(scriptFolder,'01_original_and_noisy.png'));
imwrite([meanFiltered medianFiltered gaussianFiltered wienerFiltered], ...
    fullfile(scriptFolder,'02_traditional_filters.png'));
if aiAvailable
    imwrite([originalImage noisyImage wienerFiltered aiFiltered], ...
        fullfile(scriptFolder,'03_wiener_vs_DnCNN.png'));
end

% Also display a titled figure to inspect during the session.
fig = figure('Color','white','Name','Lab 7 - Denoising methods');
count = 4 + double(aiAvailable);
subplot(1,count,1); imshow(originalImage,[]); title('Original');
subplot(1,count,2); imshow(noisyImage,[]); title('Noisy');
subplot(1,count,3); imshow(wienerFiltered,[]); title('Wiener');
subplot(1,count,4); imshow(gaussianFiltered,[]); title('Gaussian');
if aiAvailable
    subplot(1,count,5); imshow(aiFiltered,[]); title('AI DnCNN');
end

%% 6) Save a text summary without invented AI metrics
fid=fopen(fullfile(scriptFolder,'lab7_measurements.txt'),'w');
if fid<0, error('Unable to write lab7_measurements.txt'); end
fprintf(fid,'Lab 7 - Traditional vs AI Gaussian Filters\n');
fprintf(fid,'MATLAB version: %s\n',version);
fprintf(fid,'Image: cameraman.tif; size: %d rows x %d columns\n',size(originalImage,1),size(originalImage,2));
fprintf(fid,'rng seed: 7; Gaussian noise mean: 0; variance: %.6f; sigma: %.3f\n',noiseSigma^2,noiseSigma);
fprintf(fid,'DnCNN status: %s\n',stringStatus(aiAvailable));
if ~aiAvailable
    fprintf(fid,'DnCNN error: %s\n',strrep(aiError,sprintf('\n'),' '));
end
fprintf(fid,'\nMethod | MSE | PSNR (dB) | SSIM\n');
for k=1:n
    fprintf(fid,'%s | %.8f | %.4f | %.6f\n',names{k},mseValues(k),psnrValues(k),ssimValues(k));
end
fprintf(fid,'MSE lower is better; PSNR and SSIM higher are generally better, versus original reference.\n');
fprintf(fid,'Record your own visual comparison in README.md.\n');
fclose(fid);
fprintf('Saved PNG comparisons, lab7_metrics.csv and lab7_measurements.txt in:\n%s\n',scriptFolder);
if aiAvailable
    fprintf('DnCNN executed and its measurements were included.\n');
else
    fprintf('DnCNN unavailable; please install/enable it to meet the AI part of the lab.\n');
end

function out = stringStatus(flag)
if flag, out='SUCCESS'; else, out='UNAVAILABLE'; end
end
