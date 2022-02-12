#!/bin/sh

VERILOG_SOURCE="../src/Discrete_FIR_Filter3.v"
VERILOG_SOURCE+=" ../src/Discrete_FIR_Filter4.v"
VERILOG_SOURCE+=" ../src/two_stage_downsampler_tc.v"
VERILOG_SOURCE+=" ../src/two_stage_downsampler.v"
#VERILOG_SOURCE+=" ../src/two_stage_downsampler_tb.v"
VERILOG_SOURCE+=" ../test/downsampler_tb.sv"

echo "${VERILOG_SOURCE}"

iverilog -o downsampler_simulation $VERILOG_SOURCE
vvp downsampler_simulation
#gtkwave downsampler.vcd