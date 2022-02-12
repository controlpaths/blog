/**
  Module name:  top_downsampler
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Feb2022
  Description: Top module for the two-stage downsampler project
  Revision: 1.0 Module created
**/

module top_downsampler (
  output pwm_output, /* pwm output */
  
  output ce_downsampled,
  output spi_mosi, /* spi signals */
  input spi_miso, /* spi signals */
  output reg spi_sclk, /* spi signals */
  output reg spi_ss /* spi signals */
);

  reg reset_1 = 1'b1;;
  reg reset = 1'b1;
  wire pll_locked;
  
  wire clk160mhz;
  wire clk40mhz;
  wire clk_enable_x100;
  wire [15:0] adc15_data;
  wire signed [11:0] adc12_data_signed;

  wire signed [11:0] downsampled_data_signed;
  wire [11:0] downsampled_data;

  PF_OSC_C0 PF_OSC_C0_inst(
  .RCOSC_160MHZ_CLK_DIV(clk160mhz)
  );

  //PF_CLK_DIV_C0 PF_CLK_DIV_C0_inst(
  //.CLK_IN(clk160mhz),
  //.CLK_OUT(clk40mhz)
  //);
  
  PF_CCC_C0 PF_CCC_C0_inst(
  .REF_CLK_0(clk160mhz),
  .OUT0_FABCLK_0(clk40mhz),
  .PLL_LOCK_0(pll_locked)
  );
  
  always @(posedge clk40mhz)
    if (!pll_locked) begin
      reset_1 <= 1'b1;
      reset <= 1'b1;
    end
    else begin    
      reset_1 <= !pll_locked;
      reset <= reset_1;
    end

  clk_enable_generate_100x clk_enable_generate_100x_inst (
  .clk(clk40mhz), 
  .clk_enable_400ksps(clk_enable_x100)
  );

  axis_adc122s_clk_v1_0 axis_adc (
  .aclk(clk40mhz),
  .resetn(!reset),
  .clk_prescaler(32'd5),
  .m_axis_ch0_tdata(adc15_data),
  .m_axis_ch0_tlast(),
  .m_axis_ch0_tvalid(),
  .m_axis_ch0_tready(1'b1),
  .m_axis_ch1_tdata(),
  .m_axis_ch1_tlast(),
  .m_axis_ch1_tvalid(),
  .m_axis_ch1_tready(),
  .spi_mosi(spi_mosi),
  .spi_miso(spi_miso),
  .spi_sclk(spi_sclk),
  .spi_ss(spi_ss)
  );

  assign adc12_data_signed = $signed(adc15_data[11:0] - 2**11);

  two_stage_downsampler two_stage_downsampler_inst (
  .clk(clk40mhz),
  .reset(reset),
  .clk_enable(clk_enable_x100),
  .In1(adc12_data_signed),
  .ce_out_0(),
  .ce_out_1(ce_downsampled),
  .Out1(),
  .Out2(downsampled_data_signed)
  );

  assign downsampled_data = downsampled_data_signed + 2**11; /* apply offset to make data unsigned */

  pwm_v1_0 #(
  .width(12)
  ) pwm_inst (
  .clk(clk160mhz), 
  .rst(reset), 
  .modulator(downsampled_data),
  .period(4095),
  .counter(),
  .pwm(pwm_output)  
  );
endmodule

