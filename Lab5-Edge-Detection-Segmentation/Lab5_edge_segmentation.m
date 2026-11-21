%% Lab 5: Edge Detection and Segmentation
% Course: Mathematical Algorithms (DSP) - Image Processing Labs
% Run in MATLAB with Image Processing Toolbox.
% All PNG figures are saved to the same folder as this script.

close all; clear; clc;
scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end

%% 0) Load and inspect image
if exist('peppers.png','file') == 2
    sourceName = 'peppers.png';
elseif exist('cameraman.tif','file') == 2
    sourceName = 'cameraman.tif';
else
    error('Neither peppers.png nor cameraman.tif was found. Supply an input image.');
end
I0 = imread(sourceName);
if size(I0,3) == 3
    I = im2double(rgb2gray(I0));
else
    I = im2double(I0);
end
fprintf('Source: %s | grayscale size: %d x %d\n',sourceName,size(I,1),size(I,2));

%% 1) Basic derivative filters: Sobel and Prewitt
edges_sobel = edge(I,'Sobel');
edges_prewitt = edge(I,'Prewitt');
f1 = figure('Color','w','Position',[100 100 1100 440]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile; imshow(edges_sobel); title('Sobel edges');
nexttile; imshow(edges_prewitt); title('Prewitt edges');
sgtitle('Gradient-based edge detection');
exportgraphics(f1,fullfile(scriptFolder,'01_sobel_prewitt.png'),'Resolution',160);

%% 2) Canny detector (multi-stage)
edges_canny = edge(I,'Canny',[0.05 0.2]);
f2 = figure('Color','w','Position',[100 100 640 520]);
imshow(edges_canny); title('Canny edges (thresholds = [0.05 0.2])');
exportgraphics(f2,fullfile(scriptFolder,'02_canny_edges.png'),'Resolution',160);

%% 3) Laplacian of Gaussian: zero crossings
edges_log = edge(I,'log');
f3 = figure('Color','w','Position',[100 100 640 520]);
imshow(edges_log); title('Laplacian of Gaussian (LoG) edges');
exportgraphics(f3,fullfile(scriptFolder,'03_log_edges.png'),'Resolution',160);

%% 4) Otsu threshold and simple binary segmentation
level = graythresh(I);
BW = imbinarize(I,level);
f4 = figure('Color','w','Position',[100 100 1100 440]);
tiledlayout(1,2,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I,[]); title('Original grayscale image');
nexttile; imshow(BW); title(sprintf('Otsu binary mask (threshold = %.4f)',level));
sgtitle('Histogram-based global segmentation');
exportgraphics(f4,fullfile(scriptFolder,'04_otsu_segmentation.png'),'Resolution',160);

%% 5) Label connected components in the thresholded mask
[L,num] = bwlabel(BW,8); % Eight-connected components
RGB = label2rgb(L,'jet','k','shuffle');
f5 = figure('Color','w','Position',[100 100 750 530]);
imshow(RGB); title(sprintf('Connected regions: %d (8-connectivity)',num));
exportgraphics(f5,fullfile(scriptFolder,'05_labeled_regions.png'),'Resolution',160);

%% 6) Summary comparison of all edge methods (helpful for reflections)
f6 = figure('Color','w','Position',[100 100 1200 800]);
tiledlayout(2,3,'Padding','compact','TileSpacing','compact');
nexttile; imshow(I,[]); title('Original grayscale');
nexttile; imshow(edges_sobel); title('Sobel');
nexttile; imshow(edges_prewitt); title('Prewitt');
nexttile; imshow(edges_canny); title('Canny');
nexttile; imshow(edges_log); title('LoG');
nexttile; imshow(BW); title('Otsu segmentation');
sgtitle('Lab 5: Edge detection and segmentation comparison');
exportgraphics(f6,fullfile(scriptFolder,'06_method_comparison.png'),'Resolution',160);

%% 7) Save measurements (computed from this run, not assumed)
edgeCounts = [nnz(edges_sobel),nnz(edges_prewitt),nnz(edges_canny),nnz(edges_log)];
methods = {'Sobel';'Prewitt';'Canny';'LoG'};
T = table(methods,edgeCounts(:),'VariableNames',{'Method','EdgePixels'});
writetable(T,fullfile(scriptFolder,'edge_pixel_counts.csv'));
fid = fopen(fullfile(scriptFolder,'lab5_measurements.txt'),'w');
if fid < 0, error('Could not create lab5_measurements.txt'); end
fprintf(fid,'LAB 5 - EDGE DETECTION AND SEGMENTATION\n');
fprintf(fid,'Source image: %s\n',sourceName);
fprintf(fid,'Image size: %d rows x %d columns\n',size(I,1),size(I,2));
fprintf(fid,'Canny thresholds: 0.05, 0.20\n');
fprintf(fid,'Otsu threshold (normalized 0..1): %.6f\n',level);
fprintf(fid,'Otsu foreground pixels: %d of %d (%.2f%%)\n',nnz(BW),numel(BW),100*nnz(BW)/numel(BW));
fprintf(fid,'8-connected regions in Otsu binary mask: %d\n',num);
for k = 1:numel(methods)
    fprintf(fid,'%s edge pixels: %d\n',methods{k},edgeCounts(k));
end
fprintf(fid,'Note: Edge-pixel count alone does not establish edge quality.\n');
fclose(fid);

disp(T);
fprintf('Otsu threshold = %.6f; connected regions = %d\n',level,num);
fprintf('Saved 6 PNG figures, edge_pixel_counts.csv, and lab5_measurements.txt in:\n%s\n',scriptFolder);
