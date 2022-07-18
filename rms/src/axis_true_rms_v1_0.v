/**
  Module name:  axis_true_rms
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jul 2022
  Description: RMS compute with AXIS interface
  Revision: 1.0 Module created.
**/

module axis_true_rms_v1_0 #(
  parameter inout_width = 16,
  parameter inout_fractional = 15,
  parameter rms_nsamples = 256
)(
  input aclk, 
  input resetn,

  /* slave axis interface */
  input signed [inout_width-1:0] s_axis_tdata,
  input s_axis_tvalid,
  output reg s_axis_tready,

  /* master axis interface */
  output [inout_width-1:0] m_axis_tdata,
  output m_axis_tvalid,
  input m_axis_tready
);

  localparam mem_samples_index_width = $clog2(rms_nsamples);

  /* rms fsm state */
  reg [2:0] rms_state; /* fsm state */

  /* samples memory */
  (* ram_style =  "distributed" *)  reg [(inout_width*2)-1:0] mem_samples [rms_nsamples-1:0]; /* samples memory */
  reg [mem_samples_index_width-1:0] mem_samples_index; /* samples memory index */

  wire [(inout_width*2)-1:0] squared_last_sample; /* last sample squared */
  reg [(inout_width*2*$clog2(rms_nsamples))-1:0] acc_squared_samples;  /* accumulator of squared samples */

  wire [(inout_width*2)-1:0] mean_squared; /* mean squared */
  reg [(inout_width*2)-1:0] sample_to_subtract;  /* sample to subtract in te next iteration */
  wire o_division_dv; /* division data ready signal */
  reg i_division_sqrt_pipe_dv; /* division data valid signal */

  integer j;
  initial   
    for(j = 0; j < rms_nsamples; j = j+1) 
      mem_samples[j] = {inout_width{1'b0}};

  assign rms_dvalid = (rms_state == 0)? 1'b1: 1'b0;

  assign squared_last_sample = s_axis_tdata * s_axis_tdata; /* squaring last sample combinationally. Add registers if needed */

  always @(posedge aclk)
    if (!resetn) begin
      rms_state <= 3'd0;
      mem_samples_index <= 0;
      i_division_sqrt_pipe_dv <= 1'b0;
      acc_squared_samples <= 0;
      s_axis_tready <= 1'b0;
      sample_to_subtract <= 0;
    end
    else 
      case (rms_state)
        3'd0: begin
          if (s_axis_tvalid) rms_state <= 3'd1;
          else rms_state <= 3'd0;
          
          s_axis_tready <= 1'b1;
          
        end
        3'd1: begin 
          rms_state <= 3'd2;

          /* sustract first sample and add last one */
          acc_squared_samples <= acc_squared_samples - sample_to_subtract + squared_last_sample;

          s_axis_tready <= 1'b0;
        end
        3'd2: begin /* start division and square root pipeline */
          rms_state <= 3'd3;

          /* increase samples index */
          mem_samples_index <= (mem_samples_index == (rms_nsamples-1))? 0: mem_samples_index + 1;

          mem_samples[mem_samples_index] <= $unsigned(squared_last_sample);         

          i_division_sqrt_pipe_dv <= 1'b1;
        end
        3'd3: begin
          if (m_axis_tvalid) rms_state <= 3'd0;
          else rms_state <= 3'd3;

          i_division_sqrt_pipe_dv <= 1'b0;
          sample_to_subtract <= mem_samples[mem_samples_index];
        end
      endcase


  non_restoring_division_v1_1 #(
  .inout_width((inout_width*2*$clog2(rms_nsamples)))
  )non_restoring_division_inst(
  .aclk(aclk), 
  .resetn(resetn), 
  .numerator(acc_squared_samples), /* numerator */
  .denominator(rms_nsamples), /* denominator */
  .i_data_valid(i_division_sqrt_pipe_dv), /* start division */
  .quotient(mean_squared), /* quotient result */
  .remainder(), /* remainder result */
  .o_data_valid(o_division_dv), /* end division algorithm. Data ready in output port */
  .o_data_ready(o_division_dr), /* end division algorithm. Data ready in output port */
  .error_div0() /* error: division by zero */
  );

  non_restoring_sqrt_v1_0 #(
  .inout_width(inout_width)
  ) non_resoring_sqrt_inst (
  .aclk(aclk), 
  .resetn(resetn), 
  .radicand(mean_squared), /* radicand. double width */
  .i_data_valid(o_division_dv), /* start division */
  .root(m_axis_tdata), /* quotient result */
  .o_data_valid(m_axis_tvalid), /* end division algorithm. Data ready in output port */
  .error_value0() /* error: division by zero */
  );

endmodule