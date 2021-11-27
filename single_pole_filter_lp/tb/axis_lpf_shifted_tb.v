`timescale 1ns/10ps

module axis_fir_tb ();

  reg aclk;
  reg resetn;
  reg ce;
  wire [11:0] output_data;

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
    #(10000-5)
    forever begin
      ce <= 1'b1;
      #10
      ce <= 1'b0;
      #(10000-10);
    end
  end

  axis_lpf_shifted_v1_0 #(
  .inout_width(12),
  .inout_decimal_width(11),
  .internal_width(32),
  .internal_decimal_width(31)
  ) uut (
  .aclk(aclk),
  .resetn(resetn),
  .i5_alpha(5'd8), /* alpha input in shift value */
  .s_axis_tdata(12'd300),
  .s_axis_tlast(),
  .s_axis_tvalid(ce),
  .s_axis_tready(),
  .m_axis_tdata(output_data),
  .m_axis_tlast(),
  .m_axis_tvalid(),
  .m_axis_tready()
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
      //#1500000
      #21500000
      $fclose(f);
      $finish;
  end


endmodule