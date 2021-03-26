module mwarbiter_axis # (
  parameter NUM_AXIS_CHANNELS = 8,
  parameter DSTPORT_0 = 8,
  parameter DSTPORT_1 = 8,
  parameter DSTPORT_2 = 8,
  parameter DSTPORT_3 = 8,
  parameter DSTPORT_4 = 8,
  parameter DSTPORT_5 = 8,
  parameter DSTPORT_6 = 8,
  parameter DSTPORT_7 = 8,
  parameter GETVERSION= 'h80,
  parameter FPGA_RST  = 'h81,
  parameter DUT_RST   = 'h82,
  parameter DATAWIDTH = 8
)(

input                  rxclk,
input                  txclk,
input                  dutclk,

input                  reset,
output                 rxrst,
output                 txrst,
output                 dutrst,

output                 rxbuffer_rden,
input  [DATAWIDTH-1:0] rxbuffer_data,
input                  rxbuffer_datavld,
input                  rxbuffer_eop,
input                  rxbuffer_empty,

output [DATAWIDTH-1:0] txbuffer_data,
output                 txbuffer_datavld,
output                 txbuffer_eop,
input                  txbuffer_afull,

input                  statusReady,
output [DATAWIDTH-1:0] status,
output                 statusVld,
output                 statusEOP,
output          [31:0] ver_udpport,

//---- ch0
output [DATAWIDTH-1:0] ch0_m_axis_tdata,
output                 ch0_m_axis_tvalid,
output                 ch0_m_axis_tlast,
input                  ch0_m_axis_tready,

input  [DATAWIDTH-1:0] ch0_s_axis_tdata,
input                  ch0_s_axis_tvalid,
input                  ch0_s_axis_tlast,
output                 ch0_s_axis_tready,
//---- ch1
output [DATAWIDTH-1:0] ch1_m_axis_tdata,
output                 ch1_m_axis_tvalid,
output                 ch1_m_axis_tlast,
input                  ch1_m_axis_tready,

input  [DATAWIDTH-1:0] ch1_s_axis_tdata,
input                  ch1_s_axis_tvalid,
input                  ch1_s_axis_tlast,
output                 ch1_s_axis_tready,
//---- ch2
output [DATAWIDTH-1:0] ch2_m_axis_tdata,
output                 ch2_m_axis_tvalid,
output                 ch2_m_axis_tlast,
input                  ch2_m_axis_tready,

input  [DATAWIDTH-1:0] ch2_s_axis_tdata,
input                  ch2_s_axis_tvalid,
input                  ch2_s_axis_tlast,
output                 ch2_s_axis_tready,

//---- ch3
output [DATAWIDTH-1:0] ch3_m_axis_tdata,
output                 ch3_m_axis_tvalid,
output                 ch3_m_axis_tlast,
input                  ch3_m_axis_tready,

input  [DATAWIDTH-1:0] ch3_s_axis_tdata,
input                  ch3_s_axis_tvalid,
input                  ch3_s_axis_tlast,
output                 ch3_s_axis_tready,
//---- ch4
output [DATAWIDTH-1:0] ch4_m_axis_tdata,
output                 ch4_m_axis_tvalid,
output                 ch4_m_axis_tlast,
input                  ch4_m_axis_tready,

input  [DATAWIDTH-1:0] ch4_s_axis_tdata,
input                  ch4_s_axis_tvalid,
input                  ch4_s_axis_tlast,
output                 ch4_s_axis_tready,
//---- ch5
output [DATAWIDTH-1:0] ch5_m_axis_tdata,
output                 ch5_m_axis_tvalid,
output                 ch5_m_axis_tlast,
input                  ch5_m_axis_tready,

input  [DATAWIDTH-1:0] ch5_s_axis_tdata,
input                  ch5_s_axis_tvalid,
input                  ch5_s_axis_tlast,
output                 ch5_s_axis_tready,
//---- ch6
output [DATAWIDTH-1:0] ch6_m_axis_tdata,
output                 ch6_m_axis_tvalid,
output                 ch6_m_axis_tlast,
input                  ch6_m_axis_tready,

input  [DATAWIDTH-1:0] ch6_s_axis_tdata,
input                  ch6_s_axis_tvalid,
input                  ch6_s_axis_tlast,
output                 ch6_s_axis_tready,
//---- ch7
output [DATAWIDTH-1:0] ch7_m_axis_tdata,
output                 ch7_m_axis_tvalid,
output                 ch7_m_axis_tlast,
input                  ch7_m_axis_tready,

input  [DATAWIDTH-1:0] ch7_s_axis_tdata,
input                  ch7_s_axis_tvalid,
input                  ch7_s_axis_tlast,
output                 ch7_s_axis_tready
);  


