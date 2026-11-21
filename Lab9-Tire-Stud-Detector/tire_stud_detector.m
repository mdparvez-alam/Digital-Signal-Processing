%% Lab 9 - Tire Stud Detector (traditional image processing only)
% Requires MATLAB Image Processing Toolbox. No AI models are used.
% Place the two teacher-provided photos in this script's folder.
% IMPORTANT: Parameters are starting points, NOT calibrated accuracy claims.
clear; clc; close all;

scriptFolder = fileparts(mfilename('fullpath'));
if isempty(scriptFolder), scriptFolder = pwd; end
imageFiles = {'studded_tire.jpeg', 'summer_tire.jpg'};

% Parameters to inspect/tune on BOTH teacher-provided images
resizeScale = 0.5;
minTireArea = 500;            % pixels after resizing
minStudArea = 4;              % candidate pixels
maxStudArea = 120;
minCircularity = 0.60;        % 4*pi*area / perimeter^2
maxEccentricity = 0.85;
minimumStudCount = 11;        % more than 10 = studded (example rule)
tophatRadius = 7;             % disk radius in resized pixels
minLocalContrast = 0.07;      % minimum top-hat brightness in [0, 1]

labels = strings(numel(imageFiles),1);
counts = zeros(numel(imageFiles),1);
densities = zeros(numel(imageFiles),1);
maskAreas = zeros(numel(imageFiles),1);

for i = 1:numel(imageFiles)
    filename = imageFiles{i};
    sourcePath = fullfile(scriptFolder, filename);
    if ~isfile(sourcePath) && i == 1
        filename = 'studded_tire.jpg';  % accept common alternate extension
        sourcePath = fullfile(scriptFolder, filename);
    end
    if ~isfile(sourcePath)
        error(['Missing %s. Download BOTH original tire photos from Moodle, ' ...
               'upload them to %s, and rerun.'], imageFiles{i}, scriptFolder);
    end

    %% 1. Read / resize / grayscale
    source = imread(sourcePath);
    source = imresize(source, resizeScale);
    if ndims(source)==3 && size(source,3)==3
        Igray = im2double(rgb2gray(source));
        Irgb = im2uint8(source);
    elseif ismatrix(source)
        Igray = im2double(source);
        Irgb = repmat(im2uint8(Igray),1,1,3);
    else
        error('Unsupported image channels in %s',filename);
    end
    [M,N] = size(Igray);

    %% 2. Rough dark tire region mask + morphological cleaning
    % Otsu's threshold is an initial guess, not a guaranteed tire segmentation.
    darkThreshold = graythresh(Igray);
    darkMask = Igray < darkThreshold;
    darkMask = imclose(darkMask, strel('disk', 5, 0));
    darkMask = imfill(darkMask,'holes');
    darkMask = bwareaopen(darkMask, minTireArea);
    CCtire = bwconncomp(darkMask);
    if CCtire.NumObjects == 0
        warning('%s: no dark connected region found; using entire image.',filename);
        tireMask = true(M,N); % explicit fallback; inspect before trusting results
    else
        areasTire = cellfun(@numel, CCtire.PixelIdxList);
        [~,largest] = max(areasTire);
        tireMask = false(M,N);
        tireMask(CCtire.PixelIdxList{largest}) = true;
    end
    % Prevent the bright contour between tire and background from being counted.
    tireMask = imerode(tireMask, strel('disk', 2, 0));

    %% 3. Find bright *local* spots inside the tire area
    % White top-hat highlights bright details smaller than its structuring element.
    localBright = imtophat(Igray, strel('disk', tophatRadius, 0));
    localValues = localBright(tireMask);
    if isempty(localValues)
        error('%s: tire mask empty. Adjust dark-mask processing.',filename);
    end
    localThreshold = max(minLocalContrast, graythresh(localValues));
    candidates = (localBright > localThreshold) & tireMask;
    candidates = bwareaopen(candidates, minStudArea);
    candidates = imclose(candidates, strel('disk', 1, 0));

    %% 4. Connected components + area / roundness / eccentricity filters
    CC = bwconncomp(candidates);
    stats = regionprops(CC,'Area','Perimeter','Eccentricity','PixelIdxList','Centroid');
    studMask = false(M,N);
    studCount = 0;
    for k = 1:numel(stats)
        a = stats(k).Area;
        p = stats(k).Perimeter;
        circ = 4*pi*a/max(p^2,eps);
        if a >= minStudArea && a <= maxStudArea && ...
                circ >= minCircularity && stats(k).Eccentricity <= maxEccentricity
            studMask(stats(k).PixelIdxList) = true;
            studCount = studCount + 1;
        end
    end
    studDensity = 10000*studCount/max(nnz(tireMask),1); % studs/10k tire pixels
    if studCount >= minimumStudCount
        decision = 'STUDDED TIRE';
    else
        decision = 'NON-STUDDED TIRE';
    end
    labels(i) = string(decision);
    counts(i) = studCount;
    densities(i) = studDensity;
    maskAreas(i) = nnz(tireMask);

    %% 5. Save reliable PNG montage (no figure-export dependency)
    % Blue = candidate mask; red = accepted stud boundaries.
    blue = uint8(255*candidates);
    candidateRGB = cat(3, uint8(0*candidates), uint8(0*candidates), blue);
    detectionRGB = Irgb;
    perimeter = bwperim(studMask);
    rr = detectionRGB(:,:,1); gg = detectionRGB(:,:,2); bb = detectionRGB(:,:,3);
    rr(perimeter) = 255; gg(perimeter) = 0; bb(perimeter) = 0;
    detectionRGB = cat(3,rr,gg,bb);
    panel = [Irgb, candidateRGB, detectionRGB];
    outputFile = fullfile(scriptFolder, sprintf('%02d_%s_detection.png',i,erase(filename,{'.jpeg','.jpg','.png'})));
    imwrite(panel,outputFile);

    %% 6. Show clearly labeled comparison in MATLAB
    figure('Color','w','Name',filename);
    subplot(1,3,1), imshow(Irgb), title(['Original: ' filename],'Interpreter','none');
    subplot(1,3,2), imshow(candidates), title('Candidate bright spots');
    subplot(1,3,3), imshow(detectionRGB), ...
        title(sprintf('%s: %d candidates accepted',decision,studCount));
    fprintf('%s | dark threshold %.3f | local threshold %.3f | stud count %d | %s\n', ...
        filename,darkThreshold,localThreshold,studCount,decision);
    fprintf('  Tire mask: %d pixels | density: %.3f studs/10k tire pixels\n', ...
        nnz(tireMask),studDensity);
