module mwmacaxis_top # (
  parameter MWMACADDR1 = 16'h00,
  parameter MWMACADDR2 = 16'h0A,
  parameter MWMACADDR3 = 16'h35,
  parameter MWMACADDR4 = 16'h02,
  parameter MWMACADDR5 = 16'h21,
  parameter MWMACADDR6 = 16'h8A,
  parameter MWIPADDR1 = 192,
  parameter MWIPADDR2 = 168,
  parameter MWIPADDR3 = 0,
  parameter MWIPADDR4 = 2,
  parameter BUFFERADDRWIDTH = 12,
  parameter NUM_AXIS_CHANNELS = 8,
  parameter DSTPORT_0 = 50101,
  parameter DSTPORT_1 = 50102,
  parameter DSTPORT_2 = 50103,
  parameter DSTPORT_3 = 50104,
  parameter DSTPORT_4 = 50105,
  parameter DSTPORT_5 = 50106,
  parameter DSTPORT_6 = 50107,
  parameter DSTPORT_7 = 50108,
  parameter GETVERSION= 'h80,
  parameter FPGA_RST  = 'h81,
  parameter DUT_RST   = 'h82,
  parameter UDPCRCBUFFERADDRWIDTH = 11,
  parameter ADDRWIDTH   = 14,
  parameter DATAWIDTH = 8
)(
//----- Input & Output
input                  rxclk,
input                  rxclk_en,

input                  txclk,
input                  txclk_en,

input                  dutclk,
input                  reset,

input  [DATAWIDTH-1:0] gmii_rxd,
input                  gmii_rx_dv,
input                  gmii_rx_er,
input                  gmii_col,
input                  gmii_crs,

output [DATAWIDTH-1:0] gmii_txd,
output                 gmii_tx_en,
output                 gmii_tx_er,

output                 dutrst,
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



//---- internal signals
wire                   rxrst;
wire                   txrst;

wire   [DATAWIDTH-1:0] rxdata;
wire                   rxdatavalid;
wire                   rxeop;
wire                   rxcrcok;
wire                   rxcrcbad;

wire                   rxbuffer_rden;
wire   [DATAWIDTH-1:0] rxbuffer_data;
wire                   rxbuffer_datavld;
wire                   rxbuffer_eop;
wire                   rxbuffer_empty;
wire             [7:0] numofpacket_rxcanhold;

wire   [DATAWIDTH-1:0] txbuffer_data;
wire                   txbuffer_datavld;
wire                   txbuffer_eop;
wire                   txbuffer_afull;

wire                   txReady;
wire                   txdata_rden;
wire   [DATAWIDTH-1:0] txdata;
wire                   txdatavalid;
wire                   txeop;
wire   [DATAWIDTH-1:0] mac_txdata;
wire                   mac_txdatavalid;
wire                   mac_txeop;
wire [BUFFERADDRWIDTH:0] TxDataLength;
wire            [31:0] udpport_4;
wire            [31:0] mac_udpport_4;
wire             [7:0] udpsrcport1;
wire             [7:0] udpsrcport2;
wire             [7:0] udpdstport1;
wire             [7:0] udpdstport2;

wire                    statusReady;
wire    [DATAWIDTH-1:0] status;
wire                    statusVld;
wire                    statusEOP;
wire             [31:0] ver_udpport;

//----- Mapping source and destination ports
assign udpsrcport1 = mac_udpport_4[31:24];
assign udpsrcport2 = mac_udpport_4[23:16];
assign udpdstport1 = mac_udpport_4[15:8];
assign udpdstport2 = mac_udpport_4[7:0];


//---- MWMAC
MWMAC # (
  .MWMACADDR1 (MWMACADDR1),
  .MWMACADDR2 (MWMACADDR2),
  .MWMACADDR3 (MWMACADDR3),
  .MWMACADDR4 (MWMACADDR4),
  .MWMACADDR5 (MWMACADDR5),
  .MWMACADDR6 (MWMACADDR6),
  .MWIPADDR1 (MWIPADDR1),
  .MWIPADDR2 (MWIPADDR2),
  .MWIPADDR3 (MWIPADDR3),
  .MWIPADDR4 (MWIPADDR4),
  .BUFFERADDRWIDTH (BUFFERADDRWIDTH)
) DUT_MWMAC (
  .rxclk(rxclk),
  .rxclk_en(rxclk_en),
  .RxReset(rxrst),

  .txclk(txclk),
  .txclk_en(txclk_en),
  .TxReset(txrst),
  
  .gmii_rxd(gmii_rxd),
  .gmii_rx_dv(gmii_rx_dv),
  .gmii_rx_er(gmii_rx_er),
  .gmii_col(gmii_col),
  .gmii_crs(gmii_crs),
  
  .TxData(mac_txdata),
  .TxDataValid(mac_txdatavalid),
  .TxEOP(mac_txeop),
  .TxDataLength(TxDataLength),
  .udpsrcport1(udpsrcport1),
  .udpsrcport2(udpsrcport2),
  .udpdstport1(udpdstport1),
  .udpdstport2(udpdstport2),
  
  .gmii_txd(gmii_txd),
  .gmii_tx_en(gmii_tx_en),
  .gmii_tx_er(gmii_tx_er),

  .RxData(rxdata),
  .RxDataValid(rxdatavalid),
  .RxEOP(rxeop),
  .RxCRCOK(rxcrcok),
  .RxCRCBad(rxcrcbad),
  
  .TxReady(txReady)

);

