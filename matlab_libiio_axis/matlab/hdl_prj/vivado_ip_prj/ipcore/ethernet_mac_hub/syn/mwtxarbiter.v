module mwtxarbiter # (
  parameter DSTPORT_0 = 8,
  parameter DSTPORT_1 = 8,
  parameter DSTPORT_2 = 8,
  parameter DSTPORT_3 = 8,
  parameter DSTPORT_4 = 8,
  parameter DSTPORT_5 = 8,
  parameter DSTPORT_6 = 8,
  parameter DSTPORT_7 = 8,
  parameter DATAWIDTH = 8
)(
input                  dutclk,
input                  reset,

output reg [DATAWIDTH-1:0] txbuffer_data,
output reg             txbuffer_datavld,
output reg             txbuffer_eop,
input                  txbuffer_afull,

input           [15:0] ch0_m_axis_srcport,
input           [15:0] ch1_m_axis_srcport,
input           [15:0] ch2_m_axis_srcport,
input           [15:0] ch3_m_axis_srcport,
input           [15:0] ch4_m_axis_srcport,
input           [15:0] ch5_m_axis_srcport,
input           [15:0] ch6_m_axis_srcport,
input           [15:0] ch7_m_axis_srcport,

input  [DATAWIDTH-1:0] ch0_s_axis_tdata,
input                  ch0_s_axis_tvalid,
input                  ch0_s_axis_tlast,
output reg             ch0_s_axis_tready,

input  [DATAWIDTH-1:0] ch1_s_axis_tdata,
input                  ch1_s_axis_tvalid,
input                  ch1_s_axis_tlast,
output reg             ch1_s_axis_tready,

input  [DATAWIDTH-1:0] ch2_s_axis_tdata,
input                  ch2_s_axis_tvalid,
input                  ch2_s_axis_tlast,
output reg             ch2_s_axis_tready,

input  [DATAWIDTH-1:0] ch3_s_axis_tdata,
input                  ch3_s_axis_tvalid,
input                  ch3_s_axis_tlast,
output reg             ch3_s_axis_tready,

input  [DATAWIDTH-1:0] ch4_s_axis_tdata,
input                  ch4_s_axis_tvalid,
input                  ch4_s_axis_tlast,
output reg             ch4_s_axis_tready,

input  [DATAWIDTH-1:0] ch5_s_axis_tdata,
input                  ch5_s_axis_tvalid,
input                  ch5_s_axis_tlast,
output reg             ch5_s_axis_tready,

input  [DATAWIDTH-1:0] ch6_s_axis_tdata,
input                  ch6_s_axis_tvalid,
input                  ch6_s_axis_tlast,
output reg             ch6_s_axis_tready,

input  [DATAWIDTH-1:0] ch7_s_axis_tdata,
input                  ch7_s_axis_tvalid,
input                  ch7_s_axis_tlast,
output reg             ch7_s_axis_tready

);

//----- Input & Output

//---- parameters
localparam TXSTATE_IDLE         = 4'd0,
           TXSTATE_CHKFRPORTVLD = 4'd1,
           TXSTATE_RDATAFRMCH0  = 4'd2,
           TXSTATE_RDATAFRMCH1  = 4'd3,
           TXSTATE_RDATAFRMCH2  = 4'd4,
           TXSTATE_RDATAFRMCH3  = 4'd5,
           TXSTATE_RDATAFRMCH4  = 4'd6,
           TXSTATE_RDATAFRMCH5  = 4'd7,
           TXSTATE_RDATAFRMCH6  = 4'd8,
           TXSTATE_RDATAFRMCH7  = 4'd9;

//---- internal signals
reg           [4:0] txarbiter_curstate;
reg           [4:0] txarbiter_curstate_reg;
reg          [31:0] txbuffer_portdata;
reg          [31:0] txbuffer_portdata_reg;
wire                portdata_vld;
reg                 wait_fr_4clks;
reg           [1:0] sendport_count;
reg          [15:0] ch0_m_axis_dstport = DSTPORT_0;
reg          [15:0] ch1_m_axis_dstport = DSTPORT_1;
reg          [15:0] ch2_m_axis_dstport = DSTPORT_2;
reg          [15:0] ch3_m_axis_dstport = DSTPORT_3;
reg          [15:0] ch4_m_axis_dstport = DSTPORT_4;
reg          [15:0] ch5_m_axis_dstport = DSTPORT_5;
reg          [15:0] ch6_m_axis_dstport = DSTPORT_6;
reg          [15:0] ch7_m_axis_dstport = DSTPORT_7;

//---- wait for 4 clock cycles to write the src and dst port numbers
assign portdata_vld = ((wait_fr_4clks) && (!txbuffer_afull));

