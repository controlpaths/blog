`timescale 1ns/10ps

module axis_fir_tb ();

  reg aclk;
  reg resetn;
  reg ce;

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

  axis_window_v1_0 #(
  .window_length(32),
  .inout_width(16),
  .inout_decimal_width(15),
  .window_coeff_width(16),
  .window_coeff_decimal_width(15),
  .internal_width(16),
  .internal_decimal_width(15),
  .memory_depth_width(6)
  ) uut (
  .aclk(aclk), 
  .resetn(resetn), 
  /* slave axis interface */
  .s_axis_tdata(16'd1000),
  .s_axis_tlast(),
  .s_axis_tvalid(ce),
  .s_axis_tready(),
  /* master axis interface */
  .m_axis_tdata(), /* fixed width for up to 16 bit xfft */
  .m_axis_tlast(),
  .m_axis_tvalid(),
  .m_axis_tready(1'b1),
  /* window memory interface */
  .mem_addr(),
  .mem_din(16'd32767)
  );

  /* log */
  initial begin
    $dumpfile("axis_window.vcd");
    $dumpvars;
  end

endmodule


