/**
  Module name:  axis_lpf_shifted_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: May 2021
  Description: Module to implement a 8th order FIR filter
  Revision: 1.0 Module created
**/

module axis_lpf_shifted_v1_0 #(
  parameter inout_width = 16,
  parameter inout_decimal_width = 15,
  parameter internal_width = 16,
  parameter internal_decimal_width = 15
  )(
  input aclk,
  input resetn,

  input [4:0] i5_alpha, /* alpha input in shift value */

  /* slave axis interface */
  input [inout_width-1:0] s_axis_tdata,
  input s_axis_tlast,
  input s_axis_tvalid,
  output s_axis_tready,

  /* master axis interface */
  output [inout_width-1:0] m_axis_tdata,
  output reg m_axis_tlast,
  output reg m_axis_tvalid,
  input m_axis_tready
  );

  localparam inout_integer_width = inout_width - inout_decimal_width; /* compute integer width */
  localparam internal_integer_width = internal_width - internal_decimal_width; /* compute integer width */

  wire signed [internal_width-1:0] input_int; /* input data internal size */
  reg signed [internal_width-1:0] reg_output_int; /* output internal size */

  /* resize signals to internal width */
  assign input_int = { {(internal_integer_width-inout_integer_width){s_axis_tdata[inout_width-1]}},
                            s_axis_tdata,
                            {(internal_decimal_width-inout_decimal_width){1'b0}} };

  /* tlast management */
  always @(posedge aclk)
    if (!resetn)
      m_axis_tlast <= 1'b0;
    else
      if (s_axis_tvalid)
        m_axis_tlast <= s_axis_tlast;

  /* tvalid management */
  always @(posedge aclk)
    if (!resetn)
      m_axis_tvalid <= 1'b0;
    else
      m_axis_tvalid <= s_axis_tvalid;
  
  /* filter kernel */
  always @(posedge aclk)
    if (!resetn)
      reg_output_int <= {inout_width{1'b0}};
    else
      if (s_axis_tvalid)
        reg_output_int <= reg_output_int + ((input_int - reg_output_int) >>> i5_alpha);
  
  /* resize for inout width */
  assign m_axis_tdata = reg_output_int >>> (internal_decimal_width-inout_decimal_width);


endmodule