# Lecture 6 — Practical Digital Filtering Assignment

**Course:** Digital Signal Processing  
**Assignment:** Lecture 6 — Practical Digital Filtering  
**Tools:** MATLAB and Signal Processing Toolbox  
**Submission:** MATLAB script, report (3–5 pages), and generated figures

## 1. Project overview

This project investigates digital filtering in two experiments:

- **Part A — Sensor signal:** Compare an order-60 finite impulse response (FIR) low-pass filter with an order-4 Butterworth infinite impulse response (IIR) low-pass filter. Both have a nominal cutoff frequency of 20 Hz and are applied with `filtfilt` for zero-phase *offline* filtering.
- **Part B — Audio signal:** Add a controlled 50 Hz hum to MATLAB's built-in Handel recording. Compare a narrow 49–51 Hz band-stop filter with a wider 45–55 Hz band-stop filter.

The objective is to reduce unwanted signal components while preserving useful content. Results are evaluated with waveforms, frequency responses, amplitude spectra and numerical measurements.

## 2. Repository structure

```text
lecture-6-practical-digital-filtering/
├── README.md
├── lecture6_filtering.m
├── Lecture_6_Report_Draft.docx
├── figures/
│   ├── A1_sensor_time.png             # generated after running MATLAB
│   ├── A2_filter_responses.png        # generated after running MATLAB
│   ├── A3_sensor_spectra.png          # generated after running MATLAB
│   ├── B1_audio_waveforms.png         # generated after running MATLAB
│   ├── B2_audio_spectra.png           # generated after running MATLAB
│   └── B3_notch_responses.png         # generated after running MATLAB
├── sensor_rmse.csv                    # generated after running MATLAB
└── measured_results.txt              # generated after running MATLAB
```

**Note:** The report is a draft until the verified numerical results, plots, and personal listening observations have been added. Generated files listed above will appear only after the MATLAB script runs successfully.

## 3. Requirements and instructions

**Requirements:** MATLAB, Signal Processing Toolbox (`fir1`, `butter`, `freqz`, `filtfilt`), and the built-in Handel dataset (`load handel`).

