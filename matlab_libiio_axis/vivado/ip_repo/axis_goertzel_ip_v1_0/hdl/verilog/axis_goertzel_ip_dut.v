// -------------------------------------------------------------
// 
// File Name: hdl_prj/hdlsrc/model/axis_goertzel_ip_dut.v
// Created: 2021-03-17 20:02:41
// 
// Generated by MATLAB 9.9 and HDL Coder 3.17
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: axis_goertzel_ip_dut
// Source Path: axis_goertzel_ip/axis_goertzel_ip_dut
// Hierarchy Level: 1
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module axis_goertzel_ip_dut
          (clk,
           reset,
           dut_enable,
           data_in,
           cos_input,
           wkn_re,
           wkn_im,
           in_data_valid,
           ce_out,
           re_data_out,
           re_data_valid);


  input   clk;
  input   reset;
  input   dut_enable;  // ufix1
  input   signed [31:0] data_in;  // sfix32_En31
  input   signed [31:0] cos_input;  // sfix32_En28
  input   signed [31:0] wkn_re;  // sfix32_En28
  input   signed [31:0] wkn_im;  // sfix32_En28
  input   in_data_valid;  // ufix1
  output  ce_out;  // ufix1
  output  signed [31:0] re_data_out;  // sfix32_En31
  output  re_data_valid;  // ufix1


  wire enb;
  wire ce_out_sig;  // ufix1
  wire signed [31:0] re_data_out_sig;  // sfix32_En31
  wire re_data_valid_sig;  // ufix1


  assign enb = dut_enable;

  axis_goertzel_ip_src_model u_axis_goertzel_ip_src_model (.clk(clk),
                                                           .clk_enable(enb),
                                                           .reset(reset),
                                                           .data_in(data_in),  // sfix32_En31
                                                           .cos_input(cos_input),  // sfix32_En28
                                                           .wkn_re(wkn_re),  // sfix32_En28
                                                           .wkn_im(wkn_im),  // sfix32_En28
                                                           .in_data_valid(in_data_valid),  // ufix1
                                                           .ce_out(ce_out_sig),  // ufix1
                                                           .re_data_out(re_data_out_sig),  // sfix32_En31
                                                           .re_data_valid(re_data_valid_sig)  // ufix1
                                                           );

  assign ce_out = ce_out_sig;

  assign re_data_out = re_data_out_sig;

  assign re_data_valid = re_data_valid_sig;

endmodule  // axis_goertzel_ip_dut

