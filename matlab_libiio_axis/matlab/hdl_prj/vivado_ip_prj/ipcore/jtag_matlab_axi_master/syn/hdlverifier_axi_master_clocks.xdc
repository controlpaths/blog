#create_clock -name aximaster_tck [get_pins {u_jtag/u_jtag/u_BSCANE2/TCK}] -period 30
create_clock -period 30.000 -name tck -waveform {0.000 15.000} [get_pins -filter { NAME =~  "*/TCK*" } -of_objects [get_cells -hierarchical -filter { PRIMITIVE_TYPE =~ *.BSCANE2 }]] 
set_clock_groups -asynchronous -group [get_clocks {tck}] -group [get_clocks -of_objects [get_nets -filter { NAME =~  "*aclk" }  -of_objects [get_cells -hierarchical -filter { NAME =~  "*readram" } ]] ]
#set_clock_groups -asynchronous -group [get_clocks {tck}] -group [get_clocks -of_objects [get_nets aclk]]
set_property CLOCK_BUFFER_TYPE BUFG [get_nets tck]