1. Open [MATLAB Online](https://matlab.mathworks.com/) or desktop MATLAB.
2. Upload/open `lecture6_filtering.m` in the project folder.
3. Run the entire script using **Run**.
4. Check the six figures in `figures/` and the automatically generated `sensor_rmse.csv` and `measured_results.txt`.
5. Record the MATLAB version displayed by the script: **26.2.0.3468271 (R2026b) Update 2**.
6. Use the commented `sound(...)` commands near the end of the script to compare audio at the same gain, playing the files **one at a time**.
7. Insert your verified results and listening observations into the report. Export the final report to PDF if your instructor prefers that format.

The script uses `rng(7)` so the synthetic sensor noise is reproducible. It does not export or submit audio recordings.

## 4. Part A — Sensor signal filtering

### Signal and filter design

| Parameter | Value |
|---|---|
| Sampling frequency | 1000 Hz |
| Duration | 2 s |
| Wanted components | 5 Hz, amplitude 1; 12 Hz, amplitude 0.35 |
| Interference | 50 Hz, amplitude 0.35; 137 Hz, amplitude 0.20; Gaussian noise |
| Low-pass cutoff | 20 Hz |
| FIR filter | Order 60, 61 taps, `fir1` |
| IIR filter | 4th-order Butterworth, `butter` |
| Filtering method | `filtfilt` (forward/backward, offline) |

A 20 Hz low-pass cutoff is reasonable because both wanted sensor frequencies, 5 Hz and 12 Hz, are below it, while the known 50 Hz and 137 Hz interference components are above it. This design assumes the information of interest does not contain important frequencies above 20 Hz.

### Figures

After running the script and committing the generated images, these relative image links will display directly on GitHub.

**Sensor waveforms (0–0.2 s)**

![Clean, noisy, FIR-filtered and IIR-filtered sensor signals](figures/A1_sensor_time.png)

**FIR and IIR frequency responses**

![One-pass magnitude responses and 20 Hz cutoff](figures/A2_filter_responses.png)

**Sensor amplitude spectra**

![Single-sided amplitude spectra of noisy and filtered signals](figures/A3_sensor_spectra.png)

### RMSE measurements

RMSE is calculated against the known clean reference using

\[
\operatorname{RMSE} = \sqrt{\frac{1}{N}\sum_{n=1}^{N}(y[n]-x_{\mathrm{clean}}[n])^2}.
\]

| Signal | RMSE (from MATLAB) |
|---|---:|
| Noisy input | **0.38012** |
| FIR output | **0.10559** |
| IIR output | **0.054774** |

**Measured interpretation:** The IIR output has the lowest RMSE (0.054774), compared with FIR (0.10559) and noisy input (0.38012). Relative to the noisy signal these correspond to approximately 85.59% and 72.22% RMSE reductions, respectively. Both filters greatly reduce the measured 50 and 137 Hz peaks. The FIR suppresses those interference peaks slightly more, but also attenuates the wanted 12 Hz component more strongly. Inspect the generated 0–0.2 s plot and full-recording endpoints before reporting any visible edge effects.

| Frequency | Noisy amplitude | FIR amplitude | IIR amplitude |
|---|---:|---:|---:|
| 5 Hz | 0.99911 | 0.93034 | 0.99878 |
| 12 Hz | 0.34970 | 0.22984 | 0.34319 |
| 50 Hz | 0.34578 | 0.00042 | 0.00138 |
| 137 Hz | 0.20465 | 0.00013 | 0.00042 |

RMSE quantifies average sample-by-sample error when a clean reference is available. It does not, by itself, reveal the frequency distribution of errors, perceived quality, or which signal features have been lost.

### FIR vs IIR comparison

The FIR design uses 61 numerator coefficients; the Butterworth design is order 4, with 5 numerator and 5 denominator coefficients in its direct-form representation. These orders are **not** directly equivalent measures of computational cost. Their transition regions and stopband attenuation should be compared using the generated frequency-response figure.

Because `filtfilt` filters forward and backward, the plotted **one-pass** frequency responses are not the complete effective magnitude responses: the effective magnitude is the square of the one-pass magnitude. It avoids an intentional phase shift but requires buffering and can introduce endpoint transients.

A linear-phase FIR design can be preferable when predictable phase behavior is important in a causal implementation. An IIR design can be preferable when a low-order implementation and lower computational workload are priorities, subject to stability and phase/delay requirements. For this particular experiment, the better-performing output should be chosen based on the actual RMSE **and** the time/spectrum plots.

## 5. Part B — Removing a 50 Hz audio hum

### Audio and filter design

| Parameter | Configuration |
|---|---|
| Recording | MATLAB built-in Handel example (`load handel`) |
| Audio sampling frequency | **8192 Hz** |
| Added interference | 50 Hz sinusoidal hum, amplitude 0.15 |
| Narrow band-stop filter | Butterworth, order 2, 49–51 Hz |
| Wide comparison filter | Butterworth, order 2, 45–55 Hz |
| Filtering method | `filtfilt` (offline) |

The 49–51 Hz band-stop filter targets a steady 50 Hz interference while limiting removal of nearby audio frequencies. The 45–55 Hz filter covers more possible frequency variation, but it also suppresses a larger region of potentially useful low-frequency content.

### Figures

**Audio waveform comparison**

![Clean Handel audio, hum-added audio and filtered audio](figures/B1_audio_waveforms.png)

**Spectrum near 50 Hz**

![Spectrum of clean, hum-added and two filtered audio signals](figures/B2_audio_spectra.png)

**Narrow and wide notch responses**

![Magnitude responses of 49–51 Hz and 45–55 Hz band-stop filters](figures/B3_notch_responses.png)

### Measured hum reduction

The script compares the **largest single-sided FFT amplitude within 50 ± 0.3 Hz** in the full recording. This is a near-50 Hz spectrum measurement; it may also contain components from the original audio and should **not** be described as a measurement of only the artificially added hum.

| Measurement | MATLAB result |
|---|---:|
| Hum-added audio, peak near 50 Hz | **0.135547** |
| Narrow-filter output, peak near 50 Hz | **0.00105802** |
| Wide-filter output, peak near 50 Hz | **0.000235649** |
| Narrow-filter peak change (dB) | **−42.15 dB** |
| Wide-filter peak change (dB) | **−55.20 dB** |

Peak change is calculated as:

\[
20\log_{10}\!\left(\frac{A_{\mathrm{after}}}{A_{\mathrm{before}}}\right)\;\mathrm{dB}.
\]

**Listening comparison (not yet provided):** [After listening at identical playback gain, describe whether the hum became quieter and whether the narrow and wide notch filters changed any useful audio. Do not claim a listening result without listening.]

## 6. Answers to the report questions

**Q1. Why is 20 Hz reasonable for Part A?**  
The wanted components are 5 and 12 Hz, while the known interference is at 50 and 137 Hz. A 20 Hz low-pass is designed to pass the wanted components and reduce higher frequencies. The key assumption is that no important sensor information is above 20 Hz.

**Q2. Which filter gives the better result?**  
For this synthetic sensor signal, the IIR is the stronger choice when preserving the known 5 and 12 Hz components and minimizing RMSE are priorities. Evidence 1: IIR RMSE = 0.054774 versus FIR RMSE = 0.10559. Evidence 2: the IIR preserves 12 Hz amplitude (0.34319) more closely to the clean target (0.35) than FIR (0.22984). Both greatly suppress 50 and 137 Hz interference; FIR has the smaller measured residual interference peaks. Inspect endpoint behavior before drawing a conclusion about edge artifacts.

**Q3. What changes for live, low-latency filtering?**  
`filtfilt` uses future samples and is not suitable as written for real-time causal streaming. A live system needs a causal filtering implementation and an explicit latency budget; compare group delay, processing cost, startup behavior, and any phase distortion. A lower-order IIR may be attractive for lower latency, but must be evaluated for stability and acceptable phase behavior.

**Q4. Why use a narrow notch? What if the hum drifts?**  
A narrow notch isolates a stable 50 Hz component while preserving more adjacent audio content. If the interference drifts, an adaptive notch or a suitably wider stop band could be considered and validated against the risk of removing useful sound.

**Q5. One limitation and one improvement.**  
The sensor interference and audio hum are artificially generated under controlled conditions, so these results may not represent all real sensor or recording environments. An improvement would be to test the chosen methods on independently recorded signals with realistic interference variation and assess distortion as well as attenuation.

## 7. MATLAB environment and reproducibility

- **MATLAB version used:** 26.2.0.3468271 (R2026b) Update 2
- **Signal Processing Toolbox:** functions available (confirmed by script)
- **Sensor noise seed:** `rng(7)`
- **Sensor sampling rate:** 1000 Hz
- **Audio source:** Built-in MATLAB Handel example
- **External audio files included:** None

## 8. AI-use declaration

**AI-use declaration (review before submission):** I used AI assistance to prepare the MATLAB script and README/report structure and to help interpret the filtering methods. I ran the script in MATLAB and reviewed its numerical outputs. Audio listening observations must be written after I personally listen to the recordings. I checked the final text against my own results. **Edit this statement to match exactly what you have done.**

## 9. Submission checklist

- [ ] `lecture6_filtering.m` runs without errors in MATLAB.
- [ ] I verified the MATLAB version and Signal Processing Toolbox availability.
- [ ] All six generated PNG figures are saved and visible on GitHub.
- [ ] `sensor_rmse.csv` and `measured_results.txt` contain the actual generated values.
- [ ] I inserted the actual plots and measurements into my 3–5 page report.
- [ ] I listened to the audio outputs at the same gain and wrote my own observations.
- [ ] I replaced all `[bracketed placeholders]` and checked the AI-use statement.
- [ ] I checked the repository from GitHub and submitted the required link in Moodle (if submission is allowed).

---

**Important:** The numerical results above are based on the supplied MATLAB output. Download the actual generated figures and results files from MATLAB Drive, confirm the edge behavior, complete the listening observations, and finalize the 3–5 page report before submitting.
