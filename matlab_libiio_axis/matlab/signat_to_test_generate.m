clear all
close all
clc

format long 

k = 4; % second harmonic
N = 32; % 32 samples 

in_cos = -2*cos(2*pi*k/N)

Wkn = -exp(-j*2*pi*k/N);

angleVector = linspace(2*pi/N, 2*pi, 32);
signal = cos(4*angleVector);

time = [];

signals = struct('values',signal);

data_to_test = struct('time',time,'signals',signals);

Ts = 1e-3

signal_filtered = filter([1 real(Wkn) 0],[1 in_cos 1],signal);

signal_filtered(end)

plot(signal_filtered)
hold on
plot(signal)

fft(signal)