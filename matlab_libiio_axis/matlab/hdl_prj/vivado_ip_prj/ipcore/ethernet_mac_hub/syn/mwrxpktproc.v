module mwrxpktproc # (
  parameter DATAWIDTH = 8,
  parameter ADDRWIDTH = 14,
  parameter UDPCRCBUFFERADDRWIDTH = 8
)(
//----- Input & Output
input                  dutclk,
input                  reset,
input                  rxclk,
input                  rxclk_en,
input                  rxrst,
//---- from rxmac
input  [DATAWIDTH-1:0] rxdata,
input                  rxdatavalid,
input                  rxeop,
input                  rxcrcok,
input                  rxcrcbad,

//---- to arbiter
input                  rxbuffer_rden,
output [DATAWIDTH-1:0] rxbuffer_data,
output                 rxbuffer_datavld,
output                 rxbuffer_eop,
output                 rxbuffer_empty,

//---- to tx arbiter
output reg       [7:0] numofpacket_rxcanhold
);

localparam RXBUFFERSIZE = 2**ADDRWIDTH;
localparam MAXPACKETLEN = 2048;
localparam MAXPACKETBUFFER = (RXBUFFERSIZE/MAXPACKETLEN)-1;

//---- internal signals
wire  [DATAWIDTH-1:0] dataout;
wire                  dataoutvld;
wire                  dataeopout;
wire    [DATAWIDTH:0] rxbuffer_data_int;
wire    [DATAWIDTH:0] fifo_datain;

wire     [ADDRWIDTH:0] wr_addr_bin_next;
wire     [ADDRWIDTH:0] rd_addr_bin_next;
reg [(ADDRWIDTH-12):0] wr_addr_bin_sync1;
reg [(ADDRWIDTH-12):0] wr_addr_bin;
reg [(ADDRWIDTH-12):0] rd_addr_bin;
reg                    wr_grthan_rd;
reg                    wr_grthan_rd_reg;
reg                    rd_grthan_wr;
reg                    rd_grthan_wr_reg;
reg [(ADDRWIDTH-12):0] wraddr_minusrd;
reg [(ADDRWIDTH-12):0] rdaddr_minuswr;
reg [(ADDRWIDTH-12):0] maxaddr_minusrd;
reg [(ADDRWIDTH-12):0] maxaddr_minuswr;
reg [(ADDRWIDTH-12):0] maxaddr_minuswrrd;
reg [(ADDRWIDTH-12):0] buffer_statusgray;
wire                   fifo_full;

//---- 
assign rxbuffer_data = rxbuffer_data_int[DATAWIDTH-1:0];
assign rxbuffer_eop  = rxbuffer_data_int[DATAWIDTH];
assign fifo_datain   = {dataeopout, dataout};

//---- CRC cehck, if CRC BAD ignore the packet else pass the packet to the next level
FILUDPCRC # (
  .BUFFERADDRWIDTH (UDPCRCBUFFERADDRWIDTH)
) MWUDPCRC (
  .clk (rxclk),
  .clk_en(rxclk_en),
  .reset(rxrst),
  
  .dataIn(rxdata),
  .datavldIn(rxdatavalid),
  .EOPIn(rxeop),
  .CRCOK(rxcrcok),
  .CRCBAD(rxcrcbad),
  
  .dataOut(dataout),
  .dataVldOut(dataoutvld),
  .EOPOut(dataeopout)
);

//---- Buffer to store packet data
MWAsyncFIFO # (
  .DATA_WIDTH (DATAWIDTH+1),
  .ADDR_WIDTH (ADDRWIDTH)
) u_RxFIFOBuffer (
  .data_in_clk (rxclk),
  .data_in     (fifo_datain),
  .data_in_vld (dataoutvld),
  .data_out_clk(dutclk),
  .data_rst    (reset),
  .data_out_en (rxbuffer_rden),
  .data_out    (rxbuffer_data_int),
  .data_out_vld(rxbuffer_datavld),
  .fifo_empty  (rxbuffer_empty),
  .fifo_almostfull (),
  .fifo_full (fifo_full),
  .wr_addr_bin_next1 (wr_addr_bin_next),
  .rd_addr_bin_next1 (rd_addr_bin_next)
);

//---- Create RX Buffer Information which required to the host to send further packets
always @ (posedge dutclk) begin
  //---- #1 two sync added
  if (reset) begin
    wr_addr_bin_sync1 <= 'd0;
    wr_addr_bin <= 'd0;
  end else begin
    wr_addr_bin_sync1 <= wr_addr_bin_next[ADDRWIDTH-1:11];
    wr_addr_bin <= wr_addr_bin_sync1;
  end
end

always @ (posedge dutclk) begin
  //---- #1
  if (reset)
    rd_addr_bin <= 'd0;
  else
    rd_addr_bin <= rd_addr_bin_next[ADDRWIDTH-1:11];
end

always @ (posedge dutclk) begin
  //---- #2
  if (reset)
    wr_grthan_rd <= 1'd0;
  else if (wr_addr_bin > rd_addr_bin)
    wr_grthan_rd <= 1'd1;
  else
    wr_grthan_rd <= 1'd0;

  //---- #3
  wr_grthan_rd_reg <= wr_grthan_rd;

  if (reset)
    rd_grthan_wr <= 1'd0;
  else if (rd_addr_bin > wr_addr_bin)
    rd_grthan_wr <= 1'd1;
  else
    rd_grthan_wr <= 1'd0;

  rd_grthan_wr_reg <= rd_grthan_wr;
  
end
always @ (posedge dutclk) begin
  //---- #2
  if (reset)
    wraddr_minusrd <= 'd0;
  else
    wraddr_minusrd <= wr_addr_bin - rd_addr_bin;
	
  //---- #3
  if (reset)
    maxaddr_minuswr <= 'd0;
  else
    maxaddr_minuswr <= MAXPACKETBUFFER - wraddr_minusrd;
  
  if (reset)
    rdaddr_minuswr <= 'd0;
  else
    rdaddr_minuswr <= rd_addr_bin - wr_addr_bin;
	
  //---- #3
  if (reset)
    maxaddr_minusrd <= 'd0;
  else
    maxaddr_minusrd <= (rdaddr_minuswr);
  
  //---- #3
  if (reset)
    maxaddr_minuswrrd <= 'd0;
  else
    maxaddr_minuswrrd <= MAXPACKETBUFFER - (rdaddr_minuswr);
  
  //---- #4
  if (reset)
    buffer_statusgray <= 'd0;
  else if (wr_grthan_rd_reg)
    buffer_statusgray <= maxaddr_minuswr;
  else if (rd_grthan_wr_reg)
    buffer_statusgray <= maxaddr_minusrd;
  else
    buffer_statusgray <= maxaddr_minuswrrd;  
end

always @ (posedge dutclk) begin
 //---- #5
 if (reset)
   numofpacket_rxcanhold <= 8'd0;
 else if (fifo_full)
   numofpacket_rxcanhold <= 8'd0;
 else
   numofpacket_rxcanhold <= buffer_statusgray;
end
endmodule
