create_project vivado_prj {} -part xc7z015clg485-1 -force
set_property board_part [lindex [get_board_parts em.avnet.com:picozed_7015_fmc2:part0:*] end] [current_project]
set_property target_language VHDL [current_project]
set defaultRepoPath {./ipcore}
set_property ip_repo_paths $defaultRepoPath [current_fileset]
update_ip_catalog
set ipList [glob -nocomplain -directory $defaultRepoPath *.zip]
foreach ipCore $ipList {
  set folderList [glob -nocomplain -directory $defaultRepoPath -type d *]
  if {[lsearch -exact $folderList [file rootname $ipCore]] == -1} {
    catch {update_ip_catalog -add_ip $ipCore -repo_path $defaultRepoPath}
  }
}
update_ip_catalog
set AXIDMAFreqMHz {100.0}
set HDLVerifierJTAGAXI {off}
source vivado_custom_block_design.tcl
# Use global synthesis for this project
set_property synth_checkpoint_mode None [get_files system.bd]
set_property -dict [list CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {25.000}] [get_bd_cells core_clkwiz]
save_bd_design
close_project
exit
