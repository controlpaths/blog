
`timescale 1 ns / 1 ns
module pcie_matlab_axi_master #(
    parameter ID_WIDTH=1,
    parameter AXI_DATA_WIDTH=128,
    parameter AXI_ADDR_WIDTH=32
)
(
///////// AXI4 Lite slave interface for control registers /////////////////////////////
//    input wire  axis_aclk,
//    input wire  axis_aresetn,
    input wire [4 : 0] axis_awaddr,
    input wire  axis_awvalid,
    output wire  axis_awready,
    input wire [31 : 0] axis_wdata,
    input wire  axis_wvalid,
    output wire  axis_wready,
    output wire  axis_bvalid,
    input wire  axis_bready,
    input wire [4 : 0] axis_araddr,
    input wire  axis_arvalid,
    output wire  axis_arready,
    output wire [31 : 0] axis_rdata,
    output wire  axis_rvalid,
    input wire  axis_rready, 
    input logic [2:0]  axis_awprot,  //       .awprot
    input logic [3:0] axis_wstrb,
    output  logic [1:0]  axis_bresp,
    input logic [2:0]  axis_arprot,  //       .arprot
    output  logic [1:0]  axis_rresp,  
//*********************** First AXI Master Interface ***************************************
// Write channel - AXI-Lite part
    output wire [AXI_ADDR_WIDTH-1:0] axm1_awaddr,  // axm_m0.awaddr
    output wire [2:0]  axm1_awprot,  //       .awprot
    output reg         axm1_awvalid, //       .awvalid
    input  wire        axm1_awready, //       .awready
    output reg  [AXI_DATA_WIDTH-1:0] axm1_wdata,   //       .wdata
    output reg         axm1_wvalid,  //       .wvalid
    input  wire        axm1_wready,  //       .wready
    output wire [(AXI_DATA_WIDTH>>3)-1:0]  axm1_wstrb,
	
// Write channel - AXI set
    output wire [ID_WIDTH-1:0]  axm1_awid,     // Write ID Tag
    output wire [7:0]  axm1_awlen,         // Burst length
    output wire [2:0]  axm1_awsize,        // Burst size
    output wire [1:0]  axm1_awburst,       // Burst type
    output wire        axm1_awlock,        // Busrst lock
    output wire [3:0]  axm1_awcache,       // Memory type
    output wire        axm1_wlast,         // Write last
    output wire [3:0]  axm1_awqos,         // Quality of service
// Write respone
    input  wire [1:0]  axm1_bresp,
    input  wire        axm1_bvalid,  // Write response valid
    input  wire [0:0]  axm1_bid,     // Response ID tag
    output wire        axm1_bready,  //       .bready
    
// Read address channel     
    output wire [AXI_ADDR_WIDTH-1:0] axm1_araddr,  //       .araddr
    output wire [2:0]  axm1_arprot,  //       .arprot
    output reg         axm1_arvalid, //       .arvalid
    input  wire        axm1_arready, //       .arready
// Read address channel - AXI set
    output wire [ID_WIDTH-1:0]  axm1_arid, 
    output wire [7:0]  axm1_arlen,   // Burst length
    output wire [2:0]  axm1_arsize,  // Burst size
    output wire [1:0]  axm1_arburst, // Burst type
    output wire        axm1_arlock,  // Lock type
    output wire [3:0]  axm1_arcache, // Memory type
    output wire [3:0]  axm1_arqos,   // Quality of service
// Read data channel
    input  wire [AXI_DATA_WIDTH-1:0] axm1_rdata,   // Read data
    input  wire        axm1_rlast,   // Read last
    input  wire [1:0]  axm1_rresp,   // Read response
    input  wire        axm1_rvalid,  // Read valid
    output reg         axm1_rready,  // Read ready
    input  wire [0:0]  axm1_rid,   // Read response id
// Global signals
//    input  wire        aclk1,
//    input  wire        aresetn1,

//*********************** Second AXI Master Interface ***************************************
// Write channel - AXI-Lite part
    output wire [AXI_ADDR_WIDTH-1:0] axm2_awaddr,  // axm_m0.awaddr
    output wire [2:0]  axm2_awprot,  //       .awprot
    output reg         axm2_awvalid, //       .awvalid
    input  wire        axm2_awready, //       .awready
    output reg  [AXI_DATA_WIDTH-1:0] axm2_wdata,   //       .wdata
    output reg         axm2_wvalid,  //       .wvalid
    input  wire        axm2_wready,  //       .wready
    output wire [(AXI_DATA_WIDTH>>3)-1:0]  axm2_wstrb,
// Write channel - AXI set
    output wire [ID_WIDTH-1:0]  axm2_awid,     // Write ID Tag
    output wire [7:0]  axm2_awlen,         // Burst length
    output wire [2:0]  axm2_awsize,        // Burst size
    output wire [1:0]  axm2_awburst,       // Burst type
    output wire        axm2_awlock,        // Busrst lock
    output wire [3:0]  axm2_awcache,       // Memory type
    output wire        axm2_wlast,         // Write last
    output wire [3:0]  axm2_awqos,         // Quality of service
// Write respone
    input  wire [1:0]  axm2_bresp,
    input  wire        axm2_bvalid,  // Write response valid
    input  wire [0:0]  axm2_bid,     // Response ID tag
    output wire        axm2_bready,  //       .bready
    
// Read address channel     
    output wire [AXI_ADDR_WIDTH-1:0] axm2_araddr,  //       .araddr
    output wire [2:0]  axm2_arprot,  //       .arprot
    output reg         axm2_arvalid, //       .arvalid
    input  wire        axm2_arready, //       .arready
// Read address channel - AXI set
    output wire [ID_WIDTH-1:0]  axm2_arid, 
    output wire [7:0]  axm2_arlen,   // Burst length
    output wire [2:0]  axm2_arsize,  // Burst size
    output wire [1:0]  axm2_arburst, // Burst type
    output wire        axm2_arlock,  // Lock type
    output wire [3:0]  axm2_arcache, // Memory type
    output wire [3:0]  axm2_arqos,   // Quality of service
// Read data channel
    input  wire [AXI_DATA_WIDTH-1:0] axm2_rdata,   // Read data
    input  wire        axm2_rlast,   // Read last
    input  wire [1:0]  axm2_rresp,   // Read response
    input  wire        axm2_rvalid,  // Read valid
    output reg         axm2_rready,  // Read ready
    input  wire [0:0]  axm2_rid,   // Read response id
// Global signals
//    input  wire        aclk2,
//    input  wire        aresetn2   
	input wire aclk,
	input wire aresetn
    
);


	function integer clogb2 (input integer bit_depth);              
	begin                                                           
	    for(clogb2=0; bit_depth>0; clogb2=clogb2+1)                   
				bit_depth = bit_depth >> 1;                                 
	    end                                                           
	endfunction  	

    reg  [31:0] wdata;
	wire [2:0]  waddr;
	logic wvalid;
	logic [2:0]  raddr;
	logic [31:0] rdata;
	
    hdlverifier_axilite_memreg u_slave(.*, .axis_aclk(aclk), .axis_aresetn(aresetn));

	logic [31:0] host_address;
	logic [31:0] target_address;
	logic [23:0] words2transfer;
	logic sw_reset, start_host2target, start_target2host;
	logic cmoplete_host2target, complete_target2host;
	logic [2:0] target_arsize, target_awsize;
	
	
	
	always_comb begin
		if(raddr==3'd0) 
			rdata <= {6'b0, complete_target2host, cmoplete_host2target};
		else if(raddr==3'd1) 
			rdata <= {32'h81420101};
		else if(raddr==3'd2) 
			rdata <= {32'h00000002}; // 32bit:0, 64bit:1, 128bit:2, 
		else 
			rdata <= 8'b0;
	end
	always_ff@(posedge aclk) begin
		if(!aresetn) begin
			sw_reset <= 0;
			start_host2target <= 0;
			start_target2host <= 0;			
		end
		else begin
			start_host2target <= 0;
			start_target2host <= 0;
			if(wvalid) begin
				if(waddr==0) 
					host_address <= wdata;
				else if(waddr==1)
					target_address <= wdata;
				else if(waddr==2) 
					words2transfer <= wdata[23:0];
				else if(waddr==3) begin
					sw_reset <= wdata[0];
					start_host2target <= wdata[1];
					start_target2host <= wdata[2];					
					target_awsize <= wdata[5:3];
					target_arsize <= wdata[8:6];					
				end
			end
		end		
	end

    
	hdlverifier_axi_memcpy 
		#(.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
		  .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH))
		 host2target (
		.axim_src_araddr(axm1_araddr),  //       .araddr
		.axim_src_arprot(axm1_arprot),  //       .arprot
		.axim_src_arvalid(axm1_arvalid), //       .arvalid
		.axim_src_arready(axm1_arready), //       .arready
		.axim_src_arid(axm1_arid), 
		.axim_src_arlen(axm1_arlen),   // Burst length
		.axim_src_arsize(axm1_arsize),  // Burst size
		.axim_src_arburst(axm1_arburst), // Burst type
		.axim_src_arlock(axm1_arlock),  // Lock type
		.axim_src_arcache(axm1_arcache), // Memory type
		.axim_src_arqos(axm1_arqos),   // Quality of service
		.axim_src_rdata(axm1_rdata),   // Read data
		.axim_src_rlast(axm1_rlast),   // Read last
		.axim_src_rresp(axm1_rresp),   // Read response, not used?
		.axim_src_rvalid(axm1_rvalid),  // Read valid
		.axim_src_rready(axm1_rready),  // Read ready
		.axim_src_rid(axm1_rid),   // Read response id, not used
		.aclk_src(aclk),
		.aresetn_src(aresetn), 
		.axim_dst_awaddr(axm2_awaddr),  // axm_m0.awaddr
		.axim_dst_awprot(axm2_awprot),  //       .awprot
		.axim_dst_awvalid(axm2_awvalid), //       .awvalid
		.axim_dst_awready(axm2_awready), //       .awready
		.axim_dst_wdata(axm2_wdata),   //       .wdata
		.axim_dst_wvalid(axm2_wvalid),  //       .wvalid
		.axim_dst_wready(axm2_wready),  //       .wready
		.axim_dst_wstrb(axm2_wstrb),
		.axim_dst_awid(axm2_awid),     // Write ID Tag
		.axim_dst_awlen(axm2_awlen),         // Burst length
		.axim_dst_awsize(axm2_awsize),        // Burst size
		.axim_dst_awburst(axm2_awburst),       // Burst type
		.axim_dst_awlock(axm2_awlock),        // Busrst lock
		.axim_dst_awcache(axm2_awcache),       // Memory type
		.axim_dst_wlast(axm2_wlast),         // Write last
		.axim_dst_awqos(axm2_awqos),         // Quality of service
		.axim_dst_bresp(axm2_bresp),
		.axim_dst_bvalid(axm2_bvalid),  // Write response valid
		.axim_dst_bid(axm2_bid),     // Response ID tag
		.axim_dst_bready(axm2_bready),  //       .bready
		.aclk_dst(aclk),
		.aresetn_dst(aresetn),
		.src_addr(host_address),
		.dst_addr(target_address),
		.words2transfer(words2transfer),
		.start(start_host2target),
		.complete(cmoplete_host2target),
		.awsize_in(target_awsize),
		.arsize_in(clogb2((AXI_DATA_WIDTH/8)-1)),
		.sw_reset(sw_reset));	
		
	hdlverifier_axi_memcpy 
		#(.AXI_DATA_WIDTH(AXI_DATA_WIDTH),
		  .AXI_ADDR_WIDTH(AXI_ADDR_WIDTH))
		 target2host (
		.axim_src_araddr(axm2_araddr),  //       .araddr
		.axim_src_arprot(axm2_arprot),  //       .arprot
		.axim_src_arvalid(axm2_arvalid), //       .arvalid
		.axim_src_arready(axm2_arready), //       .arready
		.axim_src_arid(axm2_arid), 
		.axim_src_arlen(axm2_arlen),   // Burst length
		.axim_src_arsize(axm2_arsize),  // Burst size
		.axim_src_arburst(axm2_arburst), // Burst type
		.axim_src_arlock(axm2_arlock),  // Lock type
		.axim_src_arcache(axm2_arcache), // Memory type
		.axim_src_arqos(axm2_arqos),   // Quality of service
		.axim_src_rdata(axm2_rdata),   // Read data
		.axim_src_rlast(axm2_rlast),   // Read last
		.axim_src_rresp(axm2_rresp),   // Read response, not used?
		.axim_src_rvalid(axm2_rvalid),  // Read valid
		.axim_src_rready(axm2_rready),  // Read ready
		.axim_src_rid(axm2_rid),   // Read response id, not used
		.aclk_src(aclk),
		.aresetn_src(aresetn), 
		.axim_dst_awaddr(axm1_awaddr),  // axm_m0.awaddr
		.axim_dst_awprot(axm1_awprot),  //       .awprot
		.axim_dst_awvalid(axm1_awvalid), //       .awvalid
		.axim_dst_awready(axm1_awready), //       .awready
		.axim_dst_wdata(axm1_wdata),   //       .wdata
		.axim_dst_wvalid(axm1_wvalid),  //       .wvalid
		.axim_dst_wready(axm1_wready),  //       .wready
		.axim_dst_wstrb(axm1_wstrb),
		.axim_dst_awid(axm1_awid),     // Write ID Tag
		.axim_dst_awlen(axm1_awlen),         // Burst length
		.axim_dst_awsize(axm1_awsize),        // Burst size
		.axim_dst_awburst(axm1_awburst),       // Burst type
		.axim_dst_awlock(axm1_awlock),        // Busrst lock
		.axim_dst_awcache(axm1_awcache),       // Memory type
		.axim_dst_wlast(axm1_wlast),         // Write last
		.axim_dst_awqos(axm1_awqos),         // Quality of service
		.axim_dst_bresp(axm1_bresp),
		.axim_dst_bvalid(axm1_bvalid),  // Write response valid
		.axim_dst_bid(axm1_bid),     // Response ID tag
		.axim_dst_bready(axm1_bready),  //       .bready
		.aclk_dst(aclk),
		.aresetn_dst(aresetn),
		.src_addr(target_address),
		.dst_addr(host_address),
		.words2transfer(words2transfer),
		.start(start_target2host),
		.complete(complete_target2host),
		.awsize_in(clogb2((AXI_DATA_WIDTH/8)-1)),
		.arsize_in(target_arsize),
		.sw_reset(sw_reset));		
	
endmodule


