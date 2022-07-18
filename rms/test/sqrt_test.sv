/**
  Module name:  sqrt_test
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jun 2022
  Description: testbench for the division algorothms
  Revision: 1.0 Module created
**/

`timescale 1ns/1ns

`define _clkcycle 10
`define _1us 1000
`define _10us 10000

module sqrt_test();

  parameter inout_width = 16;
  reg aclk;
  reg resetn;

  reg [(inout_width*2)-1:0] radicand = 0;
  reg [inout_width-1:0] root;
  reg data_valid = 1'b0;

  /* clock generation */
  initial begin
    aclk <= 1'b1;
    #(`_clkcycle / 2);
    forever begin
      aclk <= ~aclk;
      #(`_clkcycle / 2);
    end
  end

  non_restoring_sqrt_v1_0 #(
  .inout_width(inout_width)
  ) uut (
  .aclk(aclk), 
  .resetn(resetn), 
  .radicand(radicand), /* radicand. double width */
  .i_data_valid(data_valid), /* start division */
  .root(root), /* quotient result */
  .o_data_valid(), /* end division algorithm. Data ready in output port */
  .error_value0() /* error: division by zero */
  );

  integer i;
  /* test flow */
  initial begin

    $dumpfile ("sim_data_sqrt.vcd"); // Change filename as appropriate. 
    $dumpvars(); 

    resetn <= 1'b0;

    #(10*`_clkcycle);
    resetn <= 1'b1;
    radicand <= 16'd1895;
    #(10*`_clkcycle);
    data_valid <= 1'b1;
    #(1*`_clkcycle);
    data_valid <= 1'b0;


    #(100*`_10us);


    $finish;
  
  end

endmodule