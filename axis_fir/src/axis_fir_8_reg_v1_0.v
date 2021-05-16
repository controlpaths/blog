/**
  Module name:  axis_fir_8_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: May 2021
  Description: Module to implement a 8th order FIR filter
  Revision: 1.0 Module created
**/

module axis_fir_8_reg_v1_0 #(
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
  input signed [coefficient_width-1:0] b3,
  input signed [coefficient_width-1:0] b4,
  input signed [coefficient_width-1:0] b5,
  input signed [coefficient_width-1:0] b6,
  input signed [coefficient_width-1:0] b7,
  input signed [coefficient_width-1:0] b8
  );

  localparam inout_integer_width = inout_width - inout_decimal_width; /* compute integer width */
  localparam coefficient_integer_width = coefficient_width -coefficient_decimal_width; /* compute integer width */
  localparam internal_integer_width = internal_width - internal_decimal_width; /* compute integer width */

  wire signed [internal_width-1:0] input_int; /* input data internal size */
  wire signed [internal_width-1:0] b0_int; /* coefficient internal size */
  wire signed [internal_width-1:0] b1_int; /* coefficient internal size */
  wire signed [internal_width-1:0] b2_int; /* coefficient internal size */
  wire signed [internal_width-1:0] b3_int; /* coefficient internal size */
  wire signed [internal_width-1:0] b4_int; /* coefficient internal size */
  wire signed [internal_width-1:0] b5_int; /* coefficient internal size */
  wire signed [internal_width-1:0] b6_int; /* coefficient internal size */
  wire signed [internal_width-1:0] b7_int; /* coefficient internal size */
  wire signed [internal_width-1:0] b8_int; /* coefficient internal size */
  wire signed [internal_width-1:0] output_int; /* output internal size */

  reg signed [internal_width-1:0] input_pipe0; /* input data pipeline */
  reg signed [internal_width-1:0] input_pipe1; /* input data pipeline */
  reg signed [internal_width-1:0] input_pipe2; /* input data pipeline */
  reg signed [internal_width-1:0] input_pipe3; /* input data pipeline */
  reg signed [internal_width-1:0] input_pipe4; /* input data pipeline */
  reg signed [internal_width-1:0] input_pipe5; /* input data pipeline */
  reg signed [internal_width-1:0] input_pipe6; /* input data pipeline */
  reg signed [internal_width-1:0] input_pipe7; /* input data pipeline */
  reg signed [internal_width-1:0] input_pipe8; /* input data pipeline */

  reg signed [internal_width + internal_width-1:0] input_b0; /* product input */
  reg signed [internal_width + internal_width-1:0] input_b1; /* product input */
  reg signed [internal_width + internal_width-1:0] input_b2; /* product input */
  reg signed [internal_width + internal_width-1:0] input_b3; /* product input */
  reg signed [internal_width + internal_width-1:0] input_b4; /* product input */
  reg signed [internal_width + internal_width-1:0] input_b5; /* product input */
  reg signed [internal_width + internal_width-1:0] input_b6; /* product input */
  reg signed [internal_width + internal_width-1:0] input_b7; /* product input */
  reg signed [internal_width + internal_width-1:0] input_b8; /* product input */
  wire signed [internal_width + internal_width-1:0] output_2int; /* adder output */

  reg s_axis_tvalid_1; /* delayed tvalid signal */ 
  reg m_axis_tlast_mem; /* stored tlast signal */

  /* tlast management */
  always @(posedge aclk)
    if (!resetn)
      m_axis_tlast_mem <= 1'b0;
    else
      if (s_axis_tvalid)
        m_axis_tlast_mem <= s_axis_tlast;

  /* tvalid management */
  always @(posedge aclk)
    if (!resetn)
      m_axis_tvalid <= 1'b0;
    else
      m_axis_tvalid <= s_axis_tvalid_1;

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
  assign b3_int = { {(internal_integer_width-coefficient_integer_width){b3[coefficient_width-1]}},
                            b3,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign b4_int = { {(internal_integer_width-coefficient_integer_width){b4[coefficient_width-1]}},
                            b4,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign b5_int = { {(internal_integer_width-coefficient_integer_width){b5[coefficient_width-1]}},
                            b5,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign b6_int = { {(internal_integer_width-coefficient_integer_width){b6[coefficient_width-1]}},
                            b6,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign b7_int = { {(internal_integer_width-coefficient_integer_width){b7[coefficient_width-1]}},
                            b7,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign b8_int = { {(internal_integer_width-coefficient_integer_width){b8[coefficient_width-1]}},
                            b8,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };

/* pipeline registers */
  always @(posedge aclk)
    if (!resetn) begin
      input_pipe0 <= 0;
      input_pipe1 <= 0;
      input_pipe2 <= 0;
      input_pipe3 <= 0;
      input_pipe4 <= 0;
      input_pipe5 <= 0;
      input_pipe6 <= 0;
      input_pipe7 <= 0;
      input_pipe8 <= 0;
    end
    else
      if (s_axis_tvalid) begin
        input_pipe0 <= input_int;
        input_pipe1 <= input_pipe0;
        input_pipe2 <= input_pipe1;
        input_pipe3 <= input_pipe2;
        input_pipe4 <= input_pipe3;
        input_pipe5 <= input_pipe4;
        input_pipe6 <= input_pipe5;
        input_pipe7 <= input_pipe6;
        input_pipe8 <= input_pipe7;
      end

  /* one cycle delay */
  always @(posedge aclk)
    if (!resetn)
      s_axis_tvalid_1 <= 1'b0;
    else 
      s_axis_tvalid_1 <= s_axis_tvalid;

  /* MACC structure registered */
  always @(posedge aclk)
    if (!resetn) begin
      input_b0 <= 0;
      input_b1 <= 0;
      input_b2 <= 0;
      input_b3 <= 0;
      input_b4 <= 0;
      input_b5 <= 0;
      input_b6 <= 0;
      input_b7 <= 0;
      input_b8 <= 0;
    end
    else begin
      input_b0 <= input_pipe0 * b0_int;
      input_b1 <= (input_pipe1 * b1_int);
      input_b2 <= (input_pipe2 * b2_int);
      input_b3 <= (input_pipe3 * b3_int);
      input_b4 <= (input_pipe4 * b4_int);
      input_b5 <= (input_pipe5 * b5_int);
      input_b6 <= (input_pipe6 * b6_int);
      input_b7 <= (input_pipe7 * b7_int);
      input_b8 <= (input_pipe8 * b8_int);    
    end
  
  assign output_2int = input_b0 + input_b1 + input_b2 + input_b3 + input_b4 + input_b5 + input_b6 + input_b7 + input_b8;
  assign output_int = output_2int >>> (internal_decimal_width);

  assign m_axis_tdata = output_int >>> (internal_decimal_width-inout_decimal_width);

endmodule