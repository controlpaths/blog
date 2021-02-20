## Script name:   project1
## Script version:  1.0
## Author:  P.Trujillo (pablo@controlpaths.com)
## Date:    Mar20
## Description: Script for create eclypsez7_adc_dac project

set projectDir ../../project
set projectName axis_dma_xfft
set bdName axis_dma_xfft
set bdDir .

## Create project in ../project
create_project -force $projectDir/$projectName.xpr

## Set verilog as default language
set_property target_language Verilog [current_project]

## Set current board eclypsez7.
set_property BOARD_PART trenz.biz:te0802_2cg_1e:part0:2.0 [current_project]

## Create block design
create_bd_design $bdName

## Configure block design through external file
source [glob $bdDir/axis_dma_xfft_bd.tcl]

## Regenerate block design layout
regenerate_bd_layout
regenerate_bd_layout
set_property location {5 1990 909} [get_bd_cells axi_dma_1]
set_property location {3 1294 884} [get_bd_cells rst_ps8_0_100M]
set_property location {2 1411 305} [get_bd_cells xlconcat_0]
regenerate_bd_layout -routing

## Validate block design design
validate_bd_design

## Generate and add wrapper file for synthesis
make_wrapper -files [get_files $projectDir/$projectName.srcs/sources_1/bd/$bdName/$bdName.bd] -top

## Open vivado for verify
start_gui