//---- internal
wire          [15:0] ch0_m_axis_srcport;
wire          [15:0] ch1_m_axis_srcport;
wire          [15:0] ch2_m_axis_srcport;
wire          [15:0] ch3_m_axis_srcport;
wire          [15:0] ch4_m_axis_srcport;
wire          [15:0] ch5_m_axis_srcport;
wire          [15:0] ch6_m_axis_srcport;
wire          [15:0] ch7_m_axis_srcport;

//---- RX
mwrxarbiter # (
  .NUM_AXIS_CHANNELS(NUM_AXIS_CHANNELS),
  .DSTPORT_0 (DSTPORT_0),
  .DSTPORT_1 (DSTPORT_1),
  .DSTPORT_2 (DSTPORT_2),
  .DSTPORT_3 (DSTPORT_3),
  .DSTPORT_4 (DSTPORT_4),
  .DSTPORT_5 (DSTPORT_5),
  .DSTPORT_6 (DSTPORT_6),
  .DSTPORT_7 (DSTPORT_7),
  .GETVERSION (GETVERSION),
  .FPGA_RST (FPGA_RST),
  .DUT_RST (DUT_RST),
  .DATAWIDTH (DATAWIDTH)
) MWRXARBITER (
  .dutclk(dutclk),
  .reset(reset),

  .rxclk(rxclk),
  .txclk(txclk),
  .rxrst(rxrst),
  .txrst(txrst),
  .dutrst(dutrst),
  
  .rxbuffer_rden(rxbuffer_rden),
  .rxbuffer_data(rxbuffer_data),
  .rxbuffer_datavld(rxbuffer_datavld),
  .rxbuffer_eop(rxbuffer_eop),
  .rxbuffer_empty(rxbuffer_empty),

  .statusReady(statusReady),
  .status(status),
  .statusVld(statusVld),
  .statusEOP(statusEOP),
  .ver_udpport(ver_udpport),

  .ch0_m_axis_srcport(ch0_m_axis_srcport),
  .ch1_m_axis_srcport(ch1_m_axis_srcport),
  .ch2_m_axis_srcport(ch2_m_axis_srcport),
  .ch3_m_axis_srcport(ch3_m_axis_srcport),
  .ch4_m_axis_srcport(ch4_m_axis_srcport),
  .ch5_m_axis_srcport(ch5_m_axis_srcport),
  .ch6_m_axis_srcport(ch6_m_axis_srcport),
  .ch7_m_axis_srcport(ch7_m_axis_srcport),
  
  .ch0_m_axis_tdata(ch0_m_axis_tdata),
  .ch0_m_axis_tvalid(ch0_m_axis_tvalid),
  .ch0_m_axis_tlast(ch0_m_axis_tlast),
  .ch0_m_axis_tready(ch0_m_axis_tready),
  
  .ch1_m_axis_tdata(ch1_m_axis_tdata),
  .ch1_m_axis_tvalid(ch1_m_axis_tvalid),
  .ch1_m_axis_tlast(ch1_m_axis_tlast),
  .ch1_m_axis_tready(ch1_m_axis_tready),
  
  .ch2_m_axis_tdata(ch2_m_axis_tdata),
  .ch2_m_axis_tvalid(ch2_m_axis_tvalid),
  .ch2_m_axis_tlast(ch2_m_axis_tlast),
  .ch2_m_axis_tready(ch2_m_axis_tready),
  
  .ch3_m_axis_tdata(ch3_m_axis_tdata),
  .ch3_m_axis_tvalid(ch3_m_axis_tvalid),
  .ch3_m_axis_tlast(ch3_m_axis_tlast),
  .ch3_m_axis_tready(ch3_m_axis_tready),
  
  .ch4_m_axis_tdata(ch4_m_axis_tdata),
  .ch4_m_axis_tvalid(ch4_m_axis_tvalid),
  .ch4_m_axis_tlast(ch4_m_axis_tlast),
  .ch4_m_axis_tready(ch4_m_axis_tready),
  
  .ch5_m_axis_tdata(ch5_m_axis_tdata),
  .ch5_m_axis_tvalid(ch5_m_axis_tvalid),
  .ch5_m_axis_tlast(ch5_m_axis_tlast),
  .ch5_m_axis_tready(ch5_m_axis_tready),
  
  .ch6_m_axis_tdata(ch6_m_axis_tdata),
  .ch6_m_axis_tvalid(ch6_m_axis_tvalid),
  .ch6_m_axis_tlast(ch6_m_axis_tlast),
  .ch6_m_axis_tready(ch6_m_axis_tready),
  
  .ch7_m_axis_tdata(ch7_m_axis_tdata),
  .ch7_m_axis_tvalid(ch7_m_axis_tvalid),
  .ch7_m_axis_tlast(ch7_m_axis_tlast),
  .ch7_m_axis_tready(ch7_m_axis_tready)  
);