always @ (posedge dutclk)
begin
  if (reset)
    wait_fr_4clks <= 1'd0;
  else if ((sendport_count == 'd3) && (!txbuffer_afull))
    wait_fr_4clks <= 1'd0;
  else if (((txarbiter_curstate != TXSTATE_CHKFRPORTVLD)) && (txarbiter_curstate_reg == TXSTATE_CHKFRPORTVLD))
    wait_fr_4clks <= 1'd1;
  else
    wait_fr_4clks <= wait_fr_4clks;

  if (reset)
    sendport_count <= 2'd0;
  else if ((sendport_count == 'd3) && (!txbuffer_afull))
    sendport_count <= 2'd0;
  else if (portdata_vld == 1'd1)
    sendport_count <= sendport_count + 2'd1;
  else
    sendport_count <= sendport_count;
end

always @ (*)
begin
  if (reset)
    txbuffer_portdata = 'd0;  
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH0)
    txbuffer_portdata = {ch0_m_axis_srcport, ch0_m_axis_dstport};
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH1)
    txbuffer_portdata = {ch1_m_axis_srcport, ch1_m_axis_dstport};
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH2)
    txbuffer_portdata = {ch2_m_axis_srcport, ch2_m_axis_dstport};
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH3)
    txbuffer_portdata = {ch3_m_axis_srcport, ch3_m_axis_dstport};
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH4)
    txbuffer_portdata = {ch4_m_axis_srcport, ch4_m_axis_dstport};
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH5)
    txbuffer_portdata = {ch5_m_axis_srcport, ch5_m_axis_dstport};
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH6)
    txbuffer_portdata = {ch6_m_axis_srcport, ch6_m_axis_dstport};
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH7)
    txbuffer_portdata = {ch7_m_axis_srcport, ch7_m_axis_dstport};
  else
    txbuffer_portdata = {ch0_m_axis_srcport, ch0_m_axis_dstport};
end

always @ (posedge dutclk)
begin
  if (txarbiter_curstate_reg == TXSTATE_CHKFRPORTVLD)
    txbuffer_portdata_reg <= txbuffer_portdata;
  else if (portdata_vld)
    txbuffer_portdata_reg <= {txbuffer_portdata_reg[23:0],txbuffer_portdata_reg[7:0]};
  else 
    txbuffer_portdata_reg <= txbuffer_portdata_reg;
end

//---- AXI Slave Stream generation
always @ (posedge dutclk)
begin
  if (portdata_vld)
    txbuffer_data <= txbuffer_portdata_reg[31:24];
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH0)
    txbuffer_data <= ch0_s_axis_tdata;
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH1)
    txbuffer_data <= ch1_s_axis_tdata;
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH2)
    txbuffer_data <= ch2_s_axis_tdata;
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH3)
    txbuffer_data <= ch3_s_axis_tdata;
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH4)
    txbuffer_data <= ch4_s_axis_tdata;
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH5)
    txbuffer_data <= ch5_s_axis_tdata;
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH6)
    txbuffer_data <= ch6_s_axis_tdata;
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH7)
    txbuffer_data <= ch7_s_axis_tdata;
  else
    txbuffer_data <= ch0_s_axis_tdata;
end

always @ (posedge dutclk)
begin
  if (portdata_vld)
    txbuffer_datavld <= 1'd1;
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH0)
    txbuffer_datavld <= (ch0_s_axis_tvalid && ch0_s_axis_tready);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH1)
    txbuffer_datavld <= (ch1_s_axis_tvalid && ch1_s_axis_tready);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH2)
    txbuffer_datavld <= (ch2_s_axis_tvalid && ch2_s_axis_tready);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH3)
    txbuffer_datavld <= (ch3_s_axis_tvalid && ch3_s_axis_tready);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH4)
    txbuffer_datavld <= (ch4_s_axis_tvalid && ch4_s_axis_tready);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH5)
    txbuffer_datavld <= (ch5_s_axis_tvalid && ch5_s_axis_tready);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH6)
    txbuffer_datavld <= (ch6_s_axis_tvalid && ch6_s_axis_tready);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH7)
    txbuffer_datavld <= (ch7_s_axis_tvalid && ch7_s_axis_tready);
  else
    txbuffer_datavld <= (ch0_s_axis_tvalid && ch0_s_axis_tready);
end

