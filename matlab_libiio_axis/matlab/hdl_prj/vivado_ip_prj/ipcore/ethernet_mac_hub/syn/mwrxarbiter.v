module mwrxarbiter # (
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
  parameter VERSION   = 'h0100,
  parameter DATAWIDTH = 8
)(
//----- Input & Output
input                  rxclk,
input                  txclk,
input                  dutclk,
input                  reset,

output                 rxbuffer_rden,
input  [DATAWIDTH-1:0] rxbuffer_data,
input                  rxbuffer_datavld,
input                  rxbuffer_eop,
input                  rxbuffer_empty,

input                  statusReady,
output reg [DATAWIDTH-1:0] status,
output reg             statusVld,
output reg             statusEOP,
output reg      [31:0] ver_udpport,

output reg             rxrst,
output reg             txrst,
output reg             dutrst,

output reg      [15:0] ch0_m_axis_srcport,
output reg      [15:0] ch1_m_axis_srcport,
output reg      [15:0] ch2_m_axis_srcport,
output reg      [15:0] ch3_m_axis_srcport,
output reg      [15:0] ch4_m_axis_srcport,
output reg      [15:0] ch5_m_axis_srcport,
output reg      [15:0] ch6_m_axis_srcport,
output reg      [15:0] ch7_m_axis_srcport,

output [DATAWIDTH-1:0] ch0_m_axis_tdata,
output                 ch0_m_axis_tvalid,
output                 ch0_m_axis_tlast,
input                  ch0_m_axis_tready,

output [DATAWIDTH-1:0] ch1_m_axis_tdata,
output                 ch1_m_axis_tvalid,
output                 ch1_m_axis_tlast,
input                  ch1_m_axis_tready,

output [DATAWIDTH-1:0] ch2_m_axis_tdata,
output                 ch2_m_axis_tvalid,
output                 ch2_m_axis_tlast,
input                  ch2_m_axis_tready,

output [DATAWIDTH-1:0] ch3_m_axis_tdata,
output                 ch3_m_axis_tvalid,
output                 ch3_m_axis_tlast,
input                  ch3_m_axis_tready,

output [DATAWIDTH-1:0] ch4_m_axis_tdata,
output                 ch4_m_axis_tvalid,
output                 ch4_m_axis_tlast,
input                  ch4_m_axis_tready,

output [DATAWIDTH-1:0] ch5_m_axis_tdata,
output                 ch5_m_axis_tvalid,
output                 ch5_m_axis_tlast,
input                  ch5_m_axis_tready,

output [DATAWIDTH-1:0] ch6_m_axis_tdata,
output                 ch6_m_axis_tvalid,
output                 ch6_m_axis_tlast,
input                  ch6_m_axis_tready,

output [DATAWIDTH-1:0] ch7_m_axis_tdata,
output                 ch7_m_axis_tvalid,
output                 ch7_m_axis_tlast,
input                  ch7_m_axis_tready
);

//---- parameters
localparam RXSTATE_IDLE       = 4'd0,
           RXSTATE_RDSRCPORT1 = 4'd1,
           RXSTATE_RDSRCPORT2 = 4'd2,
           RXSTATE_RDDSTPORT1 = 4'd3,
           RXSTATE_RDDSTPORT2 = 4'd4,
           RXSTATE_RDFIRSTBYTE= 4'd5,
           RXSTATE_CHKFRPORT  = 4'd6,
           RXSTATE_RDATAFRCH0 = 4'd7,
           RXSTATE_RDATAFRCH1 = 4'd8,
           RXSTATE_RDATAFRCH2 = 4'd9,
           RXSTATE_RDATAFRCH3 = 4'd10,
           RXSTATE_RDATAFRCH4 = 4'd11,
           RXSTATE_RDATAFRCH5 = 4'd12,
           RXSTATE_RDATAFRCH6 = 4'd13,
           RXSTATE_RDATAFRCH7 = 4'd14,
		   RXSTATE_WAITFREOP  = 4'd15;

//----- getversion response packet state machine
localparam VER_IDLE     = 3'd0,
           VER_WAIT_RDY = 3'd1,
           VER_CMMND    = 3'd2,
           VER_LEN      = 3'd3,
           VER_BYTE1    = 3'd4,
           VER_BYTE2    = 3'd5,
		   VER_PORTERROR= 3'd6;
		   
