// -------------------------------------------------------------
// 
// File Name: hdl_prj/hdlsrc/model/axis_goertzel_ip.v
// Created: 2021-03-17 20:02:41
// 
// Generated by MATLAB 9.9 and HDL Coder 3.17
// 
// 
// -- -------------------------------------------------------------
// -- Rate and Clocking Details
// -- -------------------------------------------------------------
// Model base rate: -1
// Target subsystem base rate: -1
// 
// -------------------------------------------------------------


// -------------------------------------------------------------
// 
// Module: axis_goertzel_ip
// Source Path: axis_goertzel_ip
// Hierarchy Level: 0
// 
// -------------------------------------------------------------

`timescale 1 ns / 1 ns

module axis_goertzel_ip
          (IPCORE_CLK,
           IPCORE_RESETN,
           AXI4_Stream_Master_TREADY,
           AXI4_Stream_Slave_TDATA,
           AXI4_Stream_Slave_TVALID,
           AXI4_Lite_ACLK,
           AXI4_Lite_ARESETN,
           AXI4_Lite_AWADDR,
           AXI4_Lite_AWVALID,
           AXI4_Lite_WDATA,
           AXI4_Lite_WSTRB,
           AXI4_Lite_WVALID,
           AXI4_Lite_BREADY,
           AXI4_Lite_ARADDR,
           AXI4_Lite_ARVALID,
           AXI4_Lite_RREADY,
           AXI4_Stream_Master_TDATA,
           AXI4_Stream_Master_TVALID,
           AXI4_Stream_Master_TLAST,
           AXI4_Stream_Slave_TREADY,
           AXI4_Lite_AWREADY,
           AXI4_Lite_WREADY,
           AXI4_Lite_BRESP,
           AXI4_Lite_BVALID,
           AXI4_Lite_ARREADY,
           AXI4_Lite_RDATA,
           AXI4_Lite_RRESP,
           AXI4_Lite_RVALID);


  input   IPCORE_CLK;  // ufix1
  input   IPCORE_RESETN;  // ufix1
  input   AXI4_Stream_Master_TREADY;  // ufix1
  input   [31:0] AXI4_Stream_Slave_TDATA;  // ufix32
  input   AXI4_Stream_Slave_TVALID;  // ufix1
  input   AXI4_Lite_ACLK;  // ufix1
  input   AXI4_Lite_ARESETN;  // ufix1
  input   [15:0] AXI4_Lite_AWADDR;  // ufix16
  input   AXI4_Lite_AWVALID;  // ufix1
  input   [31:0] AXI4_Lite_WDATA;  // ufix32
  input   [3:0] AXI4_Lite_WSTRB;  // ufix4
  input   AXI4_Lite_WVALID;  // ufix1
  input   AXI4_Lite_BREADY;  // ufix1
  input   [15:0] AXI4_Lite_ARADDR;  // ufix16
  input   AXI4_Lite_ARVALID;  // ufix1
  input   AXI4_Lite_RREADY;  // ufix1
  output  [31:0] AXI4_Stream_Master_TDATA;  // ufix32
  output  AXI4_Stream_Master_TVALID;  // ufix1
  output  AXI4_Stream_Master_TLAST;  // ufix1
  output  AXI4_Stream_Slave_TREADY;  // ufix1
  output  AXI4_Lite_AWREADY;  // ufix1
  output  AXI4_Lite_WREADY;  // ufix1
  output  [1:0] AXI4_Lite_BRESP;  // ufix2
  output  AXI4_Lite_BVALID;  // ufix1
  output  AXI4_Lite_ARREADY;  // ufix1
  output  [31:0] AXI4_Lite_RDATA;  // ufix32
  output  [1:0] AXI4_Lite_RRESP;  // ufix2
  output  AXI4_Lite_RVALID;  // ufix1


  wire reset;
  wire enb;
  wire [31:0] ip_timestamp;  // ufix32
  wire reset_cm;  // ufix1
  wire reset_internal;  // ufix1
  wire reset_before_sync;  // ufix1
  wire write_axi_enable;  // ufix1
  wire [31:0] write_packet_size_axi4_stream_master;  // ufix32
  wire signed [31:0] write_cos_input;  // sfix32_En28
  wire signed [31:0] write_wkn_re;  // sfix32_En28
  wire signed [31:0] write_wkn_im;  // sfix32_En28
  wire const_1;  // ufix1
  wire re_data_valid_sig;  // ufix1
  wire top_user_valid;  // ufix1
  wire top_user_valid_1;  // ufix1
  wire in_data_valid_sig;  // ufix1
  wire auto_ready_axi4_stream_master;  // ufix1
  wire [31:0] top_user_data;  // ufix32
  wire signed [31:0] data_in_sig;  // sfix32_En31
  reg  auto_ready_dut_enb;  // ufix1
  wire dut_enable;  // ufix1
  wire ce_out_sig;  // ufix1
  wire signed [31:0] re_data_out_sig;  // sfix32_En31
  wire [31:0] top_user_data_1;  // ufix32


  assign ip_timestamp = 32'b01111101010110111101101110100010;



  assign reset_cm =  ~ IPCORE_RESETN;



  assign reset_before_sync = reset_cm | reset_internal;



  axis_goertzel_ip_reset_sync u_axis_goertzel_ip_reset_sync_inst (.clk(IPCORE_CLK),  // ufix1
                                                                  .reset_in(reset_before_sync),  // ufix1
                                                                  .reset_out(reset)
                                                                  );

  axis_goertzel_ip_axi_lite u_axis_goertzel_ip_axi_lite_inst (.reset(reset),
                                                              .AXI4_Lite_ACLK(AXI4_Lite_ACLK),  // ufix1
                                                              .AXI4_Lite_ARESETN(AXI4_Lite_ARESETN),  // ufix1
                                                              .AXI4_Lite_AWADDR(AXI4_Lite_AWADDR),  // ufix16
                                                              .AXI4_Lite_AWVALID(AXI4_Lite_AWVALID),  // ufix1
                                                              .AXI4_Lite_WDATA(AXI4_Lite_WDATA),  // ufix32
                                                              .AXI4_Lite_WSTRB(AXI4_Lite_WSTRB),  // ufix4
                                                              .AXI4_Lite_WVALID(AXI4_Lite_WVALID),  // ufix1
                                                              .AXI4_Lite_BREADY(AXI4_Lite_BREADY),  // ufix1
                                                              .AXI4_Lite_ARADDR(AXI4_Lite_ARADDR),  // ufix16
                                                              .AXI4_Lite_ARVALID(AXI4_Lite_ARVALID),  // ufix1
                                                              .AXI4_Lite_RREADY(AXI4_Lite_RREADY),  // ufix1
                                                              .read_ip_timestamp(ip_timestamp),  // ufix32
                                                              .AXI4_Lite_AWREADY(AXI4_Lite_AWREADY),  // ufix1
                                                              .AXI4_Lite_WREADY(AXI4_Lite_WREADY),  // ufix1
                                                              .AXI4_Lite_BRESP(AXI4_Lite_BRESP),  // ufix2
                                                              .AXI4_Lite_BVALID(AXI4_Lite_BVALID),  // ufix1
                                                              .AXI4_Lite_ARREADY(AXI4_Lite_ARREADY),  // ufix1
                                                              .AXI4_Lite_RDATA(AXI4_Lite_RDATA),  // ufix32
                                                              .AXI4_Lite_RRESP(AXI4_Lite_RRESP),  // ufix2
                                                              .AXI4_Lite_RVALID(AXI4_Lite_RVALID),  // ufix1
                                                              .write_axi_enable(write_axi_enable),  // ufix1
                                                              .write_packet_size_axi4_stream_master(write_packet_size_axi4_stream_master),  // ufix32
                                                              .write_cos_input(write_cos_input),  // sfix32_En28
                                                              .write_wkn_re(write_wkn_re),  // sfix32_En28
                                                              .write_wkn_im(write_wkn_im),  // sfix32_En28
                                                              .reset_internal(reset_internal)  // ufix1
                                                              );

  assign const_1 = 1'b1;



  assign enb = const_1;

  assign top_user_valid = re_data_valid_sig;



  assign in_data_valid_sig = top_user_valid_1;



  axis_goertzel_ip_axi4_stream_slave u_axis_goertzel_ip_axi4_stream_slave_inst (.clk(IPCORE_CLK),  // ufix1
                                                                                .reset(reset),
                                                                                .enb(const_1),
                                                                                .AXI4_Stream_Slave_TDATA(AXI4_Stream_Slave_TDATA),  // ufix32
                                                                                .AXI4_Stream_Slave_TVALID(AXI4_Stream_Slave_TVALID),  // ufix1
                                                                                .auto_ready(auto_ready_axi4_stream_master),  // ufix1
                                                                                .AXI4_Stream_Slave_TREADY(AXI4_Stream_Slave_TREADY),  // ufix1
                                                                                .user_data(top_user_data),  // ufix32
                                                                                .user_valid(top_user_valid_1)  // ufix1
                                                                                );

  assign data_in_sig = top_user_data;



  always @(posedge IPCORE_CLK or posedge reset)
    begin : reg_rsvd_process
      if (reset == 1'b1) begin
        auto_ready_dut_enb <= 1'b0;
      end
      else begin
        if (enb) begin
          auto_ready_dut_enb <= auto_ready_axi4_stream_master;
        end
      end
    end



  assign dut_enable = write_axi_enable & auto_ready_dut_enb;



  axis_goertzel_ip_dut u_axis_goertzel_ip_dut_inst (.clk(IPCORE_CLK),  // ufix1
                                                    .reset(reset),
                                                    .dut_enable(dut_enable),  // ufix1
                                                    .data_in(data_in_sig),  // sfix32_En31
                                                    .cos_input(write_cos_input),  // sfix32_En28
                                                    .wkn_re(write_wkn_re),  // sfix32_En28
                                                    .wkn_im(write_wkn_im),  // sfix32_En28
                                                    .in_data_valid(in_data_valid_sig),  // ufix1
                                                    .ce_out(ce_out_sig),  // ufix1
                                                    .re_data_out(re_data_out_sig),  // sfix32_En31
                                                    .re_data_valid(re_data_valid_sig)  // ufix1
                                                    );

  assign top_user_data_1 = re_data_out_sig;



  axis_goertzel_ip_axi4_stream_master u_axis_goertzel_ip_axi4_stream_master_inst (.clk(IPCORE_CLK),  // ufix1
                                                                                  .reset(reset),
                                                                                  .enb(const_1),
                                                                                  .AXI4_Stream_Master_TREADY(AXI4_Stream_Master_TREADY),  // ufix1
                                                                                  .user_data(top_user_data_1),  // ufix32
                                                                                  .user_valid(top_user_valid),  // ufix1
                                                                                  .write_packet_size_axi4_stream_master(write_packet_size_axi4_stream_master),  // ufix32
                                                                                  .AXI4_Stream_Master_TDATA(AXI4_Stream_Master_TDATA),  // ufix32
                                                                                  .AXI4_Stream_Master_TVALID(AXI4_Stream_Master_TVALID),  // ufix1
                                                                                  .AXI4_Stream_Master_TLAST(AXI4_Stream_Master_TLAST),  // ufix1
                                                                                  .auto_ready(auto_ready_axi4_stream_master)  // ufix1
                                                                                  );

endmodule  // axis_goertzel_ip
