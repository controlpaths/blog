/**
  Module name:  clk_enable_generate_4x
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Feb2022
  Description: Module to geneate the corresponding clock enable
  Revision: 1.0 Module created
**/

module clk_enable_generate_100x (
  input clk, 

  output clk_enable_400ksps
);

  reg [7:0] counter100;

  initial counter100 <= 7'd0;

  always @(posedge clk)
    if (counter100 < 100)
      counter100 <= counter100 + 7'd1;
    else
      counter100 <= 7'd0;

  assign clk_enable_400ksps = (counter100 == 7'd100)? 1'b1: 1'b0;

endmodule