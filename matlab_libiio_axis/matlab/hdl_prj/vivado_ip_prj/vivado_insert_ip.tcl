open_project vivado_prj.xpr
set AXIDMAFreqMHz {100.0}
set HDLVerifierJTAGAXI {off}
update_ip_catalog -delete_ip {./ipcore/axis_goertzel_ip_v1_0/component.xml} -repo_path {./ipcore} -quiet
update_ip_catalog -add_ip {./ipcore/axis_goertzel_ip_v1_0.zip} -repo_path {./ipcore}
update_ip_catalog
set HDLCODERIPVLNV [get_property VLNV [get_ipdefs -filter {NAME==axis_goertzel_ip && VERSION==1.0}]]
set HDLCODERIPINST axis_goertzel_ip_0
set BDFILEPATH [get_files -quiet system.bd]
open_bd_design $BDFILEPATH
create_bd_cell -type ip -vlnv $HDLCODERIPVLNV $HDLCODERIPINST
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins core_clkwiz/clk_out1]] [get_bd_pins $HDLCODERIPINST/AXI4_Lite_ACLK] [get_bd_pins core_clkwiz/clk_out1]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins sys_core_rstgen/peripheral_aresetn]] [get_bd_pins $HDLCODERIPINST/AXI4_Lite_ARESETN] [get_bd_pins sys_core_rstgen/peripheral_aresetn]
connect_bd_intf_net [get_bd_intf_pins $HDLCODERIPINST/AXI4_Lite] [get_bd_intf_pins axi_cpu_interconnect/M00_AXI]
create_bd_addr_seg -range 0x10000 -offset 0x40010000 [get_bd_addr_spaces sys_cpu/Data] [get_bd_addr_segs $HDLCODERIPINST/AXI4_Lite/reg0] SEG_${HDLCODERIPINST}_reg0
connect_bd_intf_net [get_bd_intf_pins $HDLCODERIPINST/AXI4_Stream_Master] [get_bd_intf_pins axi_dma_s2mm_fifo/S_AXIS]
connect_bd_intf_net [get_bd_intf_pins $HDLCODERIPINST/AXI4_Stream_Slave] [get_bd_intf_pins axi_dma_mm2s_fifo/M_AXIS]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins core_clkwiz/clk_out1]] [get_bd_pins $HDLCODERIPINST/IPCORE_CLK] [get_bd_pins core_clkwiz/clk_out1]
connect_bd_net -net [get_bd_nets -of_objects [get_bd_pins sys_core_rstgen/peripheral_aresetn]] [get_bd_pins $HDLCODERIPINST/IPCORE_RESETN] [get_bd_pins sys_core_rstgen/peripheral_aresetn]
make_wrapper -files $BDFILEPATH -top
regsub -all "system.bd" [get_files system.bd] "hdl" TOPFILEPATH
add_files -norecurse $TOPFILEPATH
update_compile_order -fileset sources_1
validate_bd_design
save_bd_design
close_project
exit
