/**
  Module name:  axis_biquad
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Abr 2021
  Description: Module to implement a biquad filter with AXI Stream interface.
  Revision: 1.0 Module created
**/

module axis_biquad_v1_0 #(
  parameter inout_width = 16,
  parameter inout_decimal_width = 15,
  parameter coefficient_width = 16,
  parameter coefficient_decimal_width = 15,
  parameter internal_width = 16,
  parameter internal_decimal_width = 15
  )(
  input aclk,
  input resetn,

  /* slave axis interface */
  input [inout_width-1:0] s_axis_tdata,
  input s_axis_tlast,
  input s_axis_tvalid,
  output s_axis_tready,

  /* master axis interface */
  output [inout_width-1:0] m_axis_tdata,
  output reg m_axis_tlast,
  output reg m_axis_tvalid,
  input m_axis_tready,

  /* coefficients */
  input signed [coefficient_width-1:0] b0,
  input signed [coefficient_width-1:0] b1,
  input signed [coefficient_width-1:0] b2,
  input signed [coefficient_width-1:0] a1,
  input signed [coefficient_width-1:0] a2
  );

  localparam inout_integer_width = inout_width - inout_decimal_width; /* compute integer width */
  localparam coefficient_integer_width = coefficient_width -coefficient_decimal_width; /* compute integer width */
  localparam internal_integer_width = internal_width - internal_decimal_width; /* compute integer width */

  wire signed [internal_width-1:0] input_int; /* input data internal size */
  wire signed [internal_width-1:0] b0_int; /* coefficient internal size */
  wire signed [internal_width-1:0] b1_int; /* coefficient internal size */
  wire signed [internal_width-1:0] b2_int; /* coefficient internal size */
  wire signed [internal_width-1:0] a1_int; /* coefficient internal size */
  wire signed [internal_width-1:0] a2_int; /* coefficient internal size */
  wire signed [internal_width-1:0] output_int; /* output internal size */

  reg signed [internal_width-1:0] input_pipe1; /* input data pipeline */
  reg signed [internal_width-1:0] input_pipe2; /* input data pipeline */
  reg signed [internal_width-1:0] output_pipe1; /* output data pipeline */
  reg signed [internal_width-1:0] output_pipe2; /* output data pipeline */

  wire signed [internal_width + internal_width-1:0] input_b0; /* product input */
  wire signed [internal_width + internal_width-1:0] input_b1; /* product input */
  wire signed [internal_width + internal_width-1:0] input_b2; /* product input */
  wire signed [internal_width + internal_width-1:0] output_a1; /* product output */
  wire signed [internal_width + internal_width-1:0] output_a2; /* product output */
  wire signed [internal_width + internal_width-1:0] output_2int; /* adder output */

  /* tvalid management */
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
      m_axis_tlast <= s_axis_tlast;


  /* resize signals to internal width */
  assign input_int = { {(internal_integer_width-inout_integer_width){s_axis_tdata[inout_width-1]}},
                            s_axis_tdata,
                            {(internal_decimal_width-inout_decimal_width){1'b0}} };
  assign b0_int = { {(internal_integer_width-coefficient_integer_width){b0[coefficient_width-1]}},
                            b0,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign b1_int = { {(internal_integer_width-coefficient_integer_width){b1[coefficient_width-1]}},
                            b1,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign b2_int = { {(internal_integer_width-coefficient_integer_width){b2[coefficient_width-1]}},
                            b2,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign a1_int = { {(internal_integer_width-coefficient_integer_width){a1[coefficient_width-1]}},
                            a1,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign a2_int = { {(internal_integer_width-coefficient_integer_width){a2[coefficient_width-1]}},
                            a2,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };

  /* pipeline registers */
  always @(posedge aclk)
    if (!resetn) begin
      input_pipe1 <= 0;
      input_pipe2 <= 0;
      output_pipe1 <= 0;
      output_pipe2 <= 0;
    end
    else
      if (s_axis_tvalid) begin
        input_pipe1 <= input_int;
        input_pipe2 <= input_pipe1;
        output_pipe1 <= output_int;
        output_pipe2 <= output_pipe1;
      end

  /* combinational multiplications */
  assign input_b0 = input_int * b0_int;
  assign input_b1 = input_pipe1 * b1_int;
  assign input_b2 = input_pipe2 * b2_int;
  assign output_a1 = output_pipe1 * a1_int;
  assign output_a2 = output_pipe2 * a2_int;

  assign output_2int = input_b0 + input_b1 + input_b2 - output_a1 - output_a2;
  assign output_int = output_2int >>> (internal_decimal_width);

  assign m_axis_tdata = output_int >>> (internal_decimal_width-inout_decimal_width);

endmodule