//---- TX
mwtxarbiter # (
  .DSTPORT_0 (DSTPORT_0),
  .DSTPORT_1 (DSTPORT_1),
  .DSTPORT_2 (DSTPORT_2),
  .DSTPORT_3 (DSTPORT_3),
  .DSTPORT_4 (DSTPORT_4),
  .DSTPORT_5 (DSTPORT_5),
  .DSTPORT_6 (DSTPORT_6),
  .DSTPORT_7 (DSTPORT_7),
  .DATAWIDTH (DATAWIDTH)
) MWTXARBITER (
  .dutclk(dutclk),
  .reset(reset),

  .txbuffer_data(txbuffer_data),
  .txbuffer_datavld(txbuffer_datavld),
  .txbuffer_eop(txbuffer_eop),
  .txbuffer_afull(txbuffer_afull),

  .ch0_m_axis_srcport(ch0_m_axis_srcport),
  .ch1_m_axis_srcport(ch1_m_axis_srcport),
  .ch2_m_axis_srcport(ch2_m_axis_srcport),
  .ch3_m_axis_srcport(ch3_m_axis_srcport),
  .ch4_m_axis_srcport(ch4_m_axis_srcport),
  .ch5_m_axis_srcport(ch5_m_axis_srcport),
  .ch6_m_axis_srcport(ch6_m_axis_srcport),
  .ch7_m_axis_srcport(ch7_m_axis_srcport),

  .ch0_s_axis_tdata(ch0_s_axis_tdata),
  .ch0_s_axis_tvalid(ch0_s_axis_tvalid),
  .ch0_s_axis_tlast(ch0_s_axis_tlast),
  .ch0_s_axis_tready(ch0_s_axis_tready),
  
  .ch1_s_axis_tdata(ch1_s_axis_tdata),
  .ch1_s_axis_tvalid(ch1_s_axis_tvalid),
  .ch1_s_axis_tlast(ch1_s_axis_tlast),
  .ch1_s_axis_tready(ch1_s_axis_tready),
  
  .ch2_s_axis_tdata(ch2_s_axis_tdata),
  .ch2_s_axis_tvalid(ch2_s_axis_tvalid),
  .ch2_s_axis_tlast(ch2_s_axis_tlast),
  .ch2_s_axis_tready(ch2_s_axis_tready),
  
  .ch3_s_axis_tdata(ch3_s_axis_tdata),
  .ch3_s_axis_tvalid(ch3_s_axis_tvalid),
  .ch3_s_axis_tlast(ch3_s_axis_tlast),
  .ch3_s_axis_tready(ch3_s_axis_tready),
  
  .ch4_s_axis_tdata(ch4_s_axis_tdata),
  .ch4_s_axis_tvalid(ch4_s_axis_tvalid),
  .ch4_s_axis_tlast(ch4_s_axis_tlast),
  .ch4_s_axis_tready(ch4_s_axis_tready),
  
  .ch5_s_axis_tdata(ch5_s_axis_tdata),
  .ch5_s_axis_tvalid(ch5_s_axis_tvalid),
  .ch5_s_axis_tlast(ch5_s_axis_tlast),
  .ch5_s_axis_tready(ch5_s_axis_tready),
  
  .ch6_s_axis_tdata(ch6_s_axis_tdata),
  .ch6_s_axis_tvalid(ch6_s_axis_tvalid),
  .ch6_s_axis_tlast(ch6_s_axis_tlast),
  .ch6_s_axis_tready(ch6_s_axis_tready),
  
  .ch7_s_axis_tdata(ch7_s_axis_tdata),
  .ch7_s_axis_tvalid(ch7_s_axis_tvalid),
  .ch7_s_axis_tlast(ch7_s_axis_tlast),
  .ch7_s_axis_tready(ch7_s_axis_tready)  
);

endmodule