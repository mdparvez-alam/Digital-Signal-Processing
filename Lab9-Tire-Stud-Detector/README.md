# Lab 9 — Image Preprocessing and Segmentation without AI

**Course:** Mathematical Algorithms (DSP) — Image Processing Labs  
**Task:** Detect metal studs on tires with traditional MATLAB image processing  
**Submission:** GitHub repository URL only

## Objective

The goal is to locate small, approximately round bright features within a dark tire area and use the number of detected candidates to distinguish the provided studded-tire photo from the summer-tire photo. No AI classifier is used.

## Input images

Use the **original images provided by the teacher**:
- `studded_tire.jpeg`
- `summer_tire.jpg`

Place both beside `tire_stud_detector.m`. The MATLAB program also accepts `studded_tire.jpg` as an alternative spelling. The files are **not included in this starter ZIP** because the Moodle downloads were inaccessible here. Do not substitute unrelated tire images when reporting results for the assignment.

## How to run

1. Upload the script and both images to the same folder in MATLAB Drive.
2. Open `tire_stud_detector.m` in MATLAB Online.
3. Click **Run**. MATLAB Image Processing Toolbox is needed.
4. Inspect the two generated comparisons and the detection counts.
5. Modify the threshold, component-size, roundness, or decision parameters if the actual teacher images require it. Run again after any changes.

## Processing pipeline

1. **Read and resize:** Load both photos, resize to 50%, convert to grayscale.
2. **Tire mask:** Threshold dark pixels, close gaps, fill holes, and select the largest dark connected region. This assumes the tire is darker than the background.
3. **Bright candidates:** Use a white top-hat transform and a contrast threshold to find small, locally bright spots inside the tire mask.
4. **Morphological cleanup:** Remove isolated tiny objects and close small gaps.
5. **Connected components:** Use `bwconncomp` and `regionprops` to calculate area, perimeter, and eccentricity. Reject components that are too large, too small, or insufficiently round.
6. **Decision:** An initial heuristic of **11 or more** accepted components means *STUDDED TIRE*. This number is **not validated** until the photos have been tested.
7. **Results:** Export a three-panel image per input and a CSV/text summary.

## Expected output files

| File | Purpose |
|---|---|
| `01_studded_tire_detection.png` | Original / candidates / detected studs (red outlines) |
| `02_summer_tire_detection.png` | Same comparison for the summer tire |
| `lab9_results.csv` | Detected counts, mask sizes, densities, decisions |
| `lab9_measurements.txt` | Parameters and measured values |

The figure labels are displayed inside MATLAB. The saved PNGs contain the same three image panels in left-to-right order, with no baked-in text.

## Results — fill from your MATLAB run

| Input | Detected stud count | Classification | Does it match the photo? |
|---|---:|---|---|
| Studded tire | **[your result]** | **[your result]** | **[verify]** |
| Summer tire | **[your result]** | **[your result]** | **[verify]** |

**Observations:** [Describe whether bright metal studs were correctly highlighted. Mention false positives from rubber reflections or tread texture, and missed studs if present.]

## Short explanation and limitations

The method uses grayscale thresholding, morphology, local brightness enhancement, and connected-component geometry instead of machine learning. It works only if the tire area can be separated from the background and its metal studs appear as distinct bright, compact spots. Sunlight reflections, tread texture, dark studs, scale changes, and background objects can produce errors. A fixed count threshold must be evaluated on the supplied images; two photos do not demonstrate general reliability.



## Submission checklist

- [ ] Both original teacher-provided tire images added
- [ ] Script runs in MATLAB without errors
- [ ] Two detection PNGs saved and opened successfully
- [ ] Counts and classification independently verified
- [ ] README measurements and observations filled in
- [ ] All files uploaded to GitHub
- [ ] GitHub link submitted to Moodle
