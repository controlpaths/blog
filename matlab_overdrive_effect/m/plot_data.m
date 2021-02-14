%% Plot data
close all

fSample = 22.6e6;
f0 = 1e3;
nSamples = fSample/f0;
fResample = 44e3;
nResamples = fResample/f0;

figure
plot(dataCaptureOut.output_dataL)
hold on 
plot(dataCaptureOut.output_effect/4)
legend('input', 'effect')

inputData = resample(double(dataCaptureOut.output_dataL), fResample, fSample);
outputEffect = resample(double(dataCaptureOut.output_effect), fResample, fSample);

inputData = inputData(6:nResamples+6);
outputEffect = outputEffect(6:nResamples+6);


figure
stem(inputData)
hold on 
stem(outputEffect)
legend('input', 'effect')
title('Effect disabled')

figure
stem(abs(fft(double(inputData))))
hold on
stem(abs(fft(double(outputEffect))))
xlim([0,nResamples])
legend('input', 'effect')
title('FFT for hard clipping')