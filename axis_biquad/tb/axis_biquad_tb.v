`timescale 1ns/10ps

module axis_biquad_tb ();

  reg aclk;
  reg resetn;
  reg ce;
  wire [15:0] output_data;
  integer f;

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
    ce <= 1'b0;
    #10000
    forever begin
      ce <= 1'b1;
      #10
      ce <= 1'b0;
      #(10000-10);
    end
  end

  axis_biquad_v1_0 #(
  .inout_width(16),
  .inout_decimal_width(15),
  .coefficient_width(20),
  .coefficient_decimal_width(18),
  .internal_width(20),
  .internal_decimal_width(18)
  ) uut (
  .aclk(aclk),
  .resetn(resetn),
  /* slave axis interface */
  .s_axis_tdata(1000),
  .s_axis_tlast(1'b0),
  .s_axis_tvalid(ce),
  .s_axis_tready(),
  /* master axis interface */
  .m_axis_tdata(output_data),
  .m_axis_tlast(),
  .m_axis_tvalid(),
  .m_axis_tready(1'b1),
  /* coefficients */
  .b0(20'd256),
  .b1(20'd513),
  .b2(20'd256),
  .a1(-20'd519991),
  .a2(20'd258873)
  );

  /* log data on biquad_simu.sim/sim_1/behav/xsim*/
  initial begin
    f = $fopen("data.txt","w");
  end

  initial
    forever begin
      #10000;
      $fwrite(f,"%d\n",output_data);
    end

  initial begin
      #1500000
      $fclose(f);
      $finish;
  end




endmodule
