%% Lab 2: 2D Convolution & FIR Filters (Blur, Sharpen, Edges)
% Course: Mathematical Algorithms (DSP) - Image Processing Labs
% Run this script in MATLAB with Image Processing Toolbox.
% All figures and results are saved beside this script.
close all; clear; clc;

scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end

%% Load image
if exist('peppers.png','file') == 2
    sourceName = 'peppers.png';
    I0 = imread(sourceName);
elseif exist('cameraman.tif','file') == 2
    sourceName = 'cameraman.tif (grayscale fallback)';
    I0 = imread('cameraman.tif');
else
    error('Neither peppers.png nor cameraman.tif found. Upload an image to MATLAB Drive.');
end
if size(I0,3) == 3
    I = im2double(rgb2gray(I0));
else
    I = im2double(I0);
end
fprintf('Image: %s | %d rows x %d columns\n', sourceName, size(I,1), size(I,2));

%% 1) Delta image and 3x3 impulse response
delta = zeros(101,101); delta(51,51) = 1;
h_avg = ones(3,3)/9;
H_vis = conv2(delta,h_avg,'same');
fig = figure('Color','w','Name','Lab 2 - Impulse response');
imagesc(H_vis); axis image; colorbar;
xlabel('Column (pixels)'); ylabel('Row (pixels)');
title('Impulse response: delta convolved with 3x3 averaging kernel');
exportgraphics(fig,fullfile(scriptFolder,'01_impulse_response.png'),'Resolution',180);

%% 2) Box and separable Gaussian low-pass filters
h_box3 = ones(3,3)/9;
h_box7 = ones(7,7)/49;
sigma = 1.2;
g1d = fspecial('gaussian',[1 7],sigma);
h_gauss = g1d' * g1d;
I_box3 = imfilter(I,h_box3,'replicate');
I_box7 = imfilter(I,h_box7,'replicate');
I_gauss = imfilter(I,h_gauss,'replicate');
% Demonstrate equivalent separable passes (replicate at each stage).
I_gauss_2pass = imfilter(imfilter(I,g1d,'replicate'),g1d','replicate');
separabilityDiff = max(abs(I_gauss(:)-I_gauss_2pass(:)));
fig = figure('Color','w','Name','Lab 2 - Blurring');
tiledlayout(1,4,'Padding','compact','TileSpacing','compact');
labels = {'Original','Box 3x3','Box 7x7','Gaussian 7x7, sigma=1.2'};
imgs = {I,I_box3,I_box7,I_gauss};
for k=1:4
    nexttile; imshow(imgs{k},[]); title(labels{k});
end
sgtitle('Low-pass filtering: box versus Gaussian');
exportgraphics(fig,fullfile(scriptFolder,'02_blur_comparison.png'),'Resolution',180);

%% 3) Unsharp masking
I_blur = I_gauss;
mask = I-I_blur;
gain = 1.0;
I_sharp = min(max(I+gain*mask,0),1);
fig = figure('Color','w','Name','Lab 2 - Unsharp masking');
tiledlayout(1,4,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I,[]); title('Original');
nexttile; imshow(I_blur,[]); title('Gaussian blur');
nexttile; imshow(mask,[]); title('High-frequency mask (display scaled)');
nexttile; imshow(I_sharp,[]); title('Sharpened, gain=1');
sgtitle('Unsharp masking');
exportgraphics(fig,fullfile(scriptFolder,'03_unsharp_masking.png'),'Resolution',180);

%% 4) Sobel and Laplacian edges
h_sobel_x = fspecial('sobel');
h_sobel_y = h_sobel_x';
Gx = imfilter(I,h_sobel_x,'replicate');
Gy = imfilter(I,h_sobel_y,'replicate');
Gmag = hypot(Gx,Gy);
h_lap = fspecial('laplacian',0.2);
I_lap = imfilter(I,h_lap,'replicate');
fig = figure('Color','w','Name','Lab 2 - Edges');
tiledlayout(1,4,'Padding','compact','TileSpacing','compact');
edgeImgs = {Gx,Gy,Gmag,I_lap};
edgeLabels = {'Sobel Gx','Sobel Gy','Gradient magnitude','Laplacian'};
for k=1:4
    nexttile; imshow(mat2gray(edgeImgs{k})); title(edgeLabels{k});
end
sgtitle('Edges: Sobel and Laplacian (each panel display-normalized)');
exportgraphics(fig,fullfile(scriptFolder,'04_edge_detection.png'),'Resolution',180);

%% 5) Convolution and correlation
% Both functions use zero padding here, so the results are comparable.
C1 = conv2(I,h_box3,'same');
C2 = imfilter(I,h_box3,'conv','same',0);
diff_val = max(abs(C1(:)-C2(:)));
% A symmetric box kernel has the same weights after flipping;
% use an asymmetric demonstration kernel to show correlation vs convolution.
h_asym = [0 1 2; -1 0 3; 4 5 6];
convAsym = imfilter(I,h_asym,'conv','same',0);
corrAsym = imfilter(I,h_asym,'corr','same',0);
asymDiff = max(abs(convAsym(:)-corrAsym(:)));
fprintf('Max difference: conv2 vs imfilter conv (box 3x3): %.12g\n',diff_val);
fprintf('Max difference: correlation vs convolution (asymmetric kernel): %.12g\n',asymDiff);

%% 6) Boundary handling
I_rep = imfilter(I,h_box7,'replicate');
I_sym = imfilter(I,h_box7,'symmetric');
I_cir = imfilter(I,h_box7,'circular');
fig = figure('Color','w','Name','Lab 2 - Boundaries');
tiledlayout(1,3,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I_rep,[]); title('Replicate');
nexttile; imshow(I_sym,[]); title('Symmetric');
nexttile; imshow(I_cir,[]); title('Circular');
sgtitle('Boundary handling for 7x7 box filter');
exportgraphics(fig,fullfile(scriptFolder,'05_boundary_handling.png'),'Resolution',180);

%% Save results for README verification
resultFile = fullfile(scriptFolder,'lab2_measurements.txt');
fid = fopen(resultFile,'w');
if fid == -1, error('Could not write lab2_measurements.txt.'); end
fprintf(fid,'Lab 2: 2D Convolution and FIR Filters\n');
fprintf(fid,'Input image: %s\n',sourceName);
fprintf(fid,'Image dimensions: %d rows x %d columns\n',size(I,1),size(I,2));
fprintf(fid,'3x3 box filter coefficients: 9; each coefficient = 1/9\n');
fprintf(fid,'7x7 box filter coefficients: 49; each coefficient = 1/49\n');
fprintf(fid,'Gaussian sigma: %.1f; separable 1D filter length: %d\n',sigma,numel(g1d));
fprintf(fid,'Gaussian full 2D versus two 1D passes max difference: %.12g\n',separabilityDiff);
fprintf(fid,'conv2 versus imfilter conv max difference (3x3 box): %.12g\n',diff_val);
fprintf(fid,'Convolution versus correlation max difference (asymmetric kernel): %.12g\n',asymDiff);
fprintf(fid,'Unsharp masking gain: %.1f\n',gain);
fclose(fid);
fprintf('Saved five PNG figures and lab2_measurements.txt in:\n%s\n',scriptFolder);
fprintf('Read the figures and write your personal observations in README.md.\n');
