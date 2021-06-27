/**
  Module name:  axis_i2s_rx_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jun 2021
  Description: Module to receive via i2s protocol
  Revision: 1.0 Module created
**/

module axis_i2s_rx_v1_0 (
  input aclk, 
  input resetn,

  /* slave axis interface */
  output reg [63:0] m_axis_tdata, /* format = [l_data, 8'd0, r_data, 8'd0] */
  output m_axis_tlast,
  output reg m_axis_tvalid,
  input m_axis_tready, 

  /* i2s interface */
  output mclk,
  output lrck,
  output sclk,
  input sdin
);

  reg [7:0] pulse_counter = 0; /* counter for pulses between LRCK. change to 9 for 44kHz, 8 for 96kHz, 7 for 192kHz */
  reg [5:0] data_counter = 0; /* counter for data */
  reg [63:0] data_received;

  assign lrck = pulse_counter[7]; /* change to 8 for 44kHz, 7 for 96kHz, 6 for 192kHz */
  assign mclk = aclk;
  assign sclk = pulse_counter[1]; /* fixed to 64 counts per lrck cycle. Change to 2 for 44kHz, 1 for 96kHz, 0 for 192kHz */

  /* input data management */
  always @(posedge aclk)
    if (!resetn) begin
      m_axis_tvalid <= 1'b0;
      m_axis_tdata <= 64'd0;
    end
    else 
      if (pulse_counter == 9'd0) begin
        m_axis_tvalid <= 1'b1;
        m_axis_tdata <= data_received;
      end
      else 
        m_axis_tvalid <= 1'b0;
        

  assign m_axis_tlast = m_axis_tvalid;

  /* synchronous counters */
  always @(posedge aclk)
    if (!resetn)
      pulse_counter <= 0;
    else
      pulse_counter <= pulse_counter + 1;

  always @(posedge sclk)
    if (!resetn)
      data_counter <= 6'h3f;
    else
      data_counter <= data_counter - 1;

  /* data shift */
  always @(posedge sclk)
    if (!resetn)
      data_received <= 1'b0;
    else 
      data_received[data_counter] <= sdin;

endmodule