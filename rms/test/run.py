import subprocess
import os

print("Reading source files.")

VERILOG_SOURCES = '../src/axis_true_rms_v1_0.v'
VERILOG_SOURCES = VERILOG_SOURCES + ' ../src/axis_true_rms_filter_v1_0.v'
VERILOG_SOURCES = VERILOG_SOURCES + ' ../src/non_restoring_division_v1_1.v'
VERILOG_SOURCES = VERILOG_SOURCES + ' ../src/non_restoring_sqrt_v1_0.v'
VERILOG_SOURCES = VERILOG_SOURCES + ' ../src/axis_lpf_shifted_v1_0.v'
TEST_SOURCE = './rms_test.sv'
TOP_LEVEL = 'rms_test'

print("Calling iVerilog.")

process = subprocess.Popen('iverilog -o output.vvp -g2012 -s ' + TOP_LEVEL + ' ' + TEST_SOURCE + ' ' + VERILOG_SOURCES,shell=True)
print(process.wait())
process = subprocess.Popen('vvp output.vvp',shell=True)
print(process.wait())
os.remove('output.vvp')