//---- internal signals
reg  [4:0] rxarbiter_curstate;
reg        rxbuffer_rden_int;
reg [15:0] chver_m_axis_srcport;
reg [15:0] chver_m_axis_dstport;
reg [15:0] chx_m_axis_srcport;
reg        chx_m_axis_srcportvld;
reg [15:0] dst_port;
reg        ch0_m_axis_tvalid_int;
reg        ch1_m_axis_tvalid_int;
reg        ch2_m_axis_tvalid_int;
reg        ch3_m_axis_tvalid_int;
reg        ch4_m_axis_tvalid_int;
reg        ch5_m_axis_tvalid_int;
reg        ch6_m_axis_tvalid_int;
reg        ch7_m_axis_tvalid_int;
reg  [3:0] get_ver_reg;
reg [15:0] fpga_rst_reg;
reg [15:0] dut_rst_reg;
reg        rxrst_int;
reg        txrst_int;

//----- getversion response packet signals
reg              [2:0] verstatus_curstate;
reg                    get_ver_reg1;
reg                    get_ver_reg2;
reg                    get_ver_reg3;
reg                    get_ver_posedge;
reg             [31:0] ver_udpport_dutclk;
reg             [31:0] ver_udpport_sync;
//---- send back the destination port value if doesn't match with any of the application
reg       sendporterrorinfo;
reg [3:0] sendporterrorinfo_vld;
reg       porterr_reg1;
reg       porterr_reg2;
reg       porterr_reg3;
reg       porterr_posedge;

//----
assign rxbuffer_rden = (  (((rxarbiter_curstate == RXSTATE_RDATAFRCH0) && ch0_m_axis_tready)
                        || ((rxarbiter_curstate == RXSTATE_RDATAFRCH1) && ch1_m_axis_tready)
						|| ((rxarbiter_curstate == RXSTATE_RDATAFRCH2) && ch2_m_axis_tready)
						|| ((rxarbiter_curstate == RXSTATE_RDATAFRCH3) && ch3_m_axis_tready)
						|| ((rxarbiter_curstate == RXSTATE_RDATAFRCH4) && ch4_m_axis_tready)
						|| ((rxarbiter_curstate == RXSTATE_RDATAFRCH5) && ch5_m_axis_tready)
						|| ((rxarbiter_curstate == RXSTATE_RDATAFRCH6) && ch6_m_axis_tready)
						|| ((rxarbiter_curstate == RXSTATE_RDATAFRCH7) && ch7_m_axis_tready)
						|| ((rxarbiter_curstate == RXSTATE_IDLE) || (rxarbiter_curstate == RXSTATE_RDSRCPORT1))
						|| ((rxarbiter_curstate == RXSTATE_RDSRCPORT2) || (rxarbiter_curstate == RXSTATE_RDDSTPORT1))
						|| ((rxarbiter_curstate == RXSTATE_RDDSTPORT2) || (rxarbiter_curstate == RXSTATE_RDFIRSTBYTE) || (rxarbiter_curstate == RXSTATE_WAITFREOP)))
						&& (rxbuffer_rden_int && (!rxbuffer_empty)));
//----
assign ch0_m_axis_tdata = rxbuffer_data; assign ch4_m_axis_tdata = rxbuffer_data;
assign ch1_m_axis_tdata = rxbuffer_data; assign ch5_m_axis_tdata = rxbuffer_data;
assign ch2_m_axis_tdata = rxbuffer_data; assign ch6_m_axis_tdata = rxbuffer_data;
assign ch3_m_axis_tdata = rxbuffer_data; assign ch7_m_axis_tdata = rxbuffer_data;

assign ch0_m_axis_tlast = rxbuffer_eop; assign ch4_m_axis_tlast = rxbuffer_eop;
assign ch1_m_axis_tlast = rxbuffer_eop; assign ch5_m_axis_tlast = rxbuffer_eop;
assign ch2_m_axis_tlast = rxbuffer_eop; assign ch6_m_axis_tlast = rxbuffer_eop;
assign ch3_m_axis_tlast = rxbuffer_eop; assign ch7_m_axis_tlast = rxbuffer_eop;

