`timescale 1 ns / 1 ns
module udp_matlab_axi_master #
(
    parameter ID_WIDTH=1,
    parameter AXI_DATA_WIDTH=32,
    parameter AXI_ADDR_WIDTH=32
)
(
   //  AXI stream interface
   input                  axis_aclk,
   input                  axis_aresetn,
   input            [7:0] s_axis_tdata,
   input                  s_axis_tvalid,
   input                  s_axis_tlast,
   output                 s_axis_tready,

   output           [7:0] m_axis_tdata,
   output                 m_axis_tvalid,
   output                 m_axis_tlast,
   input                  m_axis_tready,

// Write channel - AXI-Lite part
    output wire [AXI_ADDR_WIDTH-1:0] axi4m_awaddr,  // .awaddr
    output wire [2:0]  axi4m_awprot,  //       .awprot
    output reg         axi4m_awvalid, //       .awvalid
    input  wire        axi4m_awready, //       .awready
    output reg  [AXI_DATA_WIDTH-1:0] axi4m_wdata,   //       .wdata
    output reg         axi4m_wvalid,  //       .wvalid
    input  wire        axi4m_wready,  //       .wready
    output wire [(AXI_DATA_WIDTH>>3)-1:0]  axi4m_wstrb,
// Write channel - AXI set
    output wire [ID_WIDTH-1:0]  axi4m_awid,     // Write ID Tag
    output wire [7:0]  axi4m_awlen,         // Burst length
    output wire [2:0]  axi4m_awsize,        // Burst size
    output wire [1:0]  axi4m_awburst,       // Burst type
    output wire        axi4m_awlock,        // Busrst lock
    output wire [3:0]  axi4m_awcache,       // Memory type
    output wire        axi4m_wlast,         // Write last
    output wire [3:0]  axi4m_awqos,         // Quality of service
// Write respone
    input  wire [1:0]  axi4m_bresp,
    input  wire        axi4m_bvalid,  // Write response valid
    input  wire [0:0]  axi4m_bid,     // Response ID tag
    output wire        axi4m_bready,  //       .bready
    
// Read address channel     
    output wire [AXI_ADDR_WIDTH-1:0] axi4m_araddr,  //       .araddr
    output wire [2:0]  axi4m_arprot,  //       .arprot
    output reg         axi4m_arvalid, //       .arvalid
    input  wire        axi4m_arready, //       .arready
// Read address channel - AXI set
    output wire [ID_WIDTH-1:0]  axi4m_arid, 
    output wire [7:0]  axi4m_arlen,   // Burst length
    output wire [2:0]  axi4m_arsize,  // Burst size
    output wire [1:0]  axi4m_arburst, // Burst type
    output wire        axi4m_arlock,  // Lock type
    output wire [3:0]  axi4m_arcache, // Memory type
    output wire [3:0]  axi4m_arqos,   // Quality of service
// Read data channel
    input  wire [AXI_DATA_WIDTH-1:0] axi4m_rdata,   // Read data
    input  wire        axi4m_rlast,   // Read last
    input  wire [1:0]  axi4m_rresp,   // Read response
    input  wire        axi4m_rvalid,  // Read valid
    output reg         axi4m_rready,  // Read ready
    input  wire [0:0]  axi4m_rid,   // Read response id
    
// Global signals
    input  wire        aclk,
    input  wire        aresetn
);
    
//----- AXI Stream DATAWIDTH
parameter DATAWIDTH=8;
    
wire [31:0] reg_wdata;
wire reg_write;
reg  [31:0] status;
wire shift_out_state;
wire shift_out_en;
wire shift_out_data;
wire shift_in_state;
wire shift_in_en;
wire shift_in_data;

logic [AXI_ADDR_WIDTH-1:0] address;
logic [AXI_ADDR_WIDTH-1:0] addressw_aclk;
logic [AXI_ADDR_WIDTH-1:0] addressr_aclk;
reg  start_read;
reg  start_write, start_write_d1, start_write_d2;
reg  [7:0] burst_lengthw_aclk;
reg  [7:0] burst_lengthr_aclk;
reg  [1:0] burst_typew_aclk;
reg  [1:0] burst_typer_aclk;

logic [3:0] aclk_cnt;


// Double flip-flop for synthronization
logic start_read_aclk;
logic trigger_d1;
logic trigger;

//-----udp_matlab_axi_master_map
wire                 reset_status;
wire                 clock_status;
wire           [1:0] axis2m_awburst;
wire           [7:0] axis2m_awlen;
wire                 axis2m_wstart;
wire          [63:0] axis2m_waddr;
wire           [7:0] axis2m_wdata;
wire                 axis2m_wdatav;
reg                  axis2m_wresp_aclk;
reg                  axis2m_wresp_d1;
reg                  axis2m_wresp_re;
reg                  axis2m_wresp;
wire           [1:0] axis2m_arburst;
wire           [7:0] axis2m_arlen;
wire                 axis2m_rstart;
wire          [63:0] axis2m_raddr;
wire           [7:0] axis2m_rdata;
wire                 axis2m_rdenb;
reg                  axis2m_rresp;
reg                  axis2m_rresp_aclk;
reg                  axis2m_rresp_d1;
wire                 axis2m_rdvld;
wire                 axis2m_rresp_done;

// Assign write address channel constant values
assign axi4m_awid       = 0;
assign axi4m_arid       = 0;
assign axi4m_awlen      = burst_lengthw_aclk; 

generate
   if ( AXI_DATA_WIDTH == 32 ) begin
         assign axi4m_awsize     = 3'b010;   // 4 bytes
         assign axi4m_wstrb      = 4'b1111;
   end      
   else begin
         assign axi4m_awsize     = 3'b011;   // 8 bytes
         assign axi4m_wstrb      = 8'b11111111;
   end      
endgenerate

assign axi4m_awlock     = 1'b0;
assign axi4m_awcache    = 4'b0000;
assign axi4m_awqos      = 4'b0;
  
// Assign read address channel constant values
assign axi4m_arlen      = burst_lengthr_aclk;
generate
   if ( AXI_DATA_WIDTH == 32 ) 
         assign axi4m_arsize     = 3'b010;   // 4 bytes
   else
         assign axi4m_arsize     = 3'b011;   // 8 bytes
endgenerate

assign axi4m_arlock     = 1'b0;
assign axi4m_arcache    = 4'b0;
assign axi4m_arqos      = 4'b0;

assign axi4m_awaddr = addressw_aclk;

assign axi4m_bready = 1'b1;


assign axi4m_araddr = addressr_aclk;
assign axi4m_arprot = 3'b000;
assign axi4m_awprot = 3'b000;
assign axi4m_awburst = burst_typew_aclk;
assign axi4m_arburst = burst_typer_aclk;
    
localparam [7:0]  MAJOR_VER = 8'b1;
localparam [3:0]  MINOR_VER = 4'b0;
localparam [3:0]  APP_TYPE  = 4'h0; // Application type
localparam [15:0] SIGNATURE = 16'd8141; // Application type

localparam [31:0] AXIMASTER_IP_ID0 = {SIGNATURE, APP_TYPE, MAJOR_VER, MINOR_VER};
localparam [0:0]  AXIMASTER_DATA_64 = (AXI_DATA_WIDTH==32) ? 1'b0 : 1'b1 ;
localparam [0:0]  AXIMASTER_ADDRS_64 = (AXI_ADDR_WIDTH==32) ? 1'b0 : 1'b1 ;  
localparam [31:0] AXIMATER_IP_CONFIG = { 30'b0 , AXIMASTER_DATA_64 , AXIMASTER_ADDRS_64 } ;

function integer log2;
input integer value;
reg [31:0] shifted;
integer res;
begin
	if (value < 2)
		log2 = value;
	else
	begin
		shifted = value-1;
		for (res=0; shifted>0; res=res+1)
			shifted = shifted>>1;
		log2 = res;
	end
end
endfunction


localparam log2AXI_DATA_WIDTH = log2(AXI_DATA_WIDTH/8);

udp_matlab_axi_master_map #(.ID_WIDTH(ID_WIDTH),
  .DATAWIDTH(DATAWIDTH),
  .AXI_DATA_WIDTH(AXI_DATA_WIDTH),
  .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
  .AXIMASTER_IP_ID0(AXIMASTER_IP_ID0),
  .AXIMASTER_DATA_64(AXIMASTER_DATA_64),
  .AXIMASTER_ADDRS_64(AXIMASTER_ADDRS_64)
) u_udp_matlab_axi_master_map(
  .axis_aclk(axis_aclk),
  .axis_areset(udp_reset),
	
  .ch0_s_axis_tdata(s_axis_tdata),
  .ch0_s_axis_tvalid(s_axis_tvalid),
  .ch0_s_axis_tlast(s_axis_tlast),
  .ch0_s_axis_tready(s_axis_tready),
  .ch0_m_axis_tdata(m_axis_tdata),
  .ch0_m_axis_tvalid(m_axis_tvalid),
  .ch0_m_axis_tlast(m_axis_tlast),
  .ch0_m_axis_tready(m_axis_tready),

  .reset_status(reset_status),
  .clock_status(clock_status),
  
  .axis2m_awburst(axis2m_awburst),
  .axis2m_awlen(axis2m_awlen),
  .axis2m_wstart(axis2m_wstart),
  .axis2m_waddr(axis2m_waddr),
  .axis2m_wdata(axis2m_wdata),
  .axis2m_wdatav(axis2m_wdatav),
  .axis2m_wresp(axis2m_wresp),

  .axis2m_arburst(axis2m_arburst),
  .axis2m_arlen(axis2m_arlen),
  .axis2m_rstart(axis2m_rstart),
  .axis2m_raddr(axis2m_raddr),
  .axis2m_rdenb(axis2m_rdenb),
  .axis2m_rdata(axis2m_rdata),
  .axis2m_rdvld(axis2m_rdvld),
  .axis2m_rresp(axis2m_rresp),
  .axis2m_rresp_done(axis2m_rresp_done)
);

logic udp_reset_d1, udp_reset;
always_ff@(posedge axis_aclk) begin
    udp_reset_d1 <= axis_aresetn;
    udp_reset    <= !udp_reset_d1;
end

logic tmp1,tmp2,tmp3,tmp4;
logic aclk_reset;
always_ff@(posedge aclk) begin
    tmp1 <= udp_reset;
    tmp2 <= tmp1;
    tmp3 <= aresetn;
    tmp4 <= tmp3;
    aclk_reset <= tmp2 || !tmp4;
end

logic trigger_udp, trigger_udp_d1;
always_ff@(posedge axis_aclk) begin
    if(udp_reset) begin
        start_read <= 1'b0;
    end
    else begin
        trigger_udp <= trigger_d1;
        trigger_udp_d1 <= trigger_udp;
        if(axis2m_rstart) begin
            start_read <= 1'd1;
        end
        else if (trigger_udp_d1) begin
            start_read <= 1'b0;
        end
    end
end    

       
always_ff@(posedge aclk) begin      
    start_read_aclk <= start_read;
    trigger         <= start_read_aclk;
    trigger_d1      <= trigger;
    burst_lengthw_aclk <= axis2m_awlen;
    burst_lengthr_aclk <= axis2m_arlen;
    addressw_aclk    <= axis2m_waddr;
    addressr_aclk    <= axis2m_raddr;
    burst_typew_aclk <= axis2m_awburst;
    burst_typer_aclk <= axis2m_arburst;
end

assign reset_status = !aresetn;
assign clock_status = !aclk_cnt[3];

always_ff@(posedge aclk or posedge aclk_reset) begin
	if(aclk_reset)
		aclk_cnt <= 4'b0;
	else if(aclk_cnt!=4'b1111) begin
		aclk_cnt <= aclk_cnt + 1'b1;	
	end
end
   
//=============== AXI Read=====================================================================
// Dual-clock RAM for read
logic [23:0] read_count;
logic readram_wr, readram_rd;
logic [7:0] readram_waddr, readram_raddr;
logic [AXI_DATA_WIDTH-1:0] readram_q;
assign readram_waddr = read_count[7:0];
udp_master_dcram #(.DATA_WIDTH(AXI_DATA_WIDTH)) readram(        
    .wdata(axi4m_rdata),
    .waddr(readram_waddr),
    .raddr(readram_raddr),
    .wr(readram_wr),
    .rd(readram_rd),
    .q(readram_q),
    .rclk(axis_aclk),
    .wclk(aclk));

// Read control axis_aclk domain
reg  [log2AXI_DATA_WIDTH-1:0] bitcount; // Count from 0 to 4/8
reg  [AXI_DATA_WIDTH-1:0] shift_reg;
assign axis2m_rdata = shift_reg[7:0];    
assign readram_rd = axis2m_rdenb && (bitcount==0);//shift_out_state && (bitcount==0);  
always_ff @(posedge axis_aclk) begin
    if(udp_reset) begin
        readram_raddr <= 'b0;   
        bitcount <= 'd0;
    end else if (axis2m_rresp_done) begin
        readram_raddr <= 'd0;   
        bitcount <= 'd0;
    end else if(axis2m_rdvld) begin       
        shift_reg <= {8'd0,shift_reg[AXI_DATA_WIDTH-1:8]};
        bitcount <= bitcount + 1'b1;
        if(bitcount == 0) begin
           shift_reg <= readram_q;
           readram_raddr <= readram_raddr + 1'b1;
        end            
    end
end

// Read aclk domain
assign readram_wr = axi4m_rvalid;
always@(posedge aclk) begin
    if (aclk_reset) begin
        axi4m_arvalid <= 1'b0;
        axi4m_rready  <= 1'b0;
        axis2m_rresp_aclk <= 1'b0;
        read_count <= 'b0;
    end
    else if(trigger && !trigger_d1) begin
        axi4m_arvalid <= 1'b1;
        axi4m_rready <= 1'b0;
        axis2m_rresp_aclk <= 1'b0;
        read_count <= 'b0;
    end
    else if( axi4m_arvalid && axi4m_arready) begin
        axi4m_arvalid <= 1'b0;
        axi4m_rready  <= 1'b1;
    end
    else if( axi4m_rready && axi4m_rvalid) begin
        if(axi4m_rlast) begin
            axis2m_rresp_aclk <= 1'b1;
            axi4m_rready <= 1'b0;
        end
        read_count <= read_count + 1'b1;
    end
end
//=============== End of AXI Read=============================================================

//=============== AXI Write=====================================================================
// Dual-clock RAM for write
logic [23:0] write_count;
logic writeram_wr, writeram_rd;
logic [7:0] writeram_waddr, writeram_raddr;
logic [7:0] writeram_raddr_reg;
logic [AXI_DATA_WIDTH-1:0] writeram_q;
logic [AXI_DATA_WIDTH-1:0] writeram_wdata;
udp_master_dcram #(.DATA_WIDTH(AXI_DATA_WIDTH)) writeram(         
    .wdata(writeram_wdata),
    .waddr(writeram_waddr),
    .raddr(writeram_raddr),
    .wr(writeram_wr),
    .rd(writeram_rd),
    .q(writeram_q),
    .rclk(aclk),
    .wclk(axis_aclk));

// Process to write into dcram
logic shift_in_state_d1;
logic [AXI_DATA_WIDTH-1:0] shift_in_reg;
assign writeram_wdata = shift_in_reg;
logic writeram_wr_comb ;
logic [7:0] writeram_waddr_comb ;

always@(posedge axis_aclk) begin
  axis2m_wresp_d1 <= axis2m_wresp_aclk;
  axis2m_wresp <= axis2m_wresp_d1;
  
  if (udp_reset)
    axis2m_wresp_re <= 1'd0;
  else if (axis2m_wresp_d1 && (!axis2m_wresp))
    axis2m_wresp_re <= 1'd1;
  else
    axis2m_wresp_re <= 1'd0;

  axis2m_rresp_d1 <= axis2m_rresp_aclk;
  axis2m_rresp <= axis2m_rresp_d1;
end  
always@(posedge axis_aclk) begin
    if(udp_reset) begin// || ~axis2m_wstart) begin
        write_count <= 'b0;
        writeram_wr <= 1'b0;
    end else if (axis2m_wresp_re) begin
      write_count <= 'd0;
	  writeram_wr <= 1'b0;
    end else begin
        if(axis2m_wdatav) begin
            shift_in_reg[AXI_DATA_WIDTH-9:0] <= shift_in_reg[AXI_DATA_WIDTH-1:8];  
            shift_in_reg[AXI_DATA_WIDTH-1:AXI_DATA_WIDTH-8] <= axis2m_wdata;   
            write_count <= write_count + 1'b1; 
            writeram_wr <= writeram_wr_comb ;
            writeram_waddr <= writeram_waddr_comb ;  
            // Need to protect from overflow
	    end
        else
            writeram_wr <= 1'b0;
    end    
end    

generate 
	if ( AXI_DATA_WIDTH == 32) begin
	   always @(*) begin
         writeram_wr_comb = (write_count[1:0] == 2'b11) && (write_count[15:10]==0);
         writeram_waddr_comb = write_count[9:2];
       end
	end
	else begin
	   always @(*) begin
	     writeram_wr_comb = (write_count[2:0] == 3'b111) && (write_count[15:11]==0);
         writeram_waddr_comb = write_count[10:3];
       end  
	end
endgenerate

always@(posedge axis_aclk) begin
    if(udp_reset) begin
        start_write <= 1'b0;
    end
    else begin
        // Detect positive edge of axis2m_wstart
        shift_in_state_d1 <= axis2m_wstart;
        if(!shift_in_state_d1 && axis2m_wstart) begin
            start_write <= 1'b1;
        end    
        else if(shift_in_state_d1 && !axis2m_wstart) begin
            start_write <= 1'b0;
        end
    end
end

always@(posedge aclk) begin
    start_write_d1 <= start_write;
    start_write_d2 <= start_write_d1;
end

enum logic[2:0] {WSTATE_IDLE, WSTATE_RFIRST, WSTATE_WAIT_BOTH, WSTATE_WAIT_AWREADY, WSTATE_WAIT_WREADY, WSTATE_WAIT_BVALID} 
    state_write;

assign axi4m_wdata = writeram_q;

always@(posedge aclk) begin
    if (aclk_reset) begin
        writeram_raddr_reg <= 'b0;
        writeram_rd <= 1'b0;    
    end
    else if(start_write_d1 && !start_write_d2 && state_write==WSTATE_IDLE) begin
        // Read out the first data
        writeram_raddr_reg <= 'b0;
        writeram_rd <= 1'b1;
    end
    else if(state_write!=WSTATE_IDLE) begin
        writeram_rd <= 1'b1;
        writeram_raddr_reg <= writeram_raddr ;
    end
    else begin
        writeram_rd <= 1'b0;
    end
end

assign writeram_raddr = (axi4m_wvalid&&axi4m_wready)? writeram_raddr_reg+1'b1:writeram_raddr_reg;

// Write process
logic [7:0] write_word_count;
always@(posedge aclk) begin
    if(aclk_reset) begin
        write_word_count <= 'b0;
    end
    else if (state_write==WSTATE_IDLE) begin
        write_word_count <= 'b0;
    end
    else if (axi4m_wvalid && axi4m_wready) begin
        write_word_count <= write_word_count + 1'b1;
    end
end

assign axi4m_wlast = (write_word_count == burst_lengthw_aclk) && axi4m_wvalid;

   
always@(posedge aclk) begin
    if (aclk_reset) begin
        axi4m_awvalid <= 1'b0;
        axi4m_wvalid <= 1'b0;
        state_write <= WSTATE_IDLE;
        axis2m_wresp_aclk <= 1'b0;
    end
    else if(start_write_d1 && !start_write_d2 && state_write==WSTATE_IDLE) begin
        state_write <= WSTATE_RFIRST;
    end
    else if(state_write==WSTATE_RFIRST) begin
        // Assert awvalid and wvalid at the same time
        axi4m_awvalid <= 1'b1;
        axi4m_wvalid <= 1'b1;
        state_write <= WSTATE_WAIT_BOTH;
        axis2m_wresp_aclk <= 1'b0;
    end
    else if(state_write==WSTATE_WAIT_BOTH) begin
        if(axi4m_awready && axi4m_wready && axi4m_wlast) begin
            state_write <= WSTATE_WAIT_BVALID;
            axi4m_awvalid <= 1'b0;
            axi4m_wvalid <= 1'b0;
        end
        else if(axi4m_awready) begin
            state_write <= WSTATE_WAIT_WREADY;
            axi4m_awvalid <= 1'b0;
        end
        else if(axi4m_wready && axi4m_wlast) begin
            state_write <= WSTATE_WAIT_AWREADY;
            axi4m_wvalid <= 1'b0;
        end
    end
    else if(state_write==WSTATE_WAIT_WREADY) begin
        if(axi4m_wready && axi4m_wlast) begin
            state_write <= WSTATE_WAIT_BVALID;      
            axi4m_wvalid <= 1'b0;
        end
    end
    else if(state_write==WSTATE_WAIT_AWREADY) begin
        if(axi4m_awready) begin
            state_write <= WSTATE_WAIT_BVALID;  
            axi4m_awvalid <= 1'b0;          
        end
    end
    else if((state_write==WSTATE_WAIT_BVALID) && axi4m_bvalid) begin        
        state_write <= WSTATE_IDLE;
        axis2m_wresp_aclk <= 1'b1;
    end
end

endmodule


module udp_master_dcram #(parameter DATA_WIDTH = 32,
                                    ADDR_WIDTH = 8)(
    input [DATA_WIDTH - 1:0] wdata,
    input [ADDR_WIDTH - 1:0] raddr, 
    input [ADDR_WIDTH - 1:0] waddr,
    input wr,
    input rd, 
    input rclk, 
    input wclk,
    output reg [DATA_WIDTH - 1:0] q
);
    localparam DEPTH = 2**ADDR_WIDTH;

    // The RAM variable
    (* ramstyle = "no_rw_check" *) reg [DATA_WIDTH - 1:0] ram [DEPTH - 1:0]; 
    
    // Write
    always @ (posedge wclk) begin       
        if (wr)
            ram[waddr] <= wdata;
    end
    
    // Read 
    always @ (posedge rclk) begin
        if (rd)
            q <= ram[raddr];
    end
endmodule
