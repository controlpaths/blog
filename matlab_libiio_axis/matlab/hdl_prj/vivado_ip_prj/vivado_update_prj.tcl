open_project vivado_prj.xpr
set AXIDMAFreqMHz {100.0}
set HDLVerifierJTAGAXI {off}
set HDLCODERIPVLNV [get_property VLNV [get_ipdefs -filter {NAME==axis_goertzel_ip && VERSION==1.0}]]
set HDLCODERIPINST axis_goertzel_ip_0
set BDFILEPATH [get_files -quiet system.bd]
source vivado_custom_update_prj.tcl
close_project
exit
