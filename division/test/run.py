import subprocess
import os

print("Reading source files.")

VERILOG_SOURCES = '../src/long_division_v1_0.v'
VERILOG_SOURCES = VERILOG_SOURCES + ' ../src/restoring_division_v1_0.v'
VERILOG_SOURCES = VERILOG_SOURCES + ' ../src/non_restoring_division_v1_0.v'
VERILOG_SOURCES = VERILOG_SOURCES + ' ../src/signed_non_restoring_division_v1_0.v'
VERILOG_SOURCES = VERILOG_SOURCES + ' ../src/newton_raphson_division_v1_0.v'
TEST_SOURCE = './division_test.sv'
TOP_LEVEL = 'division_test'

print("Calling iVerilog.")

process = subprocess.Popen('iverilog -o output.vvp -g2012 -s ' + TOP_LEVEL + ' ' + TEST_SOURCE + ' ' + VERILOG_SOURCES,shell=True)
print(process.wait())
process = subprocess.Popen('vvp output.vvp',shell=True)
print(process.wait())
os.remove('output.vvp')