`timescale 1ns/1ns

module hdlverifier_sync_fifo
#(parameter DATA_WIDTH=32, ADDR_WIDTH=8)
(
    input [DATA_WIDTH-1:0] wdata,
    input wrreq,
    output logic [DATA_WIDTH-1:0] rdata,
    input rdreq,
    output logic full,
    output logic empty, 
    input aclr,
    input clk
);
	(* ramstyle = "no_rw_check" *) reg [DATA_WIDTH - 1:0] ram [2**ADDR_WIDTH - 1:0]; 
    reg [ADDR_WIDTH-1:0] waddr, waddrinc;
    reg [ADDR_WIDTH-1:0] raddr, raddrinc;
    assign waddrinc = waddr + 1'b1;
	assign raddrinc = raddr + 1'b1;
	//assign rdata = ram[raddr];
	
    always@(posedge clk or posedge aclr) begin
		if(aclr) begin
			waddr <= 0;
			raddr <= 0;
			full <=  0;
			empty <= 1;
		end
		else begin
			if(wrreq) begin
				waddr <= waddrinc;
				ram[waddr] <= wdata;
			end
			if(rdreq) begin
				raddr <= raddrinc;			
				rdata <= ram[raddr];
			end
			
			if(wrreq && !rdreq) begin
				full <= (raddr == waddrinc);
				empty <= 0; 
			end
			else if(!wrreq && rdreq) begin
				full <= 0;
				empty <= (waddr == raddrinc);
			end
		end
	end
	
	
    


endmodule
