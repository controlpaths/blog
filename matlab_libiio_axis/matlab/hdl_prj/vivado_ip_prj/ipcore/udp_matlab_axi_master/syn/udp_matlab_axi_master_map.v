module udp_matlab_axi_master_map #
(
    parameter ID_WIDTH=1,
    parameter DATAWIDTH=8,
    parameter AXI_DATA_WIDTH=32,
    parameter AXI_ADDR_WIDTH=32,
	parameter [31:0] AXIMASTER_IP_ID0= 0,
	parameter [0:0]  AXIMASTER_DATA_64= 0,
	parameter [0:0]  AXIMASTER_ADDRS_64= 0
)
(
   axis_aclk,
   axis_areset,
   //  AXI stream interface
   ch0_s_axis_tdata,
   ch0_s_axis_tvalid,
   ch0_s_axis_tlast,
   ch0_s_axis_tready,

   ch0_m_axis_tdata,
   ch0_m_axis_tvalid,
   ch0_m_axis_tlast,
   ch0_m_axis_tready,
   
   //----
   reset_status,
   clock_status,
   
   //----
   axis2m_awburst,
   axis2m_awlen,
   axis2m_wstart,
   axis2m_waddr,
   axis2m_wdata,
   axis2m_wdatav,
   axis2m_wresp,
   
   axis2m_arburst,
   axis2m_arlen,
   axis2m_rstart,
   axis2m_raddr,
   axis2m_rdenb,
   axis2m_rdvld,
   axis2m_rdata,
   axis2m_rresp,
   axis2m_rresp_done
);

input                  axis_aclk;
input                  axis_areset;
//----  AXI stream interface
input  [DATAWIDTH-1:0] ch0_s_axis_tdata;
input                  ch0_s_axis_tvalid;
input                  ch0_s_axis_tlast;
output                 ch0_s_axis_tready;

output [DATAWIDTH-1:0] ch0_m_axis_tdata;
output                 ch0_m_axis_tvalid;
output                 ch0_m_axis_tlast;
input                  ch0_m_axis_tready;

input                  reset_status;
input                  clock_status;

output           [1:0] axis2m_awburst;
output           [7:0] axis2m_awlen;
output                 axis2m_wstart;
output          [63:0] axis2m_waddr;
output           [7:0] axis2m_wdata;
output                 axis2m_wdatav;
input                  axis2m_wresp;

output           [1:0] axis2m_arburst;
output           [7:0] axis2m_arlen;
output                 axis2m_rstart;
output          [63:0] axis2m_raddr;
output                 axis2m_rdenb;
output                 axis2m_rdvld;
input            [7:0] axis2m_rdata;
input                  axis2m_rresp;
output                 axis2m_rresp_done;

//---- parameters
localparam AXIMSTATE_IDLE         = 4'd0,
           AXIMSTATE_CHKFIRSTBYTE = 4'd1,
           AXIMSTATE_VERSIONPKT   = 4'd2,
           AXIMSTATE_WRITECMND    = 4'd3,
           AXIMSTATE_WRITEADDR    = 4'd4,
           AXIMSTATE_WRITELEN     = 4'd5,
           AXIMSTATE_READCMND     = 4'd6,
           AXIMSTATE_READADDR     = 4'd7,
		   AXIMSTATE_READLEN      = 4'd8,
           AXIMSTATE_WRITE        = 4'd9,
		   AXIMSTATE_WRITERESP    = 4'd10,
		   AXIMSTATE_READATARESP  = 4'd11;

//---- parameters
localparam AXIMRESPSTATE_IDLE    = 2'd0,
           AXIMRESPSTATE_AXIVER  = 2'd1,
           AXIMRESPSTATE_WRRESP  = 2'd2,
           AXIMRESPSTATE_RDRESP  = 2'd3;

parameter  GETAXIVERSION = 'h83;
parameter  WRITECONFIG1  = 'h84;
parameter  WRITECONFIG2  = 'h85;
parameter  READCONFIG1   = 'h86;
parameter  READCONFIG2   = 'h87;


