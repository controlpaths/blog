// -------------------------------------------------------------
// 
// File Name: hdl_prj/hdlsrc/model/axis_goertzel_src_goertzel_system.v
// Created: 2021-03-13 19:16:33
// 
// Generated by MATLAB 9.9 and HDL Coder 3.17
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: axis_goertzel_src_goertzel_system
// Source Path: model/goertzel_system
// Hierarchy Level: 1
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module axis_goertzel_src_goertzel_system
          (clk,
           reset,
           enb,
           data_in,
           cos_input,
           wkn_re,
           data_in_valid,
           re_data_out,
           re_data_out_valid);


  input   clk;
  input   reset;
  input   enb;
  input   signed [31:0] data_in;  // sfix32_En31
  input   signed [31:0] cos_input;  // sfix32_En28
  input   signed [31:0] wkn_re;  // sfix32_En28
  input   data_in_valid;
  output  signed [31:0] re_data_out;  // sfix32_En31
  output  re_data_out_valid;


  wire signed [63:0] goertzel_out1;  // sfix64_En56
  wire signed [31:0] Data_Type_Conversion_out1;  // sfix32_En31
  reg [4:0] HDL_Counter_out1;  // ufix5
  wire Compare_To_Zero_out1;


  axis_goertzel_src_goertzel u_goertzel (.clk(clk),
                                         .reset(reset),
                                         .enb(enb),
                                         .Input_rsvd(data_in),  // sfix32_En31
                                         .cos_input(cos_input),  // sfix32_En28
                                         .wkn_re(wkn_re),  // sfix32_En28
                                         .Enable(data_in_valid),
                                         .Re(goertzel_out1)  // sfix64_En56
                                         );

  assign Data_Type_Conversion_out1 = goertzel_out1[56:25];



  assign re_data_out = Data_Type_Conversion_out1;

  // Free running, Unsigned Counter
  //  initial value   = 0
  //  step value      = 1
  always @(posedge clk or posedge reset)
    begin : HDL_Counter_process
      if (reset == 1'b1) begin
        HDL_Counter_out1 <= 5'b00000;
      end
      else begin
        if (enb && data_in_valid) begin
          HDL_Counter_out1 <= HDL_Counter_out1 + 5'b00001;
        end
      end
    end



  assign Compare_To_Zero_out1 = HDL_Counter_out1 == 5'b00000;



  assign re_data_out_valid = Compare_To_Zero_out1;

endmodule  // axis_goertzel_src_goertzel_system