//----
assign ch0_m_axis_tvalid = (((rxarbiter_curstate == RXSTATE_RDATAFRCH0)) && ((rxbuffer_datavld || ch0_m_axis_tvalid_int)));
assign ch1_m_axis_tvalid = (((rxarbiter_curstate == RXSTATE_RDATAFRCH1)) && ((rxbuffer_datavld || ch1_m_axis_tvalid_int)));
assign ch2_m_axis_tvalid = (((rxarbiter_curstate == RXSTATE_RDATAFRCH2)) && ((rxbuffer_datavld || ch2_m_axis_tvalid_int)));
assign ch3_m_axis_tvalid = (((rxarbiter_curstate == RXSTATE_RDATAFRCH3)) && ((rxbuffer_datavld || ch3_m_axis_tvalid_int)));
assign ch4_m_axis_tvalid = (((rxarbiter_curstate == RXSTATE_RDATAFRCH4)) && ((rxbuffer_datavld || ch4_m_axis_tvalid_int)));
assign ch5_m_axis_tvalid = (((rxarbiter_curstate == RXSTATE_RDATAFRCH5)) && ((rxbuffer_datavld || ch5_m_axis_tvalid_int)));
assign ch6_m_axis_tvalid = (((rxarbiter_curstate == RXSTATE_RDATAFRCH6)) && ((rxbuffer_datavld || ch6_m_axis_tvalid_int)));
assign ch7_m_axis_tvalid = (((rxarbiter_curstate == RXSTATE_RDATAFRCH7)) && ((rxbuffer_datavld || ch7_m_axis_tvalid_int)));


//---- source port
always @ (posedge dutclk)
begin
  if (reset) begin
    chx_m_axis_srcport    <= 16'd0;
	chx_m_axis_srcportvld <= 1'd0;
  end else if ((rxarbiter_curstate == RXSTATE_IDLE) && (rxbuffer_datavld))begin
    chx_m_axis_srcport    <= {chx_m_axis_srcport[7:0], rxbuffer_data};
	chx_m_axis_srcportvld <= 1'd0;
  end else if ((rxarbiter_curstate == RXSTATE_RDSRCPORT1) && (rxbuffer_datavld))begin
    chx_m_axis_srcport    <= {chx_m_axis_srcport[7:0], rxbuffer_data};
	chx_m_axis_srcportvld <= 1'd0;
  end else if ((rxarbiter_curstate == RXSTATE_RDSRCPORT2) && (rxbuffer_datavld))begin
    chx_m_axis_srcport    <= {chx_m_axis_srcport[7:0], rxbuffer_data};
	chx_m_axis_srcportvld <= 1'd1;
  end else begin
    chx_m_axis_srcport    <= chx_m_axis_srcport;
	chx_m_axis_srcportvld <= chx_m_axis_srcportvld;
  end
end

always @ (posedge dutclk)
begin
  if (rxarbiter_curstate == RXSTATE_RDATAFRCH0)
    ch0_m_axis_srcport <=  chx_m_axis_srcport;
  else
    ch0_m_axis_srcport <= ch0_m_axis_srcport;
  if (rxarbiter_curstate == RXSTATE_RDATAFRCH1)
    ch1_m_axis_srcport <=  chx_m_axis_srcport;
  else
    ch1_m_axis_srcport <= ch1_m_axis_srcport;
  if (rxarbiter_curstate == RXSTATE_RDATAFRCH2)
    ch2_m_axis_srcport <=  chx_m_axis_srcport;
  else
    ch2_m_axis_srcport <= ch2_m_axis_srcport;
  if (rxarbiter_curstate == RXSTATE_RDATAFRCH2)
    ch2_m_axis_srcport <=  chx_m_axis_srcport;
  else
    ch2_m_axis_srcport <= ch2_m_axis_srcport;
  if (rxarbiter_curstate == RXSTATE_RDATAFRCH3)
    ch3_m_axis_srcport <=  chx_m_axis_srcport;
  else
    ch3_m_axis_srcport <= ch3_m_axis_srcport;
  if (rxarbiter_curstate == RXSTATE_RDATAFRCH4)
    ch4_m_axis_srcport <=  chx_m_axis_srcport;
  else
    ch4_m_axis_srcport <= ch4_m_axis_srcport;
  if (rxarbiter_curstate == RXSTATE_RDATAFRCH5)
    ch5_m_axis_srcport <=  chx_m_axis_srcport;
  else
    ch5_m_axis_srcport <= ch5_m_axis_srcport;
  if (rxarbiter_curstate == RXSTATE_RDATAFRCH6)
    ch6_m_axis_srcport <=  chx_m_axis_srcport;
  else
    ch6_m_axis_srcport <= ch6_m_axis_srcport;
  if (rxarbiter_curstate == RXSTATE_RDATAFRCH7)
    ch7_m_axis_srcport <=  chx_m_axis_srcport;
  else
    ch7_m_axis_srcport <= ch7_m_axis_srcport;
  if (rxarbiter_curstate == RXSTATE_WAITFREOP)
    chver_m_axis_srcport <=  chx_m_axis_srcport;
  else
    chver_m_axis_srcport <= chver_m_axis_srcport;
  
  if (rxarbiter_curstate == RXSTATE_WAITFREOP)
    chver_m_axis_dstport <=  dst_port;
  else
    chver_m_axis_dstport <= chver_m_axis_dstport;
