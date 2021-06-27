# Clock signal
set_property -dict {PACKAGE_PIN E3 IOSTANDARD LVCMOS33} [get_ports clk100mhz]
create_clock -period 10.000 -name sys_clk_pin -waveform {0.000 5.000} -add [get_ports clk100mhz]

# Switches
set_property -dict {PACKAGE_PIN A8 IOSTANDARD LVCMOS33} [get_ports {freq_sw[0]}]
set_property -dict {PACKAGE_PIN C11 IOSTANDARD LVCMOS33} [get_ports {freq_sw[1]}]
set_property -dict {PACKAGE_PIN C10 IOSTANDARD LVCMOS33} [get_ports {freq_sw[2]}]
set_property -dict {PACKAGE_PIN A10 IOSTANDARD LVCMOS33} [get_ports {freq_sw[3]}]

## LEDs
set_property -dict { PACKAGE_PIN H5    IOSTANDARD LVCMOS33 } [get_ports { led[0] }]; #IO_L24N_T3_35 Sch=led[4]
set_property -dict { PACKAGE_PIN J5    IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; #IO_25_35 Sch=led[5]
set_property -dict { PACKAGE_PIN T9    IOSTANDARD LVCMOS33 } [get_ports { led[2] }]; #IO_L24P_T3_A01_D17_14 Sch=led[6]
set_property -dict { PACKAGE_PIN T10   IOSTANDARD LVCMOS33 } [get_ports { led[3] }]; #IO_L24N_T3_A00_D16_14 Sch=led[7]

# Pmod Header JA
set_property -dict {PACKAGE_PIN G13 IOSTANDARD LVCMOS33} [get_ports tx_mclk]
set_property -dict {PACKAGE_PIN B11 IOSTANDARD LVCMOS33} [get_ports tx_lrck]
set_property -dict {PACKAGE_PIN A11 IOSTANDARD LVCMOS33} [get_ports tx_sclk]
set_property -dict {PACKAGE_PIN D12 IOSTANDARD LVCMOS33} [get_ports tx_data]
set_property -dict {PACKAGE_PIN D13 IOSTANDARD LVCMOS33} [get_ports rx_mclk]
set_property -dict {PACKAGE_PIN B18 IOSTANDARD LVCMOS33} [get_ports rx_lrck]
set_property -dict {PACKAGE_PIN A18 IOSTANDARD LVCMOS33} [get_ports rx_sclk]
set_property -dict {PACKAGE_PIN K16 IOSTANDARD LVCMOS33} [get_ports rx_data]

