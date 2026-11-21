# Hybrid Traditional + AI Pipeline — Image Segmentation and Classification

## Objective
This MATLAB experiment combines **traditional image processing (K-means color segmentation)** with **AI image classification (pretrained SqueezeNet)**. We compare predictions on the original image and its isolated region rather than assuming segmentation helps.

## Image and environment
- Input image: `peppers.png` in the starter exercise. **This is a peppers image, not a flower image.** If changing to your own flower picture, update the script and report its origin.
- MATLAB version: **[copy from your run]**
- Image Processing Toolbox: **[verified yes/no]**
- Deep Learning Toolbox / pretrained SqueezeNet: **[verified yes/no]**

## Folder contents

```text
Hybrid-Traditional-AI-Pipeline/
├── Hybrid_Traditional_AI.m
├── README.md
├── 01_original.png                (generated after running)
├── 02_kmeans_mask.png            (generated after running)
├── 03_isolated_object.png        (generated after running)
├── 04_original_ai_input.png      (generated after running)
├── 05_segmented_ai_input.png     (generated after running)
├── 06_pipeline_comparison.png    (generated after running)
└── lab8_results.txt             (generated after running)
```

## Run in MATLAB Online
1. Upload `Hybrid_Traditional_AI.m` to MATLAB Drive. `peppers.png` may be available as a MATLAB sample; if not, upload the image into the same folder.
2. Open and run the script. If SqueezeNet is unavailable, check your Deep Learning Toolbox installation/licence.
3. Inspect the mask carefully: K-means cluster IDs **do not guarantee an object is isolated**. Change `foregroundCluster` to 1 if the other cluster better represents the desired object, then rerun.
4. Verify the PNG files can be opened and record the actual predictions from `lab8_results.txt`.

## Section 1 — Original image and SqueezeNet
**Figure:** `01_original.png`

**Observation (complete after MATLAB run):** [Describe the objects and background visible in your image.]

SqueezeNet uses a resized 227 × 227 RGB input and predicts a class from its pretrained category set. The returned top-class probability is a model output, not proof of accuracy.

## Section 2 — K-means color segmentation
**Figures:** `02_kmeans_mask.png`, `03_isolated_object.png`

RGB is converted to L*a*b*, and the two chromatic channels (`a*`, `b*`) are clustered into two groups. One chosen cluster becomes a binary mask; other pixels are set to black. This separates *colors*, and may not cleanly isolate a physical object.

**Observation:** [Describe which regions were retained and whether the mask successfully separated the intended object.]

## Section 3 — AI classification
**Figures:** `04_original_ai_input.png`, `05_segmented_ai_input.png`

The same pretrained SqueezeNet classifies the original and masked versions of the image. Both images are resized to the network's input dimensions before classification.

| Input | Top predicted class | Top-class probability |
|---|---|---|
| Original | [copy from MATLAB] | [copy from MATLAB] |
| Segmented | [copy from MATLAB] | [copy from MATLAB] |

## Section 4 — Results and discussion
**Figure:** `06_pipeline_comparison.png`

**Measured mask coverage:** [copy from `lab8_results.txt`]

**Comparison in your own words:** [Does the predicted label change? Does the probability change? Does the isolated image visibly preserve the target?]

**Important limitation:** A higher predicted probability after segmentation **does not establish** higher classification accuracy. A verified ground-truth object label and multiple test images would be needed for an accuracy comparison. Masking the wrong color cluster may remove informative object parts or alter the image significantly.

## Short reflection
- **Traditional contribution:** Color clustering gives an interpretable, adjustable mask before AI classification.
- **AI contribution:** A pretrained CNN maps the prepared image to learned object categories.
- **Potential benefit:** Less distracting background *if* the mask isolates the relevant object correctly.
- **Potential drawbacks:** Cluster-label ambiguity, color overlap between object/background, loss of context, and possible mismatch with pretrained CNN classes.

## AI assistance and verification
**AI tool:** ChatGPT.

**Assistance provided:** Helped organize MATLAB code, generate files, identify the need for a baseline prediction, and explain limitations.

**Verification completed by student:** [Describe the MATLAB screenshots, valid PNGs, labels, probabilities, and any corrections made. Do not claim a successful classification until you check it.]

## References
- MathWorks, [SqueezeNet documentation](https://www.mathworks.com/help/deeplearning/ref/squeezenet.html).
- MathWorks, [K-means image segmentation documentation](https://www.mathworks.com/help/images/ref/imsegkmeans.html).

## Submission checklist
- [ ] Script runs without errors
- [ ] Six PNG screenshots/outputs are visible on GitHub
- [ ] Segmentation mask checked and selected cluster justified
- [ ] Prediction table filled with actual MATLAB output
- [ ] Short original observations and AI-verification note completed
- [ ] GitHub URL submitted in Moodle
