%% Individual Assignment - Image Processing Fundamentals
% Option C: Compare Edge Detectors
% Run with MATLAB Image Processing Toolbox.
% Important: run in MATLAB, then save AS analysis.mlx (Live Script).
% Execute the Live Script and export analysis.pdf for submission.

clear; close all; clc;

%% 1. Original image and fixed Gaussian-noise experiment
% Provided MATLAB sample image. No image upload required.
I = imread('cameraman.tif');
rng(42);
In = imnoise(I,'gaussian',0,0.01);

fprintf('Reference: cameraman.tif; noise: Gaussian variance 0.01; rng(42)\n');
fprintf('MATLAB version: %s\n',version);
fprintf('Image Processing Toolbox installed: %d\n',license('test','image_toolbox'));

%% 2. Sobel after Gaussian smoothing (sigma = 1)
% Default Sobel edge threshold is intentionally not overridden.
E_sobel_clean = edge(imgaussfilt(I,1),'Sobel');
E_sobel_noisy = edge(imgaussfilt(In,1),'Sobel');

%% 3. Canny sigma = 1 and sigma = 3, default thresholds
E_canny1_clean = edge(I,'Canny',[],1);
E_canny1_noisy = edge(In,'Canny',[],1);
E_canny3_clean = edge(I,'Canny',[],3);
E_canny3_noisy = edge(In,'Canny',[],3);

%% 4. Display all SIX edge maps in one figure
% Rows = clean/noisy; columns = Sobel / Canny sigma 1 / Canny sigma 3.
fig = figure('Color','w','Name','Option C: Six edge maps','Position',[50 50 1150 730]);
imgs = {E_sobel_clean,E_canny1_clean,E_canny3_clean, ...
        E_sobel_noisy,E_canny1_noisy,E_canny3_noisy};
labels = {'Clean - Sobel (pre-smoothed sigma 1)', ...
          'Clean - Canny (sigma 1)', ...
          'Clean - Canny (sigma 3)', ...
          'Noisy - Sobel (pre-smoothed sigma 1)', ...
          'Noisy - Canny (sigma 1)', ...
          'Noisy - Canny (sigma 3)'};
for k = 1:6
    subplot(2,3,k);
    imshow(imgs{k});
    title(labels{k},'Interpreter','none');
end
sgtitle('Edge detection on cameraman.tif: clean versus Gaussian noisy');

%% 5. Edge pixel counts and results table
methods = ["Sobel after Gaussian sigma 1";"Canny sigma 1";"Canny sigma 3"];
cleanCount = [nnz(E_sobel_clean);nnz(E_canny1_clean);nnz(E_canny3_clean)];
noisyCount = [nnz(E_sobel_noisy);nnz(E_canny1_noisy);nnz(E_canny3_noisy)];
difference = noisyCount - cleanCount;
results = table(methods,cleanCount,noisyCount,difference, ...
    'VariableNames',{'Method','CleanEdgePixels','NoisyEdgePixels','NoisyMinusClean'});
disp(results);

%% 6. Inspect one image region for possible false/missing edges
% Example region: change ONLY for inspection, describe actual observations.
% Coordinates below are within standard 256 x 256 cameraman.tif.
rows = 80:160;
cols = 100:180;
figRegion = figure('Color','w','Name','Region inspection','Position',[100 100 1050 450]);
subplot(1,3,1); imshow(In(rows,cols)); title('Noisy source region');
subplot(1,3,2); imshow(E_canny1_noisy(rows,cols)); title('Canny sigma 1');
subplot(1,3,3); imshow(E_canny3_noisy(rows,cols)); title('Canny sigma 3');
sgtitle('Selected region for visual inspection (rows 80:160, cols 100:180)');

%% 7. Save result images and CSV next to script
%% Save into the CURRENT MATLAB Drive folder (not temporary Live Editor cache).
% Before running, navigate to Image-Processing-Fundamentals-Option-C in MATLAB.
scriptFolder = pwd;
out = fullfile(scriptFolder,'results');
if ~isfolder(out), mkdir(out); end

% Direct image writing avoids PNG format problems with some figure exports.
for k = 1:6
    imwrite(imgs{k},fullfile(out,sprintf('edge_map_%d.png',k)));
end
imwrite(I,fullfile(out,'original_reference.png'));
imwrite(In,fullfile(out,'gaussian_noisy.png'));
writetable(results,fullfile(out,'edge_pixel_counts.csv'));

% Save six edge maps as a valid PNG with imwrite (not figure export).
% Row 1: clean; row 2: noisy. Columns: Sobel, Canny 1, Canny 3.
sixMap = [E_sobel_clean, E_canny1_clean, E_canny3_clean; ...
          E_sobel_noisy, E_canny1_noisy, E_canny3_noisy];
imwrite(sixMap,fullfile(out,'six_edge_maps.png'));

% Selected region: noisy image, Canny 1 and Canny 3, in that order.
regionPanel = [In(rows,cols), ...
               im2uint8(E_canny1_noisy(rows,cols)), ...
               im2uint8(E_canny3_noisy(rows,cols))];
imwrite(regionPanel,fullfile(out,'region_inspection.png'));

% Optional labeled figures (not required for the raw PNGs).
try
    exportgraphics(fig,fullfile(out,'six_edge_maps_labeled.png'),'Resolution',160);
    exportgraphics(figRegion,fullfile(out,'region_inspection_labeled.png'),'Resolution',160);
catch ME
    warning('Labeled figure export unavailable: %s',ME.message);
end

fprintf('\nSaved results to: %s\n',out);
fprintf('Open and inspect six_edge_maps.png and region_inspection.png.\n');
fprintf('Save the executed Live Script as analysis.mlx and export analysis.pdf.\n');

%% 8. Interpretation of the measured results (from submitted executed PDF)
% In the noisy image, Canny sigma 1 creates many extra edges around the
% photographer/camera and textured background (18112 versus 7816 clean).
% Canny sigma 3 suppresses many of those short noise-related edges, but it
% also loses some fine camera/tripod detail in the inspected region.
% Sobel after pre-smoothing preserves the large silhouette with fewer edges.
% Edge-pixel counts alone do NOT indicate accuracy: no hand-labelled
% ground truth is available for precision/recall assessment.
% These observations describe the supplied plots; inspect after rerunning.
