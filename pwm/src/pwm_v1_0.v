/**
  Module name:  pwm_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jan 2022
  Description: Module to implement a pwm modulator
  Revision: 1.0 Module created
**/

module pwm_v1_0 #(
  parameter width = 16
  )(
  input clk, 
  input rst, 

  input [width-1:0] modulator,
  input [width-1:0] period,
  
  output reg [width-1:0] counter,
  output pwm  
);

  /* carrier generation */

  always @(posedge clk)
    if (rst)
      counter <= 0;
    else
      if (counter > period) counter <= 0;
      else counter <= counter+1;

  assign pwm = ((modulator < counter) && rst)? 1'b1: 1'b0;

endmodule