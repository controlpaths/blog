// IP VLNV: xilinx.com:ip:axi_vip:1.1
// IP Revision: 2


`timescale 1 ns / 1 ns
import axi_vip_pkg::*;


package hdlverifier;
typedef enum bit {
    HDLV_AXI_BURST_TYPE_FIXED = 1'b0,
    HDLV_AXI_BURST_TYPE_INCR = 1'b1
} hdlv_axi_burst_t;
endpackage


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
    output wire [3:0]  axi4m_awregion,		// Write Addr Channel region indx
	
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
    output wire [3:0]  axi4m_arregion, //Channel addr region indx
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

// The temp bit is used to convert the narrower BID/RID channel into ID_WIDTH.
// The reason of 1-bit BID/RID channel is by following the same definiation in
// ip design file. 
//   bit [ID_WIDTH-1:0] tempM_BID = axi4m_bid;
//   bit [ID_WIDTH-1:0] tempM_RID = axi4m_rid;
   bit [ID_WIDTH-1:0] zeroID = 0;

  axi_vip_v1_1_6_top #(
    .C_AXI_PROTOCOL(0),
    .C_AXI_INTERFACE_MODE(0),
    .C_AXI_ADDR_WIDTH(AXI_ADDR_WIDTH),
    .C_AXI_WDATA_WIDTH(AXI_DATA_WIDTH),
    .C_AXI_RDATA_WIDTH(AXI_DATA_WIDTH),
    .C_AXI_WID_WIDTH(ID_WIDTH),
    .C_AXI_RID_WIDTH(ID_WIDTH),
    .C_AXI_AWUSER_WIDTH(0),
    .C_AXI_ARUSER_WIDTH(0),
    .C_AXI_WUSER_WIDTH(0),
    .C_AXI_RUSER_WIDTH(0),
    .C_AXI_BUSER_WIDTH(0),
    .C_AXI_SUPPORTS_NARROW(1),
    .C_AXI_HAS_BURST(1),
    .C_AXI_HAS_LOCK(1),
    .C_AXI_HAS_CACHE(1),
    .C_AXI_HAS_REGION(1),
    .C_AXI_HAS_PROT(1),
    .C_AXI_HAS_QOS(1),
    .C_AXI_HAS_WSTRB(1),
    .C_AXI_HAS_BRESP(1),
    .C_AXI_HAS_RRESP(1),
    .C_AXI_HAS_ARESETN(1)
  ) master (
    .aclk(aclk),
    .aclken(1'B1),
    .aresetn(aresetn),
    .s_axi_awid(zeroID),
    .s_axi_awaddr(32'B0),
    .s_axi_awlen(8'B0),
    .s_axi_awsize(3'D2),
    .s_axi_awburst(2'B1),
    .s_axi_awlock(1'B0),
    .s_axi_awcache(4'B0),
    .s_axi_awprot(3'B0),
    .s_axi_awregion(4'B0),
    .s_axi_awqos(4'B0),
    .s_axi_awuser(1'B0),
    .s_axi_awvalid(1'B0),
    .s_axi_awready(), 
    .s_axi_wid(zeroID),
    .s_axi_wdata(32'B0),
    .s_axi_wstrb(4'HF),
    .s_axi_wlast(1'B0),
    .s_axi_wuser(1'B0),
    .s_axi_wvalid(1'B0),
    .s_axi_wready(),
    .s_axi_bid(),
    .s_axi_bresp(),
    .s_axi_buser(),
    .s_axi_bvalid(),
    .s_axi_bready(1'B0),
    .s_axi_arid(zeroID),
    .s_axi_araddr(32'B0),
    .s_axi_arlen(8'B0),
    .s_axi_arsize(3'D2),
    .s_axi_arburst(2'B1),
    .s_axi_arlock(1'B0),
    .s_axi_arcache(4'B0),
    .s_axi_arprot(3'B0),
    .s_axi_arregion(4'B0),
    .s_axi_arqos(4'B0),
    .s_axi_aruser(1'B0),
    .s_axi_arvalid(1'B0),
    .s_axi_arready(),
    .s_axi_rid(),
    .s_axi_rdata(),
    .s_axi_rresp(),
    .s_axi_rlast(),
    .s_axi_ruser(),
    .s_axi_rvalid(),
    .s_axi_rready(1'B0),
    .m_axi_awid(axi4m_awid),
    .m_axi_awaddr(axi4m_awaddr),
    .m_axi_awlen(axi4m_awlen),
    .m_axi_awsize(axi4m_awsize),
    .m_axi_awburst(axi4m_awburst),
    .m_axi_awlock(axi4m_awlock),
    .m_axi_awcache(axi4m_awcache),
    .m_axi_awprot(axi4m_awprot),
    .m_axi_awregion(axi4m_awregion),
    .m_axi_awqos(axi4m_awqos),
    .m_axi_awuser(),
    .m_axi_awvalid(axi4m_awvalid),
    .m_axi_awready(axi4m_awready),
    .m_axi_wid(),
    .m_axi_wdata(axi4m_wdata),
    .m_axi_wstrb(axi4m_wstrb),
    .m_axi_wlast(axi4m_wlast),
    .m_axi_wuser(),
    .m_axi_wvalid(axi4m_wvalid),
    .m_axi_wready(axi4m_wready),
    .m_axi_bid(axi4m_bid),
    .m_axi_bresp(axi4m_bresp),
    .m_axi_buser(1'B0),
    .m_axi_bvalid(axi4m_bvalid),
    .m_axi_bready(axi4m_bready),
    .m_axi_arid(axi4m_arid),
    .m_axi_araddr(axi4m_araddr),
    .m_axi_arlen(axi4m_arlen),
    .m_axi_arsize(axi4m_arsize),
    .m_axi_arburst(axi4m_arburst),
    .m_axi_arlock(axi4m_arlock),
    .m_axi_arcache(axi4m_arcache),
    .m_axi_arprot(axi4m_arprot),
    .m_axi_arregion(axi4m_arregion),
    .m_axi_arqos(axi4m_arqos),
    .m_axi_aruser(),
    .m_axi_arvalid(axi4m_arvalid),
    .m_axi_arready(axi4m_arready),
    .m_axi_rid(axi4m_rid),
    .m_axi_rdata(axi4m_rdata),
    .m_axi_rresp(axi4m_rresp),
    .m_axi_rlast(axi4m_rlast),
    .m_axi_ruser(1'B0),
    .m_axi_rvalid(axi4m_rvalid),
    .m_axi_rready(axi4m_rready)
  );	
    localparam PROTOCOL           = 0;
    localparam READ_WRITE_MODE    = "READ_WRITE";
    localparam INTERFACE_MODE     = 0;
    localparam DATA_BYTE_LEN      = AXI_DATA_WIDTH / 8;
    localparam AWUSER_WIDTH       = 0;
    localparam ARUSER_WIDTH       = 0;
    localparam RUSER_WIDTH        = 0;
    localparam WUSER_WIDTH        = 0;
    localparam BUSER_WIDTH        = 0;
    localparam SUPPORTS_NARROW    = 1;
    localparam HAS_BURST          = 1;
    localparam HAS_LOCK           = 1;
    localparam HAS_CACHE          = 1;
    localparam HAS_REGION         = 1;
    localparam HAS_QOS            = 1;
    localparam HAS_PROT           = 1;
    localparam HAS_WSTRB          = 1;
    localparam HAS_BRESP          = 1;
    localparam HAS_RRESP          = 1;
    localparam HAS_ACLKEN         = 0;
    localparam HAS_ARESETN        = 1;
    localparam MAX_AWLEN_FIXED    =16; // Transactions of burst type FIXED cannot have a length greater than 16 beats. --Xilinx VIP PG267
    typedef axi_vip_pkg::axi_mst_agent #(PROTOCOL, 
    					AXI_ADDR_WIDTH,
    					AXI_DATA_WIDTH,
    					AXI_DATA_WIDTH,
    					ID_WIDTH,
    					ID_WIDTH,
    					AWUSER_WIDTH, 
    					WUSER_WIDTH, 
    					BUSER_WIDTH, 
    					ARUSER_WIDTH,
    					RUSER_WIDTH, 
    					SUPPORTS_NARROW, 
    					HAS_BURST,
    					HAS_LOCK,
    					HAS_CACHE,
    					HAS_REGION,
    					HAS_PROT,
    					HAS_QOS,
    					HAS_WSTRB,
    					HAS_BRESP,
    					HAS_RRESP,
    					HAS_ARESETN) agent_type;
    agent_type agent;
    bit agent_started;
    hdlverifier::hdlv_axi_burst_t testburst;
    initial begin
        agent = new("AXI Master Agent", master.IF);		
        agent.start_master();
        agent_started = 1'b1;
    end
    task automatic readmemory(input bit[AXI_ADDR_WIDTH-1:0] addr, input integer length, input hdlverifier::hdlv_axi_burst_t burst, output bit [AXI_DATA_WIDTH - 1:0] rdata[]);
    	bit [1024:0][AXI_DATA_WIDTH - 1:0] buffer;
        integer rlen,maxlen;
    	integer k=0;
        rdata = new[length];
        // This size is determined by the matlab readmemory() call.
        assert(length<=16777216) else begin $error("The read size cannot be larger than 16777216"); end
        assert(addr%DATA_BYTE_LEN==0) else begin $error("The address must be %0dbit aligned",AXI_DATA_WIDTH); end
        if (burst == hdlverifier::HDLV_AXI_BURST_TYPE_FIXED) begin
            while(length) begin
                rlen = length;
                if(rlen>MAX_AWLEN_FIXED)
            	    rlen = MAX_AWLEN_FIXED;			
                axi_read(addr, rlen-1, burst, buffer);		
    
                for(integer i=0;i<rlen;i=i+1, k=k+1) begin
            	    rdata[k][AXI_DATA_WIDTH - 1:0] = buffer[i][AXI_DATA_WIDTH - 1:0];
                end
                length -= rlen;
            end
        end
        else if (burst == hdlverifier::HDLV_AXI_BURST_TYPE_INCR) begin
            while(length) begin
            	rlen = length;
            	maxlen = 256 - (addr%(256*DATA_BYTE_LEN)/DATA_BYTE_LEN);
            	if(rlen>maxlen)
            	    rlen = maxlen;			
    		axi_read(addr, rlen-1, burst, buffer);		
    
            	for(integer i=0;i<rlen;i=i+1, k=k+1) begin
            	    rdata[k][AXI_DATA_WIDTH - 1:0] = buffer[i][AXI_DATA_WIDTH - 1:0];
            	end
            	length -= rlen;
            	addr += rlen*DATA_BYTE_LEN;
            end
        end
    endtask
    
    task automatic axi_read(input bit[AXI_ADDR_WIDTH-1:0] addr, input integer length, input hdlverifier::hdlv_axi_burst_t  burst, output bit [1024:0][AXI_DATA_WIDTH - 1:0] rdata);
    	axi_vip_pkg::xil_axi_resp_t [255:0]    resp;
    	axi_vip_pkg::xil_axi_data_beat [255:0] ruser;
    	axi_vip_pkg::xil_axi_burst_t vipburst;
        axi_vip_pkg::xil_axi_size_t vipsize;
        vipburst = (burst == hdlverifier::HDLV_AXI_BURST_TYPE_FIXED) ? (axi_vip_pkg::XIL_AXI_BURST_TYPE_FIXED):(axi_vip_pkg::XIL_AXI_BURST_TYPE_INCR);
        vipsize = (AXI_DATA_WIDTH == 64) ? (axi_vip_pkg::XIL_AXI_SIZE_8BYTE) : (axi_vip_pkg::XIL_AXI_SIZE_4BYTE);
    	agent.AXI4_READ_BURST(
    	    zeroID,
    	    addr,
    	    length,
            vipsize,
    	    vipburst,
    	    axi_vip_pkg::XIL_AXI_ALOCK_NOLOCK,
    	    0,
    	    0,
    	    0,
    	    0,
    	    0,
    	    rdata,
    	    resp,
    	    ruser);	
    endtask
    
    task automatic writememory(input bit[AXI_ADDR_WIDTH-1:0] addr, input bit [AXI_DATA_WIDTH - 1:0] wdata[], input hdlverifier::hdlv_axi_burst_t burst);
    	bit [1024:0][AXI_DATA_WIDTH - 1:0] buffer;
    	integer k=0;
    	integer length = wdata.size();
        integer rlen, maxlen;	
        assert(length>0) else begin $error("The write data size cannot be zero"); end
        assert(addr%DATA_BYTE_LEN==0) else begin $error("The address must be %0dbit aligned",AXI_DATA_WIDTH); end
        if (burst == hdlverifier::HDLV_AXI_BURST_TYPE_FIXED) begin
    	    while(length) begin
        	rlen = length;
        	if(rlen>MAX_AWLEN_FIXED)
        	rlen = MAX_AWLEN_FIXED;			
                for(integer i=0;i<rlen;i++,k++) begin
        	    buffer[i][AXI_DATA_WIDTH - 1:0] = wdata[k][AXI_DATA_WIDTH - 1:0];
                end
                axi_write(addr, rlen-1, burst, buffer);
                length -= rlen;
            end
        end
        else if (burst == hdlverifier::HDLV_AXI_BURST_TYPE_INCR) begin
            while(length) begin
                rlen = length;
    	        maxlen = 256 - (addr%(256*DATA_BYTE_LEN)/DATA_BYTE_LEN);
    		if(rlen>maxlen)
            	    rlen = maxlen;		
             	for(integer i=0;i<rlen;i++,k++) begin
                    buffer[i][AXI_DATA_WIDTH - 1:0] = wdata[k][AXI_DATA_WIDTH - 1:0];
            	end
     		axi_write(addr, rlen-1, burst, buffer);
      		length -= rlen;
        	addr += rlen*DATA_BYTE_LEN;
            end
        end
    endtask;
    
    task automatic axi_write(input bit[AXI_ADDR_WIDTH-1:0] addr, input integer length, input hdlverifier::hdlv_axi_burst_t burst,  input bit [1024:0][AXI_DATA_WIDTH - 1:0] wdata);
    	axi_vip_pkg::xil_axi_resp_t [255:0]    resp;
    	axi_vip_pkg::xil_axi_data_beat [255:0] wuser;			
        axi_vip_pkg::xil_axi_burst_t vipburst;
        axi_vip_pkg::xil_axi_size_t vipsize;
        vipsize = (AXI_DATA_WIDTH == 64) ? (axi_vip_pkg::XIL_AXI_SIZE_8BYTE) : (axi_vip_pkg::XIL_AXI_SIZE_4BYTE);
        vipburst = (burst == hdlverifier::HDLV_AXI_BURST_TYPE_FIXED) ? (axi_vip_pkg::XIL_AXI_BURST_TYPE_FIXED):(axi_vip_pkg::XIL_AXI_BURST_TYPE_INCR);
    	agent.AXI4_WRITE_BURST(
    	    zeroID,
    	    addr,
    	    length,
            vipsize,
            vipburst,
    	    axi_vip_pkg::XIL_AXI_ALOCK_NOLOCK,
    	    0,
    	    0,
    	    0,
    	    0,
    	    0,
    	    wdata,
    	    resp,
    	    wuser);	
    endtask



endmodule
