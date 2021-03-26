module mwpktproc # (
  parameter DATAWIDTH = 8,
  parameter ADDRWIDTH = 14,
  parameter UDPCRCBUFFERADDRWIDTH = 11
)(
//----- Input & Output
input                  dutclk,
input                  reset,

//---- from rxmac
input                  rxclk,
input                  rxclk_en,
input                  rxrst,

input  [DATAWIDTH-1:0] rxdata,
input                  rxdatavalid,
input                  rxeop,
input                  rxcrcok,
input                  rxcrcbad,

//---- to rx arbiter
input                  rxbuffer_rden,
output [DATAWIDTH-1:0] rxbuffer_data,
output                 rxbuffer_datavld,
output                 rxbuffer_eop,
output                 rxbuffer_empty,

//---- to txmac
input                  txclk,
input                  txrst,

input                  txdata_rden,
output [DATAWIDTH-1:0] txdata,
output                 txdatavalid,
output                 txeop,
output          [31:0] udpport_4,

//---- from tx arbiter
input  [DATAWIDTH-1:0] txbuffer_data,
input                  txbuffer_datavld,
input                  txbuffer_eop,
output                 txbuffer_afull,
output           [7:0] numofpacket_rxcanhold
);

//----
mwrxpktproc # (
  .DATAWIDTH (DATAWIDTH),
  .ADDRWIDTH (ADDRWIDTH),
  .UDPCRCBUFFERADDRWIDTH (UDPCRCBUFFERADDRWIDTH)
) MWRXPKTPROC (
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
  .numofpacket_rxcanhold(numofpacket_rxcanhold)
);

mwtxpktproc # (
  .DATAWIDTH (DATAWIDTH),
  .ADDRWIDTH (ADDRWIDTH)
) MWTXPKTPROC (
  .dutclk(dutclk),
  .reset(reset),

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
  .txbuffer_afull(txbuffer_afull)
);


endmodule