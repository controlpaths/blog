%% Second order low pass filter design

close all
clear all
clc

fc = 1000;
wc = 2*pi*fc
q = 0.707;

q = 1;

s = tf('s');

% Low pass filter
h = wc^2/(s^2+wc/q*s+wc^2)

step(h)

% discretize filter

fs = 1e5;
ts = 1/fs;

hz = c2d(h,ts,'tustin')

[num, den] = tfdata(hz)

b0 = num{1}(1)
b1 = num{1}(2)
b2 = num{1}(3)
a1 = den{1}(2)
a2 = den{1}(3)

% quantize

nBits = 18;

b0_qq = floor(b0*2^nBits)
b1_qq = floor(b1*2^nBits)
b2_qq = floor(b2*2^nBits)

a1_qq = floor(a1*2^nBits)
a2_qq = floor(a2*2^nBits)

figure
step(hz)

% test quantized
b0_qqq = b0_qq / 2^nBits;
b1_qqq = b1_qq / 2^nBits;
b2_qqq = b2_qq / 2^nBits;
a1_qqq = a1_qq / 2^nBits;
a2_qqq = a2_qq / 2^nBits;

hzq = tf([b0_qqq b1_qqq b2_qqq], [1 a1_qqq a2_qqq], ts)

hold on
step(hzq)

