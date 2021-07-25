/**
  Module name:  axis_mcp3204
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jul 2021
  Description: Driver for mcp3204 from Microchip. AXI Stream data interface.
  Revision: 1.0 Module created
**/

module axis_mcp3204_v1_0 #(
  parameter prescaler_sclk = 10,
  parameter prescaler_sclk_width = 4,
  parameter sngl_ndiff = 1 /* select single ended channels or differential channels */
  )(
  input aclk,
  input resetn,

  output reg [15:0] m_axis_ch0_tdata,
  output m_axis_ch0_tlast,
  output reg m_axis_ch0_tvalid,
  input m_axis_ch0_tready,

  output reg [15:0] m_axis_ch1_tdata,
  output m_axis_ch1_tlast,
  output reg m_axis_ch1_tvalid,
  input m_axis_ch1_tready,

  output reg [15:0] m_axis_ch2_tdata,
  output m_axis_ch2_tlast,
  output reg m_axis_ch2_tvalid,
  input m_axis_ch2_tready,

  output reg [15:0] m_axis_ch3_tdata,
  output m_axis_ch3_tlast,
  output reg m_axis_ch3_tvalid,
  input m_axis_ch3_tready,

  output spi_mosi,
  input spi_miso,
  output reg spi_sclk,
  output spi_ss
  );

  reg [prescaler_sclk_width-1:0] prescaler_counter; /* prescaler for sclk generation */
  wire prescaler_tick; /* tick for data logic */
  reg [1:0] channel_select; /* channel select */
  reg [4:0] bit_counter_to_send; /* send frame bit counter */
  reg [4:0] bit_counter_to_read; /* read frame bit counter */
  wire [19:0] data_to_send; /* cs = 1| {2'b1, 1x sngl/diff, 3xchannel, 1'b0, 12x data_read} */
  reg [19:0] data_to_read; /* cs = 1| {2'b1, 1x sngl/diff, 3xchannel, 1'b0, 12x data_read} */
  wire sngl_ndiff_1bit; /* 1 bit single/diff parameter */

  assign m_axis_ch0_tlast = 1'b0;
  assign m_axis_ch1_tlast = 1'b0;
  assign m_axis_ch2_tlast = 1'b0;
  assign m_axis_ch3_tlast = 1'b0;

  assign sngl_ndiff_1bit = sngl_ndiff;

  assign data_to_send = {1'b1, sngl_ndiff_1bit, 1'b0, channel_select, 2'b00, 12'h000};
  assign tick = (prescaler_counter == prescaler_sclk)? 1'b1: 1'b0;

  /* clock generation */
  always @(posedge aclk)
    if (!resetn) begin
      prescaler_counter <= 0;
      spi_sclk <= 1'b1;
    end 
    else 
      if (prescaler_counter == prescaler_sclk) begin
        spi_sclk <= ~spi_sclk;
        prescaler_counter <= 0;
      end
      else
        prescaler_counter <= prescaler_counter + 1;

  /* bit counter to send*/
  always @(posedge aclk) 
    if (!resetn) begin
      bit_counter_to_send <= 0;
      channel_select <= 2'b00;
      data_to_read <= 18'd0;
    end
    else 
      if (tick && spi_sclk && bit_counter_to_send > 0) begin
        bit_counter_to_send <= bit_counter_to_send - 1;
      end
      else if (tick && spi_sclk && bit_counter_to_send == 0) begin
        bit_counter_to_send <= 19;
        channel_select <= channel_select + 1;
      end
      // else if (tick && !spi_sclk)
      //   data_to_read[bit_counter_to_send] <= spi_miso;
      else begin
        bit_counter_to_send <= bit_counter_to_send;
        data_to_read[bit_counter_to_send] <= spi_miso;
      end
  
  assign spi_mosi = data_to_send[bit_counter_to_send];

  assign spi_ss = (bit_counter_to_send == 19)? 1'b1: 1'b0;

  /* output assign */
  always @(posedge aclk)
    if (!resetn) begin
      m_axis_ch0_tdata <= 1'b0;
      m_axis_ch0_tvalid <= 1'b0;
      m_axis_ch1_tdata <= 1'b0;
      m_axis_ch1_tvalid <= 1'b0;
      m_axis_ch2_tdata <= 1'b0;
      m_axis_ch2_tvalid <= 1'b0;
      m_axis_ch3_tdata <= 1'b0;
      m_axis_ch3_tvalid <= 1'b0;
    end
    else
      if (tick && spi_sclk && bit_counter_to_send == 0 && (channel_select == 2'b00)) begin
        m_axis_ch0_tdata <= {4'd0, data_to_read[11:0]};
        m_axis_ch0_tvalid <= 1'b1;
      end
      else if (tick && spi_sclk && bit_counter_to_send == 0 && (channel_select == 2'b01)) begin
        m_axis_ch1_tdata <= {4'd0, data_to_read[11:0]};
        m_axis_ch1_tvalid <= 1'b1;
      end
      else if (tick && spi_sclk && bit_counter_to_send == 0 && (channel_select == 2'b10)) begin
        m_axis_ch2_tdata <= {4'd0, data_to_read[11:0]};
        m_axis_ch2_tvalid <= 1'b1;
      end
      else if (tick && spi_sclk && bit_counter_to_send == 0 && (channel_select == 2'b11)) begin
        m_axis_ch3_tdata <= {4'd0, data_to_read[11:0]};
        m_axis_ch3_tvalid <= 1'b1;
      end
      else begin
        m_axis_ch0_tvalid <= 1'b0;
        m_axis_ch1_tvalid <= 1'b0;
        m_axis_ch2_tvalid <= 1'b0;
        m_axis_ch3_tvalid <= 1'b0;
      end

endmodule