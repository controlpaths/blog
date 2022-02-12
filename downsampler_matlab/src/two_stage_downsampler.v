// -------------------------------------------------------------
// 
// File Name: two_stage_hdl/two_stage_hdl_coder/two_stage_downsampler.v
// Created: 2022-02-06 17:05:08
// 
// Generated by MATLAB 9.11 and HDL Coder 3.19
// 
// 
// -- -------------------------------------------------------------
// -- Rate and Clocking Details
// -- -------------------------------------------------------------
// Model base rate: 2.5e-06
// Target subsystem base rate: 2.5e-06
// 
// 
// Clock Enable  Sample Time
// -- -------------------------------------------------------------
// ce_out_1      9e-05
// ce_out_0      0.00036
// -- -------------------------------------------------------------
// 
// 
// Output Signal                 Clock Enable  Sample Time
// -- -------------------------------------------------------------
// Out1                          ce_out_0      0.00036
// Out2                          ce_out_1      9e-05
// -- -------------------------------------------------------------
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: two_stage_downsampler
// Source Path: two_stage_hdl_coder/two stage downsampler
// Hierarchy Level: 0
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module two_stage_downsampler
          (clk,
           reset,
           clk_enable,
           In1,
           ce_out_0,
           ce_out_1,
           Out1,
           Out2);


  input   clk;
  input   reset;
  input   clk_enable;
  input   signed [11:0] In1;  // sfix12_En11
  output  ce_out_0;
  output  ce_out_1;
  output  signed [11:0] Out1;  // sfix12_En11
  output  signed [11:0] Out2;  // sfix12_En11


  wire enb;
  wire enb_1_9_0;
  wire enb_1_9_1;
  wire enb_1_36_1;
  wire enb_4_1_1;
  wire enb_4_9_1;
  wire signed [11:0] Discrete_FIR_Filter3_out1_reg;  // sfix12_En11
  reg signed [11:0] Discrete_FIR_Filter3_out1;  // sfix12_En11
  reg signed [11:0] delayMatch_reg [0:6];  // sfix12 [7]
  wire signed [11:0] delayMatch_reg_next [0:6];  // sfix12_En11 [7]
  wire signed [11:0] Discrete_FIR_Filter3_out1_1;  // sfix12_En11
  reg signed [11:0] Downsample4_bypass_reg;  // sfix12
  wire signed [11:0] Downsample4_out1;  // sfix12_En11
  wire signed [11:0] Discrete_FIR_Filter4_out1_reg;  // sfix12_En11
  reg signed [11:0] Discrete_FIR_Filter4_out1;  // sfix12_En11
  reg signed [11:0] Discrete_FIR_Filter4_out1_1;  // sfix12_En11
  reg signed [11:0] Downsample5_bypass_reg;  // sfix12
  wire signed [11:0] Downsample5_out1;  // sfix12_En11
  reg signed [11:0] delayMatch2_reg [0:2];  // sfix12 [3]
  wire signed [11:0] delayMatch2_reg_next [0:2];  // sfix12_En11 [3]
  wire signed [11:0] Downsample4_out1_1;  // sfix12_En11


  two_stage_downsampler_tc u_two_stage_downsampler_tc (.clk(clk),
                                                       .reset(reset),
                                                       .clk_enable(clk_enable),
                                                       .enb_4_1_1(enb_4_1_1),
                                                       .enb(enb),
                                                       .enb_4_9_1(enb_4_9_1),
                                                       .enb_1_9_0(enb_1_9_0),
                                                       .enb_1_9_1(enb_1_9_1),
                                                       .enb_1_36_1(enb_1_36_1)
                                                       );

  Discrete_FIR_Filter3 u_Discrete_FIR_Filter3 (.clk(clk),
                                               .enb_4_1_1(enb_4_1_1),
                                               .reset(reset),
                                               .Discrete_FIR_Filter3_in(In1),  // sfix12_En11
                                               .Discrete_FIR_Filter3_out(Discrete_FIR_Filter3_out1_reg)  // sfix12_En11
                                               );

  always @(posedge clk or posedge reset)
    begin : Discrete_FIR_Filter3_reg_process
      if (reset == 1'b1) begin
        Discrete_FIR_Filter3_out1 <= 12'sb000000000000;
      end
      else begin
        if (enb) begin
          Discrete_FIR_Filter3_out1 <= Discrete_FIR_Filter3_out1_reg;
        end
      end
    end



  always @(posedge clk or posedge reset)
    begin : delayMatch_process
      if (reset == 1'b1) begin
        delayMatch_reg[0] <= 12'sb000000000000;
        delayMatch_reg[1] <= 12'sb000000000000;
        delayMatch_reg[2] <= 12'sb000000000000;
        delayMatch_reg[3] <= 12'sb000000000000;
        delayMatch_reg[4] <= 12'sb000000000000;
        delayMatch_reg[5] <= 12'sb000000000000;
        delayMatch_reg[6] <= 12'sb000000000000;
      end
      else begin
        if (enb) begin
          delayMatch_reg[0] <= delayMatch_reg_next[0];
          delayMatch_reg[1] <= delayMatch_reg_next[1];
          delayMatch_reg[2] <= delayMatch_reg_next[2];
          delayMatch_reg[3] <= delayMatch_reg_next[3];
          delayMatch_reg[4] <= delayMatch_reg_next[4];
          delayMatch_reg[5] <= delayMatch_reg_next[5];
          delayMatch_reg[6] <= delayMatch_reg_next[6];
        end
      end
    end

  assign Discrete_FIR_Filter3_out1_1 = delayMatch_reg[6];
  assign delayMatch_reg_next[0] = Discrete_FIR_Filter3_out1;
  assign delayMatch_reg_next[1] = delayMatch_reg[0];
  assign delayMatch_reg_next[2] = delayMatch_reg[1];
  assign delayMatch_reg_next[3] = delayMatch_reg[2];
  assign delayMatch_reg_next[4] = delayMatch_reg[3];
  assign delayMatch_reg_next[5] = delayMatch_reg[4];
  assign delayMatch_reg_next[6] = delayMatch_reg[5];



  // Downsample4: Downsample by 9, Sample offset 0 
  // Downsample bypass register
  always @(posedge clk or posedge reset)
    begin : Downsample4_bypass_process
      if (reset == 1'b1) begin
        Downsample4_bypass_reg <= 12'sb000000000000;
      end
      else begin
        if (enb_1_9_1) begin
          Downsample4_bypass_reg <= Discrete_FIR_Filter3_out1_1;
        end
      end
    end

  assign Downsample4_out1 = (enb_1_9_1 == 1'b1 ? Discrete_FIR_Filter3_out1_1 :
              Downsample4_bypass_reg);



  Discrete_FIR_Filter4 u_Discrete_FIR_Filter4 (.clk(clk),
                                               .enb_4_9_1(enb_4_9_1),
                                               .reset(reset),
                                               .Discrete_FIR_Filter4_in(Downsample4_out1),  // sfix12_En11
                                               .Discrete_FIR_Filter4_out(Discrete_FIR_Filter4_out1_reg)  // sfix12_En11
                                               );

  always @(posedge clk or posedge reset)
    begin : Discrete_FIR_Filter4_reg_process
      if (reset == 1'b1) begin
        Discrete_FIR_Filter4_out1 <= 12'sb000000000000;
      end
      else begin
        if (enb_1_9_0) begin
          Discrete_FIR_Filter4_out1 <= Discrete_FIR_Filter4_out1_reg;
        end
      end
    end



  always @(posedge clk or posedge reset)
    begin : delayMatch1_process
      if (reset == 1'b1) begin
        Discrete_FIR_Filter4_out1_1 <= 12'sb000000000000;
      end
      else begin
        if (enb_1_9_0) begin
          Discrete_FIR_Filter4_out1_1 <= Discrete_FIR_Filter4_out1;
        end
      end
    end



  // Downsample5: Downsample by 4, Sample offset 0 
  // Downsample bypass register
  always @(posedge clk or posedge reset)
    begin : Downsample5_bypass_process
      if (reset == 1'b1) begin
        Downsample5_bypass_reg <= 12'sb000000000000;
      end
      else begin
        if (enb_1_36_1) begin
          Downsample5_bypass_reg <= Discrete_FIR_Filter4_out1_1;
        end
      end
    end

  assign Downsample5_out1 = (enb_1_36_1 == 1'b1 ? Discrete_FIR_Filter4_out1_1 :
              Downsample5_bypass_reg);



  assign Out1 = Downsample5_out1;

  always @(posedge clk or posedge reset)
    begin : delayMatch2_process
      if (reset == 1'b1) begin
        delayMatch2_reg[0] <= 12'sb000000000000;
        delayMatch2_reg[1] <= 12'sb000000000000;
        delayMatch2_reg[2] <= 12'sb000000000000;
      end
      else begin
        if (enb_1_9_0) begin
          delayMatch2_reg[0] <= delayMatch2_reg_next[0];
          delayMatch2_reg[1] <= delayMatch2_reg_next[1];
          delayMatch2_reg[2] <= delayMatch2_reg_next[2];
        end
      end
    end

  assign Downsample4_out1_1 = delayMatch2_reg[2];
  assign delayMatch2_reg_next[0] = Downsample4_out1;
  assign delayMatch2_reg_next[1] = delayMatch2_reg[0];
  assign delayMatch2_reg_next[2] = delayMatch2_reg[1];



  assign Out2 = Downsample4_out1_1;

  assign ce_out_0 = enb_1_36_1;

  assign ce_out_1 = enb_1_9_1;

endmodule  // two_stage_downsampler
