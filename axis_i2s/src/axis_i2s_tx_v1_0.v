/**
  Module name:  axis_i2s_tx_v1_0
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jun 2021
  Description: Module to transmit via i2s protocol
  Revision: 1.0 Module created
**/

module axis_i2s_tx_v1_0 (
  input aclk, 
  input resetn,

  /* slave axis interface */
  input [63:0] s_axis_tdata, /* format = [l_data, 8'd0, r_data, 8'd0] */
  input s_axis_tlast,
  input s_axis_tvalid,
  output s_axis_tready, 

  /* i2s interface */
  output mclk,
  output lrck,
  output sclk,
  output reg sdout
);

  reg [7:0] pulse_counter = 0; /* counter for pulses between LRCK. change to 9 for 44kHz, 8 for 96kHz, 7 for 192kHz */
  reg [5:0] data_counter = 0; /* counter for data */
  reg [63:0] data2send;

  assign lrck = pulse_counter[7]; /* change to 8 for 44kHz, 7 for 96kHz, 6 for 192kHz */
  assign mclk = aclk;
  assign sclk = pulse_counter[1]; /* fixed to 64 counts per lrck cycle. Change to 2 for 44kHz, 1 for 96kHz, 0 for 192kHz */

  /* tready management */
  assign s_axis_tready = &data_counter;

  /* input data management */
  always @(posedge aclk)
    if (!resetn)
      data2send <= 64'd0;
    else 
      if (pulse_counter == 9'd0/*s_axis_tvalid*/)
        data2send <= s_axis_tdata;

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
  always @(negedge sclk)
    if (!resetn)
      sdout <= 1'b0;
    else 
      sdout <= data2send[data_counter];

endmodule