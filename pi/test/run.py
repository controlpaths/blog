from sphinx import os


import subprocess
import os

print("Reading source files.")

VERILOG_SOURCES = '../src/axis_pi_v1_0.v'
TEST_SOURCE = './axis_pi_tb.sv'
TOP_LEVEL = 'axis_pi_tb'

print("Calling iVerilog.")

process = subprocess.Popen('iverilog -o output.vvp -g2012 -s ' + TOP_LEVEL + ' ' + TEST_SOURCE + ' ' + VERILOG_SOURCES,shell=True)
print(process.wait())
process = subprocess.Popen('vvp output.vvp',shell=True)
print(process.wait())
os.remove('output.vvp')

# process = subprocess.Popen('gtkwave sim_data.vcd',shell=True)
# print(process.wait())
