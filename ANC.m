clc;
clear;
close all;

%% Parameters
fs = 44100;              % Sampling frequency
duration = 15;          % Recording duration (seconds)
N = fs * duration;      % Total samples

%% Step 1: Record Speech (Real-Time)
disp('Start speaking... Recording for 15 seconds');
recObj = audiorecorder(fs, 16, 1); % 16-bit, mono
recordblocking(recObj, duration);
disp('Recording finished');

speech = getaudiodata(recObj);
audiowrite('Original_speech_ANC.wav', speech, fs);

t = (0:length(speech)-1)/fs;

%% Step 2: Add Noise (for testing)
noise = 0.5 * randn(size(speech)); % White Gaussian noise
noisy_signal = speech + noise;

%% Step 3: LMS Adaptive Filter
M = 32;              % Filter order
mu = 0.01;           % Step size (learning rate)

w = zeros(M,1);      % Initial weights
y = zeros(N,1);      % Filter output
e = zeros(N,1);      % Error (cleaned signal)

x = noise;           % Reference input (noise)

for n = M:N
    x_vec = x(n:-1:n-M+1);   % Input vector
    
    y(n) = w' * x_vec;      % Filter output
    e(n) = noisy_signal(n) - y(n); % Error signal
    
    w = w + 2 * mu * e(n) * x_vec; % LMS update
end

clean_signal = e;

%% Step 4: Plot Signals
figure;

subplot(3,1,1);
plot(t, speech);
title('Original Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,2);
plot(t, noisy_signal);
title('Noisy Speech Signal');
xlabel('Time (s)');
ylabel('Amplitude');

subplot(3,1,3);
plot(t, clean_signal);
title('Filtered (Cleaned) Signal using LMS');
xlabel('Time (s)');
ylabel('Amplitude');

%% Step 5: Play Audio

disp('Playing Noisy Signal...');
sound(noisy_signal, fs);
pause(duration + 2);

disp('Playing Cleaned Signal...');
sound(clean_signal, fs);

%% Optional: Save Audio Files
audiowrite('noisy_signal_NC.wav', noisy_signal, fs);
audiowrite('clean_signal_NC.wav', clean_signal, fs);