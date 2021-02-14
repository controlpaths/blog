/**
  Module name:  square_root_finder
  Author: P Trujillo (pablo@controlpaths.com)
  Date: May 2020
  Description: Module to found the square root by iteration. Example of Custom IP.
  Revision: 1.0 Module created
**/

module is2s_axis_controller (
  input clk,
  input rst,

  output reg [23:0] o24_data_r,
  output reg [23:0] o24_data_l,

  input [23:0] i24_data_r,
  input [23:0] i24_data_l,

  output tx_mclk,
  output tx_lrck,
  output tx_sclk,
  output tx_sdout,
  output rx_mclk,
  output rx_lrck,
  output rx_sclk,
  input  rx_sdin
  );

  wire w_rx_dv;
  wire w_rx_last;
  wire w_rx_ready;
  wire [31:0] w32_rx_data;

  reg r_tx_dv;
  reg r_tx_last = 1'b0;
  wire w_tx_ready;
  reg [31:0] r32_tx_data;

  /* reception */
  assign w_rx_ready = 1'b1;

  always @(posedge clk)
    if (rst) begin
      o24_data_r <= 32'd0;
      o24_data_l <= 32'd0;
    end
    else begin
      if (w_rx_dv && w_rx_last)
        o24_data_r <= w32_rx_data[23:0];
      if (w_rx_dv && !w_rx_last)
        o24_data_l <= w32_rx_data[23:0];
    end

  /* transmission */
  always @(posedge clk)
    if (rst) begin
      r_tx_dv <= 1'b0;
      r32_tx_data <= 32'd0;
    end
    else
      if (w_tx_ready && !r_tx_dv) begin
        r32_tx_data <= r_tx_last? {8'b0, i24_data_l}:{8'b0, i24_data_r};
        r_tx_dv <= 1'b1;
      end
      else if (!w_tx_ready && r_tx_dv)
        r_tx_dv <= 1'b0;

  always @(w_tx_ready)
    if (w_tx_ready)
      r_tx_last <= ~r_tx_last;


  axis_i2s2 i2s_inst(
  .axis_clk(clk), // require: approx 22.591MHz
  .axis_resetn(!rst),
  .tx_axis_s_data(r32_tx_data),
  .tx_axis_s_valid(r_tx_dv),
  .tx_axis_s_ready(w_tx_ready),
  .tx_axis_s_last(r_tx_last),
  .rx_axis_m_data(w32_rx_data),
  .rx_axis_m_valid(w_rx_dv),
  .rx_axis_m_ready(w_rx_ready),
  .rx_axis_m_last(w_rx_last),
  .tx_mclk(tx_mclk), // JA[0]
  .tx_lrck(tx_lrck), // JA[1]
  .tx_sclk(tx_sclk), // JA[2]
  .tx_sdout(tx_sdout), // JA[3]
  .rx_mclk(rx_mclk), // JA[4]
  .rx_lrck(rx_lrck), // JA[5]
  .rx_sclk(rx_sclk), // JA[6]
  .rx_sdin(rx_sdin) // JA[7]
  );


endmodule
