## Script name:   project1
## Script version:  1.0
## Author:  P.Trujillo (pablo@controlpaths.com)
## Date:    Aug21
## Description: Script for create eclypsez7_adc_dac project

set projectDir ../project
set projectName picozed7015_pcie
set bdName picozed7015_pcie_bd
set bdDir ./2020.2

## Create project in ../project
create_project -force $projectDir/$projectName.xpr

## Set verilog as default language
set_property target_language Verilog [current_project]

## Set current board eclypsez7.
set_property BOARD_PART avnet.com:picozed_7015_fmc2:part0:1.3 [current_project]

## Adding files to the project 

## Adding constraints files
read_xdc ../xdc/picozed_pcie_bd_wrapper.xdc


## Create block design
create_bd_design $bdName

## Configure block design through external file
source [glob $bdDir/$bdName.tcl]

## Regenerate block design layout
regenerate_bd_layout

## Validate block design design
validate_bd_design

## Generate and add wrapper file for synthesis
make_wrapper -files [get_files $projectDir/$projectName.srcs/sources_1/bd/$bdName/$bdName.bd] -top

## Open vivado for verify
start_gui
