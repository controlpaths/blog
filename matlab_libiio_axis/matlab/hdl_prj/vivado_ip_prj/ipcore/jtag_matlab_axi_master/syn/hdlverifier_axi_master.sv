
`timescale 1 ns / 1 ns
module hdlverifier_axi_master #
(
    parameter ID_WIDTH=1,
    parameter AXI_DATA_WIDTH=32,
    parameter AXI_ADDR_WIDTH=32
)
(
// Write channel - AXI-Lite part
    output wire [AXI_ADDR_WIDTH-1:0] axi4m_awaddr,  // axm_m0.awaddr
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
    input  wire [ID_WIDTH-1:0]  axi4m_bid,     // Response ID tag
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
    input  wire [ID_WIDTH-1:0]  axi4m_rid,   // Read response id
    
// Global signals
    input  wire        aclk,
    input  wire        aresetn
);
    

localparam JTAG_ID=3;
    
wire tck;
wire jtag_reset;
wire [4:0]  reg_addr;
wire [31:0] reg_wdata;
wire reg_write;
reg  [31:0] reg_rdata;
reg  [31:0] status;
wire shift_out_state;
wire shift_out_en;
wire shift_out_data;
wire shift_in_state;
wire shift_in_en;
wire shift_in_data;

logic [AXI_ADDR_WIDTH-1:0] address;
logic [AXI_ADDR_WIDTH-1:0] address_aclk;
reg  start_read;
reg  start_write, start_write_d1, start_write_d2;
reg  [7:0] burst_length;
reg  [7:0] burst_length_aclk;
reg  [1:0] burst_type;
reg  [1:0] burst_type_aclk;

logic [3:0] aclk_cnt;


// Double flip-flop for synthronization
logic start_read_aclk;
logic trigger_d1;
logic trigger;

// Assign write address channel constant values
assign axi4m_awid       = 0;
assign axi4m_arid       = 0;
assign axi4m_awlen      = burst_length_aclk; 

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
assign axi4m_arlen      = burst_length_aclk;
generate
   if ( AXI_DATA_WIDTH == 32 ) 
         assign axi4m_arsize     = 3'b010;   // 4 bytes
   else
         assign axi4m_arsize     = 3'b011;   // 8 bytes
endgenerate

assign axi4m_arlock     = 1'b0;
assign axi4m_arcache    = 4'b0;
assign axi4m_arqos      = 4'b0;

assign axi4m_awaddr = address_aclk;

assign axi4m_bready = 1'b1;


assign axi4m_araddr = address_aclk;
assign axi4m_arprot = 3'b000;
assign axi4m_awprot = 3'b000;
assign axi4m_awburst = burst_type_aclk;
assign axi4m_arburst = burst_type_aclk;
    
localparam [7:0] MAJOR_VER = 8'b1;
localparam [3:0] MINOR_VER = 4'b1;
localparam [3:0] APP_TYPE  = 4'h0; // Application type
localparam [15:0] SIGNATURE = 16'd8141; // Application type

localparam [31:0] AXIMASTER_IP_ID0 = {SIGNATURE, APP_TYPE, MAJOR_VER, MINOR_VER};
localparam [0:0] AXIMASTER_DATA_64 = (AXI_DATA_WIDTH==32) ? 1'b0 : 1'b1 ;
localparam [0:0] AXIMASTER_ADDRS_64 = (AXI_ADDR_WIDTH==32) ? 1'b0 : 1'b1 ;  
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


localparam log2AXI_DATA_WIDTH = log2(AXI_DATA_WIDTH);
//localparam DATA_COUNT_WIDTH = log2(AXI_DATA_WIDTH);

always_comb begin
    unique case(reg_addr)
        5'd1 : reg_rdata <= status;
        5'd2 : reg_rdata <= AXIMATER_IP_CONFIG;  
        default : reg_rdata <= AXIMASTER_IP_ID0;        
    endcase
end
    
hdlverifier_jtag_core #(.JTAG_ID(JTAG_ID))
u_jtag(
    .*,
    .reset(jtag_reset)
);

logic jtag_reset_d1, tck_reset;
always_ff@(posedge tck) begin
    jtag_reset_d1 <= jtag_reset;
    tck_reset     <= jtag_reset_d1;
end

logic tmp1,tmp2,tmp3,tmp4;
logic aclk_reset;
always_ff@(posedge aclk) begin
    tmp1 <= tck_reset;
    tmp2 <= tmp1;
    tmp3 <= aresetn;
    tmp4 <= tmp3;
    aclk_reset <= tmp2 || !tmp4;
end

logic trigger_tck, trigger_tck_d1;
always_ff@(posedge tck) begin
    if(tck_reset) begin
        start_read <= 1'b0;
    end
    else begin
        trigger_tck <= trigger_d1;
        trigger_tck_d1 <= trigger_tck;
        if(reg_write && reg_addr==5'b0) begin
            start_read <= reg_wdata[0];
        end
        else if (trigger_tck_d1) begin
            start_read <= 1'b0;
        end
    end
end    

generate
if ( AXI_ADDR_WIDTH == 32 ) begin
     always@(posedge tck) begin
          if(tck_reset) begin
               address <= 32'b0;
         end
         else if(reg_write) begin
              if(reg_addr==5'd1) 
                  address <= reg_wdata;
              else if(reg_addr==5'd4) begin
                  burst_length <= reg_wdata[7:0];   
                  burst_type   <= reg_wdata[9:8];
              end
         end
     end
end
else begin
   always@(posedge tck) begin
         if(tck_reset) 
              address <= 64'b0;
         else if(reg_write) begin
                if(reg_addr==5'd1)   // Lower 32 bits are driven here 
                    address[31:0] <= reg_wdata;
                else if (reg_addr==5'd2)  // Now we are using 1 more register with address 2 to drive axi4m_araddr,axi4m_awaddr
                    address[63:32] <= reg_wdata;  // Upper 32 bits are driven here
                else if(reg_addr==5'd4) begin
                    burst_length <= reg_wdata[7:0];   
                    burst_type   <= reg_wdata[9:8];
                end
          end
   end 
end
endgenerate
       
always_ff@(posedge aclk) begin      
    start_read_aclk <= start_read;
    trigger         <= start_read_aclk;
    trigger_d1      <= trigger;
    burst_length_aclk <= burst_length;
    address_aclk    <= address;
    burst_type_aclk <= burst_type;
end

assign status[2] = !aresetn;
assign status[3] = !aclk_cnt[3];

always_ff@(posedge aclk or posedge tmp3) begin
	if(tmp3) // tck_reset
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
jtag_master_dcram #(.DATA_WIDTH(AXI_DATA_WIDTH)) readram(        
    .wdata(axi4m_rdata),
    .waddr(readram_waddr),
    .raddr(readram_raddr),
    .wr(readram_wr),
    .rd(readram_rd),
    .q(readram_q),
    .rclk(tck),
    .wclk(aclk));

// Read control tck domain
reg  [log2AXI_DATA_WIDTH-1:0] bitcount; // Count from 0 to 31/63
reg  [AXI_DATA_WIDTH-1:0] shift_reg;
assign shift_out_data = shift_reg[0];    
assign readram_rd = shift_out_state && (bitcount==0);  
always_ff @(posedge tck) begin
    if(tck_reset || !shift_out_state) begin
        readram_raddr <= 'b0;   
        bitcount <= 'b0;
    end
    else if(shift_out_state) begin       
        if(shift_out_en) begin
            shift_reg <= {1'b0,shift_reg[AXI_DATA_WIDTH-1:1]};
            bitcount <= bitcount + 1'b1;
            if(bitcount == 1) begin
                shift_reg <= readram_q;
                readram_raddr <= readram_raddr + 1'b1;
            end            
        end
    end
end

// Read aclk domain
assign readram_wr = axi4m_rvalid;
always@(posedge aclk) begin
    if (aclk_reset) begin
        axi4m_arvalid <= 1'b0;
        axi4m_rready  <= 1'b0;
        status[0] <= 1'b0;
        read_count <= 'b0;
    end
    else if(trigger && !trigger_d1) begin
        axi4m_arvalid <= 1'b1;
        axi4m_rready <= 1'b0;
        status[0] <= 1'b0;
        read_count <= 'b0;
    end
    else if( axi4m_arvalid && axi4m_arready) begin
        axi4m_arvalid <= 1'b0;
        axi4m_rready  <= 1'b1;
    end
    else if( axi4m_rready && axi4m_rvalid) begin
        if(axi4m_rlast) begin
            //read_data_clk <= axi4m_rdata;
            status[0] <= 1'b1;
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
//assign readram_waddr = read_count[7:0];
jtag_master_dcram #(.DATA_WIDTH(AXI_DATA_WIDTH)) writeram(         
    .wdata(writeram_wdata),
    .waddr(writeram_waddr),
    .raddr(writeram_raddr),
    .wr(writeram_wr),
    .rd(writeram_rd),
    .q(writeram_q),
    .rclk(aclk),
    .wclk(tck));

// Process to write into dcram
logic shift_in_state_d1;
logic [AXI_DATA_WIDTH-1:0] shift_in_reg;
assign writeram_wdata = shift_in_reg;
logic writeram_wr_comb ;
logic [7:0] writeram_waddr_comb ;

always@(posedge tck) begin
    if(tck_reset || ~shift_in_state) begin
        write_count <= 'b0;
        writeram_wr <= 1'b0;
    end
    else begin
        if(shift_in_en) begin
            shift_in_reg[AXI_DATA_WIDTH-2:0] <= shift_in_reg[AXI_DATA_WIDTH-1:1];  
            shift_in_reg[AXI_DATA_WIDTH-1] <= shift_in_data;   
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
         writeram_wr_comb = (write_count[4:0] == 5'b11111) && (write_count[15:13]==0);
         writeram_waddr_comb = write_count[12:5];
       end
	end
	else begin
	   always @(*) begin
	     writeram_wr_comb = (write_count[5:0] == 6'b111111) && (write_count[15:14]==0);
         writeram_waddr_comb = write_count[13:6];
       end  
	end
endgenerate

always@(posedge tck) begin
    if(tck_reset) begin
        start_write <= 1'b0;
    end
    else begin
        // Detect negative edge of shift_in_state
        shift_in_state_d1 <= shift_in_state;
        if(shift_in_state_d1 && !shift_in_state) begin
            start_write <= 1'b1;
        end    
        else if(!shift_in_state_d1 && shift_in_state) begin
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

assign axi4m_wlast = (write_word_count == burst_length_aclk) && axi4m_wvalid;

   
always@(posedge aclk) begin
    if (aclk_reset) begin
        axi4m_awvalid <= 1'b0;
        axi4m_wvalid <= 1'b0;
        state_write <= WSTATE_IDLE;
        status[1] <= 1'b0;
    end
    else if(start_write_d1 && !start_write_d2 && state_write==WSTATE_IDLE) begin
        state_write <= WSTATE_RFIRST;
    end
    else if(state_write==WSTATE_RFIRST) begin
        // Assert awvalid and wvalid at the same time
        axi4m_awvalid <= 1'b1;
        axi4m_wvalid <= 1'b1;
        state_write <= WSTATE_WAIT_BOTH;
        status[1] <= 1'b0;
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
        status[1] <= 1'b1;
    end
end

endmodule


module jtag_master_dcram #(parameter DATA_WIDTH = 32,
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
