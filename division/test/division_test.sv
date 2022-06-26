/**
  Module name:  division_test
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jun 2022
  Description: testbench for the division algorothms
  Revision: 1.0 Module created
**/

`timescale 1ns/1ns

`define _clkcycle 10
`define _1us 1000
`define _10us 10000

module division_test();

  reg aclk;
  reg resetn;

  reg signed [11:0] numerator;
  reg signed [11:0] denominator;
  reg data_valid;
  
  /* long division results */
  wire signed [11:0] quotient_ld;
  wire signed [11:0] remainder_ld;
  wire data_ready_ld;
  wire error_div0_ld;

  /* restoring division results */
  wire signed [11:0] quotient_r;
  wire signed [11:0] remainder_r;
  wire data_ready_r;
  wire error_div0_r;

  /* non-restoring division results */
  wire signed [11:0] quotient_nr;
  wire signed [11:0] remainder_nr;
  wire data_ready_nr;
  wire error_div0_nr;

  /* non-restoring division results */
  wire signed [11:0] quotient_snr;
  wire signed [11:0] remainder_snr;
  wire data_ready_snr;
  wire error_div0_snr;

  /* newton raphson division results */
  wire signed [23:0] quotient_nwr;
  wire signed [11:0] remainder_nwr;
  wire data_ready_nwr;
  wire error_div0_nwr;

  initial begin
    aclk <= 1'b0;
    #(`_clkcycle / 2);
    forever begin
      aclk <= ~aclk;
      #(`_clkcycle / 2);
    end
  end

  long_division_v1_0 #(
  .inout_width(12)
  ) long_division_inst (
  .aclk(aclk), 
  .resetn(resetn),
  .numerator(numerator), /* numerator */ 
  .denominator(denominator), /* denominator */
  .data_valid(data_valid), /* start division */
  .quotient(quotient_ld), /* quotient result */
  .remainder(remainder_ld), /* remainder result */
  .data_ready(data_ready_ld), /* end division algorithm. Data ready in output port */
  .error_div0(error_div0_ld) /* error: division by zero */
  );

  restoring_division_v1_0 #(
  .inout_width(12)
  )restoring_division_inst(
  .aclk(aclk),
  .resetn(resetn), 
  .numerator(numerator), /* numerator */
  .denominator(denominator), /* denominator */
  .data_valid(data_valid), /* start division */
  .quotient(quotient_r), /* quotient result */
  .remainder(remainder_r), /* remainder result */
  .data_ready(data_ready_r), /* end division algorithm. Data ready in output port */
  .error_div0(error_div0_r) /* error: division by zero */
  );

  non_restoring_division_v1_0 #(
  .inout_width(12)
  )non_restoring_division_inst(
  .aclk(aclk), 
  .resetn(resetn), 
  .numerator(numerator), /* numerator */
  .denominator(denominator), /* denominator */
  .data_valid(data_valid), /* start division */
  .quotient(quotient_nr), /* quotient result */
  .remainder(remainder_nr), /* remainder result */
  .data_ready(data_ready_nr), /* end division algorithm. Data ready in output port */
  .error_div0(error_div0_nr) /* error: division by zero */
  );

  signed_non_restoring_division_v1_0 #(
  .inout_width(12)
  )signed_non_restoring_division_inst(
  .aclk(aclk), 
  .resetn(resetn), 
  .numerator($signed(-numerator)), /* numerator */
  .denominator($signed(-denominator)), /* denominator */
  .data_valid(data_valid), /* start division */
  .quotient(quotient_snr), /* quotient result */
  .remainder(remainder_snr), /* remainder result */
  .data_ready(data_ready_snr), /* end division algorithm. Data ready in output port */
  .error_div0(error_div0_snr) /* error: division by zero */
  );


  // newton_raphson_division_v1_0 #(
  // .inout_width(12),
  // .n_iterations(4)
  // )newton_raphson_division_inst(
  // .aclk(aclk), 
  // .resetn(resetn), 
  // .numerator(numerator), /* numerator */
  // .denominator(denominator), /* denominator */
  // .data_valid(data_valid), /* start division */
  // .quotient(quotient_nwr), /* quotient result */
  // .data_ready(data_ready_nwr), /* end division algorithm. Data ready in output port */
  // .error_div0(error_div0_nwr) /* error: division by zero */
  // );

  /* test flow */
  initial begin

    $dumpfile ("sim_data.vcd"); // Change filename as appropriate. 
    $dumpvars(); 

    resetn <= 1'b0;
    data_valid <= 1'b0;
    numerator <= 12'd0;
    denominator <= 12'd0;
    #(10*`_clkcycle);
    resetn <= 1'b1;
    #(10*`_clkcycle);

    numerator <= 12'd684;
    denominator <= 12'd5;
    data_valid <= 1'b1;
    #(`_clkcycle);
    data_valid <= 1'b0;
    // #(20*`_10us);

    fork: f1
      begin
        @(posedge data_ready_ld);
        disable f1;
      end

      begin
        #(20*`_10us);
        disable f1;
      end
    join

    #(`_10us);

    $finish;
  
  end

endmodule