end

 
//---- destination port
always @ (posedge dutclk)
begin
  if (reset)
    dst_port <= 16'd0;
  else if (((rxarbiter_curstate == RXSTATE_RDDSTPORT1) || (rxarbiter_curstate == RXSTATE_RDDSTPORT2)) && rxbuffer_datavld)
    dst_port <= {dst_port[7:0], rxbuffer_data};
  else
    dst_port <= dst_port;
end


//---- AXI Master Stream tvalid generation
//---- CH0
always @ (posedge dutclk)
begin
  if (reset)
    ch0_m_axis_tvalid_int <= 1'd0;
  else if ((ch0_m_axis_tready) && (rxarbiter_curstate == RXSTATE_RDATAFRCH0))
    ch0_m_axis_tvalid_int <= 1'd0;
  else if (rxbuffer_datavld)
    ch0_m_axis_tvalid_int <= 1'd1;
  else
    ch0_m_axis_tvalid_int <= ch0_m_axis_tvalid_int;
end
//---- CH1
always @ (posedge dutclk)
begin
  if (reset)
    ch1_m_axis_tvalid_int <= 1'd0;
  else if ((ch1_m_axis_tready) && (rxarbiter_curstate == RXSTATE_RDATAFRCH1))
    ch1_m_axis_tvalid_int <= 1'd0;
  else if (rxbuffer_datavld)
    ch1_m_axis_tvalid_int <= 1'd1;
  else
    ch1_m_axis_tvalid_int <= ch1_m_axis_tvalid_int;
end
//---- CH2
always @ (posedge dutclk)
begin
  if (reset)
    ch2_m_axis_tvalid_int <= 1'd0;
  else if ((ch2_m_axis_tready) && (rxarbiter_curstate == RXSTATE_RDATAFRCH2))
    ch2_m_axis_tvalid_int <= 1'd0;
  else if (rxbuffer_datavld)
    ch2_m_axis_tvalid_int <= 1'd1;
  else
    ch2_m_axis_tvalid_int <= ch2_m_axis_tvalid_int;
end
//---- CH3
always @ (posedge dutclk)
begin
  if (reset)
    ch3_m_axis_tvalid_int <= 1'd0;
  else if ((ch3_m_axis_tready) && (rxarbiter_curstate == RXSTATE_RDATAFRCH3))
    ch3_m_axis_tvalid_int <= 1'd0;
  else if (rxbuffer_datavld)
    ch3_m_axis_tvalid_int <= 1'd1;
  else
    ch3_m_axis_tvalid_int <= ch3_m_axis_tvalid_int;
end
//---- CH4
always @ (posedge dutclk)
begin
  if (reset)
    ch4_m_axis_tvalid_int <= 1'd0;
  else if ((ch4_m_axis_tready) && (rxarbiter_curstate == RXSTATE_RDATAFRCH4))
    ch4_m_axis_tvalid_int <= 1'd0;
  else if (rxbuffer_datavld)
    ch4_m_axis_tvalid_int <= 1'd1;
  else
    ch4_m_axis_tvalid_int <= ch4_m_axis_tvalid_int;
end
//---- CH5
always @ (posedge dutclk)
begin
  if (reset)
    ch5_m_axis_tvalid_int <= 1'd0;
  else if ((ch5_m_axis_tready) && (rxarbiter_curstate == RXSTATE_RDATAFRCH5))
    ch5_m_axis_tvalid_int <= 1'd0;
  else if (rxbuffer_datavld)
    ch5_m_axis_tvalid_int <= 1'd1;
  else
    ch5_m_axis_tvalid_int <= ch5_m_axis_tvalid_int;
end
//---- CH6
always @ (posedge dutclk)
begin
  if (reset)
    ch6_m_axis_tvalid_int <= 1'd0;
  else if ((ch6_m_axis_tready) && (rxarbiter_curstate == RXSTATE_RDATAFRCH6))
    ch6_m_axis_tvalid_int <= 1'd0;
  else if (rxbuffer_datavld)
    ch6_m_axis_tvalid_int <= 1'd1;
  else
    ch6_m_axis_tvalid_int <= ch6_m_axis_tvalid_int;
