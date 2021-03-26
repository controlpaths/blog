open_bd_design ./[current_project].srcs/sources_1/bd/system/system.bd

# Set AXI DMA clock frequency
set_property -dict [list CONFIG.CLKOUT2_REQUESTED_OUT_FREQ $AXIDMAFreqMHz] [get_bd_cells axi_clkwiz]

validate_bd_design
save_bd_design
