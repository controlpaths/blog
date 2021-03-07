## Script name:   project1
## Script version:  1.0
## Author:  P.Trujillo (pablo@controlpaths.com)
## Date:    mar20
## Description: Script for create iio_manage project

set projectDir ../../project
set projectName iio_manage
set bdName iio_manage_bd
set bdDir .

## Create project in ../project
create_project -force $projectDir/$projectName.xpr

## Set verilog as default language
set_property target_language Verilog [current_project]

## Set current board eclypsez7.
set_property BOARD_PART em.avnet.com:picozed_7015_fmc2:part0:1.2 [current_project]

## Create block design
create_bd_design $bdName

## Configure block design through external file
source [glob $bdDir/axis_dma_xfft_bd.tcl]

## Regenerate block design layout
regenerate_bd_layout

## Validate block design design
validate_bd_design

## Generate and add wrapper file for synthesis
make_wrapper -files [get_files $projectDir/$projectName.srcs/sources_1/bd/$bdName/$bdName.bd] -top

## Open vivado for verify
start_gui