end
//---- CH7
always @ (posedge dutclk)
begin
  if (reset)
    ch7_m_axis_tvalid_int <= 1'd0;
  else if ((ch7_m_axis_tready) && (rxarbiter_curstate == RXSTATE_RDATAFRCH7))
    ch7_m_axis_tvalid_int <= 1'd0;
  else if (rxbuffer_datavld)
    ch7_m_axis_tvalid_int <= 1'd1;
  else
    ch7_m_axis_tvalid_int <= ch7_m_axis_tvalid_int;
end

//---- rx arbiter  -- priority goes to CH0
//---- CRC BAD back to back may occur with minimum packet receive clock cycles
//---- by that status packet should be formed
always @ (posedge dutclk)
begin
  if (reset) begin
    rxarbiter_curstate <= RXSTATE_IDLE;
	sendporterrorinfo  <= 1'd0;
  end else begin
    case (rxarbiter_curstate)
	  RXSTATE_IDLE: begin
		if (rxbuffer_datavld)
	      rxarbiter_curstate <= RXSTATE_RDSRCPORT2;
		else if (!rxbuffer_empty)
	      rxarbiter_curstate <= RXSTATE_RDSRCPORT1;
		else
		  rxarbiter_curstate <= RXSTATE_IDLE;
	    
		sendporterrorinfo  <= 1'd0;
	  end
	  RXSTATE_RDSRCPORT1: begin
		if (rxbuffer_datavld) rxarbiter_curstate <= RXSTATE_RDSRCPORT2;
	  end
	  RXSTATE_RDSRCPORT2: begin
		if (rxbuffer_datavld) rxarbiter_curstate <= RXSTATE_RDDSTPORT1;
	  end
	  RXSTATE_RDDSTPORT1: begin
		if (rxbuffer_datavld) rxarbiter_curstate <= RXSTATE_RDDSTPORT2;
	  end
	  RXSTATE_RDDSTPORT2: begin
		if (rxbuffer_datavld) rxarbiter_curstate <= RXSTATE_RDFIRSTBYTE;
	  end
	  RXSTATE_RDFIRSTBYTE: begin
		if (rxbuffer_datavld) begin
		  if ((rxbuffer_data == GETVERSION) || (rxbuffer_data == FPGA_RST) || (rxbuffer_data == DUT_RST))
		    rxarbiter_curstate <= RXSTATE_WAITFREOP;
		  else
		    rxarbiter_curstate <= RXSTATE_CHKFRPORT;
		end else if (!rxbuffer_empty)
		  rxarbiter_curstate <= RXSTATE_RDFIRSTBYTE;
	  end
	  RXSTATE_CHKFRPORT: begin
		if ((dst_port == DSTPORT_0) && (NUM_AXIS_CHANNELS > 0))
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH0;
		else if ((dst_port == DSTPORT_1) && (NUM_AXIS_CHANNELS > 1))
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH1;
		else if ((dst_port == DSTPORT_2) && (NUM_AXIS_CHANNELS > 2))
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH2;
		else if ((dst_port == DSTPORT_3) && (NUM_AXIS_CHANNELS > 3))
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH3;
		else if ((dst_port == DSTPORT_4) && (NUM_AXIS_CHANNELS > 4))
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH4;
		else if ((dst_port == DSTPORT_5) && (NUM_AXIS_CHANNELS > 5))
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH5;
		else if ((dst_port == DSTPORT_6) && (NUM_AXIS_CHANNELS > 6))
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH6;
		else if ((dst_port == DSTPORT_7) && (NUM_AXIS_CHANNELS > 7))
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH7;
		else
		  rxarbiter_curstate <= RXSTATE_WAITFREOP;
		
		//---- if this state moves to waitforeop -- indicates the destination application with this port values dosn't exist
		sendporterrorinfo <= 1'd1;
	  end
	  RXSTATE_RDATAFRCH0: begin
	    if ((rxbuffer_eop) && (rxbuffer_datavld || ch0_m_axis_tvalid_int) && (ch0_m_axis_tready))
		  rxarbiter_curstate <= RXSTATE_IDLE;
		else
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH0;
	  end
	  RXSTATE_RDATAFRCH1: begin
	    if ((rxbuffer_eop) && (rxbuffer_datavld || ch1_m_axis_tvalid_int) && (ch1_m_axis_tready))
		  rxarbiter_curstate <= RXSTATE_IDLE;
		else
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH1;
	  end
	  RXSTATE_RDATAFRCH2: begin
	    if ((rxbuffer_eop) && (rxbuffer_datavld || ch2_m_axis_tvalid_int) && (ch2_m_axis_tready))
		  rxarbiter_curstate <= RXSTATE_IDLE;
		else
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH2;
	  end
	  RXSTATE_RDATAFRCH3: begin
	    if ((rxbuffer_eop) && (rxbuffer_datavld || ch3_m_axis_tvalid_int) && (ch3_m_axis_tready))
		  rxarbiter_curstate <= RXSTATE_IDLE;
		else
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH3;

	  end
	  RXSTATE_RDATAFRCH4: begin
	    if ((rxbuffer_eop) && (rxbuffer_datavld || ch4_m_axis_tvalid_int) && (ch4_m_axis_tready))
		  rxarbiter_curstate <= RXSTATE_IDLE;
		else
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH4;
	  end
	  RXSTATE_RDATAFRCH5: begin
	    if ((rxbuffer_eop) && (rxbuffer_datavld || ch5_m_axis_tvalid_int) && (ch5_m_axis_tready))
		  rxarbiter_curstate <= RXSTATE_IDLE;
		else
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH5;
	  end
	  RXSTATE_RDATAFRCH6: begin
	    if ((rxbuffer_eop) && (rxbuffer_datavld || ch6_m_axis_tvalid_int) && (ch6_m_axis_tready))
		  rxarbiter_curstate <= RXSTATE_IDLE;
		else
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH6;
	  end
	  RXSTATE_RDATAFRCH7: begin
	    if ((rxbuffer_eop) && (rxbuffer_datavld || ch7_m_axis_tvalid_int) && (ch7_m_axis_tready))
		  rxarbiter_curstate <= RXSTATE_IDLE;
		else
		  rxarbiter_curstate <= RXSTATE_RDATAFRCH7;
	  end
	  RXSTATE_WAITFREOP: begin
	    if ((rxbuffer_eop) && (rxbuffer_datavld))
		  rxarbiter_curstate <= RXSTATE_IDLE;
		else
		  rxarbiter_curstate <= RXSTATE_WAITFREOP;		
	  end
      default:
		rxarbiter_curstate <= RXSTATE_IDLE;
	endcase
  end
