/**
  Module name:  axis_true_rms
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jul 2022
  Description: RMS compute with AXIS interface
  Revision: 1.0 Module created.
**/

module axis_true_rms_filter_v1_0 #(
  parameter inout_width = 16,
  parameter inout_fractional = 15
)(
  input aclk, 
  input resetn,

  /* slave axis interface */
  input signed [inout_width-1:0] s_axis_tdata,
  input s_axis_tvalid,
  output s_axis_tready,

  /* master axis interface */
  output signed [inout_width-1:0] m_axis_tdata,
  output m_axis_tvalid,
  input m_axis_tready
);

  /* rms fsm state */
  reg [2:0] rms_state; /* fsm state */

  wire [(inout_width*2)-1:0] squared_last_sample; /* last sample squared */

  wire [(inout_width*2)-1:0] mean_squared; /* mean squared */
  wire [(inout_width*2)-1:0] mean_squared_2; /* mean squared */
  wire o_filter1_dv; /* first filters tvalid signal */
  wire o_filter_dv; /* filter output data validready signal */
  wire i_sqrt_data_ready; /* sqrt read to accept new data */

  assign squared_last_sample = s_axis_tdata * s_axis_tdata; /* squaring last sample combinationally. Add registers if needed */

  assign s_axis_tready = i_filter_data_ready & i_sqrt_data_ready;

  axis_lpf_shifted_v1_0 #(
  .inout_width((inout_width*2)+1), /* add 1 bit to make it unsigned */
  .inout_decimal_width(31),
  .internal_width(38),
  .internal_decimal_width(36)
  ) lpf_inst (
  .aclk(aclk),
  .resetn(resetn),
  .i5_alpha(5), /* alpha input in shift value */
  /* slave axis interface */
  .s_axis_tdata(squared_last_sample),
  .s_axis_tlast(1'b0),
  .s_axis_tvalid(s_axis_tvalid),
  .s_axis_tready(i_filter_data_ready),
  /* master axis interface */
  .m_axis_tdata(mean_squared),
  .m_axis_tlast(),
  .m_axis_tvalid(o_filter1_dv),
  .m_axis_tready()
  );

  axis_lpf_shifted_v1_0 #(
  .inout_width((inout_width*2)+1), /* add 1 bit to make it unsigned */
  .inout_decimal_width(31),
  .internal_width(38),
  .internal_decimal_width(36)
  ) lpf2_inst (
  .aclk(aclk),
  .resetn(resetn),
  .i5_alpha(5), /* alpha input in shift value */
  /* slave axis interface */
  .s_axis_tdata(mean_squared),
  .s_axis_tlast(1'b0),
  .s_axis_tvalid(o_filter1_dv),
  .s_axis_tready(),
  /* master axis interface */
  .m_axis_tdata(mean_squared_2),
  .m_axis_tlast(),
  .m_axis_tvalid(o_filter_dv),
  .m_axis_tready()
  );

  non_restoring_sqrt_v1_0 #(
  .inout_width(inout_width)
  ) non_resoring_sqrt_inst (
  .aclk(aclk), 
  .resetn(resetn), 
  .radicand(mean_squared_2), /* radicand. double width */
  .i_data_valid(o_filter_dv), /* start division */
  .i_data_ready(i_sqrt_data_ready), /* algorithm ready to accept new data */
  .root(m_axis_tdata), /* quotient result */
  .o_data_valid(m_axis_tvalid), /* end division algorithm. Data ready in output port */
  .error_value0() /* error: division by zero */
  );

endmodule