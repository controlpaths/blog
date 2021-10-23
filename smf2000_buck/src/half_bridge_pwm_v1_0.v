/**
  Module name:  half_bridge_pwm_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Sept 2021
  Description: Module to generate a synchronous pwm signal with configurable deadtime.
  Revision: 1. Module created.
**/

module half_bridge_pwm_v1_0 (
  input clk, 
  input rstn, 

  input [31:0] period, /* pwm period */
  input [31:0] duty_cycle, /* pwm duty cycle */
  input [31:0] dead_time, /* dead time between high and low conmutation */

  /* config */
  input slope, /* configure whether counter is a sawtooth (0), or a triangular signal (1) */
  input pwm_on, /* start modulation */

  /* status */
  output f_period, /* signal indicates when counter is equal to period */
  output f_zero, /* signal indicates when counter is equal to zero */
  output reg [31:0] counter, /* period counter */
  output reg [31:0] dt_counter, /* dead time counter */

  /* pwm signals */
  output reg pwm_h, /* high side pwm */
  output reg pwm_l
);

  reg up; /* indicates the direction of the carrier  */
  reg [1:0] pwm_state; /* pwm output state */

  /* carrier generation */
  always @(posedge clk)
    if (!rstn) begin
      counter <= 32'd0;
      up <= 0;
    end
    else 
      if (up && (counter < period))
        counter <= counter + 1;
      else if (up && (counter == period) && !slope) /* if sawtooth selected , counter is reset */
        counter <= 32'd0;
      else if (up && (counter == period) && slope) /* if triangular mode is selected, slope changes direction */
        up <= 1'b0;
      else if (!up && (counter > 0))
        counter <= counter - 32'd1;
      else if (!up && (counter == 0))
        up <= 1'b1;

  assign f_period = (counter == period)? 1'b1: 1'b0;
  assign f_zero = (counter == 32'd0)? 1'b1: 1'b0;

  /* pwm generation */
  always @(posedge clk)
    if (!rstn) begin
      pwm_h <= 1'b0;
      pwm_l <= 1'b0;
      dt_counter <= 32'd0;
      pwm_state <= 2'b00;
    end
    else 
      case (pwm_state)
        2'b00: begin /* all open */
          if ((counter < duty_cycle) && pwm_on) pwm_state <= 2'b01;
          else if ((counter >= duty_cycle) && pwm_on) pwm_state <= 2'b10;
          else pwm_state <= 2'b00;

          pwm_h <= 1'b0;
          pwm_l <= 1'b0;
          dt_counter <= 32'd0;
        end
        2'b01: begin /* positive connected */
          if (!pwm_on) pwm_state <= 2'b00;
          else if (counter >= duty_cycle) pwm_state <= 2'b11;
          else pwm_state <= 2'b01;

          pwm_h <= 1'b1;
          pwm_l <= 1'b0;
          dt_counter <= 32'd0;
        end
        2'b10: begin /* negative connected */
          if (!pwm_on) pwm_state <= 2'b00;
          else if (counter < duty_cycle) pwm_state <= 2'b11;
          else pwm_state <= 2'b10;

          pwm_h <= 1'b0;
          pwm_l <= 1'b1;
          dt_counter <= 32'd0;
        end
        2'b11: begin /* dead time */
          if (!pwm_on) pwm_state <= 2'b00;
          else if ((counter < duty_cycle) && (dt_counter >= dead_time)) pwm_state <= 2'b01;
          else if ((counter >= duty_cycle) && (dt_counter >= dead_time)) pwm_state <= 2'b10;
          else pwm_state <= 2'b11;

          pwm_h <= 1'b0;
          pwm_l <= 1'b0;
          dt_counter <= dt_counter + 32'd1;
        end
      endcase
      

endmodule