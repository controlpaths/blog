module mwtxpktproc # (
  parameter DATAWIDTH = 8,
  parameter ADDRWIDTH = 14
)(
//----- Input & Output
input                  dutclk,
input                  reset,
input                  txclk,
input                  txrst,

//---- to txmac
input                  txdata_rden,
output [DATAWIDTH-1:0] txdata,
output                 txdatavalid,
output                 txeop,
output reg      [31:0] udpport_4,

//---- from arbiter
input  [DATAWIDTH-1:0] txbuffer_data,
input                  txbuffer_datavld,
input                  txbuffer_eop,
output                 txbuffer_afull
);

//---- internal signals
wire  [DATAWIDTH-1:0] dataout;
wire                  dataoutvld;
wire                  dataeopout;
wire    [DATAWIDTH:0] txdata_int;
wire    [DATAWIDTH:0] fifo_datain;
wire                  txdatavalid_int;

reg                   txdata_rden_d1;
reg                   txdata_rden_re;
reg             [1:0] txbuffer_datavld_cnt;
reg                   txdata_rden_re_eop;

//----
assign txdata = txdata_int[DATAWIDTH-1:0];
assign txeop  = txdata_int[DATAWIDTH];
assign txdatavalid = txdata_rden_re? 1'd0: txdatavalid_int;
assign fifo_datain   = {txbuffer_eop, txbuffer_data};

//---- Buffer to store packet data
MWAsyncFIFO # (
  .DATA_WIDTH (DATAWIDTH+1),
  .ADDR_WIDTH (ADDRWIDTH)
) u_TxFIFOBuffer (
  .data_in_clk (dutclk),
  .data_in     (fifo_datain),
  .data_in_vld (txbuffer_datavld),
  .data_out_clk(txclk),
  .data_rst    (txrst),
  .data_out_en (txdata_rden),
  .data_out    (txdata_int),
  .data_out_vld(txdatavalid_int),
  .fifo_empty  (),
  .fifo_almostfull (txbuffer_afull),
  .fifo_full (),
  .wr_addr_bin_next1 (),
  .rd_addr_bin_next1 ()
);


//---- read the Buffer when UDPpacket builder is requesting
//---- read first 4 bytes and make them coresponding udp port registers
always @ (posedge txclk) begin
 if (txrst)
   txdata_rden_d1 <= 1'd0;
 else if ((txeop) && (txdatavalid_int))
   txdata_rden_d1 <= 1'd0;
 else
   txdata_rden_d1 <= txdata_rden;

 if (txrst)
   txdata_rden_re <= 1'd0;
 else if ((txbuffer_datavld_cnt == 2'd3) && (txdatavalid_int))
   txdata_rden_re <= 1'd0;
 else if ((txdata_rden_re_eop) && (txeop == 1'd0))
   txdata_rden_re <= 1'd0;
 else if ((txdata_rden == 1'd1) && ((txeop) && (txdatavalid_int)))
   txdata_rden_re <= 1'd1;
 else if ((txdata_rden == 1'd1) && (txdata_rden_d1 == 1'd0))
   txdata_rden_re <= 1'd1;
 else
   txdata_rden_re <= txdata_rden_re;

 if (txrst)
   txbuffer_datavld_cnt <= 2'd0;
 else if ((txbuffer_datavld_cnt == 2'd3) && (txdatavalid_int))
   txbuffer_datavld_cnt <= 2'd0;
 else if ((txdatavalid_int) && (txdata_rden_re))
   txbuffer_datavld_cnt <= txbuffer_datavld_cnt + 2'd1;
 else
   txbuffer_datavld_cnt <= txbuffer_datavld_cnt;

 //--- the ready of UDP pakcet builder may go toggle or LOW when the UDP PACKET Buffer is full
 //--- so rising edge need to be hold to low till the eop
 if (txrst)
   txdata_rden_re_eop <= 1'd0;
 else if ((txeop) && (txdatavalid_int))
   txdata_rden_re_eop <= 1'd0;
 else if ((txbuffer_datavld_cnt == 2'd3) && (txdatavalid_int))
   txdata_rden_re_eop <= 1'd1;
 else
   txdata_rden_re_eop <= txdata_rden_re_eop;
end

always @ (posedge txclk) begin
  if ((txdatavalid_int) && (txdata_rden_re))
    udpport_4 <= {udpport_4[23:0], txdata};
  else
    udpport_4 <= udpport_4;
end

endmodule