//---- internal signals
reg  [4:0] axim_curstate;
reg        axiversion_pkt_en;
reg  [1:0] axis2m_awburst;
reg  [7:0] axis2m_awlen;
reg        axis2m_wstart;
reg [63:0] axis2m_waddr;
reg  [7:0] axis2m_wdata;
reg        axis2m_wdatav;
reg  [7:0] axis2m_arlen;
reg        axis2m_rstart;
reg  [1:0] axis2m_arburst;
reg [63:0] axis2m_raddr;
reg        axis2m_rdenb;
reg        axis2m_rdvld;
reg        axis2m_rdvld_d1;
reg        axis2m_rresp_done;
reg  [2:0] count8clks_getaddr;
reg  [1:0] axim_respcurstate;
reg        axiverresp;
reg        axis2m_wresp_d1;
reg        axis2m_wresp_re;
reg        axis2m_rresp_d1;
reg        axis2m_rresp_re;
reg                 ch0_s_axis_tready;
reg [DATAWIDTH-1:0] ch0_m_axis_tdata;
reg                 ch0_m_axis_tvalid;
reg                 ch0_m_axis_tlast;
reg [DATAWIDTH-1:0] ch0_m_axis_tdata_ver;
reg                 ch0_m_axis_tlast_ver;
reg                 ch0_m_axis_tvalid_ver;
reg                 ch0_m_axis_tlast_rresp;
reg          [55:0] axiver_bunchdata_reg;
reg           [7:0] count_saxis_tvalid_ver;
reg          [10:0] rd_packet_length;
reg          [11:0] rd_packet_length_plus1;
reg          [11:0] count_saxis_tvalid_rresp;
reg           [7:0] ch0_m_axis_tdata_rdresp;
reg           [7:0] axis_rdcmnd_data;
reg                 axis_rdcmnd_resp;
reg                 axis_rdcmnd_resp_count;

