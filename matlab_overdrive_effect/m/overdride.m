
clear all
close all
clc

t = linspace(0,2*pi*2,88);

signal = sin(t);

signal_amp = signal*1.2;

saturated_signal = min(1, max(-1, signal_amp));

[b,a] = fir1(8,0.8)

signal_filt = filter(b,a,saturated_signal);

signal_filt = signal_filt(44:88);
saturated_signal = saturated_signal(44:88);
signal_amp = signal_amp(44:88);
t = t(44:88);

figure
plot(t, signal_amp)
hold on 
plot(t, saturated_signal)
plot(t, signal_filt)

figure
stem(abs(fft(saturated_signal)))
hold on
stem(abs(fft(signal_filt)))
legend('hard', 'soft')

return
[b,a] = fir1(8,0.8);

signal_filt = filter(b,a,saturated_signal);

figure
plot(t, signal_amp)
hold on 
plot(t, saturated_signal)
plot(t, signal_filt)

figure
stem(abs(fft(signal_amp)))
hold on
stem(abs(fft(signal_filt)))


