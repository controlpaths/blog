open_project vivado_prj.xpr
update_compile_order -fileset sources_1
reset_run impl_1
reset_run synth_1
launch_runs synth_1
wait_on_run synth_1
launch_runs impl_1 -to_step write_bitstream
wait_on_run impl_1
open_run impl_1
set slackvalue [get_property SLACK [get_timing_paths]]
if [expr [get_property SLACK [get_timing_paths]] < 0] { 
   cd vivado_prj.runs/impl_1
   file rename system_wrapper.bit system_wrapper_timingfailure.bit
   puts " 
 The worst slack is: $slackvalue ns "
   return -code error [format " ERROR- Timing constraints NOT met! 
 "] 
} 
close_project
puts "------------------------------------"
puts "Embedded system build completed."
puts "You may close this shell."
puts "------------------------------------"
exit
