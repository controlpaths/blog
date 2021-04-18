## Script name:   project1
## Script version:  1.0
## Author:  P.Trujillo (pablo@controlpaths.com)
## Date:    Mar20
## Description: Script for create eclypsez7_adc_dac project

set projectDir ../project
set projectName biquad_test
set srdDir ../src
set tbDir ../tb

## Create project in ../project
create_project -force $projectDir/$projectName.xpr

## Set verilog as default language
set_property target_language Verilog [current_project]

## Set current part.
set_property part xc7a12tcpg238-3 [current_project]

## Adding verilog files
add_file [glob $srdDir/axis_biquad_v1_0.v]
add_file [glob $tbDir/axis_biquad_tb.v]

## Open vivado for verify
start_gui
