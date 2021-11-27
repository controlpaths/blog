% Configurable single pole filter with shifts

clear all
close all
clc
format long

% Filter parameters

fs = 100e3;
nshift = 4;

alpha = 2^(-nshift)
ts = 1/fs;
%tau = ts / alpha
tau = -ts/log(1-alpha)
wc = 1 / tau;
fc = wc/2/pi

% Signal
%tmax = 0.0215-ts;
tmax = 0.0015-ts;

t = linspace(0,tmax,tmax*fs);
f = 916;
%x = sin(2*pi*f*t);

%x = [1,zeros(1,length(t)-1)]; % delta function
x = ones(1,length(t)); % step function

y = zeros(length(t),1);
yDigital = zeros(length(t),1);

% Implementation

inputBits = 12;
inputDecimalBits = 11;

for i = [1:length(t)]
    inputDigital= floor(x(i) * 2^(inputDecimalBits));

    if (i == 1)
        y(i) = 0 + (inputDigital-0)/(2^nshift);
    else
        y(i) = y(i-1) + (inputDigital-y(i-1))/(2^nshift);
    end
end

plot(t,x)
hold on
plot(t,y/(2^inputDecimalBits))

legend('x','y')

% compare with simulation data
import_data;

figure
plot(t,y*300/(2^inputDecimalBits))
hold on
plot(t,output_data)
legend('MATLAB','Simulation')
title('alpha = 4')