end


always @ (posedge dutclk)
begin
  if (reset) begin
    rxbuffer_rden_int <= 1'd0;
  end else begin
    case (rxarbiter_curstate)
	  RXSTATE_IDLE: begin
		if (!rxbuffer_empty)
		  rxbuffer_rden_int <= 1'd1;
		else
		  rxbuffer_rden_int <= 1'd0;
	  end
	  RXSTATE_RDSRCPORT1: begin
		if (!rxbuffer_empty) rxbuffer_rden_int <= 1'd1;
	  end
	  RXSTATE_RDSRCPORT2: begin
		if (!rxbuffer_empty) rxbuffer_rden_int <= 1'd1;
	  end
	  RXSTATE_RDDSTPORT1: begin
		if (!rxbuffer_empty) rxbuffer_rden_int <= 1'd1;
	  end
	  RXSTATE_RDDSTPORT2: begin
		if (rxbuffer_datavld) rxbuffer_rden_int <= 1'd0;
		else if (!rxbuffer_empty) rxbuffer_rden_int <= 1'd1;
	  end
	  RXSTATE_RDFIRSTBYTE: begin
		if (rxbuffer_datavld)
		  rxbuffer_rden_int <= 1'd0;
		else if (!rxbuffer_empty)
		  rxbuffer_rden_int <= ~rxbuffer_rden_int;
	  end
	  RXSTATE_CHKFRPORT: begin
		rxbuffer_rden_int <= 1'd0;
	  end
	  RXSTATE_RDATAFRCH0: begin
        if ((rxbuffer_eop) && (rxbuffer_datavld || ch0_m_axis_tvalid_int) && (ch0_m_axis_tready))                       
		  rxbuffer_rden_int <= 1'd0;
		else if ((ch0_m_axis_tready) && (!rxbuffer_empty))
		  rxbuffer_rden_int <= 1'd1;
		else
		  rxbuffer_rden_int <= 1'd0;
	  end
	  RXSTATE_RDATAFRCH1: begin
        if ((rxbuffer_eop) && (rxbuffer_datavld || ch1_m_axis_tvalid_int) && (ch1_m_axis_tready))
		  rxbuffer_rden_int <= 1'd0;
		else if ((ch1_m_axis_tready) && (!rxbuffer_empty))
		  rxbuffer_rden_int <= 1'd1;
		else
		  rxbuffer_rden_int <= 1'd0;
	  end
	  RXSTATE_RDATAFRCH2: begin
        if ((rxbuffer_eop) && (rxbuffer_datavld || ch2_m_axis_tvalid_int) && (ch2_m_axis_tready))
		  rxbuffer_rden_int <= 1'd0;
		else if ((ch2_m_axis_tready) && (!rxbuffer_empty))
		  rxbuffer_rden_int <= 1'd1;
		else
		  rxbuffer_rden_int <= 1'd0;
	  end
	  RXSTATE_RDATAFRCH3: begin
        if ((rxbuffer_eop) && (rxbuffer_datavld || ch3_m_axis_tvalid_int) && (ch3_m_axis_tready))
		  rxbuffer_rden_int <= 1'd0;
		else if ((ch3_m_axis_tready) && (!rxbuffer_empty))
		  rxbuffer_rden_int <= 1'd1;
		else
		  rxbuffer_rden_int <= 1'd0;
	  end
	  RXSTATE_RDATAFRCH4: begin
        if ((rxbuffer_eop) && (rxbuffer_datavld || ch4_m_axis_tvalid_int) && (ch4_m_axis_tready))
		  rxbuffer_rden_int <= 1'd0;
		else if ((ch4_m_axis_tready) && (!rxbuffer_empty))
		  rxbuffer_rden_int <= 1'd1;
		else
		  rxbuffer_rden_int <= 1'd0;
	  end
	  RXSTATE_RDATAFRCH5: begin
        if ((rxbuffer_eop) && (rxbuffer_datavld || ch5_m_axis_tvalid_int) && (ch5_m_axis_tready))
		  rxbuffer_rden_int <= 1'd0;
		else if ((ch5_m_axis_tready) && (!rxbuffer_empty))
		  rxbuffer_rden_int <= 1'd1;
		else
		  rxbuffer_rden_int <= 1'd0;
	  end
	  RXSTATE_RDATAFRCH6: begin
        if ((rxbuffer_eop) && (rxbuffer_datavld || ch6_m_axis_tvalid_int) && (ch6_m_axis_tready))
		  rxbuffer_rden_int <= 1'd0;
		else if ((ch6_m_axis_tready) && (!rxbuffer_empty))
		  rxbuffer_rden_int <= 1'd1;
		else
		  rxbuffer_rden_int <= 1'd0;
	  end
	  RXSTATE_RDATAFRCH7: begin
        if ((rxbuffer_eop) && (rxbuffer_datavld || ch7_m_axis_tvalid_int) && (ch7_m_axis_tready))
		  rxbuffer_rden_int <= 1'd0;
		else if ((ch7_m_axis_tready) && (!rxbuffer_empty))
		  rxbuffer_rden_int <= 1'd1;
		else
		  rxbuffer_rden_int <= 1'd0;
	  end
	  RXSTATE_WAITFREOP: begin
	    if ((rxbuffer_eop) && (rxbuffer_datavld))
		  rxbuffer_rden_int <= 1'd0;
		else if (!rxbuffer_empty)
		  rxbuffer_rden_int <= 1'd1;
		else
		  rxbuffer_rden_int <= 1'd0;
	  end
      default:
		  rxbuffer_rden_int <= 1'd0;
	endcase
  end
