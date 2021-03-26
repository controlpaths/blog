set_clock_groups -asynchronous -group [get_clocks -of_objects [get_cells -hierarchical -filter { NAME =~ "*rd_addr_bin*" && ( PRIMITIVE_TYPE =~ FLOP_LATCH.flop.*   || PRIMITIVE_TYPE == RTL_REGISTER.flop.RTL_REG || PRIMITIVE_TYPE =~ REGISTER.SDR.*  ) }]] \
                                 -group [get_clocks -of_objects [get_cells -hierarchical -filter { NAME =~ "*rd_addr_bin_sync1*" && ( PRIMITIVE_TYPE =~ FLOP_LATCH.flop.*   || PRIMITIVE_TYPE == RTL_REGISTER.flop.RTL_REG || PRIMITIVE_TYPE =~ REGISTER.SDR.*  ) }] ]