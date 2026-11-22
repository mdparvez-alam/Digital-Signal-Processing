%% In-class exercises - Image Processing Fundamentals
% MATLAB Image Processing Toolbox required.
% Convert this source to exercises.mlx in MATLAB Live Editor, RUN ALL,
% review your results, then export exercises.pdf from the executed Live Script.
% All numerical results, images and CSV tables are saved under results/.
% Source images are MATLAB samples: cameraman.tif, pout.tif, coins.png.

clear; close all; clc;

% IMPORTANT: Set this project location as the MATLAB Current Folder before Run.
% Outputs go in the 'results' subfolder of the current working directory.
outputDir = fullfile(pwd,'results');
if ~isfolder(outputDir), mkdir(outputDir); end
fprintf('MATLAB version: %s\n',version);
fprintf('Image Processing Toolbox installed: %d\n',license('test','image_toolbox'));
fprintf('Output directory: %s\n',outputDir);

%% Exercise 1 - Pixels, quantization and sampling
I8 = imread('cameraman.tif');
assert(isa(I8,'uint8') && ismatrix(I8), 'Expected uint8 cameraman.tif');
fprintf('\nEXERCISE 1: cameraman.tif size %d x %d, class %s\n', ...
    size(I8,1),size(I8,2),class(I8));
% Uniform floor quantization gives 16, 4, and 2 levels respectively.
I4 = uint8(floor(double(I8)/16)*16);
I2 = uint8(floor(double(I8)/64)*64);
I1 = uint8(floor(double(I8)/128)*128);
% Simple stride-based decimation without anti-aliasing, vs imresize's
% default antialiasing behavior for downscaling.
I_stride = I8(1:8:end,1:8:end);
I_resize = imresize(I8,1/8,'bicubic');
% Display both at original dimensions using nearest for comparable pixels.
I_stride_view = imresize(I_stride,size(I8),'nearest');
I_resize_view = imresize(I_resize,size(I8),'nearest');
f1=figure('Color','w','Name','Exercise 1 - Quantization and sampling');
tiledlayout(2,3,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I8); title('Original (8-bit)');
nexttile; imshow(I4,[]); title('4-bit, 16 levels');
nexttile; imshow(I2,[]); title('2-bit, 4 levels');
nexttile; imshow(I1,[]); title('1-bit, 2 levels');
nexttile; imshow(I_stride_view); title('Stride /8, nearest display');
nexttile; imshow(I_resize_view); title('imresize /8, nearest display');
exportgraphics(f1,fullfile(outputDir,'01_quantization_sampling.png'),'Resolution',180);
% Think about: the 1-bit image loses the most recognizable tonal detail,
% but recognition depends on the observer and image. Sharp edges and fine
% textures can alias in stride-based sampling because high frequencies are
% not removed before decimation; the imresize result is smoother.

%% Exercise 2 - Image degradations
I = im2double(I8);
rng(42); % ensures repeatable random-noise realization
I_gauss = imnoise(I,'gaussian',0,0.01);
I_sp = imnoise(I,'salt & pepper',0.05);
hmotion = fspecial('motion',15,30);
I_motion = imfilter(I,hmotion,'replicate');
% Horizontal illumination ramp: lower multiplier on the left.
ramp = repmat(linspace(0.35,1.0,size(I,2)),size(I,1),1);
I_ramp = I .* ramp;
f2=figure('Color','w','Name','Exercise 2 - Degradations');
tiledlayout(2,3,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I); title('Original');
nexttile; imshow(I_gauss); title('Gaussian, variance 0.01');
nexttile; imshow(I_sp); title('Salt & pepper, density 0.05');
nexttile; imshow(I_motion); title('Motion blur: length 15, angle 30°');
nexttile; imshow(ramp,[]); title('Brightness ramp multiplier');
nexttile; imshow(I_ramp); title('Original × brightness ramp');
exportgraphics(f2,fullfile(outputDir,'02_degradations.png'),'Resolution',180);
% Think about: Gaussian noise is additive in the noise model; salt & pepper
% replaces pixels with extreme intensities rather than simply adding noise.
% The ramp is multiplicative; blur is spatial convolution. A median filter
% is particularly suited to sparse salt & pepper impulse noise.

