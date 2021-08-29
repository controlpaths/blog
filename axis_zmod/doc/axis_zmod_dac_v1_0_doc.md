![image](logo.png)
#  axis_zmod_dac_v1_0
 --- 
 **File:** ../src/axis_zmod_dac_v1_0.v  
**Module name**\: axis_zmod_dac_v1_0  
**Author**\: P Trujillo (pablo@controlpaths.com\)  
**Date**\: Jul 2021  
**Description**\: Driver for ad9717. ZMOD DAC from Digilent. Driver for Zynq7000 device.  
**Revision**\: 1.0  

### Input list  
|**Name**|**Width**|**Description**|  
|-|-|-|  
|aclk|[0:0]|Clock input. This signal is corresponding with sample frequency|  
|resetn|[0:0]|Reset input|  
|s_axis_tdata|[31:0]|{2'bx, w13_data_i, 2'bx, w13_data_q}|  
|s_axis_tvalid|[0:0]||  

### Output list  
|**Name**|**Width**|**Description**|  
|-|-|-|  
|s_axis_tready|[0:0]||  
|ddr_data|[13:0]|Parallel DDR data for ADC|  
|ddr_clk|[0:0]|DDR clock|  
|rst_spi|[0:0]|DAC reset out|  
|spi_sck|[0:0]|DAC SPI clk out|  
|spi_cs|[0:0]|DAC SPI cs out|  
|spi_sdo|[0:0]|DAC SPI data IO out|  

### Wire list  
|**Name**|**Width**|**Description**|  
|-|-|-|  
|w13_data_i|[13:0]|Data for ch i|  
|w13_data_q|[13:0]|Data for ch q|  

### Instantiation example 
 ```verilog   
axis_zmod_dac_v1_0 axis_zmod_dac_v1_0_inst0(  
.aclk(),  
.resetn(),  
.s_axis_tdata(),  
.s_axis_tvalid(),  
.s_axis_tready(),  
.ddr_data(),  
.ddr_clk(),  
.rst_spi(),  
.spi_sck(),  
.spi_cs(),  
.spi_sdo()   
);   
```

Automatic documentation generator. (https://github.com/controlpaths/verilog_parser)