# matlab overdrive effect

## Description
On this project we are going to develop an audio processing algorithm. In this case we will develop a distortion effect to modify the sound of a guitar. The configuration of the effect will be managed through an AXI4 Lite bus. To acquire the sound signal, we are going to use the I2S2 PMOD from Digilent. This board is based on an Audio DAC and an Audio ADC. These two devices will communicate with the FPGA through a I2S protocol. The project will be implemented on a Picozed 7015 board, with the FMC Carrier board ver. 2.

## Files
- **m/configuration_axi_script.m.** Matlab script to write the corresponding AXI registers.
- **m/overdrive.m.** Matlab script to generate a demo of overdrive effect.
- **m/plot_data.m.** Matlab script to plot data read from FPGA Data Capture.
- **model/fir_model.slx.** Simulink model of FIR filter.
- **model/model1.slx.** Complete project model including acquisition and processing.
- **v/axis_i2s2.v.** PMOD_I2S2 Driver from Digilent modified.
- **v/i2s_axis_controller.v.** Verilog top module.
