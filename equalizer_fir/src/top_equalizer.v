/**
  Module name:  top_equalizer
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jun 2021
  Description: Top module to test the i2s modules.
  Revision: 1.0 Module created
**/

module top_equalizer (
  input clk100mhz, 
  
  input [3:0] freq_sw,
  output [3:0] led,
  /* i2s tx interface */
  output tx_mclk,
  output tx_lrck,
  output tx_sclk,
  output tx_data,
  /* i2s rx interface */
  output rx_mclk,
  (*MARK_DEBUG="true"*) output rx_lrck,
  output rx_sclk,
  input rx_data
);

  (*MARK_DEBUG="true"*) wire [63:0] i2s_data_rx; /* i2s data stream received */
  wire [63:0] i2s_data_tx; /* i2s data stream to send */

  (*MARK_DEBUG="true"*) wire [23:0] i2s_ldata; /* l data received */
  (*MARK_DEBUG="true"*) wire [23:0] i2s_rdata; /* r data received */

  wire [23:0] i2s_ldata_bass; /* l data received filtered bass */
  wire [23:0] i2s_ldata_mid; /* l data received filtered mid */
  wire [23:0] i2s_rdata_bass; /* r data received filtered bass */
  wire [23:0] i2s_rdata_mid; /* r data received filtered mid */

  wire [23:0] i2s_ldata_fir_acc; /* data equalized */
  wire [23:0] i2s_rdata_fir_acc; /* data equalized */

  wire i2s_rx_tvalid; /* i2s data valid */

  wire clk25mhz;
  wire resetn;

  assign led[0] = freq_sw[0];

  clk_wiz_0 clk_wiz_inst (
  .clk25mhz(clk25mhz),     
  .locked(resetn),       
  .clk100mhz(clk100mhz)
  ); 

  axis_i2s_rx_v1_0 i2s_rx_inst0(
  .aclk(clk25mhz), 
  .resetn(resetn),
  /* master axis interface */
  .m_axis_tdata(i2s_data_rx), /* format = [l_data, 8'd0, r_data, 8'd0] */
  .m_axis_tlast(),
  .m_axis_tvalid(i2s_rx_tvalid),
  .m_axis_tready(), 
  /* i2s interface */
  .mclk(rx_mclk),
  .lrck(rx_lrck),
  .sclk(rx_sclk),
  .sdin(rx_data)
  );

  assign i2s_ldata = i2s_data_rx[63-:24];
  assign i2s_rdata = i2s_data_rx[31-:24];

  /* left side */
  axis_fir1_32_symm_v1_0 #(
  .inout_width(24),
  .inout_decimal_width(23),
  .coefficient_width(24),
  .coefficient_decimal_width(23),
  .internal_width(24),
  .internal_decimal_width(23)
  ) fir_mid_l (
  .aclk(clk25mhz),
  .resetn(resetn),
  /* slave axis interface */
  .s_axis_tdata(i2s_ldata),
  .s_axis_tlast(1'b0),
  .s_axis_tvalid(i2s_rx_tvalid),
  .s_axis_tready(),
  /* master axis interface */
  .m_axis_tdata(i2s_ldata_mid),
  .m_axis_tlast(),
  .m_axis_tvalid(),
  .m_axis_tready(),
  /* coefficients */
  .b0(-24'd368824),
  .b1(-24'd349467),
  .b2(-24'd314751),
  .b3(-24'd264874),
  .b4(-24'd200762),
  .b5(-24'd124056),
  .b6(-24'd37055),
  .b7(24'd57365),
  .b8(24'd155883),
  .b9(24'd254865),
  .b10(24'd350538),
  .b11(24'd439160),
  .b12(24'd517196),
  .b13(24'd581489),
  .b14(24'd629408),
  .b15(24'd658978),
  .b16(24'd668973)
  );

  axis_fir1_32_symm_v1_0 #(
  .inout_width(24),
  .inout_decimal_width(23),
  .coefficient_width(24),
  .coefficient_decimal_width(23),
  .internal_width(24),
  .internal_decimal_width(23)
  ) fir_bass_l (
  .aclk(clk25mhz),
  .resetn(resetn),
  /* slave axis interface */
  .s_axis_tdata(i2s_ldata),
  .s_axis_tlast(1'b0),
  .s_axis_tvalid(i2s_rx_tvalid),
  .s_axis_tready(),
  /* master axis interface */
  .m_axis_tdata(i2s_ldata_bass),
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

  /* right side */
  axis_fir1_32_symm_v1_0 #(
  .inout_width(24),
  .inout_decimal_width(23),
  .coefficient_width(24),
  .coefficient_decimal_width(23),
  .internal_width(24),
  .internal_decimal_width(23)
  ) fir_mid_r (
  .aclk(clk25mhz),
  .resetn(resetn),
  /* slave axis interface */
  .s_axis_tdata(i2s_rdata),
  .s_axis_tlast(1'b0),
  .s_axis_tvalid(i2s_rx_tvalid),
  .s_axis_tready(),
  /* master axis interface */
  .m_axis_tdata(i2s_rdata_mid),
  .m_axis_tlast(),
  .m_axis_tvalid(),
  .m_axis_tready(),
  /* coefficients */
  .b0(-24'd368824),
  .b1(-24'd349467),
  .b2(-24'd314751),
  .b3(-24'd264874),
  .b4(-24'd200762),
  .b5(-24'd124056),
  .b6(-24'd37055),
  .b7(24'd57365),
  .b8(24'd155883),
  .b9(24'd254865),
  .b10(24'd350538),
  .b11(24'd439160),
  .b12(24'd517196),
  .b13(24'd581489),
  .b14(24'd629408),
  .b15(24'd658978),
  .b16(24'd668973)
  );

  axis_fir1_32_symm_v1_0 #(
  .inout_width(24),
  .inout_decimal_width(23),
  .coefficient_width(24),
  .coefficient_decimal_width(23),
  .internal_width(24),
  .internal_decimal_width(23)
  ) fir_bass_r (
  .aclk(clk25mhz),
  .resetn(resetn),
  /* slave axis interface */
  .s_axis_tdata(i2s_rdata),
  .s_axis_tlast(1'b0),
  .s_axis_tvalid(i2s_rx_tvalid),
  .s_axis_tready(),
  /* master axis interface */
  .m_axis_tdata(i2s_rdata_bass),
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

  assign i2s_ldata_fir_acc = freq_sw[0]? i2s_ldata: i2s_ldata_bass+i2s_ldata_mid;// + i2s_ldata; 
  assign i2s_rdata_fir_acc = freq_sw[0]? i2s_rdata: i2s_rdata_bass+i2s_rdata_mid;// + i2s_rdata; 

  assign i2s_data_tx = {i2s_ldata_fir_acc[22:0], 1'b0, 8'd0, i2s_rdata_fir_acc[22:0], 1'b0, 8'd0};

  axis_i2s_tx_v1_0 i2s_tx_inst0 (
  .aclk(clk25mhz), 
  .resetn(resetn),
  /* slave axis interface */
  .s_axis_tdata(i2s_data_tx), /* format = [l_data, 8'd0, l_data, 8'd0] */
  .s_axis_tlast(),
  .s_axis_tvalid(i2s_rx_tvalid),
  .s_axis_tready(), 
  /* i2s interface */
  .mclk(tx_mclk),
  .lrck(tx_lrck),
  .sclk(tx_sclk),
  .sdout(tx_data)
  );

endmodule