end

%% 7. Export summary for README and teacher review
results = table(string(imageFiles(:)),counts,maskAreas,densities,labels, ...
    'VariableNames',{'Image','StudCount','TireMaskPixels','StudsPer10000Pixels','Prediction'});
writetable(results,fullfile(scriptFolder,'lab9_results.csv'));
fid=fopen(fullfile(scriptFolder,'lab9_measurements.txt'),'w');
if fid<0, error('Could not save lab9_measurements.txt'); end
fprintf(fid,'Lab 9: Traditional tire stud detector\n');
fprintf(fid,'Resize scale: %.2f\n',resizeScale);
fprintf(fid,'Candidate area: %d to %d pixels\n',minStudArea,maxStudArea);
fprintf(fid,'Min circularity: %.2f | Max eccentricity: %.2f\n',minCircularity,maxEccentricity);
fprintf(fid,'Top-hat radius: %d | Min local contrast: %.3f\n',tophatRadius,minLocalContrast);
fprintf(fid,'Decision: >= %d accepted components implies STUDDED\n\n',minimumStudCount);
for i=1:height(results)
    fprintf(fid,'%s | studs: %d | area: %d | density: %.3f | result: %s\n', ...
        results.Image(i), results.StudCount(i),results.TireMaskPixels(i), ...
        results.StudsPer10000Pixels(i), results.Prediction(i));
end
fprintf(fid,'These are heuristic predictions; verify visually before claiming success.\n');
fclose(fid);
disp(results);
fprintf('Saved two PNG comparisons, lab9_results.csv and lab9_measurements.txt.\n');
