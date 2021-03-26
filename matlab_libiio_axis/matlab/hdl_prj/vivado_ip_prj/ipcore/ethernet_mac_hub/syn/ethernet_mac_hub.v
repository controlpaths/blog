module ethernet_mac_hub #
(
  parameter [47:0] MACADDR = 48'h000A3502218A,
  parameter IPADDR1 = 192,
  parameter IPADDR2 = 168,
  parameter IPADDR3 = 0,
  parameter IPADDR4 = 2,
  parameter NUM_AXIS_CHANNELS = 8,
  parameter UDP_DSTPORT_FORCH1 = 50101,
  parameter UDP_DSTPORT_FORCH2 = 50102,
  parameter UDP_DSTPORT_FORCH3 = 50103,
  parameter UDP_DSTPORT_FORCH4 = 50104,
  parameter UDP_DSTPORT_FORCH5 = 50105,
  parameter UDP_DSTPORT_FORCH6 = 50106,
  parameter UDP_DSTPORT_FORCH7 = 50107,
  parameter UDP_DSTPORT_FORCH8 = 50108
)(
input                  ref_clk,
input                  ref_reset,

input                  phy_rxclk,
input            [7:0] phy_rxd,
input                  phy_rxdv,
input                  phy_rxer,
input                  rxclk_en,

output                 phy_gtxclk,
output           [7:0] phy_txd,
output                 phy_txen,
output                 phy_txer,
input                  txclk_en,
input                  phy_col,
input                  phy_crs,

//---- ch0
output           [7:0] m0_axis_tdata,
output                 m0_axis_tvalid,
output                 m0_axis_tlast,
input                  m0_axis_tready,

input            [7:0] s0_axis_tdata,
input                  s0_axis_tvalid,
input                  s0_axis_tlast,
output                 s0_axis_tready,

//---- ch1
output           [7:0] m1_axis_tdata,
output                 m1_axis_tvalid,
output                 m1_axis_tlast,
input                  m1_axis_tready,

input            [7:0] s1_axis_tdata,
input                  s1_axis_tvalid,
input                  s1_axis_tlast,
output                 s1_axis_tready,
//---- ch2
output           [7:0] m2_axis_tdata,
output                 m2_axis_tvalid,
output                 m2_axis_tlast,
input                  m2_axis_tready,

input            [7:0] s2_axis_tdata,
input                  s2_axis_tvalid,
input                  s2_axis_tlast,
output                 s2_axis_tready,

//---- ch3
output           [7:0] m3_axis_tdata,
output                 m3_axis_tvalid,
output                 m3_axis_tlast,
input                  m3_axis_tready,

input            [7:0] s3_axis_tdata,
input                  s3_axis_tvalid,
input                  s3_axis_tlast,
output                 s3_axis_tready,
//---- ch4
output           [7:0] m4_axis_tdata,
output                 m4_axis_tvalid,
output                 m4_axis_tlast,
input                  m4_axis_tready,

input            [7:0] s4_axis_tdata,
input                  s4_axis_tvalid,
input                  s4_axis_tlast,
output                 s4_axis_tready,
//---- ch5
output           [7:0] m5_axis_tdata,
output                 m5_axis_tvalid,
output                 m5_axis_tlast,
input                  m5_axis_tready,

input            [7:0] s5_axis_tdata,
input                  s5_axis_tvalid,
input                  s5_axis_tlast,
output                 s5_axis_tready,
//---- ch6
output           [7:0] m6_axis_tdata,
output                 m6_axis_tvalid,
output                 m6_axis_tlast,
input                  m6_axis_tready,

input            [7:0] s6_axis_tdata,
input                  s6_axis_tvalid,
input                  s6_axis_tlast,
output                 s6_axis_tready,
//---- ch7
output           [7:0] m7_axis_tdata,
output                 m7_axis_tvalid,
output                 m7_axis_tlast,
input                  m7_axis_tready,

input            [7:0] s7_axis_tdata,
input                  s7_axis_tvalid,
input                  s7_axis_tlast,
output                 s7_axis_tready,

input                  axis_aclk,
output reg             axis_aresetn
);

//---- 
localparam DATAWIDTH = 8;

//---- internal signals
wire                   rxclk;
wire                   txclk;
wire                   phy_txclk;
wire                   dutrst;


assign phy_txclk = ref_clk;
assign phy_gtxclk = ref_clk;

always @ (posedge axis_aclk)
  axis_aresetn <= !dutrst;

