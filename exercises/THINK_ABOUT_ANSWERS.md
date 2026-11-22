# In-class exercises: short explanations (draft to verify against MATLAB outputs)

The sections below follow the teacher's six exercises. The conceptual explanations can be included in the Live Script. Image-specific judgments and measured results must be confirmed from the actual figures before submission.

## Exercise 1 — Pixels and quantization

`cameraman.tif` is inspected with `size` and `class`. The script makes four-bit (16 levels), two-bit (4 levels), and one-bit (2 levels) intensity versions. Four-bit quantization usually retains subject structure and gray variation; one-bit quantization loses most tonal detail, though the silhouette may remain recognizable. Simple every-eighth-pixel subsampling does not remove high spatial frequencies first, so detail near edges and textures may alias. Resizing with antialiasing generally yields a smoother downsampled image. **Verify:** Which details disappear first in your saved comparison?

## Exercise 2 — Degrade an image

Gaussian noise is modeled as additive random intensity variation. Salt-and-pepper noise randomly replaces selected pixels with black/white impulses, rather than being a strictly additive model. The brightness ramp is multiplicative (`image .* ramp`), while motion blur is spatial convolution with the motion kernel. The median filter is usually better suited to sparse salt-and-pepper impulses than a simple mean filter. **Verify:** Compare the actual examples visually.

## Exercise 3 — Contrast and geometry

Gamma 0.5 brightens midtones because for normalized values between zero and one, taking the square root raises intensity. Gamma 2 darkens them. `imadjust` stretches intensity values based on the adjustment mapping, and `histeq` redistributes values to alter the histogram. For enlarging the 40-by-40 patch, nearest-neighbor duplicates neighboring samples and produces blocky steps, while bicubic interpolation blends neighboring values more smoothly. A preferred contrast method depends on retained detail and undesired artifacts; inspect `03_contrast.png` before choosing one.

## Exercise 4 — Filter and compare

Use the measured `04_psnr_results.csv` to identify the highest-PSNR filter separately for Gaussian and salt-and-pepper noise. Do not fill in a winner based only on expectation. Motion blur tends to reduce some high spatial frequencies and changes the 2D spectrum anisotropically. High-frequency content is generally suppressed, while direction-dependent bands can be visible in the Fourier magnitude.

## Exercise 5 — Edges

Increasing Canny sigma increases Gaussian smoothing, typically lowering sensitivity to fine textures and noisy fluctuations, but may also suppress genuine weak edges. Compare the noisy Canny result with and without pre-smoothing using `05_edge_counts.csv`. Their **difference in edge-pixel count is not the number of false edges removed**: edges can be shifted or introduced, and there is no manual ground-truth edge map. If a numerical difference is reported, call it the net difference in detected edge pixels.

## Exercise 6 — Segment and measure

Otsu chooses a threshold from the histogram. Morphological opening removes sufficiently small foreground protrusions/features, `imfill(...,'holes')` fills enclosed holes, and `bwareaopen` removes connected foreground components below the selected area threshold. The largest measured **connected component** appears in `06_component_areas.csv`; it is not necessarily a single coin if objects touch and merge. Inspect the label image for touching coins before claiming an individual largest coin.

## AI assistance disclosure

ChatGPT assisted in structuring MATLAB source and drafting conceptual explanations. The student is responsible for running MATLAB, inspecting the generated figures/tables, and writing truthful experiment-specific observations.