//-----
MWUDPPKTBuilder # (
  .DATA_BUF_WIDTH (11),
  .DATA_PKTINFO_BUF_WIDTH (11),
  .STATUS_BUF_WIDTH (4),
  .STATUS_PKTINFO_BUF_WIDTH (2)
) U_MWUDPPKTBUILDER (
  .clk(txclk),
  .clk_en(txclk_en),
  .reset(txrst),
  
  .numofpacket_rxcanhold(numofpacket_rxcanhold),
  .dataIn(txdata),
  .dataVld(txdatavalid),
  .dataEOP(txeop),
  .dataPort(udpport_4),
  .statusIn(status),
  .statusVld(statusVld),
  .statusEOP(statusEOP),
  .statusPort(ver_udpport),
  .dataReady(txdata_rden),
  .statusReady(statusReady),
  .txReady(txReady),
  .txRequest(mac_txeop),
  .pktData(mac_txdata),
  .pktDataVld(mac_txdatavalid),
  .pktPort(mac_udpport_4),
  .pktLen(TxDataLength)
);

//-----
mwpktproc # (
  .DATAWIDTH (DATAWIDTH),
  .ADDRWIDTH (ADDRWIDTH),
  .UDPCRCBUFFERADDRWIDTH (UDPCRCBUFFERADDRWIDTH)
) MWPKTPROC (
  .dutclk(dutclk),
  .reset(reset),

  .rxclk(rxclk),
  .rxclk_en(rxclk_en),
  .rxrst(rxrst),
  
  .rxdata(rxdata),
  .rxdatavalid(rxdatavalid),
  .rxeop(rxeop),
  .rxcrcok(rxcrcok),
  .rxcrcbad(rxcrcbad),
  
  .rxbuffer_rden(rxbuffer_rden),
  .rxbuffer_data(rxbuffer_data),
  .rxbuffer_datavld(rxbuffer_datavld),
  .rxbuffer_eop(rxbuffer_eop),
  .rxbuffer_empty(rxbuffer_empty),
  
  .txclk(txclk),
  .txrst(txrst),
  
  .txdata_rden(txdata_rden),
  .txdata(txdata),
  .txdatavalid(txdatavalid),
  .txeop(txeop),
  .udpport_4(udpport_4),
  
  .txbuffer_data(txbuffer_data),
  .txbuffer_datavld(txbuffer_datavld),
  .txbuffer_eop(txbuffer_eop),
  .txbuffer_afull(txbuffer_afull),
  .numofpacket_rxcanhold(numofpacket_rxcanhold)
);

