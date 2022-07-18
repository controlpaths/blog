/**
  Module name:  rms_test
  Author: P Trujillo (pablo@controlpaths.com)
  Date: Jun 2022
  Description: testbench for the division algorothms
  Revision: 1.0 Module created
**/

`timescale 1ns/1ns

`define _clkcycle 10
`define _1us 1000
`define _10us 10000

module rms_test();

  parameter nsamples = 43;
  reg aclk;
  reg resetn;

  real real_signal;
  real angle;
  real angle2;
  real angle_increment = 2*3.141592/nsamples;
  real angle2_increment = 2*3.141592/(nsamples/4);
  real signal_gain;

  reg signed [15:0] error_filtered;

  wire rms_ready;
  reg rms_dvalid;

  wire [15:0] wire_signal;
  wire [15:0] wire_signal_rms;
  wire [15:0] wire_signal_rms_filter;

  /* clock generation */
  initial begin
    aclk <= 1'b1;
    #(`_clkcycle / 2);
    forever begin
      aclk <= ~aclk;
      #(`_clkcycle / 2);
    end
  end

  /* signal generation */
  initial begin
    angle = 0; 
    rms_dvalid <= 1'b0;
    error_filtered = 0;
    #(50*`_clkcycle);
    forever begin
      angle = angle + angle_increment;
      // angle2 = angle2 + angle2_increment;
      real_signal <= (2**15 -1) * $sin(angle) * signal_gain;// + $sin(angle2)*1024;
      rms_dvalid <= 1'b1;
      #(`_clkcycle);
      rms_dvalid <= 1'b0;
      @(posedge rms_ready);
      #(`_clkcycle);

      error_filtered = $signed(wire_signal_rms - wire_signal_rms_filter);
    end
  end

  assign wire_signal = real_signal;

  axis_true_rms_v1_0 #(
  .inout_width(16),
  .inout_fractional(15),
  .rms_nsamples(nsamples)
  ) uut (
  .aclk(aclk), 
  .resetn(resetn),
  .s_axis_tdata(wire_signal),
  .s_axis_tvalid(rms_dvalid),
  .s_axis_tready(rms_ready),
  .m_axis_tdata(wire_signal_rms),
  .m_axis_tvalid(),
  .m_axis_tready()
  );

  axis_true_rms_filter_v1_0 #(
  .inout_width(16),
  .inout_fractional(15)
  ) uut_filter (
  .aclk(aclk), 
  .resetn(resetn),
  /* slave axis interface */
  .s_axis_tdata(wire_signal),
  .s_axis_tvalid(rms_dvalid),
  .s_axis_tready(),
  /* master axis interface */
  .m_axis_tdata(wire_signal_rms_filter),
  .m_axis_tvalid(),
  .m_axis_tready()
  );



  integer i;
  /* test flow */
  initial begin

    $dumpfile ("sim_data.vcd"); // Change filename as appropriate. 
    $dumpvars(); 

    resetn <= 1'b0;

    signal_gain = 0.2;

    #(10*`_clkcycle);
    resetn <= 1'b1;

    #(100*`_10us);
    signal_gain = 0.9;
    #(100*`_10us);
    signal_gain = 0.5;
    #(100*`_10us);
    signal_gain = 1;
    #(100*`_10us);
    signal_gain = 0.5;
    $finish;
  
  end

endmodule