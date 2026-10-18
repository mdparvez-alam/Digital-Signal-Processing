clear; clc; close all;

%% Part 1: Original signal and a one-sample delay
x = [1 2 1];
n = 0:length(x)-1;

% Add a zero at the beginning to delay the signal by one sample.
xDelayed = [0 x];
nDelayed = 0:length(xDelayed)-1;

figure(1);
subplot(2,1,1);
stem(n, x, 'filled');
title('Original Signal x[n]');
xlabel('Sample n'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
stem(nDelayed, xDelayed, 'filled');
title('One-Sample Delay x[n-1]');
xlabel('Sample n'); ylabel('Amplitude');
grid on;

%% Part 2: System H(z) = 0.5 + 0.5*z^(-1)
b = [0.5 0.5];
a = 1;

% Add a zero to display the last nonzero output sample.
xInput = [x 0];
y = filter(b, a, xInput);
nOutput = 0:length(y)-1;

figure(2);
subplot(2,1,1);
stem(nOutput, xInput, 'filled');
title('Input x[n]');
xlabel('Sample n'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
stem(nOutput, y, 'filled');
title('Output y[n] - H(z) = 0.5 + 0.5z^{-1}');
xlabel('Sample n'); ylabel('Amplitude');
grid on;

disp('Output samples for H(z) = 0.5 + 0.5z^(-1):');
disp(y);

%% Part 2, Task 6: Modified system H(z) = 0.8 + 0.2*z^(-1)
bModified = [0.8 0.2];
yModified = filter(bModified, a, xInput);

figure(3);
subplot(2,1,1);
stem(nOutput, xInput, 'filled');
title('Input x[n]');
xlabel('Sample n'); ylabel('Amplitude');
grid on;

subplot(2,1,2);
stem(nOutput, yModified, 'filled');
title('Modified Output y[n] - H(z) = 0.8 + 0.2z^{-1}');
xlabel('Sample n'); ylabel('Amplitude');
grid on;

disp('Output samples for H(z) = 0.8 + 0.2z^(-1):');
disp(yModified);
