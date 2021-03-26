
`timescale 1 ns / 1 ns
module hdlverifier_axilite_memreg 
(
///////// AXI4 Lite slave interface for control registers /////////////////////////////
    input logic  axis_aclk,
    input logic  axis_aresetn,
    input logic [4 : 0] axis_awaddr,
    input logic  axis_awvalid,
    output logic  axis_awready,
    input logic [31 : 0] axis_wdata,
    input logic  axis_wvalid,
    output logic  axis_wready,
    output logic  axis_bvalid,
    input logic  axis_bready,
    input logic [4 : 0] axis_araddr,
    input logic  axis_arvalid,
    output logic  axis_arready,
    output logic [31 : 0] axis_rdata,
    output logic  axis_rvalid,
    input logic  axis_rready,   
	
    input logic [2:0]  axis_awprot,  //       .awprot
    input logic [3:0] axis_wstrb,
    output  logic [1:0]  axis_bresp,
    input logic [2:0]  axis_arprot,  //       .arprot
    output  logic [1:0]  axis_rresp,  
	
	//////// Interface with the design /////////////////
    output logic [31:0] wdata,
	output logic [2:0]  waddr,
	output logic wvalid,
	output logic [2:0]  raddr,
	input  logic [31:0] rdata	
	);

	assign axis_rresp 	= 2'b00;
	
    reg [2:0] axis_raddress_reg;

	
    always@(posedge axis_aclk) begin
        if( !axis_aresetn ) begin
            axis_awready <= 1'b0;
            axis_wready <= 0;
            axis_bvalid <= 1'b0;
			wvalid <= 1'b0;			
        end 
        else begin      
			wvalid <= 1'b0;	
            // Ready to accept 
            if(~axis_awready && axis_awvalid && axis_wvalid) begin
                axis_awready <= 1'b1;
                axis_raddress_reg <= axis_awaddr[4:2];
            end 
            else begin
                axis_awready <= 1'b0;
            end
            
            // Ready to accept data 
            if (~axis_wready && axis_wvalid && axis_awvalid)
                axis_wready <= 1;
            else
                axis_wready <= 0;
            
            
            // Write to memory mapped registers
            if(axis_wready && axis_wvalid && axis_awready && axis_awvalid) begin
				wdata <= axis_wdata;
				wvalid <= (axis_wstrb == 4'b1111);
				waddr <= axis_raddress_reg;
            end     

            // Write response
            if(axis_awready && axis_awvalid && ~axis_bvalid && axis_wvalid) begin
                axis_bvalid <= 1;
                axis_bresp <= 2'b0;
            end
            else if(axis_bready && axis_bvalid) begin
                axis_bvalid <= 1'b0;
            end 
        end
    end
    always@(posedge axis_aclk) begin
        if( !axis_aresetn ) begin
            axis_arready <= 0;
            axis_rvalid <= 0;
        end 
        else begin
            if(~axis_arready && axis_arvalid) begin
                axis_arready <= 1;
                raddr <= axis_araddr[4:2];
            end
            else begin
                axis_arready <= 0;
            end
            
            if(axis_arready && axis_arvalid && ~axis_rvalid) begin
                axis_rvalid <= 1;
            end
            else if(axis_rvalid && axis_rready) begin
                axis_rvalid <=0;
            end
        end
    end
	
	assign axis_rdata = rdata;
	
endmodule