always @ (posedge dutclk)
begin
  if (txarbiter_curstate == TXSTATE_RDATAFRMCH0)
    txbuffer_eop <= (ch0_s_axis_tvalid && ch0_s_axis_tready && ch0_s_axis_tlast);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH1)
    txbuffer_eop <= (ch1_s_axis_tvalid && ch1_s_axis_tready && ch1_s_axis_tlast);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH2)
    txbuffer_eop <= (ch2_s_axis_tvalid && ch2_s_axis_tready && ch2_s_axis_tlast);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH3)
    txbuffer_eop <= (ch3_s_axis_tvalid && ch3_s_axis_tready && ch3_s_axis_tlast);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH4)
    txbuffer_eop <= (ch4_s_axis_tvalid && ch4_s_axis_tready && ch4_s_axis_tlast);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH5)
    txbuffer_eop <= (ch5_s_axis_tvalid && ch5_s_axis_tready && ch5_s_axis_tlast);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH6)
    txbuffer_eop <= (ch6_s_axis_tvalid && ch6_s_axis_tready && ch6_s_axis_tlast);
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH7)
    txbuffer_eop <= (ch7_s_axis_tvalid && ch7_s_axis_tready && ch7_s_axis_tlast);
  else
    txbuffer_eop <= (ch0_s_axis_tvalid && ch0_s_axis_tready && ch0_s_axis_tlast);
end

//---- drivng always 1 when the tvalid availabe for that channel, assuming that almost full can handle 1 packet data
always @ (posedge dutclk)
begin
  if (reset)
    ch0_s_axis_tready <= 1'd0;
  else if (txbuffer_afull || portdata_vld || (txarbiter_curstate_reg == TXSTATE_CHKFRPORTVLD))
    ch0_s_axis_tready <= 1'd0;  
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH0) begin
    if (ch0_s_axis_tready && ch0_s_axis_tvalid && ch0_s_axis_tlast)
      ch0_s_axis_tready <= 1'd0;
    else
      ch0_s_axis_tready <= 1'd1;
  end else
    ch0_s_axis_tready <= 1'd0;
end
always @ (posedge dutclk)
begin
  if (reset)
    ch1_s_axis_tready <= 1'd0;
  else if (txbuffer_afull || portdata_vld || (txarbiter_curstate_reg == TXSTATE_CHKFRPORTVLD))
    ch1_s_axis_tready <= 1'd0;  
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH1) begin
    if (ch1_s_axis_tready && ch1_s_axis_tvalid && ch1_s_axis_tlast)
      ch1_s_axis_tready <= 1'd0;
	else
	  ch1_s_axis_tready <= 1'd1;
  end else
    ch1_s_axis_tready <= 1'd0;
end
always @ (posedge dutclk)
begin
  if (reset)
    ch2_s_axis_tready <= 1'd0;
  else if (txbuffer_afull || portdata_vld || (txarbiter_curstate_reg == TXSTATE_CHKFRPORTVLD))
    ch2_s_axis_tready <= 1'd0;  
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH2) begin 
    if (ch2_s_axis_tready && ch2_s_axis_tvalid && ch2_s_axis_tlast)
	  ch2_s_axis_tready <= 1'd0;
	else
	  ch2_s_axis_tready <= 1'd1;
  end else
    ch2_s_axis_tready <= 1'd0;
end
always @ (posedge dutclk)
begin
  if (reset)
    ch3_s_axis_tready <= 1'd0;
  else if (txbuffer_afull || portdata_vld || (txarbiter_curstate_reg == TXSTATE_CHKFRPORTVLD))
    ch3_s_axis_tready <= 1'd0;  
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH3) begin
    if (ch3_s_axis_tready && ch3_s_axis_tvalid && ch3_s_axis_tlast)
	  ch3_s_axis_tready <= 1'd0;
	else
      ch3_s_axis_tready <= 1'd1;
  end else
    ch3_s_axis_tready <= 1'd0;
end
always @ (posedge dutclk)
begin
  if (reset)
    ch4_s_axis_tready <= 1'd0;
  else if (txbuffer_afull || portdata_vld || (txarbiter_curstate_reg == TXSTATE_CHKFRPORTVLD))
    ch4_s_axis_tready <= 1'd0;  
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH4) begin
    if (ch4_s_axis_tready && ch4_s_axis_tvalid && ch4_s_axis_tlast)
	  ch4_s_axis_tready <= 1'd0;
	else
	  ch4_s_axis_tready <= 1'd1;	
  end else
    ch4_s_axis_tready <= 1'd0;
end
always @ (posedge dutclk)
begin
  if (reset)
    ch5_s_axis_tready <= 1'd0;
  else if (txbuffer_afull || portdata_vld || (txarbiter_curstate_reg == TXSTATE_CHKFRPORTVLD))
    ch5_s_axis_tready <= 1'd0;  
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH5) begin
    if (ch5_s_axis_tready && ch5_s_axis_tvalid && ch5_s_axis_tlast)
	  ch5_s_axis_tready <= 1'd0;
	else
	  ch5_s_axis_tready <= 1'd1;
  end else
    ch5_s_axis_tready <= 1'd0;