%% Exercise 3 - Contrast and geometry on pout.tif
Ip = imread('pout.tif');
Ip_adjust = imadjust(Ip);
Ip_gamma05 = imadjust(Ip,[],[],0.5);
Ip_gamma2 = imadjust(Ip,[],[],2);
Ip_histeq = histeq(Ip);
f3=figure('Color','w','Name','Exercise 3 - Contrast');
tiledlayout(2,3,'Padding','compact','TileSpacing','compact');
nexttile; imshow(Ip); title('Original pout.tif');
nexttile; imhist(Ip); title('Original histogram');
nexttile; imshow(Ip_adjust); title('imadjust');
nexttile; imshow(Ip_gamma05); title('Gamma 0.5');
nexttile; imshow(Ip_gamma2); title('Gamma 2');
nexttile; imshow(Ip_histeq); title('histeq');
exportgraphics(f3,fullfile(outputDir,'03_contrast.png'),'Resolution',180);
% Select 40 x 40 patch from center, within image dimensions.
[rp,cp] = size(Ip);
r0 = floor((rp-40)/2)+1; c0 = floor((cp-40)/2)+1;
patch40 = Ip(r0:r0+39,c0:c0+39);
patch_nearest = imresize(patch40,5,'nearest');
patch_bicubic = imresize(patch40,5,'bicubic');
f3b=figure('Color','w','Name','Exercise 3 - Patch interpolation');
tiledlayout(1,3,'Padding','compact');
nexttile; imshow(patch40); title('Original 40 × 40 patch');
nexttile; imshow(patch_nearest); title('Nearest × 5');
nexttile; imshow(patch_bicubic); title('Bicubic × 5');
exportgraphics(f3b,fullfile(outputDir,'03_patch_interpolation.png'),'Resolution',180);
% Think about: the best contrast transform depends on the scene and whether
% it clips or exaggerates noise. Gamma < 1 maps midtones upward, brightening
% them. Bicubic interpolates using neighboring samples to make smoother
% transitions; nearest repeats each input pixel and looks blockier.

%% Exercise 4 - Mean, Gaussian and median noise filtering with PSNR
hmean = fspecial('average',[3 3]);
% Explicit Gaussian width 5x5, sigma 1.0; keep these settings unchanged.
hg = fspecial('gaussian',[5 5],1.0);
G_mean = imfilter(I_gauss,hmean,'replicate');
G_gaussian = imfilter(I_gauss,hg,'replicate');
G_median = medfilt2(I_gauss,[3 3],'symmetric');
SP_mean = imfilter(I_sp,hmean,'replicate');
SP_gaussian = imfilter(I_sp,hg,'replicate');
SP_median = medfilt2(I_sp,[3 3],'symmetric');
filterName = ["Mean 3x3";"Gaussian 5x5, sigma 1";"Median 3x3"; ...
              "Mean 3x3";"Gaussian 5x5, sigma 1";"Median 3x3"];
noiseType = [repmat("Gaussian",3,1);repmat("Salt & pepper",3,1)];
PSNR_dB = [psnr(G_mean,I);psnr(G_gaussian,I);psnr(G_median,I); ...
           psnr(SP_mean,I);psnr(SP_gaussian,I);psnr(SP_median,I)];
T4 = table(noiseType,filterName,PSNR_dB, ...
    'VariableNames',{'NoiseType','Filter','PSNR_dB'});
disp('EXERCISE 4 - PSNR results:'); disp(T4);
writetable(T4,fullfile(outputDir,'04_psnr_results.csv'));
f4=figure('Color','w','Name','Exercise 4 - Denoising comparison');
tiledlayout(2,4,'Padding','compact','TileSpacing','compact');
allFiltered = {I_gauss,G_mean,G_gaussian,G_median,I_sp,SP_mean,SP_gaussian,SP_median};
allLabels = {'Gaussian noisy','Mean','Gaussian LP','Median', ...
             'Salt & pepper noisy','Mean','Gaussian LP','Median'};
for k=1:8
    nexttile; imshow(allFiltered{k}); title(allLabels{k});
end
exportgraphics(f4,fullfile(outputDir,'04_denoising_comparison.png'),'Resolution',180);
% Compare 2D Fourier spectra, normalized to their own maximum for display.
F0=fftshift(fft2(I)); Fb=fftshift(fft2(I_motion));
S0=log1p(abs(F0)); Sb=log1p(abs(Fb));
f4b=figure('Color','w','Name','Exercise 4 - Spectra');
tiledlayout(1,2,'Padding','compact');
nexttile; imshow(S0,[]); title('Original log FFT magnitude');
nexttile; imshow(Sb,[]); title('Motion-blurred log FFT magnitude');
exportgraphics(f4b,fullfile(outputDir,'04_spectra.png'),'Resolution',180);
[bestG,ig]=max(PSNR_dB(1:3)); [bestSP,isp]=max(PSNR_dB(4:6));
fprintf('Gaussian noise: highest PSNR = %s (%.3f dB)\n',filterName(ig),bestG);
fprintf('Salt & pepper: highest PSNR = %s (%.3f dB)\n',filterName(isp+3),bestSP);
% Think about: compare the measured maxima, not a predetermined winner.
% Blurring attenuates some high spatial frequencies. Directional motion
% blur has a direction-dependent frequency response with dark bands/zeros.

