%% Lab 1: Image as a 2D Signal
% Sampling, quantization, histograms, contrast enhancement, gamma
% Run this script in MATLAB with Image Processing Toolbox available.
% The script saves six PNG figures and image_measurements.txt next to itself.
close all; clear; clc;

scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end

%% 0) Load an image and inspect it
if exist('peppers.png', 'file') == 2
    sourceName = 'peppers.png';
    I_rgb = imread(sourceName);
elseif exist('cameraman.tif', 'file') == 2
    sourceName = 'cameraman.tif (grayscale fallback)';
    I_rgb = repmat(imread('cameraman.tif'), 1, 1, 3);
else
    error(['Neither peppers.png nor cameraman.tif was found. ', ...
           'Upload an image or set a valid filename in the script.']);
end

if size(I_rgb,3) == 3
    I = rgb2gray(I_rgb);
else
    I = I_rgb;
end

fprintf('Source image: %s\n', sourceName);
fprintf('Class: %s | Range: [%g, %g] | Size: %d x %d pixels\n', ...
    class(I), double(min(I(:))), double(max(I(:))), size(I,1), size(I,2));

fig = figure('Color','w','Name','Lab 1 - Original and grayscale');
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I_rgb); title('Original RGB / source');
nexttile; imshow(I); title('Grayscale (luminance)');
sgtitle('Lab 1: Original image inspection');
exportgraphics(fig, fullfile(scriptFolder,'01_original_grayscale.png'),'Resolution',180);

%% 1) Quantization: fewer intensity levels, same spatial dimensions
I8 = I;
I6 = uint8(floor(double(I)/4)*4);    % Up to 64 values (6-bit equivalent)
I4 = uint8(floor(double(I)/16)*16);  % Up to 16 values (4-bit equivalent)
fig = figure('Color','w','Name','Lab 1 - Quantization');
tiledlayout(1,3,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I8); title('8-bit (256 levels)');
nexttile; imshow(I6); title('~6-bit (64 levels)');
nexttile; imshow(I4); title('~4-bit (16 levels)');
sgtitle('Quantization: reduced intensity resolution');
exportgraphics(fig, fullfile(scriptFolder,'02_quantization.png'),'Resolution',180);

%% 2) Histogram and contrast stretching
I_norm = mat2gray(I);           % Image min-to-max normalization to [0,1]
I_stretch = imadjust(I,[0.2 0.8],[0 1]);  % Linear remapping, clipped at ends
fig = figure('Color','w','Name','Lab 1 - Histograms');
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile; imhist(I); title('Original grayscale histogram'); xlabel('Pixel intensity'); ylabel('Number of pixels');
nexttile; imhist(I_stretch); title('Contrast-stretched histogram'); xlabel('Pixel intensity'); ylabel('Number of pixels');
sgtitle('Histograms before and after contrast stretching');
exportgraphics(fig, fullfile(scriptFolder,'03_histograms.png'),'Resolution',180);

fig = figure('Color','w','Name','Lab 1 - Contrast comparison');
tiledlayout(1,3,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I); title('Original');
nexttile; imshow(I_norm); title('Min-max normalized');
nexttile; imshow(I_stretch); title('Contrast-stretched [0.2, 0.8]');
sgtitle('Dynamic range and contrast enhancement');
exportgraphics(fig, fullfile(scriptFolder,'04_contrast_stretching.png'),'Resolution',180);

%% 3) Gamma correction: nonlinear intensity mapping
I_gamma_low = imadjust(I,[],[],0.6);   % gamma < 1: brighten
I_gamma_high = imadjust(I,[],[],1.6);  % gamma > 1: darken
fig = figure('Color','w','Name','Lab 1 - Gamma');
tiledlayout(1,3,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I); title('Original');
nexttile; imshow(I_gamma_low); title('Gamma = 0.6 (brighter)');
nexttile; imshow(I_gamma_high); title('Gamma = 1.6 (darker)');
sgtitle('Nonlinear gamma correction');
exportgraphics(fig, fullfile(scriptFolder,'05_gamma_correction.png'),'Resolution',180);

%% 4) Sampling: resize down to 10%, then enlarge without lost detail
scale = 0.1;
I_small = imresize(I,scale,'nearest');
I_back = imresize(I_small,[size(I,1),size(I,2)],'nearest');
fig = figure('Color','w','Name','Lab 1 - Sampling');
tiledlayout(1,3,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I); title(sprintf('Original: %d x %d',size(I,2),size(I,1)));
nexttile; imshow(I_small,'InitialMagnification','fit');
title(sprintf('10%%: %d x %d',size(I_small,2),size(I_small,1)));
nexttile; imshow(I_back); title('Upscaled back (nearest)');
sgtitle('Spatial sampling and loss of fine details');
exportgraphics(fig, fullfile(scriptFolder,'06_sampling_resize.png'),'Resolution',180);

%% Summary for your README (do not claim observations without checking plots)
summaryPath = fullfile(scriptFolder,'image_measurements.txt');
fid = fopen(summaryPath,'w');
if fid == -1, error('Could not write measurement summary.'); end
fprintf(fid,'Lab 1: Image as a 2D Signal\n');
fprintf(fid,'Source image: %s\n',sourceName);
fprintf(fid,'Image class: %s\n',class(I));
fprintf(fid,'Original grayscale dimensions: %d rows x %d columns\n',size(I,1),size(I,2));
fprintf(fid,'Grayscale intensity range: %g to %g\n',double(min(I(:))),double(max(I(:))));
fprintf(fid,'Quantization levels (nominal): 8-bit=256, 6-bit=64, 4-bit=16\n');
fprintf(fid,'Small image dimensions: %d rows x %d columns\n',size(I_small,1),size(I_small,2));
fprintf(fid,'Sampling scale: %.2f\n',scale);
fclose(fid);
fprintf('Saved six PNG figures and image_measurements.txt to:\n%s\n',scriptFolder);
fprintf('Review each figure and describe your own observations in README.md.\n');