end
always @ (posedge dutclk)
begin
  if (reset)
    ch6_s_axis_tready <= 1'd0;
  else if (txbuffer_afull || portdata_vld || (txarbiter_curstate_reg == TXSTATE_CHKFRPORTVLD))
    ch6_s_axis_tready <= 1'd0;  
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH6) begin
    if (ch6_s_axis_tready && ch6_s_axis_tvalid && ch6_s_axis_tlast)
      ch6_s_axis_tready <= 1'd0;
    else
	  ch6_s_axis_tready <= 1'd1;
  end else
    ch6_s_axis_tready <= 1'd0;
end
always @ (posedge dutclk)
begin
  if (reset)
    ch7_s_axis_tready <= 1'd0;
  else if (txbuffer_afull || portdata_vld || (txarbiter_curstate_reg == TXSTATE_CHKFRPORTVLD))
    ch7_s_axis_tready <= 1'd0;  
  else if (txarbiter_curstate == TXSTATE_RDATAFRMCH7) begin
    if (ch7_s_axis_tready && ch7_s_axis_tvalid && ch7_s_axis_tlast)
      ch7_s_axis_tready <= 1'd0;
	else
	  ch7_s_axis_tready <= 1'd1;
  end else
    ch7_s_axis_tready <= 1'd0;
end

//---- tx arbiter state reg
always @ (posedge dutclk)
begin
  if (reset)
    txarbiter_curstate_reg <= TXSTATE_IDLE;
  else
    txarbiter_curstate_reg <= txarbiter_curstate;
end

//---- tx arbiter  -- priority goes to CH0
always @ (posedge dutclk)
begin
  if (reset) begin
    txarbiter_curstate <= TXSTATE_IDLE;
  end else begin
    case (txarbiter_curstate)
	  TXSTATE_IDLE: begin
		if (!txbuffer_afull)
	      txarbiter_curstate <= TXSTATE_CHKFRPORTVLD;
		else
		  txarbiter_curstate <= TXSTATE_IDLE;
	  end
	  TXSTATE_CHKFRPORTVLD: begin
		if (ch0_s_axis_tvalid)
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH0;
		else if (ch1_s_axis_tvalid)
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH1;
		else if (ch2_s_axis_tvalid)
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH2;
		else if (ch3_s_axis_tvalid)
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH3;
		else if (ch4_s_axis_tvalid)
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH4;
		else if (ch5_s_axis_tvalid)
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH5;
		else if (ch6_s_axis_tvalid)
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH6;
		else if (ch7_s_axis_tvalid)
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH7;
		else
		  txarbiter_curstate <= TXSTATE_CHKFRPORTVLD;
	  end
	  TXSTATE_RDATAFRMCH0: begin
	    if ((ch0_s_axis_tvalid) && (ch0_s_axis_tlast) && ch0_s_axis_tready)
		  txarbiter_curstate <= TXSTATE_IDLE;
		else
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH0;
	  end
	  TXSTATE_RDATAFRMCH1: begin
	    if ((ch1_s_axis_tvalid) && (ch1_s_axis_tlast) && ch1_s_axis_tready)
		  txarbiter_curstate <= TXSTATE_IDLE;
		else
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH1;
	  end
	  TXSTATE_RDATAFRMCH2: begin
	    if ((ch2_s_axis_tvalid) && (ch2_s_axis_tlast) && ch2_s_axis_tready)
		  txarbiter_curstate <= TXSTATE_IDLE;
		else
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH2;
	  end
	  TXSTATE_RDATAFRMCH3: begin
	    if ((ch3_s_axis_tvalid) && (ch3_s_axis_tlast) && ch3_s_axis_tready)
		  txarbiter_curstate <= TXSTATE_IDLE;
		else
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH3;
	  end
	  TXSTATE_RDATAFRMCH4: begin
	    if ((ch4_s_axis_tvalid) && (ch4_s_axis_tlast) && ch4_s_axis_tready)
		  txarbiter_curstate <= TXSTATE_IDLE;
		else
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH4;
	  end
	  TXSTATE_RDATAFRMCH5: begin
	    if ((ch5_s_axis_tvalid) && (ch5_s_axis_tlast) && ch5_s_axis_tready)
		  txarbiter_curstate <= TXSTATE_IDLE;
		else
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH5;
	  end
	  TXSTATE_RDATAFRMCH6: begin
	    if ((ch6_s_axis_tvalid) && (ch6_s_axis_tlast) && ch6_s_axis_tready)
		  txarbiter_curstate <= TXSTATE_IDLE;
		else
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH6;
	  end
	  TXSTATE_RDATAFRMCH7: begin
	    if ((ch7_s_axis_tvalid) && (ch7_s_axis_tlast) && ch7_s_axis_tready)
		  txarbiter_curstate <= TXSTATE_IDLE;
		else
		  txarbiter_curstate <= TXSTATE_RDATAFRMCH7;
	  end
      default:
		txarbiter_curstate <= TXSTATE_IDLE;
	endcase
  end
end
endmodule