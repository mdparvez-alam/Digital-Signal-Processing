# Lecture 5 — Fourier Assignment

MATLAB experiments on Fourier series, frequency-domain analysis with the FFT, spectral leakage, and DTFT versus DFT.

> **Before submitting:** Run each `.m` script yourself in MATLAB, check that every PNG is produced, verify the values and plots, and revise the observations below into your own words. This README is a prepared draft, not a claim that the MATLAB experiments were already run.

## How to run

1. Open MATLAB or MATLAB Online and upload the project folders.
2. Run `exercise-1/exercise1.m`, `exercise-2/exercise2.m`, `exercise-3/exercise3.m`, and `exercise-4/exercise4.m` one at a time (set the Current Folder to each exercise folder if needed).
3. **Before running Exercise 3, change `d = 4` to your own last student-number digit (0–9)** and update the README value below. Never include your full student number.
4. Check the generated plots and numbers printed in the Command Window. Adjust this README to describe what you actually observe.
5. Upload the complete project with the generated PNG images to the GitHub repository named `lecture-5-fourier-assignment`.

## Exercise 1 — Square wave from harmonics

**Prediction (before running):** As I increase the highest odd harmonic from 1 through 3, 9, and 25, the waveform should become flatter at its top and bottom and switch more sharply between positive and negative values. The H = 1 case is just a sine wave. I expect oscillations near sharp transitions.

**Method:** For each highest harmonic H in [1, 3, 9, 25], add the odd-harmonic sine terms

`x_H(t) = (4/pi) * sum_{k=1,3,...,H} sin(2*pi*k*t)/k`.

**Interpretation to verify with the plot:** Increasing H makes the approximation closer to a square wave away from the jumps. Near each discontinuity, the approximation overshoots and oscillates. This ringing is called the **Gibbs phenomenon**: the ringing region narrows as more harmonics are added, but the overshoot near a jump does not simply disappear.

**My observation after running:** [Describe what changes between H = 1, 3, 9, and 25 using your actual plot.]

**Output:** `exercise-1/square-wave-comparison.png`

## Exercise 2 — Find two frequencies with the FFT

**Prediction (before running):** The signal combines a 15 Hz sinusoid with amplitude 0.8 and a 40 Hz sinusoid with amplitude 0.4. I expect two spectral peaks at these frequencies and approximately these amplitudes after correct single-sided FFT scaling.

**Method:** The sampling rate is `fs = 200 Hz` and the recording duration is `T = 1 s`, so the number of samples is `N = fs*T = 200`.

**Frequency-bin spacing:** `Delta f = fs/N = 200/200 = 1 Hz`.

| Quantity | Expected | Measured in MATLAB |
| --- | ---: | --- |
| First peak frequency | 15 Hz | [check Command Window] |
| First peak amplitude | 0.8 | [check Command Window] |
| Second peak frequency | 40 Hz | [check Command Window] |
| Second peak amplitude | 0.4 | [check Command Window] |
| Bin spacing | 1 Hz | [check Command Window] |

**Explanation to verify:** Both frequencies are on the 1 Hz DFT grid, so the pure tones should have peaks at their expected bins (up to floating-point roundoff). The single-sided scaling doubles the non-DC, non-Nyquist bins to recover the sinusoidal amplitudes.

**My observation after running:** [State the displayed peak locations/amplitudes and compare with the expected values.]

**Outputs:** `exercise-2/two-frequency-time-domain.png` and `exercise-2/two-frequency-spectrum.png`

## Exercise 3 — Investigate spectral leakage

**Last digit of student number:** `d = 4` **(PLACEHOLDER — change to your real last digit before submission)**.

**Second frequency:** `f2 = 13.2 + 0.17*d` Hz. For the placeholder `d = 4`, this would be `f2 = 13.2 + 0.17*4 = 13.88 Hz`. Recalculate after entering your own digit.

**Prediction (before running):** In the 1-second recording, the second tone generally does not align with a 1 Hz FFT bin. Its spectral energy should spread across nearby bins rather than appear at one narrow bin. The 15 Hz tone is on the 1 Hz grid, but nearby leakage from the second tone can influence the displayed spectrum around it.

**Method and frequency spacing:**

| Measurement | Observed samples | FFT points | FFT frequency-grid spacing |
| --- | ---: | ---: | ---: |
| 1 s recording | 200 | 200 | 200/200 = 1 Hz |
| 4 s recording | 800 | 800 | 200/800 = 0.25 Hz |
| 1 s recording, zero-padded | 200 | 800 | 200/800 = 0.25 Hz |

**Interpretation to verify:** A 4-second observation has four times as many actual samples, giving a finer natural DFT-bin spacing and better ability to distinguish nearby tones. The peaks should generally appear more localized in frequency than with the 1-second observation, although leakage can still occur if the tones are not exactly on the 0.25 Hz grid.

Zero-padding the **one-second** signal to 800 FFT points gives a more finely sampled and smoother-looking spectrum with frequency-grid spacing of 0.25 Hz. It **does not increase the original observation length or add information**. Unlike collecting four seconds of data, zero-padding cannot provide the same intrinsic frequency resolution.

**My observation after running:** [Describe how the 1-second spectrum compares to the 4-second spectrum and the zero-padded 1-second spectrum. Mention any overlap between the 13–15 Hz peaks.]

**Outputs:** `exercise-3/one-second-spectrum.png`, `exercise-3/four-second-spectrum.png`, `exercise-3/zero-padded-spectrum.png`, and `exercise-3/leakage-comparison.png`.

## Exercise 4 — Compare DTFT and DFT

**Sequence:** `x = [1 1 1 1]`, with indices `n = 0, 1, 2, 3`.

**DTFT:** `X(e^(jw)) = 1 + exp(-jw) + exp(-j2w) + exp(-j3w)`.

**Comparison to verify:** The DTFT magnitude is a continuous function of angular frequency, approximated here by evaluating it at 1000 frequency values between -pi and pi. The 4-point DFT samples this same transform at only four equally spaced frequencies. The 64-point DFT (after padding the sequence with 60 zeros) samples it at 64 frequencies, tracing the DTFT shape more closely.

**Why 64 FFT points?** The command `fft(x,64)` appends 60 zeros to the original four values before evaluating the FFT. Thus it produces more frequency-domain samples but **no new observed time-domain samples or information**.

**DTFT magnitude zeros:** In the interval `[-pi, pi]`, the magnitude is zero at `-pi`, `-pi/2`, `pi/2`, and `pi` (mathematically exact; floating-point evaluation can give tiny nonzero values). The figure uses discrete plotting points, so the plot might not hit every zero exactly.

**My observation after running:** [Compare the smooth curve and the two stem plots, and check the locations of the zeros.]

**Output:** `exercise-4/dtft-dft-comparison.png`

## AI use declaration

**Draft — edit to accurately describe your use:** I used ChatGPT to help prepare and understand the MATLAB script structure, FFT scaling, plotting commands, and draft explanations. I ran the code myself in MATLAB, checked the generated figures and numerical results, and wrote my final observations in my own words.

## Submission checklist

- [ ] I replaced the placeholder `d = 6` with my actual last digit and updated this README.
- [ ] I ran all four `.m` files myself in MATLAB without errors.
- [ ] I inspected all saved PNG files and confirmed that axes and titles are correct.
- [ ] I replaced the bracketed observations and measured values with my own results.
- [ ] My AI-use statement truthfully describes what I did.
- [ ] I uploaded the project and plots to GitHub and checked the links.
- [ ] I submitted my GitHub repository URL in Moodle (if submission is open or permitted).
