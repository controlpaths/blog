`timescale 1ns/10ps

module mcp3204_tb ();

  reg aclk;
  reg resetn;

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

  axis_mcp3204_v1_0 #(
  .prescaler_sclk(10),
  .prescaler_sclk_width(4),
  .sngl_ndiff(1'b1)
  ) uut (
  .aclk(aclk),
  .resetn(resetn),

  .m_axis_ch0_tdata(),
  .m_axis_ch0_tlast(),
  .m_axis_ch0_tvalid(),
  .m_axis_ch0_tready(),

  .m_axis_ch1_tdata(),
  .m_axis_ch1_tlast(),
  .m_axis_ch1_tvalid(),
  .m_axis_ch1_tready(),

  .m_axis_ch2_tdata(),
  .m_axis_ch2_tlast(),
  .m_axis_ch2_tvalid(),
  .m_axis_ch2_tready(),

  .m_axis_ch3_tdata(),
  .m_axis_ch3_tlast(),
  .m_axis_ch3_tvalid(),
  .m_axis_ch3_tready(),

  .spi_mosi(miso),
  .spi_miso(miso),
  .spi_sclk(),
  .spi_ss()
  );

 endmodule