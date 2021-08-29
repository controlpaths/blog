
module top (
  input clk125mhz, 

  input [1:0] button, 

  /* dac inout */
  output signed [13:0] dac_data, /* Parallel DDR data for DAC */
  output dac_dclkio, /* clock for ddr data */
  output dac_clkout, /* main clock for DAC*/
  output dac_fsadjq, /* full scale range for Q output */
  output dac_fsadji, /* full scale range for I output */
  output dac_oenable, /* zmod output relay */

  output dac_rst, /* DAC reset out*/
  output dac_sck, /* DAC SPI clk out*/
  output dac_cs, /* DAC SPI cs out*/
  output dac_sdio, /* DAC SPI data IO out*/

  /* adc inout  */
  input [13:0] adc_data, /* ddr adc interface */
  input adc_dclkio, /* ddr adc interface */

  output adc_clkout_p, /* adc differential clock n*/
  output adc_clkout_n, /* adc differential clock p*/

  output zmod_adc_coupling_l_a, /* coupling relay control */
  output zmod_adc_coupling_h_a, /* coupling relay control */
  output zmod_adc_coupling_l_b, /* coupling relay control */
  output zmod_adc_coupling_h_b, /* coupling relay control */

  output zmod_adc_gain_l_a, /* gain relay control */
  output zmod_adc_gain_h_a, /* gain relay control */
  output zmod_adc_gain_l_b, /* gain relay control */
  output zmod_adc_gain_h_b, /* gain relay control */
  output zmod_adc_com_l, /* common gain relay control */
  output zmod_adc_com_h, /* common gain relay control */

  output adc_sync, /* DAC reset out*/
  output adc_sck, /* DAC SPI clk out*/
  output adc_cs, /* DAC SPI cs out*/
  output adc_sdio /* DAC SPI data IO out*/
);

  wire pll_locked; /* locked signal from PLL  */
  wire clk100mhz; /* 100MHz clock  */

  reg [13:0] mem_signal [63:0]; /* signal memory */
  reg [5:0] mem_index; /* index to read memory */

  wire [31:0] axis_data_signal;

  assign dac_fsadjq = button[0]; /* full scale managed by button 0 */ 
  assign dac_fsadji = button[0]; /* full scale managed by button 0 */
  assign dac_oenable = !button[1]; /* output relay managed bu button 1 */

  assign dac_clkout = clk100mhz;

  initial $readmemh("signal_sine_64samples_14sbits.mem", mem_signal);

  always @(posedge clk100mhz)
    mem_index <= mem_index + 1;

  clk_wiz_0 clk_wiz_inst (
  .clk100mhz(clk100mhz), /* output clk100mhz */
  .locked(pll_locked), /* output locked */
  .clk125mhz(clk125mhz) /* input clk125mhz */
  );

  /* differential clock for adc */
  OBUFDS #(
  .IOSTANDARD("DEFAULT"), // Specify the output I/O standard
  .SLEW("SLOW")           // Specify the output slew rate
  ) OBUFDS_adc_inst (
  .O(adc_clkout_p),     // Diff_p output (connect directly to top-level port)
  .OB(adc_clkout_n),   // Diff_n output (connect directly to top-level port)
  .I(clk100mhz)      // Buffer input
  );

  axis_zmod_dac_v1_0 axis_zmod_dac_inst (
  .aclk(clk100mhz), /* Clock input. This signal is corresponding with sample frequency */
  .resetn(pll_locked), /* Reset input */
  //.s_axis_tdata({2'b00, mem_signal[mem_index], 2'b00, mem_signal[mem_index]}), /* {2'bx, data_i, 2'bx, data_q} */
  .s_axis_tdata(axis_data_signal), /* {2'bx, data_i, 2'bx, data_q} */
  .s_axis_tvalid(),
  .s_axis_tready(),
  .ddr_data(dac_data), /* Parallel DDR data for ADC*/
  .ddr_clk(dac_dclkio), /* DDR clock */
  .rst_spi(dac_rst), /* DAC reset out*/
  .spi_sck(dac_sck), /* DAC SPI clk out*/
  .spi_cs(dac_cs), /* DAC SPI cs out*/
  .spi_sdo(dac_sdio) /* DAC SPI data IO out*/
  );

  /* adc input configuration */
  assign zmod_adc_coupling_h_a = 1'b0;
  assign zmod_adc_coupling_l_a = 1'b1;
  assign zmod_adc_coupling_h_b = 1'b0;
  assign zmod_adc_coupling_l_b = 1'b1;
  assign zmod_adc_gain_h_a = 1'b1;
  assign zmod_adc_gain_l_a = 1'b0;
  assign zmod_adc_gain_h_b = 1'b1;
  assign zmod_adc_gain_l_b = 1'b0;
  assign zmod_adc_com_h = 1'b0;
  assign zmod_adc_com_l = 1'b1;

  axis_zmod_adc_v1_0 #(
  .prescaler_clk_spi(5), /* sclk = aclk / precaler_clk_spi */
  .prescaler_clk_spi_width(3) /* precaler_clk_spi width  */
  )(
  .aclk(clk100mhz), /* Clock input */
  .resetn(pll_locked), /* Reset input */
  .adc_configured(), /* Adc configuration complete signal */
  .m_axis_tdata(axis_data_signal),
  .m_axis_tvalid(),
  .m_axis_tready(),
  .ddr_data(adc_data), /* Parallel input data from ADC */
  .ddr_clk(adc_dclkio), /* output clock select*/
  .adc_sync(adc_sync), /* ADC SPI sync */
  .spi_sck(adc_sck), /* ADC SPI aclk out */
  .spi_cs(adc_cs), /* ADC SPI data IO  */
  .spi_sdio(adc_sdio) /* ADC SPI cs out */
  );


endmodule