%--------------------------------------------------------------------------
% Software Interface Script
% 
% Generated with MATLAB 9.9 (R2020b) at 00:00:56 on 21/03/2021.
% This script was created for the IP Core generated from design 'model_biquad_wfa'.
% 
% Use this script to access DUT ports in the design that were mapped to compatible IP core interfaces.
% You can write to input ports in the design and read from output ports directly from MATLAB.
% To write to input ports, use the "writePort" command and specify the port name and input data. The input data will be cast to the DUT port's data type before writing.
% To read from output ports, use the "readPort" command and specify the port name. The output data will be returned with the same data type as the DUT port.
% Use the "release" command to release MATLAB's control of the hardware resources.
%--------------------------------------------------------------------------

%% Create fpga object
hFPGA = fpga("Xilinx");

%% Setup fpga object
% This function configures the "fpga" object with the same interfaces as the generated IP core
gs_model_biquad_wfa_setup(hFPGA);

%% Write/read DUT ports
% Uncomment the following lines to write/read DUT ports in the generated IP Core.
% Update the example data in the write commands with meaningful data to write to the DUT.
%% AXI4-Lite
% writePort(hFPGA, "axi4_wkn", zeros([1 1]));
% writePort(hFPGA, "axi4_incos", zeros([1 1]));

%% AXI4-Stream
% writePort(hFPGA, "axis_input_tdata", zeros([1 1024]));
% data_axis_output_tdata = readPort(hFPGA, "axis_output_tdata");

%% Release hardware resources
release(hFPGA);

