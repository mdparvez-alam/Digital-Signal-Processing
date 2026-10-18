# MATLAB Assignment: Z-Transform and Sample Delays

## Running the code

Open `ZTransform_SampleDelays.m` in MATLAB and click **Run**. The script produces three figures:

1. Original signal and its one-sample delay.
2. Input and output for `H(z) = 0.5 + 0.5z^-1`.
3. Input and output for `H(z) = 0.8 + 0.2z^-1`.

## Screenshots

After running the script, save screenshots of the figures and add them here:

- `screenshots/part1_original_and_delayed.png`
- `screenshots/part2_average_output.png`
- `screenshots/part2_modified_output.png`

You can take screenshots of each MATLAB figure and save them with these filenames. The screenshots are not included yet; they must be captured from MATLAB after running the code.

## Answers

### 1. Which sample does each term in X(z) represent?

For `x = [1 2 1]`, the Z-transform is `X(z) = 1 + 2z^-1 + z^-2`.

- `1` represents `x[0] = 1`.
- `2z^-1` represents `x[1] = 2`.
- `z^-2` represents `x[2] = 1`.

The exponent of `z` indicates the sample index.

### 2. Z-transform of the delayed signal

The delayed signal is `[0 1 2 1]`, so its Z-transform is:

`X_delayed(z) = z^-1 + 2z^-2 + z^-3`.

### 3. Why does one-sample delay multiply X(z) by z^-1?

A one-sample delay moves every sample one position to the right. In the Z-transform, the contribution of a sample at index `n` contains `z^-n`. Moving it to index `n+1` adds a factor of `z^-1`. Therefore, `Z{x[n-1]} = z^-1 X(z)` for the zero-extended signal.

### 4. Calculate output samples and compare with MATLAB

The system is `y[n] = 0.5x[n] + 0.5x[n-1]`. Assume `x[-1] = 0` and `x[3] = 0`.

- `y[0] = 0.5(1) + 0.5(0) = 0.5`
- `y[1] = 0.5(2) + 0.5(1) = 1.5`
- `y[2] = 0.5(1) + 0.5(2) = 1.5`
- `y[3] = 0.5(0) + 0.5(1) = 0.5`

Expected MATLAB output: `[0.5 1.5 1.5 0.5]`. Confirm by running the script.

### 5. How does b = [0.5 0.5] represent H(z)?

The first coefficient, `0.5`, multiplies the current sample `x[n]`. The second coefficient, `0.5`, multiplies the previous sample `x[n-1]`. This makes `H(z) = 0.5 + 0.5z^-1`.

### 6. Change H(z) to 0.8 + 0.2z^-1

Use `b = [0.8 0.2]`. The new output is calculated by `y[n] = 0.8x[n] + 0.2x[n-1]`.

Expected output: `[0.8 1.8 1.2 0.2]`.

The current input sample has more influence because its coefficient is `0.8`, while the previous sample has a smaller coefficient of `0.2`.

