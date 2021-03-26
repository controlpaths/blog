`timescale 1ns / 1ns

import hdlverifier::*;

module testbench;

logic reset;
logic clk;

bit [31:0] wdata[], rdata[];
integer write_size = 256;
//bit [31:0] wdata[];

hdlverifier::aximaster master;

design_1_wrapper wrapper(
    .reset(reset),
    .sys_clock(clk));

initial begin
    reset = 0;
    clk = 1;
    #10 
    reset = 1;
    #50 
    reset = 0;
end

initial begin
    master = new(wrapper.design_1_i.hdlverifier_axi_master_0.inst.inst.IF);
	
	wdata = new[write_size];

	for(integer i=0;i<write_size;i=i+1) begin	
		wdata[i][31:0] = i;
	end
	master.writememory(8, wdata);

 
	$display("Write finished at time %d",$time);
	
	#100
	
	master.readmemory(0, 512, rdata);
    
    $display("Read finished at time %d",$time);
	$display("size of read data is %d",rdata.size());
	for(integer i=0;i<rdata.size();i = i+1) begin
		$display("got rdata[%d] = %d", i, rdata[i]);
	end
end

always #5 clk = !clk;

endmodule