end

//---- read version or reset packet
always @ (posedge dutclk) begin
  if (reset)
    get_ver_reg <= 4'h0;
  else if ((rxbuffer_data == GETVERSION) && (rxbuffer_datavld) && (rxarbiter_curstate == RXSTATE_RDFIRSTBYTE))
    get_ver_reg <= 4'hF;
  else
    get_ver_reg <= {get_ver_reg[2:0], 1'd0};

  if (reset)
    fpga_rst_reg <= 16'h0000;
  else if ((rxbuffer_data == FPGA_RST) && (rxbuffer_datavld) && (rxarbiter_curstate == RXSTATE_RDFIRSTBYTE))
    fpga_rst_reg <= 16'hFFFF;
  else
    fpga_rst_reg <= {fpga_rst_reg[14:0], 1'd0};

  if (reset)
    dut_rst_reg <= 16'h0000;
  else if ((rxbuffer_data == DUT_RST) && (rxbuffer_datavld) && (rxarbiter_curstate == RXSTATE_RDFIRSTBYTE))
    dut_rst_reg <= 16'hFFFF;
  else
    dut_rst_reg <= {dut_rst_reg[14:0], 1'd0};
	
  dutrst <= (reset || dut_rst_reg[15] || fpga_rst_reg[15]);
end

//---- 
always @ (posedge txclk) begin
  if (reset)
    get_ver_reg1 <= 1'd0;
  else
    get_ver_reg1 <= get_ver_reg[3];
	
  get_ver_reg2 <= get_ver_reg1;
  get_ver_reg3 <= get_ver_reg2;
  
  if ((get_ver_reg3 == 1'd0) && (get_ver_reg2 == 1'd1))
    get_ver_posedge <= 1'd1;
  else
    get_ver_posedge <= 1'd0;
end

//---- 
always @ (posedge rxclk) begin
  rxrst_int <= reset || fpga_rst_reg[15];
  rxrst <= rxrst_int;
end
//---- 
always @ (posedge txclk) begin
  txrst_int <= reset || fpga_rst_reg[15];
  txrst <= txrst_int;
end

//---- send error port info to software -- saying the destination port with this value applpication dosnt exist 
always @ (posedge dutclk) begin
  if (reset)
    sendporterrorinfo_vld <= 4'h0;
  else if ((sendporterrorinfo == 1'd1) && (rxarbiter_curstate == RXSTATE_WAITFREOP))
    sendporterrorinfo_vld <= 4'hF;
  else
    sendporterrorinfo_vld <= {sendporterrorinfo_vld[2:0], 1'd0};
end 

//--- make it high till the mac version info snet 
always @ (posedge txclk) begin
  if (reset)
    porterr_reg1 <= 1'd0;
  else
    porterr_reg1 <= sendporterrorinfo_vld[3];
	
  porterr_reg2 <= porterr_reg1;
  porterr_reg3 <= porterr_reg2;
  
  if (reset)
    porterr_posedge <= 1'd0;
  else if ((porterr_reg3 == 1'd0) && (porterr_reg2 == 1'd1))
    porterr_posedge <= 1'd1;
  else if (verstatus_curstate == VER_IDLE)
    porterr_posedge <= 1'd0;
  else
    porterr_posedge <= porterr_posedge;
end


//----- Creating the GET VERSION response packet
always @ (posedge txclk)
begin
  if (txrst) begin
    verstatus_curstate <= VER_IDLE;
	status    <= 8'd0;
	statusVld <= 1'd0;
	statusEOP <= 1'd0;
  end else begin
    case (verstatus_curstate)
	  VER_IDLE: begin
	    status    <= 8'd0;
	    statusVld <= 1'd0;
	    statusEOP <= 1'd0;
		if (get_ver_posedge)
	      verstatus_curstate <= VER_WAIT_RDY;
		else if (porterr_posedge)
	      verstatus_curstate <= VER_PORTERROR;
		else
		  verstatus_curstate <= VER_IDLE;
	  end
	  VER_WAIT_RDY: begin
		if (statusReady) verstatus_curstate <= VER_CMMND;
		else verstatus_curstate <= VER_WAIT_RDY;
	  end
	  VER_CMMND: begin
	    status    <= GETVERSION;
	    statusVld <= 1'd1;
	    statusEOP <= 1'd0;
		verstatus_curstate <= VER_LEN;
	  end
	  VER_LEN: begin
	    status    <= 8'd2;
	    statusVld <= 1'd1;
	    statusEOP <= 1'd0;
		verstatus_curstate <= VER_BYTE1;
	  end
	  VER_BYTE1: begin
	    status    <= VERSION[15:8];
	    statusVld <= 1'd1;
	    statusEOP <= 1'd0;
		verstatus_curstate <= VER_BYTE2;
	  end
	  VER_BYTE2: begin
	    status    <= VERSION[7:0];
	    statusVld <= 1'd1;
	    statusEOP <= 1'd1;
		verstatus_curstate <= VER_IDLE;
	  end
	  VER_PORTERROR: begin
	    status    <= 8'hF0;
	    if (statusReady) begin
		  statusVld <= 1'd1;
	      statusEOP <= 1'd1;
		  verstatus_curstate <= VER_IDLE;
		end	else begin
		  statusVld <= 1'd0;
	      statusEOP <= 1'd0;
		  verstatus_curstate <= VER_PORTERROR;
		end
	  end
	  default: begin
		verstatus_curstate <= VER_IDLE;
	  end
	endcase
  end
end

always @ (posedge dutclk) begin 
  if (reset)
    ver_udpport_dutclk <= 32'd0;
  else
    ver_udpport_dutclk <= {chx_m_axis_srcport, dst_port};
end

always @ (posedge txclk) begin 
  if (txrst) begin
    ver_udpport_sync <= 32'd0;
    ver_udpport <= 32'd0;
  end else begin
    ver_udpport_sync <= ver_udpport_dutclk;
    ver_udpport <= ver_udpport_sync;
  end
end


endmodule
