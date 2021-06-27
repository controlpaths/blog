/**
  Module name:  top_i2s
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jun 2021
  Description: Top module to test the i2s modules.
  Revision: 1.0 Module created
**/

module top_i2s (
  input clk100mhz, 
  
  input [3:0] freq_sw,
  /* i2s tx interface */
  output tx_mclk,
  output tx_lrck,
  output tx_sclk,
  output tx_data,
  /* i2s rx interface */
  output rx_mclk,
  output rx_lrck,
  output rx_sclk,
  input rx_data
);

  wire clk25mhz; /* pll 25Mhz output clock */
  wire resetn; 

   reg [23:0] sine_mem [127:0];
   reg [6:0] sine_angle;

  wire i2s_tx_tready;
  wire i2s_rx_tvalid;
  // reg i2s_tx_tvalid;
  wire [23:0] i2s_tx_data;

  wire [23:0] r_data_rx;
  wire [23:0] l_data_rx;

  wire [63:0] i2s_data_rx;
  wire [63:0] i2s_data_tx;

  /* split data */
  assign r_data_rx = i2s_data_rx[62-:24];
  assign r_data_rx = i2s_data_rx[31-:24];

  reg [6:0] angle_prescaler = 0;

  initial $readmemh("sine24bits_128samples.mem", sine_mem);

  always @(posedge clk25mhz)
    angle_prescaler <= angle_prescaler + 1;

 always @(posedge clk25mhz)
   if (!resetn) begin
     sine_angle <= 0;
   end
   else 
     if (&angle_prescaler/*i2s_tx_tready*/) begin
       sine_angle <= sine_angle + freq_sw;
     end
  
   assign i2s_tx_data = sine_mem[sine_angle] >> 1;

  /* module instantiation */

  clk_wiz_0 clk_wiz_inst (
  .clk25mhz(clk25mhz),     
  .locked(resetn),       
  .clk100mhz(clk100mhz)
  );     

  axis_i2s_tx_v1_0 i2s_tx_inst0 (
  .aclk(clk25mhz), 
  .resetn(resetn),
  /* slave axis interface */
  .s_axis_tdata({i2s_tx_data, 8'd0, i2s_tx_data, 8'd0}), /* format = [8'd0, r_data, 8'd0, l_data] */
  // .s_axis_tdata(i2s_data_rx), /* format = [8'd0, r_data, 8'd0, l_data] */
  .s_axis_tlast(),
  .s_axis_tvalid(i2s_rx_tvalid),
  .s_axis_tready(i2s_tx_tready), 
  /* i2s interface */
  .mclk(tx_mclk),
  .lrck(tx_lrck),
  .sclk(tx_sclk),
  .sdout(tx_data)
  );

  axis_i2s_rx_v1_0 i2s_rx_inst0(
  .aclk(clk25mhz), 
  .resetn(resetn),
  /* master axis interface */
  .m_axis_tdata(i2s_data_rx), /* format = [8'd0, l_data, 8'd0, r_data] */
  .m_axis_tlast(),
  .m_axis_tvalid(i2s_rx_tvalid),
  .m_axis_tready(), 
  /* i2s interface */
  .mclk(rx_mclk),
  .lrck(rx_lrck),
  .sclk(rx_sclk),
  .sdin(rx_data)
  );

endmodule