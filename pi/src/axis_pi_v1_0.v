/**
  Module name:  axis_pi
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Mar 2022
  Description: PI regulator with impulse invariance discretization.
  Revision: 1.0 Module created
**/

module axis_pi_v1_0 #(
  parameter inout_width = 12, 
  parameter inout_decimal_width = 11, 
  parameter internal_width = 16,
  parameter internal_decimal_width = 15,
  parameter gain_width = 12,
  parameter gain_decimal_width = 11
)(
  input aclk, 
  input resetn, 

  input [gain_width-1:0] kp, /* regulator gain */
  input [gain_width-1:0] ki, /* regulator gain */

  input signed [inout_width-1:0] output_max, /* max saturation level */
  input signed [inout_width-1:0] output_min, /* min saturation level */

  input [inout_width-1:0] s_axis_input_tdata, /* slave axis input data */
  input s_axis_input_tvalid, /* slave axis input tvalid */
  output s_axis_input_tready, /* slave axis input tready */

  input [inout_width-1:0] s_axis_reference_tdata, /* slave axis reference data */
  input s_axis_reference_tvalid, /* slave axis reference tvalid */
  output s_axis_reference_tready, /* slave axis reference tready */

  output [inout_width-1:0] m_axis_output_tdata,  /* master axis output data */
  output reg m_axis_output_tvalid,  /* master axis output tvalid */
  input m_axis_output_tready  /* master axis output tready */
);

  localparam inout_integer_width = inout_width - inout_decimal_width; /* compute integer width */
  localparam gain_integer_width = gain_width - gain_decimal_width; /* compute integer width */
  localparam internal_integer_width = internal_width - internal_decimal_width; /* compute integer width */

  wire signed [internal_width-1:0] input_internal; /* input resized with internal width */
  wire signed [internal_width-1:0] reference_internal; /* reference resized with internal width */
  wire signed [internal_width-1:0] kp_internal; /* kp resized with internal width */
  wire signed [internal_width-1:0] ki_internal; /* ki resized with internal width */

  reg signed [internal_width+internal_width:0] integral_register; /* register to perform the integral accumulation */
  wire signed [internal_width:0] error; /* reference - input */
  wire signed [internal_width+internal_width:0] ki_error; /* result multiplication error and ki */
  wire signed [internal_width+internal_width:0] kp_error; /* result multiplication error and kp */
  wire signed [internal_width+internal_width:0] control_action_sum; /* output adder of control action */

  reg signed [inout_width-1:0] output_nsat; /* regulator output before saturation */

  assign input_internal = { {(internal_integer_width-inout_integer_width){s_axis_input_tdata[inout_width-1]}},
                            s_axis_input_tdata,
                            {(internal_decimal_width-inout_decimal_width){1'b0}} };

  assign reference_internal = { {(internal_integer_width-inout_integer_width){s_axis_reference_tdata[inout_width-1]}},
                            s_axis_reference_tdata,
                            {(internal_decimal_width-inout_decimal_width){1'b0}} };

  assign kp_internal = { {(internal_integer_width-gain_integer_width){kp[gain_width-1]}},
                            kp,
                            {(internal_decimal_width-gain_decimal_width){1'b0}} };

  assign ki_internal = { {(internal_integer_width-gain_integer_width){ki[gain_width-1]}},
                            ki,
                            {(internal_decimal_width-gain_decimal_width){1'b0}} };

  assign error = $signed({reference_internal[internal_width-1], reference_internal}) - $signed({input_internal[internal_width-1], input_internal});

  assign ki_error = error * ki_internal;
  assign kp_error = error * kp_internal;

  /* integral */
  always @(posedge aclk)
    if (!resetn)
      integral_register <= {(internal_width+1){1'b0}};
    else
      if (s_axis_input_tvalid)
        if (($signed(output_nsat > output_min) && $signed(output_nsat < output_max)) || 
            ((ki_error > 0) && $signed(output_nsat < output_min)) || 
            ((ki_error < 0) && $signed(output_nsat > output_max)))
          integral_register <= integral_register + ki_error;
        else
          integral_register <= integral_register;

  assign control_action_sum = (kp_error >>> internal_decimal_width) + (integral_register >>> internal_decimal_width);

  /* output register */
  always @(posedge aclk)
    if (!resetn)
      output_nsat <= {internal_width{1'b0}};
    else
      if (s_axis_input_tvalid)
        output_nsat <= control_action_sum >>> (internal_decimal_width-inout_decimal_width);
  
  assign m_axis_output_tdata = (output_nsat > output_max)? output_max: (output_nsat < output_min)? output_min: output_nsat;

endmodule