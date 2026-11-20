# Lecture 6 — In-class Task: Inspect and Filter a WAV File

## Goal
Inspect a permitted WAV recording, identify an unwanted frequency component, apply an appropriate filter, and compare the audio before and after filtering.

## Files

```bash
lecture-6-wav-filter-task/
├── inspect_filter_wav.m
├── README.md
├── inspection-before-filtering.png     # Generated when script runs
├── original-vs-filtered.png            # Generated when script runs
└── measurement_summary.txt            # Generated when script runs
```

## Requirements
- MATLAB with Signal Processing Toolbox (`butter`, `filtfilt`, `spectrogram`).
- A teacher-provided or permitted WAV file. Do **not** upload the recording to GitHub unless you have permission.

## How to run
1. Open `inspect_filter_wav.m` in MATLAB Online.
2. Click **Run** and choose the WAV file when prompted.
3. Inspect the initial waveform and spectrogram (Figure 1).
4. If the unwanted sound is not a 50 Hz hum, edit `filterType` and the cutoff/stop band in the script, then run again.
5. Inspect `original-vs-filtered.png`. Listen to the original and filtered signal by running the commented `sound()` lines **one at a time**.
6. Complete the explanation below using your real audio and results.

## Recording details (fill after running)
- WAV filename: **[filename]**
- Sampling rate: **[Hz]**
- Duration: **[seconds]**
- Original channels: **[mono/stereo]**
- Unwanted component identified: **[what was heard and where it appears in the spectrogram]**

## Filter choice
- Filter type: **[Butterworth band-stop / low-pass / high-pass]**
- Cutoff or stop band: **[Hz]**
- Reason for choice: **[based on the observed unwanted sound]**
- Implementation: `filtfilt`, a forward-backward offline filter without intentional phase shift; endpoint effects are possible.

## Results and observations (complete after listening)
- Waveform or spectrogram change: **[observed change]**
- Unwanted sound after filtering: **[audibly reduced / unchanged / uncertain]**
- Useful sound preserved or altered: **[own listening observation]**
- Limitations: Filtering may remove useful signal inside the attenuated frequency band; a clean reference is not available for direct error measurement.

![Original and filtered WAV](original-vs-filtered.png)

## AI-use disclosure
AI assistance was used to draft the MATLAB script and GitHub README structure. I selected the recording, inspected and ran the code in MATLAB, and checked the plots and playback myself. **Edit this statement if your actual workflow differed.**
