
% figure
% plot(signal)
% hold on
% plot(input)

data_sim = [output.signals.values(:,:,7)' output.signals.values(:,:,8)']
data_sim = data_sim(3:34)

figure
plot(input.signals.values(6,:))
hold on
plot(signal_filtered,'o')
plot(data_sim,'X')
legend('input','matlab result', 'hdl implementation')