mwmacaxis_top # (
  .MWMACADDR1 (MACADDR[47:40]),
  .MWMACADDR2 (MACADDR[39:32]),
  .MWMACADDR3 (MACADDR[31:24]),
  .MWMACADDR4 (MACADDR[23:16]),
  .MWMACADDR5 (MACADDR[15:8]),
  .MWMACADDR6 (MACADDR[7:0]),
  .MWIPADDR1 (IPADDR1),
  .MWIPADDR2 (IPADDR2),
  .MWIPADDR3 (IPADDR3),
  .MWIPADDR4 (IPADDR4),
  .NUM_AXIS_CHANNELS(NUM_AXIS_CHANNELS),
  .DSTPORT_0 (UDP_DSTPORT_FORCH1),
  .DSTPORT_1 (UDP_DSTPORT_FORCH2),
  .DSTPORT_2 (UDP_DSTPORT_FORCH3),
  .DSTPORT_3 (UDP_DSTPORT_FORCH4),
  .DSTPORT_4 (UDP_DSTPORT_FORCH5),
  .DSTPORT_5 (UDP_DSTPORT_FORCH6),
  .DSTPORT_6 (UDP_DSTPORT_FORCH7),
  .DSTPORT_7 (UDP_DSTPORT_FORCH8),
  .DATAWIDTH (DATAWIDTH)
) u_mwmacaxis_top (
  .rxclk(phy_rxclk),
  .rxclk_en(rxclk_en),

  .txclk(phy_txclk),
  .txclk_en(txclk_en),
  
  .reset(ref_reset),
  
  .gmii_rxd(phy_rxd),
  .gmii_rx_dv(phy_rxdv),
  .gmii_rx_er(phy_rxer),
  .gmii_col(phy_col),
  .gmii_crs(phy_crs),
  
  .gmii_txd(phy_txd),
  .gmii_tx_en(phy_txen),
  .gmii_tx_er(phy_txer),
  
  .dutclk(axis_aclk),
  .dutrst(dutrst),
  
  .ch0_m_axis_tdata(m0_axis_tdata),
  .ch0_m_axis_tvalid(m0_axis_tvalid),
  .ch0_m_axis_tlast(m0_axis_tlast),
  .ch0_m_axis_tready(m0_axis_tready),
  
  .ch0_s_axis_tdata(s0_axis_tdata),
  .ch0_s_axis_tvalid(s0_axis_tvalid),
  .ch0_s_axis_tlast(s0_axis_tlast),
  .ch0_s_axis_tready(s0_axis_tready),
  
  .ch1_m_axis_tdata(m1_axis_tdata),
  .ch1_m_axis_tvalid(m1_axis_tvalid),
  .ch1_m_axis_tlast(m1_axis_tlast),
  .ch1_m_axis_tready(m1_axis_tready),
  .ch1_s_axis_tdata(s1_axis_tdata),
  .ch1_s_axis_tvalid(s1_axis_tvalid),
  .ch1_s_axis_tlast(s1_axis_tlast),
  .ch1_s_axis_tready(s1_axis_tready),
  
  .ch2_m_axis_tdata(m2_axis_tdata),
  .ch2_m_axis_tvalid(m2_axis_tvalid),
  .ch2_m_axis_tlast(m2_axis_tlast),
  .ch2_m_axis_tready(m2_axis_tready),
  .ch2_s_axis_tdata(s2_axis_tdata),
  .ch2_s_axis_tvalid(s2_axis_tvalid),
  .ch2_s_axis_tlast(s2_axis_tlast),
  .ch2_s_axis_tready(s2_axis_tready),
  
  .ch3_m_axis_tdata(m3_axis_tdata),
  .ch3_m_axis_tvalid(m3_axis_tvalid),
  .ch3_m_axis_tlast(m3_axis_tlast),
  .ch3_m_axis_tready(m3_axis_tready),
  .ch3_s_axis_tdata(s3_axis_tdata),
  .ch3_s_axis_tvalid(s3_axis_tvalid),
  .ch3_s_axis_tlast(s3_axis_tlast),
  .ch3_s_axis_tready(s3_axis_tready),
  
  .ch4_m_axis_tdata(m4_axis_tdata),
  .ch4_m_axis_tvalid(m4_axis_tvalid),
  .ch4_m_axis_tlast(m4_axis_tlast),
  .ch4_m_axis_tready(m4_axis_tready),
  .ch4_s_axis_tdata(s4_axis_tdata),
  .ch4_s_axis_tvalid(s4_axis_tvalid),
  .ch4_s_axis_tlast(s4_axis_tlast),
  .ch4_s_axis_tready(s4_axis_tready),
  
  .ch5_m_axis_tdata(m5_axis_tdata),
  .ch5_m_axis_tvalid(m5_axis_tvalid),
  .ch5_m_axis_tlast(m5_axis_tlast),
  .ch5_m_axis_tready(m5_axis_tready),
  .ch5_s_axis_tdata(s5_axis_tdata),
  .ch5_s_axis_tvalid(s5_axis_tvalid),
  .ch5_s_axis_tlast(s5_axis_tlast),
  .ch5_s_axis_tready(s5_axis_tready),
  
  .ch6_m_axis_tdata(m6_axis_tdata),
  .ch6_m_axis_tvalid(m6_axis_tvalid),
  .ch6_m_axis_tlast(m6_axis_tlast),
  .ch6_m_axis_tready(m6_axis_tready),
  .ch6_s_axis_tdata(s6_axis_tdata),
  .ch6_s_axis_tvalid(s6_axis_tvalid),
  .ch6_s_axis_tlast(s6_axis_tlast),
  .ch6_s_axis_tready(s6_axis_tready),
  
  .ch7_m_axis_tdata(m7_axis_tdata),
  .ch7_m_axis_tvalid(m7_axis_tvalid),
  .ch7_m_axis_tlast(m7_axis_tlast),
  .ch7_m_axis_tready(m7_axis_tready),
  .ch7_s_axis_tdata(s7_axis_tdata),
  .ch7_s_axis_tvalid(s7_axis_tvalid),
  .ch7_s_axis_tlast(s7_axis_tlast),
  .ch7_s_axis_tready(s7_axis_tready)
);
endmodule