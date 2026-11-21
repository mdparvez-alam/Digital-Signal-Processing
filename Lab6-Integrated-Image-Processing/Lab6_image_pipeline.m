%% Lab 6 - Mini Project: Integrated Image Processing
% Course: Mathematical Algorithms (DSP) - Image Processing Labs
% Select your own image when prompted. MATLAB Image Processing Toolbox required.
% Outputs: PNG figures and lab6_measurements.txt in the current folder.
clear; close all; clc;

%% 1) Select and load your own image
% Upload an image to MATLAB Drive in this folder before running.
[file, folder] = uigetfile({'*.jpg;*.jpeg;*.png;*.tif;*.tiff;*.bmp', ...
    'Image files (*.jpg, *.png, *.tif, *.bmp)'}, 'Select your own image for Lab 6');
if isequal(file,0)
    error('No image selected. Upload/select your own image, then rerun.');
end
sourcePath = fullfile(folder,file);
inputImage = imread(sourcePath);
if ndims(inputImage)==3
    I = im2double(rgb2gray(inputImage));
elseif ismatrix(inputImage)
    I = im2double(inputImage);
else
    error('Unsupported image dimensions. Select a grayscale or RGB image.');
end
[M,N] = size(I);

%% 2) Preprocess: median filtering, a nonlinear spatial operation
I_filt = medfilt2(I,[3 3], 'symmetric');

%% 3) Enhance contrast: intensity remapping
I_enh = imadjust(I_filt,[0.2 0.8],[0 1]);

%% 4) Features: Canny edge detection
edges = edge(I_enh,'Canny',[0.1 0.25]);

%% 5) Frequency-domain ideal low-pass (circular FFT convention)
F = fftshift(fft2(I_enh));
[u,v] = meshgrid(-floor(N/2):ceil(N/2)-1, -floor(M/2):ceil(M/2)-1);
cutoffRadius = 60; % frequency-bin radius; change only after inspecting result
H = double(hypot(u,v)<cutoffRadius);
I_lp = real(ifft2(ifftshift(F.*H)));
% Clip only for image export, while retaining un-clipped result for comparison.
I_lp_display = min(max(I_lp,0),1);

%% 6) Save valid image PNGs with imwrite
imwrite(I, '01_original.png');
imwrite(I_filt, '02_denoised.png');
imwrite(I_enh, '03_contrast_enhanced.png');
imwrite(edges, '04_canny_edges.png');
imwrite(I_lp_display, '05_frequency_lowpass.png');
imwrite(H, '06_frequency_mask.png');

% Side-by-side comparison: each tile has the exact same size.
% Labels are listed in the README in left-to-right order.
comparison = [I, I_filt, I_enh, double(edges), I_lp_display];
imwrite(comparison, '07_pipeline_comparison.png');

% On-screen labeled comparison figure
figure('Color','white','Name','Lab 6 Image Processing Pipeline');
steps = {I, I_filt, I_enh, edges, I_lp_display};
names = {'Original', 'Median 3x3', 'Contrast enhanced', 'Canny edges', 'FFT ideal LP'};
for k=1:5
    subplot(1,5,k);
    imshow(steps{k},[]);
    title(names{k},'Interpreter','none');
end
sgtitle('Lab 6: Integrated image processing pipeline');

% Frequency spectrum inspection
figure('Color','white','Name','Lab 6 Spectrum and LP Mask');
subplot(1,2,1); imshow(log(1+abs(F)),[]); title('Centered log-magnitude spectrum');
subplot(1,2,2); imshow(H,[]); title(sprintf('Ideal LP mask (radius %d bins)',cutoffRadius));

%% 7) Numerical summary (descriptive measurements, not proof of improvement)
edgePixels = nnz(edges);
edgePercent = 100*edgePixels/numel(edges);
meanBefore = mean(I(:));
meanAfter = mean(I_enh(:));
rmseLP = sqrt(mean((I_enh(:)-I_lp(:)).^2));
fid = fopen('lab6_measurements.txt','w');
if fid<0, error('Could not create lab6_measurements.txt'); end
fprintf(fid,'Lab 6 - Integrated Image Processing\n');
fprintf(fid,'Selected image: %s\n', file);
fprintf(fid,'Image dimensions: %d rows x %d columns\n',M,N);
fprintf(fid,'Median filter: 3 x 3, symmetric boundary\n');
fprintf(fid,'Contrast adjustment: imadjust input [0.2 0.8] to [0 1]\n');
fprintf(fid,'Canny thresholds: [0.1 0.25]\n');
fprintf(fid,'FFT ideal low-pass radius: %d bins\n',cutoffRadius);
fprintf(fid,'Mean grayscale intensity before: %.6f\n',meanBefore);
fprintf(fid,'Mean grayscale intensity after contrast enhancement: %.6f\n',meanAfter);
fprintf(fid,'Detected Canny edge pixels: %d (%.3f%%)\n',edgePixels,edgePercent);
fprintf(fid,'RMSE between enhanced and FFT-lowpass images: %.6f\n',rmseLP);
fprintf(fid,'Note: this RMSE measures change, not quality improvement.\n');
fclose(fid);

fprintf('Loaded: %s (%d x %d)\n',file,M,N);
fprintf('Canny edges: %d pixels (%.3f%%)\n',edgePixels,edgePercent);
fprintf('FFT low-pass cutoff radius: %d bins\n',cutoffRadius);
fprintf('Saved seven valid PNG images and lab6_measurements.txt.\n');
