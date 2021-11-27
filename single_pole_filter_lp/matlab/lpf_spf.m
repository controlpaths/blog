% Configurable single pole filter

clear all
close all
clc
format long

% Filter parameters

fs = 100e3;
fc = 50;

tau = 1/(2*pi*fc);
ts = 1/fs;
alpha = ts/tau;
%alpha = 1-exp(-ts/tau)

% Signal
tmax = 0.8;

t = linspace(0,tmax,tmax*fs);
f = 50;
%x = sin(2*pi*f*t);

x = [1,zeros(1,length(t)-1)]; % delta function

y = zeros(length(t),1);

for i = [1:length(t)]
    if (i == 1)
        y(i) = 0 + alpha * (x(i)-0);
    else
        y(i) = y(i-1) + alpha * (x(i)-y(i-1));
    end
end

plot(t,x)
hold on
plot(t,y)

legend('x','y')

% fft
xfft = 20*log10(abs(fft(x)));
yfft = 20*log10(abs(fft(y)));

fVector = linspace(0,fs,length(t));

figure
semilogx(fVector, xfft)
xlim([0,fs/2])
hold on
semilogx(fVector, yfft)
xlim([0,fs/2])

legend('x','y')