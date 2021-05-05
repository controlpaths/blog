/**
  Module name:  axis_fir
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Abr2021
  Description: Module to implement a FIR filter with configurable order
  Revision: 1.0 Module created
**/

module axis_fir_v1_0 #(
  parameter filter_order = 16,
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

  /* vector coefficients */
  input [(coefficient_width*filter_order)-1:0] coeff_vector
  );

  localparam inout_integer_width = inout_width - inout_decimal_width; /* compute integer width */
  localparam coefficient_integer_width = coefficient_width -coefficient_decimal_width; /* compute integer width */
  localparam internal_integer_width = internal_width - internal_decimal_width; /* compute integer width */

  wire [internal_width-1:0] coefficient_int [0:filter_order]; /* coefficient matrix */
  wire [internal_width-1:0] input_int;

  reg [internal_width-1:0] input_pipeline [0:filter_order]; /* input pipeline matrix */

  /* resize coefficients */
  generate
    for (genvar i=0;i<=filter_order;i=i+1) begin
      assign coefficient_int[i]= { {(internal_integer_width-coefficient_integer_width){coeff_vector[i][coefficient_width-1]}},
                                    coeff_vector[i],
                                    {(internal_decimal_width-coefficient_decimal_width){1'b0}} };
    end
  endgenerate

  /* resize input */
  assign input_int= { {(internal_integer_width-inout_integer_width){s_axis_tdata[coefficient_width-1]}},
                              s_axis_tdata,
                              {(internal_decimal_width-internal_decimal_width){1'b0}} };
  
  /* input pipeline */
  always @(posedge clk)
    if (!resetn)
      input_pipeline[0] <= 0;
    else 
      if (s_axis_tvalid)
        input_pipeline[0] <= input_int;

  generate
    for (genvar i=1;i<=filter_order;i=i+1) begin
      always @(posedge clk )
        if (!resetn)
        input_pipeline[i] <= 0;
        else
          if (s_axis_tvalid)
            input_pipeline[i] <= input_pipeline[i-1];
    end
  endgenerate




endmodule