always @ (posedge axis_aclk)
begin
  if (axis_areset) begin
    axim_curstate <= AXIMSTATE_IDLE;
	ch0_s_axis_tready <= 1'd0;
  end else begin
    case (axim_curstate)
	  AXIMSTATE_IDLE: begin
		if (ch0_s_axis_tvalid)
	      axim_curstate <= AXIMSTATE_CHKFIRSTBYTE;
		else
		  axim_curstate <= AXIMSTATE_IDLE;
	  end
	  AXIMSTATE_CHKFIRSTBYTE: begin
		ch0_s_axis_tready <= 1'd1;
	    if (ch0_s_axis_tdata == GETAXIVERSION)
		  axim_curstate <= AXIMSTATE_VERSIONPKT;
	    else if (ch0_s_axis_tdata == WRITECONFIG1)
		  axim_curstate <= AXIMSTATE_WRITECMND;
	    else if (ch0_s_axis_tdata == WRITECONFIG2)
		  axim_curstate <= AXIMSTATE_WRITECMND;
	    else if (ch0_s_axis_tdata == READCONFIG1)
		  axim_curstate <= AXIMSTATE_READCMND;
	    else if (ch0_s_axis_tdata == READCONFIG2)
		  axim_curstate <= AXIMSTATE_READCMND;
	    else
		  axim_curstate <= AXIMSTATE_READCMND;
	  end
	  AXIMSTATE_VERSIONPKT: begin
		if (ch0_s_axis_tlast && ch0_s_axis_tvalid && ch0_s_axis_tready) begin
		  ch0_s_axis_tready <= 1'd0;
		  axim_curstate <= AXIMSTATE_IDLE;
		end else begin
		  ch0_s_axis_tready <= 1'd1;
		  axim_curstate <= AXIMSTATE_VERSIONPKT;
		end
	  end
	  AXIMSTATE_WRITECMND: begin
		ch0_s_axis_tready <= 1'd1;
		if (ch0_s_axis_tvalid && ch0_s_axis_tready)
		  axim_curstate <= AXIMSTATE_WRITEADDR;
		else 
		  axim_curstate <= AXIMSTATE_WRITECMND;
	  end
	  AXIMSTATE_WRITEADDR: begin
		if ((count8clks_getaddr == 3'd7) && (ch0_s_axis_tvalid && ch0_s_axis_tready)) begin
		  axim_curstate <= AXIMSTATE_WRITELEN;
		  ch0_s_axis_tready <= 1'd0;
		end else begin
		  axim_curstate <= AXIMSTATE_WRITEADDR;
		  ch0_s_axis_tready <= 1'd1;
		end
	  end
	  AXIMSTATE_WRITELEN: begin
		if (ch0_s_axis_tvalid && ch0_s_axis_tready) begin
		  axim_curstate <= AXIMSTATE_WRITE;
		  ch0_s_axis_tready <= 1'd0;
		end else begin
		  axim_curstate <= AXIMSTATE_WRITELEN;
		  ch0_s_axis_tready <= 1'd1;
		end
	  end
	  AXIMSTATE_READCMND: begin
		ch0_s_axis_tready <= 1'd1;
		if (ch0_s_axis_tvalid && ch0_s_axis_tready)
		  axim_curstate <= AXIMSTATE_READADDR;
		else 
		  axim_curstate <= AXIMSTATE_READCMND;
	  end
	  AXIMSTATE_READADDR: begin
		if ((count8clks_getaddr == 3'd7) && (ch0_s_axis_tvalid && ch0_s_axis_tready)) begin
		  axim_curstate <= AXIMSTATE_READLEN;
		  ch0_s_axis_tready <= 1'd0;
		end else begin
		  axim_curstate <= AXIMSTATE_READADDR;
		  ch0_s_axis_tready <= 1'd1;
		end
	  end
	  AXIMSTATE_READLEN: begin
		if (ch0_s_axis_tlast && ch0_s_axis_tvalid && ch0_s_axis_tready) begin
		  axim_curstate <= AXIMSTATE_READATARESP;
          ch0_s_axis_tready <= 1'd0;
		end else begin
		  axim_curstate <= AXIMSTATE_READLEN;
		  ch0_s_axis_tready <= 1'd1;
		end
	  end
	  AXIMSTATE_WRITE: begin
		if (ch0_s_axis_tlast && ch0_s_axis_tvalid && ch0_s_axis_tready) begin
		  axim_curstate <= AXIMSTATE_WRITERESP;
          ch0_s_axis_tready <= 1'd0;
		end else begin
		  axim_curstate <= AXIMSTATE_WRITE;
		  ch0_s_axis_tready <= 1'd1;
		end
	  end
	  AXIMSTATE_WRITERESP: begin
        ch0_s_axis_tready <= 1'd0;
		if (axis2m_wresp_re)
		  axim_curstate <= AXIMSTATE_IDLE;
		else
		  axim_curstate <= AXIMSTATE_WRITERESP;
	  end
	  AXIMSTATE_READATARESP: begin
        ch0_s_axis_tready <= 1'd0;
		if (axis2m_rresp_done)
		  axim_curstate <= AXIMSTATE_IDLE;
		else
		  axim_curstate <= AXIMSTATE_READATARESP;
	  end
	  default: axim_curstate <= AXIMSTATE_IDLE;
	endcase
  end
end

//---- axi write response rising edge
always @ (posedge axis_aclk)
begin
  if (axis_areset)
    axis2m_wresp_d1 <= 1'd0;
  else
    axis2m_wresp_d1 <= axis2m_wresp;
  
  if (axis_areset)
    axis2m_wresp_re <= 1'd0;
  else if (axis2m_wresp && (!axis2m_wresp_d1))
    axis2m_wresp_re <= 1'd1;
  else
    axis2m_wresp_re <= 1'd0;

  if (axis_areset)
    axis2m_rresp_d1 <= 1'd0;
  else
    axis2m_rresp_d1 <= axis2m_rresp;
  
  if (axis_areset)
    axis2m_rresp_re <= 1'd0;
  else if (axis2m_rresp && (!axis2m_rresp_d1))
    axis2m_rresp_re <= 1'd1;
  else
    axis2m_rresp_re <= 1'd0;
end

//---- driving the required configurations for writing and reading the data
always @ (posedge axis_aclk)
begin
  if ((axim_curstate == AXIMSTATE_WRITECMND) && (ch0_s_axis_tvalid && ch0_s_axis_tready))
    axis2m_awburst <= {1'b0, ch0_s_axis_tdata[0]};
  else
    axis2m_awburst <= axis2m_awburst;

  if ((axim_curstate == AXIMSTATE_WRITELEN) && (ch0_s_axis_tvalid && ch0_s_axis_tready))
    axis2m_awlen <= ch0_s_axis_tdata;
  else
    axis2m_awlen <= axis2m_awlen;

  if ((axim_curstate == AXIMSTATE_READCMND) && (ch0_s_axis_tvalid && ch0_s_axis_tready))
    axis2m_arburst <= {1'b0, ch0_s_axis_tdata[0]};
  else
    axis2m_arburst <= axis2m_arburst;
  
  if ((axim_curstate == AXIMSTATE_READLEN) && (ch0_s_axis_tvalid && ch0_s_axis_tready))
    axis2m_arlen <= ch0_s_axis_tdata;
  else
    axis2m_arlen <= axis2m_arlen;

  if (axis_areset)
    count8clks_getaddr <= 3'd0;
  else if (((axim_curstate == AXIMSTATE_WRITEADDR) || (axim_curstate == AXIMSTATE_READADDR)) && (ch0_s_axis_tvalid && ch0_s_axis_tready))
    count8clks_getaddr <= count8clks_getaddr + 3'd1;
  else
    count8clks_getaddr <= count8clks_getaddr;
end

//---- data write
always @ (posedge axis_aclk)
begin
  if (axim_curstate == AXIMSTATE_IDLE)
    axis2m_wstart <= 1'd0;
  else if (axim_curstate == AXIMSTATE_WRITERESP)
    axis2m_wstart <= 1'd1;
  else
    axis2m_wstart <= axis2m_wstart;

  if ((axim_curstate == AXIMSTATE_WRITEADDR) && (ch0_s_axis_tvalid && ch0_s_axis_tready))
    axis2m_waddr <= {ch0_s_axis_tdata, axis2m_waddr[63:8]};
  else
    axis2m_waddr <= axis2m_waddr;

  if ((axim_curstate == AXIMSTATE_WRITE) && (ch0_s_axis_tvalid && ch0_s_axis_tready))
    axis2m_wdatav <= 1'd1;
  else
    axis2m_wdatav <= 1'd0;

  if ((axim_curstate == AXIMSTATE_WRITE) && (ch0_s_axis_tvalid && ch0_s_axis_tready))
    axis2m_wdata <= ch0_s_axis_tdata;
  else
    axis2m_wdata <= axis2m_wdata;
end

//---- data read
always @ (posedge axis_aclk)
begin
  if (axim_curstate == AXIMSTATE_IDLE)
    axis2m_rstart <= 1'd0;
  else if (axim_curstate == AXIMSTATE_READATARESP)
    axis2m_rstart <= 1'd1;
  else
    axis2m_rstart <= axis2m_rstart;

  if ((axim_curstate == AXIMSTATE_READADDR) && (ch0_s_axis_tvalid && ch0_s_axis_tready))
    axis2m_raddr <= {ch0_s_axis_tdata, axis2m_raddr[63:8]};
  else
    axis2m_raddr <= axis2m_raddr;
end

//---- version packet received 
always @ (posedge axis_aclk)
begin
  if (axis_areset)
    axiverresp <= 1'd0;
  else if (axim_curstate == AXIMSTATE_VERSIONPKT) begin
    if ((ch0_s_axis_tdata == GETAXIVERSION) && (ch0_s_axis_tready && ch0_s_axis_tvalid))
      axiverresp <= 1'd1;
	else
	  axiverresp <= 1'd0;
  end else
    axiverresp <= 1'd0;
end

//------- response channel creation
always @ (posedge axis_aclk)
begin
  if (axis_areset) begin
    axim_respcurstate <= AXIMRESPSTATE_IDLE;
  end else begin
    case (axim_respcurstate)
	  AXIMRESPSTATE_IDLE: begin
		if (axiverresp)
	      axim_respcurstate <= AXIMRESPSTATE_AXIVER;
		else if (axis2m_wresp_re)
	      axim_respcurstate <= AXIMRESPSTATE_WRRESP;
		else if (axis2m_rresp_re)
	      axim_respcurstate <= AXIMRESPSTATE_RDRESP;
		else
		  axim_respcurstate <= AXIMRESPSTATE_IDLE;
	  end
	  AXIMRESPSTATE_AXIVER: begin
	    if (ch0_m_axis_tlast && ch0_m_axis_tvalid && ch0_m_axis_tready)
		  axim_respcurstate <= AXIMRESPSTATE_IDLE;
		else
		  axim_respcurstate <= AXIMRESPSTATE_AXIVER;
	  end
	  AXIMRESPSTATE_WRRESP: begin
	    if (ch0_m_axis_tlast && ch0_m_axis_tvalid && ch0_m_axis_tready)
		  axim_respcurstate <= AXIMRESPSTATE_IDLE;
		else
		  axim_respcurstate <= AXIMRESPSTATE_WRRESP;
	  end
	  AXIMRESPSTATE_RDRESP: begin
	    if (ch0_m_axis_tlast && ch0_m_axis_tvalid && ch0_m_axis_tready)
		  axim_respcurstate <= AXIMRESPSTATE_IDLE;
		else
		  axim_respcurstate <= AXIMRESPSTATE_RDRESP;
	  end
	  default: axim_respcurstate <= AXIMRESPSTATE_IDLE;
	endcase
  end
end

always @ (*)
begin
  if (axis_areset) begin
    ch0_m_axis_tvalid = 1'd0;
    ch0_m_axis_tdata  = 8'd0;
	ch0_m_axis_tlast  = 1'd0;
  end else if (axim_respcurstate == AXIMRESPSTATE_AXIVER) begin
	ch0_m_axis_tvalid = ch0_m_axis_tvalid_ver;
    ch0_m_axis_tdata  = axiver_bunchdata_reg[55:48];
	ch0_m_axis_tlast  = ch0_m_axis_tlast_ver;
  end else if (axim_respcurstate == AXIMRESPSTATE_WRRESP) begin
	ch0_m_axis_tvalid = 1'd1;
    ch0_m_axis_tdata  = WRITECONFIG1;    
	ch0_m_axis_tlast  = 1'd1;
  end else if (axim_respcurstate == AXIMRESPSTATE_RDRESP) begin
	ch0_m_axis_tvalid = (axis_rdcmnd_resp || axis2m_rdvld_d1);
    ch0_m_axis_tdata  = axis_rdcmnd_resp? axis_rdcmnd_data: axis2m_rdata;
	ch0_m_axis_tlast  = ch0_m_axis_tlast_rresp;
  end else begin
	ch0_m_axis_tvalid = 1'd0;
    ch0_m_axis_tdata  = 8'd0;    
	ch0_m_axis_tlast  = 1'd0;
  end
end

//----- version response
always @ (posedge axis_aclk)
begin
  if (axis_areset)
    count_saxis_tvalid_ver <= 3'd0;
  else if (axim_respcurstate == AXIMRESPSTATE_IDLE)
    count_saxis_tvalid_ver <= 3'd0;
  else if (ch0_m_axis_tvalid && ch0_m_axis_tready)
    count_saxis_tvalid_ver <= count_saxis_tvalid_ver + 3'd1;
  else
    count_saxis_tvalid_ver <= count_saxis_tvalid_ver;
  
  if (axis_areset)
    ch0_m_axis_tlast_ver <= 1'd0;
  else if (ch0_m_axis_tlast && ch0_m_axis_tvalid && ch0_m_axis_tready)
    ch0_m_axis_tlast_ver <= 1'd0;
  else if (count_saxis_tvalid_ver == 3'd6)
    ch0_m_axis_tlast_ver <= 1'd1;
  else
    ch0_m_axis_tlast_ver <= ch0_m_axis_tlast_ver;

  if (axis_areset)
    ch0_m_axis_tvalid_ver <= 1'd0;
  else if ((count_saxis_tvalid_ver == 3'd6) && ch0_m_axis_tvalid && ch0_m_axis_tready)
    ch0_m_axis_tvalid_ver <= 1'd0;
  else if (axim_respcurstate == AXIMRESPSTATE_AXIVER)
    ch0_m_axis_tvalid_ver <= 1'd1;
  else
    ch0_m_axis_tvalid_ver <= ch0_m_axis_tvalid_ver;
  if (axis_areset)
    axiver_bunchdata_reg  <= 56'd0;
  else if (axim_respcurstate == AXIMRESPSTATE_IDLE)
    axiver_bunchdata_reg  <= {GETAXIVERSION, 8'd5, AXIMASTER_IP_ID0, {4'd0, reset_status, clock_status, AXIMASTER_DATA_64, AXIMASTER_ADDRS_64}};
  else if (ch0_m_axis_tvalid && ch0_m_axis_tready)
    axiver_bunchdata_reg  <= {axiver_bunchdata_reg[47:0], 8'd0};
  else
    axiver_bunchdata_reg  <= axiver_bunchdata_reg;    
end

//----- read data response
always @ (*)
begin
  if (axis_areset)
    axis2m_rdenb = 1'd0;
  else if ((ch0_m_axis_tlast) && (ch0_m_axis_tvalid && ch0_m_axis_tready))
    axis2m_rdenb = 1'd0;
  else if ((axis_rdcmnd_resp_count == 1'd1) && (ch0_m_axis_tvalid && ch0_m_axis_tready))
    axis2m_rdenb = 1'd1;
  else
    axis2m_rdenb = 1'd0;
end
always @ (posedge axis_aclk)
begin
  if (axis_areset)
    axis_rdcmnd_resp <= 1'd0;
  else if ((axim_respcurstate == AXIMRESPSTATE_IDLE) && (axis2m_rresp_re))
    axis_rdcmnd_resp <= 1'd1;
  else if ((axis_rdcmnd_resp_count == 1'd1) && (ch0_m_axis_tvalid && ch0_m_axis_tready))
    axis_rdcmnd_resp <= 1'd0;
  else
    axis_rdcmnd_resp <= axis_rdcmnd_resp;

  if (axis_areset)
    axis_rdcmnd_data <= 8'd0;
  else if ((axim_respcurstate == AXIMRESPSTATE_IDLE) && (axis2m_rresp_re))
    axis_rdcmnd_data <= 8'h86;
  else if (ch0_m_axis_tvalid && ch0_m_axis_tready)
    axis_rdcmnd_data <= axis2m_arlen;
  else
    axis_rdcmnd_data <= axis_rdcmnd_data;

  if (axis_areset)
    axis_rdcmnd_resp_count <= 1'd0;
  else if (ch0_m_axis_tlast && (ch0_m_axis_tvalid && ch0_m_axis_tready))
    axis_rdcmnd_resp_count <= 1'd0;
  else if ((axim_respcurstate == AXIMRESPSTATE_RDRESP) && (ch0_m_axis_tvalid && ch0_m_axis_tready))
    axis_rdcmnd_resp_count <= 1'd1;
  else
    axis_rdcmnd_resp_count <= axis_rdcmnd_resp_count;
end
always @ (posedge axis_aclk)
begin
  if (axis_areset)
    axis2m_rdvld <= 1'd0;
  else
    axis2m_rdvld <= axis2m_rdenb;
  if (axis_areset)
    axis2m_rdvld_d1 <= 1'd0;
  else if (axis2m_rdvld)
    axis2m_rdvld_d1 <= 1'd1;
  else if (ch0_m_axis_tvalid && ch0_m_axis_tready)
    axis2m_rdvld_d1 <= 1'd0;
  else
    axis2m_rdvld_d1 <= axis2m_rdvld_d1;
end

always @ (posedge axis_aclk)
begin
  if (AXI_DATA_WIDTH == 32)
    rd_packet_length <= {axis2m_arlen, 2'd3};
  else
    rd_packet_length <= {axis2m_arlen, 3'd7};

  if (axis_areset)
    rd_packet_length_plus1 <= 'd0;
  else
    rd_packet_length_plus1 <= rd_packet_length + 'd1;

  if (axis_areset)
    count_saxis_tvalid_rresp <= 'd0;
  else if (axim_respcurstate == AXIMRESPSTATE_IDLE)
    count_saxis_tvalid_rresp <= 'd0;
  else if ((axim_respcurstate == AXIMRESPSTATE_RDRESP) && (ch0_m_axis_tvalid && ch0_m_axis_tready))
    count_saxis_tvalid_rresp <= count_saxis_tvalid_rresp + 'd1;
  else
    count_saxis_tvalid_rresp <= count_saxis_tvalid_rresp;

  if (axis_areset)
    ch0_m_axis_tlast_rresp <= 1'd0;
  else if ((ch0_m_axis_tvalid && ch0_m_axis_tready) && (ch0_m_axis_tlast))
    ch0_m_axis_tlast_rresp <= 1'd0;
  else if ((ch0_m_axis_tvalid && ch0_m_axis_tready) && (count_saxis_tvalid_rresp == rd_packet_length_plus1))
    ch0_m_axis_tlast_rresp <= 1'd1;
  else
    ch0_m_axis_tlast_rresp <= ch0_m_axis_tlast_rresp;
  if (axis_areset)
    axis2m_rresp_done <= 1'd0;
  else if ((axim_respcurstate == AXIMRESPSTATE_RDRESP) && (ch0_m_axis_tvalid && ch0_m_axis_tready && ch0_m_axis_tlast))
    axis2m_rresp_done <= 1'd1;
  else
    axis2m_rresp_done <= 1'd0;
end

endmodule