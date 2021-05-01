/**
  Module name:  axis_adc122s
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Abr 2021
  Description: Driver for adc122sxxx adc from TI. AXI Stream data interface.
  Revision: 1.0 Module created
**/

module axis_adc122s_v1_0 (
  input aclk,
  input resetn,

  output reg [15:0] m_axis_ch0_tdata,
  output reg m_axis_ch0_tlast,
  output reg m_axis_ch0_tvalid,
  input m_axis_ch0_tready,

  output reg [15:0] m_axis_ch1_tdata,
  output reg m_axis_ch1_tlast,
  output reg m_axis_ch1_tvalid,
  input m_axis_ch1_tready,

  output spi_mosi,
  input spi_miso,
  //output spi_sclk,
  output reg spi_ss
  );

  localparam lp_spi_control_register = 32'h00000800;

  reg [4:0] r5_data_index; /* index data to send */
  reg [31:0] r32_adc_data_temp; /* temporal data storage */

  always @(posedge aclk)
    if (!resetn)
      spi_ss <= 1'b1;
    else
      spi_ss <= 1'b0;

  /* transmit */
  always @(negedge aclk)
    if (!resetn)
      r5_data_index <= 5'd0;
    else
      if (!spi_ss)
        r5_data_index <= r5_data_index - 5'd1;
      else
        r5_data_index <= 5'd31;

  assign w5_output_data_index = r5_data_index + 5'd1;

  assign spi_mosi = lp_spi_control_register[r5_data_index];

  /* receive */
  always @(posedge aclk)
    if (!resetn)
      r32_adc_data_temp <= 32'd0;
    else
      r32_adc_data_temp[r5_data_index] <= spi_miso;

  always @(posedge aclk)
    if (!resetn) begin
      m_axis_ch1_tdata <= 16'd0;
      m_axis_ch1_tvalid <= 1'b0;
    end
    else
      if (r5_data_index == 5'd14) begin
        m_axis_ch1_tdata <= r32_adc_data_temp[31-:16] & 16'h0fff;
        m_axis_ch1_tvalid <= 1'b1;
      end
      else
        m_axis_ch1_tvalid <= 1'b0;

  always @(posedge aclk)
    if (!resetn) begin
      m_axis_ch0_tdata <= 16'd0;
      m_axis_ch0_tvalid <= 1'b0;
    end
    else
      if (r5_data_index == 5'd30) begin
        m_axis_ch0_tdata <= r32_adc_data_temp[15:0] & 16'h0fff;
        m_axis_ch0_tvalid <= 1'b1;
      end
      else
        m_axis_ch0_tvalid <= 1'b0;

endmodule
