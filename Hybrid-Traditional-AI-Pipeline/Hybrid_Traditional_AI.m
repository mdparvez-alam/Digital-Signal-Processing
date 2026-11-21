%% Hybrid Traditional + AI Image Classification Pipeline
% Lab assignment: K-means color segmentation + pretrained SqueezeNet
% Run in MATLAB Online with Image Processing Toolbox and Deep Learning Toolbox.
% Save all PNG images and results beside this script.
% The provided sample image is peppers.png (NOT a flower).
clear; close all; clc;
rng(7);

%% 1. Load image and pretrained network
scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end
sourceName = 'peppers.png'; % Can replace with a real flower photo if permitted
sourcePath = fullfile(scriptFolder,sourceName);
if ~isfile(sourcePath)
    if exist(sourceName,'file') == 2
        sourcePath = sourceName; % MATLAB bundled sample image
    else
        error('Missing peppers.png. Upload it into the script folder or use an existing image.');
    end
end
targetImage = imread(sourcePath);
if size(targetImage,3) ~= 3
    targetImage = repmat(targetImage,1,1,3);
end
if ~isa(targetImage,'uint8')
    targetImage = im2uint8(targetImage);
end
fprintf('Source: %s | Image: %d rows x %d cols\n', sourceName,size(targetImage,1),size(targetImage,2));

%% 2. Traditional segmentation in L*a*b* space
fprintf('Applying K-means color segmentation...\n');
lab = rgb2lab(targetImage);
ab = im2single(lab(:,:,2:3));
pixelLabels = imsegkmeans(ab,2);
% Cluster IDs have no object meaning. Inspect both masks before interpreting.
foregroundCluster = 2; % Choose 1 or 2 after examining segmentation
mask = pixelLabels == foregroundCluster;
isolatedObject = targetImage;
isolatedObject(repmat(~mask,[1 1 3])) = 0;
coverage = nnz(mask)/numel(mask);

% Save raw images as valid PNGs (avoids figure export problems)
imwrite(targetImage,fullfile(scriptFolder,'01_original.png'));
imwrite(uint8(mask)*255,fullfile(scriptFolder,'02_kmeans_mask.png'));
imwrite(isolatedObject,fullfile(scriptFolder,'03_isolated_object.png'));

%% 3. Classify BOTH original and segmented image for fair comparison
fprintf('Loading pretrained SqueezeNet...\n');
try
    net = squeezenet; % Legacy DAGNetwork API retained for this assignment
catch ME
    fprintf(2,'SqueezeNet unavailable: %s\n',ME.message);
    fprintf('Segmentation PNGs were saved. Check Deep Learning Toolbox.\n');
    rethrow(ME);
end
inputSize = net.Layers(1).InputSize;
originalInput = imresize(targetImage,inputSize(1:2));
segmentedInput = imresize(isolatedObject,inputSize(1:2));
[labelOriginal,scoresOriginal] = classify(net,originalInput);
[labelSegmented,scoresSegmented] = classify(net,segmentedInput);
scoreOriginal = 100*max(scoresOriginal);
scoreSegmented = 100*max(scoresSegmented);
imwrite(originalInput,fullfile(scriptFolder,'04_original_ai_input.png'));
imwrite(segmentedInput,fullfile(scriptFolder,'05_segmented_ai_input.png'));

%% 4. Display and save comparison
fig = figure('Name','Hybrid traditional and AI pipeline','Color','w');
subplot(2,3,1); imshow(targetImage); title('Original image');
subplot(2,3,2); imshow(mask); title(sprintf('K-means cluster %d mask',foregroundCluster));
subplot(2,3,3); imshow(isolatedObject); title('Segmented / isolated');
subplot(2,3,4); imshow(originalInput); title('Original to SqueezeNet');
subplot(2,3,5); imshow(segmentedInput); title('Segmented to SqueezeNet');
subplot(2,3,6); axis off;
text(0,0.75,sprintf('Original: %s (%.2f%%)',string(labelOriginal),scoreOriginal),'Interpreter','none','FontSize',10);
text(0,0.50,sprintf('Segmented: %s (%.2f%%)',string(labelSegmented),scoreSegmented),'Interpreter','none','FontSize',10);
text(0,0.25,sprintf('Mask area: %.1f%%',100*coverage),'FontSize',10);
sgtitle('Traditional segmentation + SqueezeNet (not an accuracy test)');
try
    exportgraphics(fig,fullfile(scriptFolder,'06_pipeline_comparison.png'),'Resolution',150);
catch
    saveas(fig,fullfile(scriptFolder,'06_pipeline_comparison.png'));
end

%% 5. Save measured output
fprintf('\n--- Hybrid Pipeline Results ---\n');
fprintf('Original image: %s (%.2f%% top-class probability)\n',string(labelOriginal),scoreOriginal);
fprintf('Segmented image: %s (%.2f%% top-class probability)\n',string(labelSegmented),scoreSegmented);
fprintf('Foreground cluster %d covers %.2f%% of image\n',foregroundCluster,coverage*100);
fprintf('NOTE: Larger confidence does NOT prove higher accuracy.\n');

resultsPath = fullfile(scriptFolder,'lab8_results.txt');
fid = fopen(resultsPath,'w');
if fid<0, error('Could not save results text.'); end
fprintf(fid,'Hybrid Traditional + AI Pipeline\n');
fprintf(fid,'MATLAB: %s\n',version);
fprintf(fid,'Image: %s\n',sourceName);
fprintf(fid,'Foreground cluster: %d\n',foregroundCluster);
fprintf(fid,'Mask coverage: %.3f%%\n',coverage*100);
fprintf(fid,'Original top class: %s\n',string(labelOriginal));
fprintf(fid,'Original top probability: %.4f%%\n',scoreOriginal);
fprintf(fid,'Segmented top class: %s\n',string(labelSegmented));
fprintf(fid,'Segmented top probability: %.4f%%\n',scoreSegmented);
fprintf(fid,'Interpretation: class probabilities alone do not determine correctness.\n');
fclose(fid);

fprintf('Saved six PNGs and lab8_results.txt to %s\n',scriptFolder);
