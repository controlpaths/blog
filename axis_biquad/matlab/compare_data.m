%% Script to compare simulation data with MATLAB data

close all

import_xsim_data

figure
plot(output)
hold on
plot(step(hzq)*1000)
grid on
title("I2Q18 Q1")
legend('simulation', 'model')
