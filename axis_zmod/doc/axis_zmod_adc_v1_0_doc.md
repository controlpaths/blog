![image](logo.png)
#  axis_zmod_adc_v1_0
 --- 
 **File:** ../src/axis_zmod_adc_v1_0.v  
**Module name**\: axis_zmod_adc_v1_0  
**Author**\: P Trujillo (pablo@controlpaths.com\)  
**Date**\: Feb 2020  
**Description**\: Driver for ad9648. ZMOD ADC from Digilent. Module uses 2 different clock, so it's neccesary use synchronizers  
**Revision**\: 1. Module created.  
### Parameter list  
|**Name**|**Default Value**|**Description**|  
|-|-|-|  
|prescaler_clk_spi|5|sclk = aclk / precaler_clk_spi|  
|prescaler_clk_spi_width|3|precaler_clk_spi width|  

### Input list  
|**Name**|**Width**|**Description**|  
|-|-|-|  
|aclk|[0:0]|Clock input|  
|resetn|[0:0]|Reset input|  
|m_axis_tready|[0:0]||  
|ddr_data|[13:0]|Parallel input data from ADC|  
|ddr_clk|[0:0]|Input clock select|  

### Output list  
|**Name**|**Width**|**Description**|  
|-|-|-|  
|adc_configured|[0:0]|Adc configuration complete signal|  
|m_axis_tdata|[31:0]||  
|m_axis_tvalid|[0:0]||  
|adc_sync|[0:0]|ADC SPI sync|  
|spi_sck|[0:0]|ADC SPI aclk out|  
|spi_cs|[0:0]|ADC SPI data IO|  
|spi_sdio|[0:0]|ADC SPI cs out|  

### Wire list  
|**Name**|**Width**|**Description**|  
|-|-|-|  
|w_spi_busy|[0:0]|SPI busy signal|  
|w14_data_i|[13:0]|data channel I|  
|w14_data_q|[13:0]|data channel Q|  

### Register list  
|**Name**|**Width**|**Description**|  
|-|-|-|  
|r24_spi_data_out|[23:0]|Synchronizer 0 spi_data_out. RW | W[1:0] | A[12:0] | DATA[7:0]|  
|r_spi_start|[0:0]|Sychronyzer 0 spi_start|  
|r27_delay_1ms_counter|[26:0]|Initial 1ms delay counter|  
|r5_adc_config_state|[4:0]|ADC controller state|  
|r_cmd_read|[0:0]|Read command signal|  
|spi_tick_prescaler_counter|[prescaler_clk_spi_width-1:0]|prescaler counter for spi tick|  
|spi_tick|[0:0]|spi clock enable|  
|r2_spi_state|[1:0]|SPI controller state|  
|r5_data_counter|[4:0]|SPI data to write signal|  

### Instantiation example 
 ```verilog   
axis_zmod_adc_v1_0 #(  
.prescaler_clk_spi(5),  
.prescaler_clk_spi_width(3)
)axis_zmod_adc_v1_0_inst0(  
.aclk(),  
.resetn(),  
.adc_configured(),  
.m_axis_tdata(),  
.m_axis_tvalid(),  
.m_axis_tready(),  
.ddr_data(),  
.ddr_clk(),  
.adc_sync(),  
.spi_sck(),  
.spi_cs(),  
.spi_sdio()   
);   
```

Automatic documentation generator. (https://github.com/controlpaths/verilog_parser)