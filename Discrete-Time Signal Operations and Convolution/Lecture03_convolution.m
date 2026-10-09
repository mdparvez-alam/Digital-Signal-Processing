clear;
close all;
clc;

% Repeatable noise
rng(1);

%% Create a clean discrete-time signal and add noise
n = 0:100;
clean = sin(0.1*pi*n);
noise = 0.4*randn(size(n));
measured = clean + noise;

% Show clean and noisy signals
figure;
plot(n,clean,'b','LineWidth',1.5);
hold on;
plot(n,measured,'Color',[0.6 0.6 0.6]);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Clean and Noisy Signals');
legend('Clean Signal','Noisy Signal','Location','best');
hold off;

%% Task 1: Amplitude scaling
scaled = 2*measured;
figure;
plot(n,measured,'Color',[0.5 0.5 0.5],'LineWidth',1.1);
hold on;
plot(n,scaled,'r--','LineWidth',1.2);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Task 1: Amplitude Scaling by 2');
legend('Noisy Signal','Scaled Signal (x2)','Location','best');
hold off;
saveas(gcf,'signal_operations.png');

%% Task 2: Delay by five samples (zero padding)
delay = 5;
delayed = [zeros(1,delay), measured];
n_measured = 0:length(measured)-1;
n_delayed = 0:length(delayed)-1;
figure;
plot(n_measured,measured,'Color',[0.5 0.5 0.5],'LineWidth',1.2);
hold on;
plot(n_delayed,delayed,'m--','LineWidth',1.2);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Task 2: Signal Delay by 5 Samples');
legend('Noisy Signal','Delayed Signal (5 samples)','Location','best');
hold off;

%% Task 3: Five-point moving average by convolution
h5 = ones(1,5)/5;
filtered5 = conv(measured,h5,'same');
figure;
plot(n,clean,'b','LineWidth',1.6);
hold on;
plot(n,measured,'Color',[0.7 0.7 0.7],'LineWidth',0.9);
plot(n,filtered5,'r','LineWidth',1.5);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Task 3: Five-Point Moving-Average Filtering');
legend('Clean Signal','Noisy Signal','5-Point Filter','Location','best');
hold off;
saveas(gcf,'noise_filtering.png');

%% Task 4: Comparison of moving-average lengths
h15 = ones(1,15)/15;
filtered15 = conv(measured,h15,'same');
figure;
plot(n,clean,'b-','LineWidth',1.7);
hold on;
plot(n,measured,'Color',[0.7 0.7 0.7],'LineWidth',0.9);
plot(n,filtered5,'r--','LineWidth',1.5);
plot(n,filtered15,'Color',[0 0.5 0],'LineStyle','-.','LineWidth',1.6);
grid on;
xlabel('Sample index n');
ylabel('Amplitude');
title('Task 4: Comparing 5-Point and 15-Point Filters');
legend('Clean Signal','Noisy Signal','5-Point Filter','15-Point Filter','Location','best');
hold off;
saveas(gcf,'filter_comparison.png');

%% Optional numerical check of how well each result matches the clean signal
mse_noisy = mean((measured-clean).^2);
mse_5 = mean((filtered5-clean).^2);
mse_15 = mean((filtered15-clean).^2);
fprintf('MSE of noisy signal: %.4f\n',mse_noisy);
fprintf('MSE after 5-point filtering: %.4f\n',mse_5);
fprintf('MSE after 15-point filtering: %.4f\n',mse_15);
