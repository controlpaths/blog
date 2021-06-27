`timescale 1ns/10ps

module axis_fir_tb ();

  reg aclk;
  reg resetn;
  reg ce;
  wire [15:0] output_data;
  wire [15:0] output_data1;
  wire [15:0] output_data2;
  wire [15:0] output_data3;
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

  // axis_fir_8_v1_0 #(
  // .inout_width(16),
  // .inout_decimal_width(15),
  // .coefficient_width(16),
  // .coefficient_decimal_width(15),
  // .internal_width(16),
  // .internal_decimal_width(15)
  // ) uut (
  // .aclk(aclk),
  // .resetn(resetn),
  // /* slave axis interface */
  // .s_axis_tdata(16'd1000),
  // .s_axis_tlast(1'b0),
  // .s_axis_tvalid(ce),
  // .s_axis_tready(),
  // /* master axis interface */
  // .m_axis_tdata(output_data),
  // .m_axis_tlast(),
  // .m_axis_tvalid(),
  // .m_axis_tready(),
  // /* coefficients */
  // .b0(-16'd202),
  // .b1(-16'd446),
  // .b2(16'd1678),
  // .b3(16'd8705),
  // .b4(16'd13292),
  // .b5(16'd8705),
  // .b6(16'd1678),
  // .b7(-16'd446),
  // .b8(-16'd202)
  // );

  axis_fir1_32_symm_v1_0 #(
  .inout_width(24),
  .inout_decimal_width(23),
  .coefficient_width(24),
  .coefficient_decimal_width(23),
  .internal_width(24),
  .internal_decimal_width(23)
  ) uut1 (
  .aclk(aclk),
  .resetn(resetn),
  /* slave axis interface */
  .s_axis_tdata(24'd1000),
  .s_axis_tlast(1'b0),
  .s_axis_tvalid(ce),
  .s_axis_tready(),
  /* master axis interface */
  .m_axis_tdata(output_data1),
  .m_axis_tlast(),
  .m_axis_tvalid(),
  .m_axis_tready(),
  /* coefficients */
  .b0(24'd224240),
  .b1(24'd229645),
  .b2(24'd234769),
  .b3(24'd239599),
  .b4(24'd244122),
  .b5(24'd248326),
  .b6(24'd252203),
  .b7(24'd255740),
  .b8(24'd258930),
  .b9(24'd261764),
  .b10(24'd264235),
  .b11(24'd266337),
  .b12(24'd268064),
  .b13(24'd269412),
  .b14(24'd270377),
  .b15(24'd270957),
  .b16(24'd271151)
  );

  // axis_fir_8_reg_v1_0 #(
  // .inout_width(16),
  // .inout_decimal_width(15),
  // .coefficient_width(16),
  // .coefficient_decimal_width(15),
  // .internal_width(16),
  // .internal_decimal_width(15)
  // ) uut2 (
  // .aclk(aclk),
  // .resetn(resetn),
  // /* slave axis interface */
  // .s_axis_tdata(16'd1000),
  // .s_axis_tlast(1'b0),
  // .s_axis_tvalid(ce),
  // .s_axis_tready(),
  // /* master axis interface */
  // .m_axis_tdata(output_data2),
  // .m_axis_tlast(),
  // .m_axis_tvalid(),
  // .m_axis_tready(),
  // /* coefficients */
  // .b0(-16'd202),
  // .b1(-16'd446),
  // .b2(16'd1678),
  // .b3(16'd8705),
  // .b4(16'd13292),
  // .b5(16'd8705),
  // .b6(16'd1678),
  // .b7(-16'd446),
  // .b8(-16'd202)
  // );

  // axis_fir1_8_reg_v1_0 #(
  // .inout_width(16),
  // .inout_decimal_width(15),
  // .coefficient_width(16),
  // .coefficient_decimal_width(15),
  // .internal_width(16),
  // .internal_decimal_width(15)
  // ) uut3 (
  // .aclk(aclk),
  // .resetn(resetn),
  // /* slave axis interface */
  // .s_axis_tdata(16'd1000),
  // .s_axis_tlast(1'b0),
  // .s_axis_tvalid(ce),
  // .s_axis_tready(),
  // /* master axis interface */
  // .m_axis_tdata(output_data3),
  // .m_axis_tlast(),
  // .m_axis_tvalid(),
  // .m_axis_tready(),
  // /* coefficients */
  // .b0(-16'd202),
  // .b1(-16'd446),
  // .b2(16'd1678),
  // .b3(16'd8705),
  // .b4(16'd13292),
  // .b5(16'd8705),
  // .b6(16'd1678),
  // .b7(-16'd446),
  // .b8(-16'd202)
  // );

  initial begin
    $dumpfile("fir_compare.vcd");
    $dumpvars;
  end


endmodule