/**
  Module name:  axis_fir1_8_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: May 2021
  Description: Module to implement a serial 8th order FIR filter
  Revision: 1.0 Module created
**/

module axis_fir1_32_symm_v1_0 #(
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
  input signed [coefficient_width-1:0] b8,
  input signed [coefficient_width-1:0] b9,
  input signed [coefficient_width-1:0] b10,
  input signed [coefficient_width-1:0] b11,
  input signed [coefficient_width-1:0] b12,
  input signed [coefficient_width-1:0] b13,
  input signed [coefficient_width-1:0] b14,
  input signed [coefficient_width-1:0] b15,
  input signed [coefficient_width-1:0] b16,
  input signed [coefficient_width-1:0] b17
  );

  localparam inout_integer_width = inout_width - inout_decimal_width; /* compute integer width */
  localparam coefficient_integer_width = coefficient_width -coefficient_decimal_width; /* compute integer width */
  localparam internal_integer_width = internal_width - internal_decimal_width; /* compute integer width */

  wire signed [internal_width-1:0] input_int; /* input data internal size */
  wire signed [internal_width-1:0] bx_int [0:16]; /* coefficient internal size */
  reg signed [internal_width-1:0] output_int; /* output internal size */

  reg signed [internal_width-1:0] input_pipe [0:32]; /* input data pipeline */

  wire signed [internal_width + internal_width-1:0] input_bn_temp; /* product input */
  wire signed [internal_width + internal_width-1:0] input_bn; /* product input */
  reg signed [internal_width + internal_width-1:0] output_2int; /* adder output */
  
  reg [5:0] index; /* counter for macc sequence */
  reg s_axis_tvalid_1; /* delayed tvalid signal */ 
  reg m_axis_tlast_mem; /* stored tlast signal */

  /* tlast management */
  always @(posedge aclk)
    if (!resetn)
      m_axis_tlast_mem <= 1'b0;
    else
      if (s_axis_tvalid)
        m_axis_tlast_mem <= s_axis_tlast;

  /* resize signals to internal width */
  assign input_int = { {(internal_integer_width-inout_integer_width){s_axis_tdata[inout_width-1]}},
                            s_axis_tdata,
                            {(internal_decimal_width-inout_decimal_width){1'b0}} };
  assign bx_int[0] = { {(internal_integer_width-coefficient_integer_width){b0[coefficient_width-1]}},
                            b0,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[1] = { {(internal_integer_width-coefficient_integer_width){b1[coefficient_width-1]}},
                            b1,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[2] = { {(internal_integer_width-coefficient_integer_width){b2[coefficient_width-1]}},
                            b2,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[3] = { {(internal_integer_width-coefficient_integer_width){b3[coefficient_width-1]}},
                            b3,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[4] = { {(internal_integer_width-coefficient_integer_width){b4[coefficient_width-1]}},
                            b4,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[5] = { {(internal_integer_width-coefficient_integer_width){b5[coefficient_width-1]}},
                            b5,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[6] = { {(internal_integer_width-coefficient_integer_width){b6[coefficient_width-1]}},
                            b6,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[7] = { {(internal_integer_width-coefficient_integer_width){b7[coefficient_width-1]}},
                            b7,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[8] = { {(internal_integer_width-coefficient_integer_width){b8[coefficient_width-1]}},
                            b8,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[9] = { {(internal_integer_width-coefficient_integer_width){b9[coefficient_width-1]}},
                            b9,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[10] = { {(internal_integer_width-coefficient_integer_width){b10[coefficient_width-1]}},
                            b10,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[11] = { {(internal_integer_width-coefficient_integer_width){b11[coefficient_width-1]}},
                            b11,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[12] = { {(internal_integer_width-coefficient_integer_width){b12[coefficient_width-1]}},
                            b12,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[13] = { {(internal_integer_width-coefficient_integer_width){b13[coefficient_width-1]}},
                            b13,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[14] = { {(internal_integer_width-coefficient_integer_width){b14[coefficient_width-1]}},
                            b14,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[15] = { {(internal_integer_width-coefficient_integer_width){b15[coefficient_width-1]}},
                            b15,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[16] = { {(internal_integer_width-coefficient_integer_width){b16[coefficient_width-1]}},
                            b16,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
  assign bx_int[17] = { {(internal_integer_width-coefficient_integer_width){b17[coefficient_width-1]}},
                            b17,
                            {(internal_decimal_width-coefficient_decimal_width){1'b0}} };

  /* pipeline registers */
  always @(posedge aclk)
    if (!resetn) begin
      input_pipe[0] <= 0;
      input_pipe[1] <= 0;
      input_pipe[2] <= 0;
      input_pipe[3] <= 0;
      input_pipe[4] <= 0;
      input_pipe[5] <= 0;
      input_pipe[6] <= 0;
      input_pipe[7] <= 0;
      input_pipe[8] <= 0;
      input_pipe[9] <= 0;
      input_pipe[10] <= 0;
      input_pipe[11] <= 0;
      input_pipe[12] <= 0;
      input_pipe[13] <= 0;
      input_pipe[14] <= 0;
      input_pipe[15] <= 0;
      input_pipe[16] <= 0;
      input_pipe[17] <= 0;
      input_pipe[18] <= 0;
      input_pipe[19] <= 0;
      input_pipe[20] <= 0;
      input_pipe[21] <= 0;
      input_pipe[22] <= 0;
      input_pipe[23] <= 0;
      input_pipe[24] <= 0;
      input_pipe[25] <= 0;
      input_pipe[26] <= 0;
      input_pipe[27] <= 0;
      input_pipe[28] <= 0;
      input_pipe[29] <= 0;
      input_pipe[30] <= 0;
      input_pipe[31] <= 0;
      input_pipe[32] <= 0;
    end
    else
      if (s_axis_tvalid) begin
        input_pipe[0] <= input_int;
        input_pipe[1] <= input_pipe[0];
        input_pipe[2] <= input_pipe[1];
        input_pipe[3] <= input_pipe[2];
        input_pipe[4] <= input_pipe[3];
        input_pipe[5] <= input_pipe[4];
        input_pipe[6] <= input_pipe[5];
        input_pipe[7] <= input_pipe[6];
        input_pipe[8] <= input_pipe[7];
        input_pipe[9] <= input_pipe[8];
        input_pipe[10] <= input_pipe[9];
        input_pipe[11] <= input_pipe[10];
        input_pipe[12] <= input_pipe[11];
        input_pipe[13] <= input_pipe[12];
        input_pipe[14] <= input_pipe[13];
        input_pipe[15] <= input_pipe[14];
        input_pipe[16] <= input_pipe[15];
        input_pipe[17] <= input_pipe[16];
        input_pipe[18] <= input_pipe[17];
        input_pipe[19] <= input_pipe[18];
        input_pipe[20] <= input_pipe[19];
        input_pipe[21] <= input_pipe[20];
        input_pipe[22] <= input_pipe[21];
        input_pipe[23] <= input_pipe[22];
        input_pipe[24] <= input_pipe[23];
        input_pipe[25] <= input_pipe[24];
        input_pipe[26] <= input_pipe[25];
        input_pipe[27] <= input_pipe[26];
        input_pipe[28] <= input_pipe[27];
        input_pipe[29] <= input_pipe[28];
        input_pipe[30] <= input_pipe[29];
        input_pipe[31] <= input_pipe[30];
        input_pipe[32] <= input_pipe[31];
      end

  /* one cycle delay */
  always @(posedge aclk)
    if (!resetn)
      s_axis_tvalid_1 <= 1'b0;
    else 
      s_axis_tvalid_1 <= s_axis_tvalid;

  /* fsm to perform macc operations */
  always @(posedge aclk)
    if (!resetn) begin
      index <= 4'd0;
      output_2int <= 0;
      output_int <= 0;
      m_axis_tvalid <= 1'b0;
      m_axis_tlast <= 1'b0;
    end
    else 
      if (index == 17) begin
        output_int <= output_2int >>> (internal_decimal_width);
        output_2int <= 0;
        m_axis_tvalid <= 1'b1;
        m_axis_tlast <= m_axis_tlast_mem;
        index <= 0;
      end
      else if (s_axis_tvalid_1 || (index != 0)) begin
        index <= index + 1;
        output_2int <= output_2int + input_bn;
      end
      else begin
        m_axis_tvalid <= 1'b0;
        m_axis_tlast <= 1'b0;
        index <= 0;
      end

  /* macc operation */
  assign input_bn_temp = (index == 16)? input_pipe[index]: (input_pipe[index]+input_pipe[32-index]);
  assign input_bn = input_bn_temp * bx_int[index];

  /* output resize */
  assign m_axis_tdata = output_int >>> (internal_decimal_width-inout_decimal_width);

endmodule