mwarbiter_axis # (
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
) MWARBITER_AXIS (
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

  .txbuffer_data(txbuffer_data),
  .txbuffer_datavld(txbuffer_datavld),
  .txbuffer_eop(txbuffer_eop),
  .txbuffer_afull(txbuffer_afull),

  .statusReady(statusReady),
  .status(status),
  .statusVld(statusVld),
  .statusEOP(statusEOP),
  .ver_udpport(ver_udpport),

  .ch0_m_axis_tdata(ch0_m_axis_tdata),
  .ch0_m_axis_tvalid(ch0_m_axis_tvalid),
  .ch0_m_axis_tlast(ch0_m_axis_tlast),
  .ch0_m_axis_tready(ch0_m_axis_tready),
  .ch0_s_axis_tdata(ch0_s_axis_tdata),
  .ch0_s_axis_tvalid(ch0_s_axis_tvalid),
  .ch0_s_axis_tlast(ch0_s_axis_tlast),
  .ch0_s_axis_tready(ch0_s_axis_tready),
  
  .ch1_m_axis_tdata(ch1_m_axis_tdata),
  .ch1_m_axis_tvalid(ch1_m_axis_tvalid),
  .ch1_m_axis_tlast(ch1_m_axis_tlast),
  .ch1_m_axis_tready(ch1_m_axis_tready),
  .ch1_s_axis_tdata(ch1_s_axis_tdata),
  .ch1_s_axis_tvalid(ch1_s_axis_tvalid),
  .ch1_s_axis_tlast(ch1_s_axis_tlast),
  .ch1_s_axis_tready(ch1_s_axis_tready),
  
  .ch2_m_axis_tdata(ch2_m_axis_tdata),
  .ch2_m_axis_tvalid(ch2_m_axis_tvalid),
  .ch2_m_axis_tlast(ch2_m_axis_tlast),
  .ch2_m_axis_tready(ch2_m_axis_tready),
  .ch2_s_axis_tdata(ch2_s_axis_tdata),
  .ch2_s_axis_tvalid(ch2_s_axis_tvalid),
  .ch2_s_axis_tlast(ch2_s_axis_tlast),
  .ch2_s_axis_tready(ch2_s_axis_tready),
  
  .ch3_m_axis_tdata(ch3_m_axis_tdata),
  .ch3_m_axis_tvalid(ch3_m_axis_tvalid),
  .ch3_m_axis_tlast(ch3_m_axis_tlast),
  .ch3_m_axis_tready(ch3_m_axis_tready),
  .ch3_s_axis_tdata(ch3_s_axis_tdata),
  .ch3_s_axis_tvalid(ch3_s_axis_tvalid),
  .ch3_s_axis_tlast(ch3_s_axis_tlast),
  .ch3_s_axis_tready(ch3_s_axis_tready),
  
  .ch4_m_axis_tdata(ch4_m_axis_tdata),
  .ch4_m_axis_tvalid(ch4_m_axis_tvalid),
  .ch4_m_axis_tlast(ch4_m_axis_tlast),
  .ch4_m_axis_tready(ch4_m_axis_tready),
  .ch4_s_axis_tdata(ch4_s_axis_tdata),
  .ch4_s_axis_tvalid(ch4_s_axis_tvalid),
  .ch4_s_axis_tlast(ch4_s_axis_tlast),
  .ch4_s_axis_tready(ch4_s_axis_tready),
  
  .ch5_m_axis_tdata(ch5_m_axis_tdata),
  .ch5_m_axis_tvalid(ch5_m_axis_tvalid),
  .ch5_m_axis_tlast(ch5_m_axis_tlast),
  .ch5_m_axis_tready(ch5_m_axis_tready),
  .ch5_s_axis_tdata(ch5_s_axis_tdata),
  .ch5_s_axis_tvalid(ch5_s_axis_tvalid),
  .ch5_s_axis_tlast(ch5_s_axis_tlast),
  .ch5_s_axis_tready(ch5_s_axis_tready),
  
  .ch6_m_axis_tdata(ch6_m_axis_tdata),
  .ch6_m_axis_tvalid(ch6_m_axis_tvalid),
  .ch6_m_axis_tlast(ch6_m_axis_tlast),
  .ch6_m_axis_tready(ch6_m_axis_tready),
  .ch6_s_axis_tdata(ch6_s_axis_tdata),
  .ch6_s_axis_tvalid(ch6_s_axis_tvalid),
  .ch6_s_axis_tlast(ch6_s_axis_tlast),
  .ch6_s_axis_tready(ch6_s_axis_tready),
  
  .ch7_m_axis_tdata(ch7_m_axis_tdata),
  .ch7_m_axis_tvalid(ch7_m_axis_tvalid),
  .ch7_m_axis_tlast(ch7_m_axis_tlast),
  .ch7_m_axis_tready(ch7_m_axis_tready),
  .ch7_s_axis_tdata(ch7_s_axis_tdata),
  .ch7_s_axis_tvalid(ch7_s_axis_tvalid),
  .ch7_s_axis_tlast(ch7_s_axis_tlast),
  .ch7_s_axis_tready(ch7_s_axis_tready)
);

endmodule
