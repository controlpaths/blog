`timescale 1ns/10ps

module axis_biquad_tb ();

  reg aclk;
  reg resetn;
  reg pwm_on;
  
  initial begin
    aclk <= 1'b0;
    #5;
    forever begin
      aclk <= ~aclk;
      #5;
    end
  end

  initial begin
    resetn <= 1'b0;
    #100;
    resetn <= 1'b1;
  end

  initial begin
    pwm_on <= 1'b0;
    #100;
    pwm_on <= 1'b1;
  end

  half_bridge_pwm_v1_0 uut (
  .clk(aclk), 
  .rstn(resetn), 
  .period(32'd1000), /* pwm period */
  .duty_cycle(32'd500), /* pwm duty cycle */
  .dead_time(32'd10), /* dead time between high and low conmutation */
  /* config */
  .slope(1'b0), /* configure whether counter is a sawtooth (0), or a triangular signal (1) */
  .pwm_on(pwm_on), /* start modulation */
  /* status */
  .f_period(), /* signal indicates when counter is equal to period */
  .f_zero(), /* signal indicates when counter is equal to zero */
  .counter(), /* period counter */
  .dt_counter(), /* dead time counter */
  /* pwm signals */
  .pwm_h(pwm_h), /* high side pwm */
  .pwm_l(pwm_l)
  );

  /* log data on biquad_simu.sim/sim_1/behav/xsim*/
  initial begin
    $dumpfile("half_bridge_pwm_test.vcd");
    $dumpvars;
  end

endmodule