module hdlverifier_axi_memcpy
#(
    parameter ID_WIDTH=1,
    parameter AXI_DATA_WIDTH=32,
    parameter AXI_ADDR_WIDTH=32
)
(
//*********************** First AXI Master Interface - Host ***************************************
    output reg [AXI_ADDR_WIDTH-1:0] axim_src_araddr,  //       .araddr
    output wire [2:0]  axim_src_arprot,  //       .arprot
    output reg         axim_src_arvalid, //       .arvalid
    input  wire        axim_src_arready, //       .arready
    output wire [ID_WIDTH-1:0]  axim_src_arid, 
    output logic [7:0]  axim_src_arlen,   // Burst length
    output wire [2:0]  axim_src_arsize,  // Burst size
    output wire [1:0]  axim_src_arburst, // Burst type
    output wire        axim_src_arlock,  // Lock type
    output wire [3:0]  axim_src_arcache, // Memory type
    output wire [3:0]  axim_src_arqos,   // Quality of service
    input  wire [AXI_DATA_WIDTH-1:0] axim_src_rdata,   // Read data
    input  wire        axim_src_rlast,   // Read last
    input  wire [1:0]  axim_src_rresp,   // Read response, not used?
    input  wire        axim_src_rvalid,  // Read valid
    output reg         axim_src_rready,  // Read ready
    input  wire [0:0]  axim_src_rid,   // Read response id, not used
    input  wire        aclk_src,
    input  wire        aresetn_src, 

//*********************** Second AXI Master Interface - Target ***************************************
    output reg [AXI_ADDR_WIDTH-1:0] axim_dst_awaddr,  // axm_m0.awaddr
    output wire [2:0]  axim_dst_awprot,  //       .awprot
    output reg         axim_dst_awvalid, //       .awvalid
    input  wire        axim_dst_awready, //       .awready
    output reg  [AXI_DATA_WIDTH-1:0] axim_dst_wdata,   //       .wdata
    output reg         axim_dst_wvalid,  //       .wvalid
    input  wire        axim_dst_wready,  //       .wready
    output wire [(AXI_DATA_WIDTH>>3)-1:0]  axim_dst_wstrb,
    output wire [ID_WIDTH-1:0]  axim_dst_awid,     // Write ID Tag
    output reg  [7:0]  axim_dst_awlen,         // Burst length
    output wire [2:0]  axim_dst_awsize,        // Burst size
    output wire [1:0]  axim_dst_awburst,       // Burst type
    output wire        axim_dst_awlock,        // Busrst lock
    output wire [3:0]  axim_dst_awcache,       // Memory type
    output logic       axim_dst_wlast,         // Write last
    output wire [3:0]  axim_dst_awqos,         // Quality of service
    input  wire [1:0]  axim_dst_bresp,
    input  wire        axim_dst_bvalid,  // Write response valid
    input  wire [0:0]  axim_dst_bid,     // Response ID tag
    output reg         axim_dst_bready,  //       .bready

    input  wire        aclk_dst,
    input  wire        aresetn_dst,
    
//*********************** Control ports *******************************************************
    input wire [AXI_ADDR_WIDTH-1:0] src_addr,
    input wire [AXI_ADDR_WIDTH-1:0] dst_addr,
	input wire [2:0] arsize_in,
	input wire [2:0] awsize_in,
	input wire [23:0] words2transfer,
    input wire start,
    output reg complete,
	input wire sw_reset
);

	function integer clogb2 (input integer bit_depth);              
	begin                                                           
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
				bit_depth = bit_depth >> 1;                                 
	    end                                                           
	endfunction  

	// Fixed signals
	assign axim_dst_awcache = 4'b0; //4'b0010;
	assign axim_src_arcache = 4'b0; //4'b0010;
	assign axim_src_arlock  = 1'b0;
	assign axim_dst_awlock  = 1'b0;
	assign axim_src_arqos   = 1'b0;
	assign axim_dst_awqos   = 1'b0;
	assign axim_src_arsize  = arsize_in;   // burst size = 4 bytes
	assign axim_dst_awsize 	= awsize_in;   //clogb2((AXI_DATA_WIDTH/8)-1);	// burst size = 4 bytes
	assign axim_src_arprot 	= 3'b000;
	assign axim_dst_awprot 	= 3'b000;
	assign axim_src_arid    = 0;
	assign axim_dst_awid    = 0;
	assign axim_dst_wstrb = {(AXI_DATA_WIDTH/8){1'b1}};
	
	// FIXME: allows this to be configured via ports. 
	assign axim_src_arburst = 2'b01;
	assign axim_dst_awburst = 2'b01;
	
	//**** Reset logic ****
	logic tmp1,tmp2,tmp3,tmp4;
	logic reset_internal;
	always_ff@(posedge aclk_src) begin
		tmp1 <= sw_reset;
		tmp2 <= tmp1;
		tmp3 <= aresetn_dst;
		tmp4 <= tmp3;
		reset_internal <= tmp2 || !tmp4;
	end	
	// **** end reset logic ****
	
    logic fifo_full, fifo_empty, fifo_rdreq, fifo_wrreq;
	assign fifo_wrreq = axim_src_rvalid && axim_src_rready;
	
    hdlverifier_sync_fifo #(.DATA_WIDTH(AXI_DATA_WIDTH), .ADDR_WIDTH(8) ) fifo(
        .wdata(axim_src_rdata),
		.rdata(axim_dst_wdata),
        .clk(aclk_src),
        .wrreq(fifo_wrreq),
        .rdreq(fifo_rdreq),
        .full(fifo_full),
        .empty(fifo_empty),
        .aclr(reset_internal));
		

		
	// **** Read logic ****
	logic start_d1;
	logic [23:0] read_remain;	
	enum {RSIDLE, RSADDR, RSDATA} rstate;	
	
	assign axim_src_rready = (rstate==RSDATA) && !fifo_full;
	always_ff@(posedge aclk_src) begin
		start_d1 <= start;
		if(reset_internal) begin
			start_d1 <= 0;
			read_remain <= 0;
			rstate <= RSIDLE;
			axim_src_arvalid <= 1'b0;
			//axim_src_rready  <= 1'b0;
			axim_src_arlen <= 0;
			axim_src_araddr <= 0;
		end
		else if(rstate==RSIDLE) begin
			//axim_src_rready <= 1'b0;
			if( start && !start_d1 ) begin // Start read
				rstate = RSADDR;
				//axim_src_arvalid <= 1'b1;
				read_remain <= words2transfer;
				axim_src_araddr <= src_addr;			
			end
		end
		else if(rstate == RSADDR) begin
			axim_src_arlen <= read_remain[23:8]==0? read_remain[7:0] : 8'hFF;
			axim_src_arvalid <= 1'b1;
			if(axim_src_arvalid && axim_src_arready) begin
				rstate <= RSDATA;
				axim_src_arvalid <= 1'b0;
			end
		end 
		else if( rstate == RSDATA) begin
			//axim_src_rready <= !fifo_full;
			if(axim_src_rvalid && axim_src_rready) begin
				read_remain <= read_remain - 1'b1;
				axim_src_araddr <= axim_src_araddr + AXI_DATA_WIDTH/8;
				if(axim_src_rlast) begin			
					if( read_remain == 0) begin
						rstate <= RSIDLE;
						read_remain <= 0;
					end
					else begin
						//axim_src_arvalid <= 1'b1;
						rstate <= RSADDR;
						//axim_src_arlen = read_remain[7:0];
					end
				end
			end				
		end 
	end	
	// **** End Read logic ****
	// **** Write Logic ****
	logic start_d2;
	logic [23:0] write_remain;	
	logic [7:0] write_count;
	logic [AXI_ADDR_WIDTH-1:0] dst_addr_reg;
	logic write_done;
	enum {WSIDLE, WSADDR, WSDATA, WSAWVALID, WSBVALID} wstate;
	
	


	//assign axim_dst_wvalid = (wstate == WSDATA) && !fifo_empty;
	assign fifo_rdreq = (wstate == WSDATA) && (!axim_dst_wvalid || axim_dst_wready) && !fifo_empty && !axim_dst_wlast;
	
	assign axim_dst_wlast = axim_dst_wvalid && (write_count==0);
	
	always_ff@(posedge aclk_dst) begin
		start_d2 <= start;
		if(reset_internal) begin
			start_d2 <= 1'b0;
			write_remain <= 0;
			wstate <= WSIDLE;
			write_done <= 0;
			axim_dst_awvalid <= 1'b0;
			axim_dst_bready <= 1'b0;
			//axim_dst_wvalid <= 1'b0;
			complete <= 1'b0;
			axim_dst_wvalid <= 1'b0;
		end
		else if(wstate==WSIDLE) begin			
			axim_dst_wvalid <= 1'b0;
			if( start && !start_d2) begin
				wstate <= WSADDR;
				write_remain <= words2transfer;
				dst_addr_reg <= dst_addr;
				complete <= 1'b0;				
			end
		end
		else if ( wstate == WSADDR ) begin		
			if(!fifo_empty) begin
				axim_dst_awaddr <= dst_addr_reg;			
				axim_dst_awlen <= write_remain[23:8]==0? write_remain[7:0] : 8'hFF;
				write_count <= write_remain[23:8]==0? write_remain[7:0] : 8'hFF;
				axim_dst_awvalid <= 1'b1;			
				wstate <= WSDATA;
				axim_dst_wvalid <= 1'b0;
				//axim_dst_wvalid <= 1'b0;
			end 
		end
		else if ( wstate == WSDATA ) begin
			if(axim_dst_awready) begin
				axim_dst_awvalid <= 1'b0;
			end			
			
			if(fifo_rdreq) 
				axim_dst_wvalid <= 1'b1;
			else if(axim_dst_wvalid && axim_dst_wready)
				axim_dst_wvalid <= 1'b0;
			
			//if(fifo_rdreq) 
			//	axim_dst_wvalid <= 1'b1;
			//else if(fifo_empty)
			//	axim_dst_wvalid <= 1'b0; // We don't have data in pipeline, stop
			
			//read_first_sample <= !fifo_empty;			
			if( axim_dst_wready && axim_dst_wvalid ) begin
				write_remain <= write_remain - 1'b1;
				write_count <= write_count - 1'b1;
				dst_addr_reg <= dst_addr_reg + AXI_DATA_WIDTH/8;
				if(write_count==0) begin
					if(axim_dst_awready || !axim_dst_awvalid) begin
						wstate <= WSBVALID;
						axim_dst_bready <= 1'b1;
					end
					else begin
						wstate <= WSAWVALID;						
					end
					write_done <= (write_remain==0);					
					//axim_dst_wvalid <= 1'b0;
				end
			end
		end
		else if( wstate == WSAWVALID) begin
			if(axim_dst_awready) begin
				axim_dst_awvalid <= 1'b0;
				wstate <= WSBVALID;
				axim_dst_bready <= 1'b1;
			end			
		end
		else if( wstate == WSBVALID ) begin
			if(axim_dst_bvalid) begin
				axim_dst_bready <= 1'b0;
				if( write_done ) begin
					wstate <= WSIDLE;
					complete <= 1'b1;
				end 
				else begin
					wstate <= WSADDR;					
				end
			end 
		end		
	end
	
	
endmodule
    