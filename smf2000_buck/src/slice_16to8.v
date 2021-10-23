/**
  Module name:  slice
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Sept 2021
  Description: Module to generate a synchronous pwm signal with configurable deadtime.
  Revision: 1. Module created.
**/

module slice_16to8 (
  input [15:0] in, 
  output [7:0] out 
);

  assign out = in [15-:8];
  
endmodule