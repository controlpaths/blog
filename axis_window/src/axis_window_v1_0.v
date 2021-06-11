/**
  Module name:  axis_window
  Author: P Trujillo (pablo@controlpaths.com)
  Date: May 2021
  Description: Module to apply a window stored in BRAM to data stream.
  Revision: 1.0 Module created
**/

module axis_window_v1_0 #(
  parameter window_length = 32,
  parameter inout_width = 16,
  parameter inout_decimal_width = 15,
  parameter window_coeff_width = 16,
  parameter window_coeff_decimal_width = 15,
  parameter internal_width = 16,
  parameter internal_decimal_width = 15,
  parameter memory_depth_width = 6
  )(
  input aclk, 
  input resetn, 

  input start_burst, /* start to apply window */

  /* slave axis interface */
  input [inout_width-1:0] s_axis_tdata,
  input s_axis_tlast,
  input s_axis_tvalid,
  output s_axis_tready,

  /* master axis interface */
  output [31:0] m_axis_tdata, /* fixed width for up to 16 bit xfft */
  output reg m_axis_tlast,
  output reg m_axis_tvalid,
  input m_axis_tready,

  /* window memory interface */
  output reg [memory_depth_width-1:0] mem_addr,
  input [window_coeff_width-1:0] mem_din
  );

  localparam inout_integer_width = inout_width - inout_decimal_width; /* compute integer width */
  localparam window_coeff_integer_width = window_coeff_width - window_coeff_decimal_width; /* compute integer width */
  localparam internal_integer_width = internal_width - internal_decimal_width; /* compute integer width */

  wire signed [internal_width-1:0] input_int; /* input data internal size */
  wire signed [internal_width-1:0] window_coeff; /* window coefficient internal size */
  wire signed [internal_width+internal_width-1:0] input_window_coeff; /* product internal size */
  reg core_run;

  /* resize signals to internal width */
  assign input_int = { {(internal_integer_width-inout_integer_width){s_axis_tdata[inout_width-1]}},
                            s_axis_tdata,
                            {(internal_decimal_width-inout_decimal_width){1'b0}} };
  assign window_coeff = { {(internal_integer_width-window_coeff_integer_width){mem_din[window_coeff_width-1]}},
                            mem_din,
                            {(internal_decimal_width-window_coeff_decimal_width){1'b0}} };
  
  /* tvalid management */
  /* change for registered multiplication */
  always @(posedge aclk)
    if (!resetn)
      m_axis_tvalid <= 1'b0;
    else
      m_axis_tvalid <= s_axis_tvalid;

  /* tlast management */
  always @(posedge aclk)
    if (!resetn)
      m_axis_tlast <= 1'b0;
    else
      m_axis_tlast <= (mem_addr == (window_length-1))? 1'b1: 1'b0;

  /* memory address management */
  always @(posedge aclk)
    if (!resetn) 
      mem_addr <= 0;
    else 
      if (s_axis_tvalid && (mem_addr <= (window_length-1)) && m_axis_tready)
        mem_addr <= mem_addr + 1;
      else if (start_burst)
        mem_addr <= 0;
      else 
        mem_addr <= mem_addr;

  assign input_window_coeff = input_int * window_coeff;
  assign m_axis_tdata = (input_window_coeff >>> ((internal_decimal_width*2)-15)) & 32'h0000ffff;
  
endmodule