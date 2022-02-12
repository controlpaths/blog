close all
clear all
clc

fsample = 100e3;

dowsampling_factor = 32;

fsample_re = fsample / dowsampling_factor

% filter compute (one stage decimator)

atten = 40; % attenuation required in db

fstop = 2000;
fpass = 500;

n = atten / (22*(fstop/fsample - fpass/fsample));

taps = fir1(floor(n),fpass/fsample);

% filter compute (two stage decimator)
signal_bw = 500;

f = (fstop-signal_bw)/fstop;

m1_th = floor(2*dowsampling_factor*(1-sqrt(dowsampling_factor*f/(2-f)))/(2-f*(dowsampling_factor + 1)));
m2_th = floor(dowsampling_factor / m1_th) + 1;

m1 = m1_th;
m2 = m2_th;

% m1 = 16;
% m2 = 2;

fstop1 = fsample/m1/2;
fpass1 = 500;

n1 = atten / (22*(fstop1/fsample - fpass1/fsample));

taps1 = fir1(floor(n1),fpass1/fsample);

fsample2 = fsample/m1;
fstop2 = fsample2/m2/2;
fpass2 = 500;

n2 = atten / (22*(fstop2/fsample2 - fpass2/fsample2));

taps2 = fir1(floor(n2),fpass2/fsample2);

fsample_re_2stage = fsample2/m2;

% compute quantize coefficients 
nt = numerictype(true,16,15); % define the width of the quantization

taps_fi = fi(taps);
taps_q = quantize(taps_fi,nt);

gain_fir_q = sum(taps_q)

taps1_fi = fi(taps1);
taps1_q = quantize(taps1_fi,nt);

gain_fir1_q = sum(taps1_q)
gain_fir1_q = sum(taps1)

freqz(taps1, 1);
hold on
freqz(double(taps1_q),1)

taps2_fi = fi(taps2);
taps2_q = quantize(taps2_fi,nt);

gain_fir2_q = sum(taps2_q)

gain_fir_2stage = gain_fir1_q * gain_fir2_q

% simulation

out = sim("model_downsampling")

figure()
plot(out.data)

figure
plot(out.downsampled_data)

figure
plot(out.downsampled_data_fir)

figure
plot(out.downsampled_data_fir_two_stage1)

figure
plot(out.downsampled_data_fir_two_stage)

data_dft = abs(fft(double(out.data)))*2/length(out.data);
downsampled_data_dft = abs(fft(double(out.downsampled_data)))*2/length(out.downsampled_data);
downsampled_data_fir_dft = abs(fft(double(out.downsampled_data_fir)))*2/length(out.downsampled_data_fir);
downsampled_data_fir_two_stage1_dft = abs(fft(double(out.downsampled_data_fir_two_stage1)))*2/length(out.downsampled_data_fir_two_stage1);
downsampled_data_fir_two_stage_dft = abs(fft(double(out.downsampled_data_fir_two_stage)))*2/length(out.downsampled_data_fir_two_stage);

fvector = linspace(0,fsample,length(out.data));
figure()
plot(fvector, data_dft)
xlim([0,fsample/2])

fvector2 = linspace(0,fsample/dowsampling_factor,length(out.downsampled_data));
figure()
plot(fvector2, downsampled_data_dft)
xlim([0,fsample_re/2])

figure()
plot(fvector2, downsampled_data_fir_dft)
xlim([0,fsample_re/2])

fvector2stage1 = linspace(0,fsample/m1,length(out.downsampled_data_fir_two_stage1));
figure()
plot(fvector2stage1, downsampled_data_fir_two_stage1_dft)
xlim([0,fsample/2/m1])

fvector2stage = linspace(0,fsample/m1/m2,length(out.downsampled_data_fir_two_stage));
figure()
plot(fvector2stage, downsampled_data_fir_two_stage_dft)
xlim([0,fsample/2/m1/m2])

% set hdl tool
hdlsetuptoolpath('ToolName', 'Microsemi Libero SoC', ...
                       'ToolPath', '/usr/local/microsemi/Libero_SoC_v2021.2/Libero/bin/libero')