%% Exercise 5 - Edge detection and smoothing effect
E_sobel=edge(I8,'Sobel');
E_canny1=edge(I8,'Canny',[],1);
E_canny2=edge(I8,'Canny',[],2);
E_canny3=edge(I8,'Canny',[],3);
% Use Gaussian-noisy image already created in Exercise 2.
E_noisy_raw = edge(I_gauss,'Canny',[],1);
E_noisy_smoothed = edge(imgaussfilt(I_gauss,1),'Canny',[],1);
% Counts may differ because smoothing suppresses and shifts edges.
countNames = ["Sobel clean";"Canny sigma 1 clean";"Canny sigma 2 clean"; ...
    "Canny sigma 3 clean";"Canny sigma 1 noisy";"Canny sigma 1 noisy + presmoothing"];
edgePixels = [nnz(E_sobel);nnz(E_canny1);nnz(E_canny2); ...
    nnz(E_canny3);nnz(E_noisy_raw);nnz(E_noisy_smoothed)];
T5=table(countNames,edgePixels,'VariableNames',{'Method','EdgePixels'});
disp('EXERCISE 5 - Edge counts:'); disp(T5);
writetable(T5,fullfile(outputDir,'05_edge_counts.csv'));
f5=figure('Color','w','Name','Exercise 5 - Edge comparison');
tiledlayout(2,3,'Padding','compact','TileSpacing','compact');
edgeImages={E_sobel,E_canny1,E_canny2,E_canny3,E_noisy_raw,E_noisy_smoothed};
for k=1:6
    nexttile; imshow(edgeImages{k}); title(countNames(k));
end
exportgraphics(f5,fullfile(outputDir,'05_edges.png'),'Resolution',180);
fprintf('Noisy Canny edge-pixel count change after pre-smoothing: %d\n', ...
    nnz(E_noisy_raw)-nnz(E_noisy_smoothed));
% Think about: increasing Canny sigma usually removes small-detail and
% noise-triggered edges, but it can also lose true thin edges. The count
% difference above is NOT an exact count of false edges removed: edge pixels
% can be added, shifted, or deleted, and no annotated ground truth is given.

%% Exercise 6 - Otsu segmentation, morphology and coin areas
Ic=imread('coins.png');
if size(Ic,3)==3, Ic=rgb2gray(Ic); end
level = graythresh(Ic);
BW0 = imbinarize(Ic,level);
BWopen = imopen(BW0,strel('disk',2,0));
BWfill = imfill(BWopen,'holes');
BWclean = bwareaopen(BWfill,50);
CC=bwconncomp(BWclean);
stats=regionprops(CC,'Area','Centroid');
coinAreas=[stats.Area]';
T6=table((1:numel(coinAreas))',coinAreas, ...
    'VariableNames',{'ComponentID','AreaPixels'});
disp('EXERCISE 6 - Connected components/areas:'); disp(T6);
writetable(T6,fullfile(outputDir,'06_component_areas.csv'));
f6=figure('Color','w','Name','Exercise 6 - Coins segmentation');
tiledlayout(2,3,'Padding','compact','TileSpacing','compact');
nexttile; imshow(Ic); title('Original coins.png');
nexttile; imshow(BW0); title(sprintf('Otsu, threshold %.3f',level));
nexttile; imshow(BWopen); title('After imopen (disk 2)');
nexttile; imshow(BWfill); title('After imfill');
nexttile; imshow(BWclean); title('After bwareaopen (50)');
nexttile; imshow(label2rgb(labelmatrix(CC),'jet','k','shuffle')); title('Labeled components');
exportgraphics(f6,fullfile(outputDir,'06_coins_segmentation.png'),'Resolution',180);
fprintf('Detected connected regions: %d\n',CC.NumObjects);
if ~isempty(coinAreas)
    [largestArea,largestIdx] = max(coinAreas);
    fprintf('Largest LABELED connected component: %d (area %d pixels)\n', ...
        largestIdx,largestArea);
else
    fprintf('No connected components detected.\n');
end
% Think about: opening removes small protrusions and bright noise, filling
% closes internal holes, and bwareaopen removes small foreground objects.
% Touching coins can merge into one connected component. The largest
% component is not necessarily a single coin if components have merged.

%% Summary
fprintf('\nAll six exercises finished. Figures/CSVs in %s\n',outputDir);
fprintf('Review plots and add personal observations to the Live Script.\n');
fprintf('Then save as exercises.mlx and export exercises.pdf.\n');
