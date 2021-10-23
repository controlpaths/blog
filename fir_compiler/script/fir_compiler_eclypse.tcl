## Script name:   project1
## Script version:  1.0
## Author:  P.Trujillo (pablo@controlpaths.com)
## Date:    Aug21
## Description: Script for create eclypsez7_adc_dac project

set projectDir ../project
set projectName fir_compiler_eclypse
set bdName fir_compiler_eclypse_bd
set bdDir ./2020.2

## Create project in ../project
create_project -force $projectDir/$projectName.xpr

## Set verilog as default language
set_property target_language Verilog [current_project]

## Set current board eclypsez7.
set_property BOARD_PART digilentinc.com:eclypse-z7:part0:1.0 [current_project]

## Adding files to the project 
## Adding verilog files
add_file [glob ../src/*.v]

## Adding constraints files
read_xdc ../xdc/eclypsez7_dacA_adcB.xdc

## Adding ip cores
read_ip ../ip/clk_wiz_0.xci

## Create block design
create_bd_design $bdName

## Configure block design through external file
source [glob $bdDir/fir_compiler_eclypse_bd.tcl]

## Regenerate block design layout
regenerate_bd_layout

## Validate block design design
validate_bd_design

## Generate and add wrapper file for synthesis
make_wrapper -files [get_files $projectDir/$projectName.srcs/sources_1/bd/$bdName/$bdName.bd] -top

## Open vivado for verify
start_gui
