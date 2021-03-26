// (c) Copyright 1995-2021 Xilinx, Inc. All rights reserved.
// 
// This file contains confidential and proprietary information
// of Xilinx, Inc. and is protected under U.S. and
// international copyright and other intellectual property
// laws.
// 
// DISCLAIMER
// This disclaimer is not a license and does not grant any
// rights to the materials distributed herewith. Except as
// otherwise provided in a valid license issued to you by
// Xilinx, and to the maximum extent permitted by applicable
// law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
// WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
// AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
// BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
// INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
// (2) Xilinx shall not be liable (whether in contract or tort,
// including negligence, or under any other theory of
// liability) for any loss or damage of any kind or nature
// related to, arising under or in connection with these
// materials, including for any direct, or any indirect,
// special, incidental, or consequential loss or damage
// (including loss of data, profits, goodwill, or any type of
// loss or damage suffered as a result of any action brought
// by a third party) even if such damage or loss was
// reasonably foreseeable or Xilinx had been advised of the
// possibility of the same.
// 
// CRITICAL APPLICATIONS
// Xilinx products are not designed or intended to be fail-
// safe, or for use in any application requiring fail-safe
// performance, such as life-support or safety devices or
// systems, Class III medical devices, nuclear facilities,
// applications related to the deployment of airbags, or any
// other applications that could lead to death, personal
// injury, or severe property or environmental damage
// (individually and collectively, "Critical
// Applications"). Customer assumes the sole risk and
// liability of any use of Xilinx products in Critical
// Applications, subject only to applicable laws and
// regulations governing limitations on product liability.
// 
// THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
// PART OF THIS FILE AT ALL TIMES.
// 
// DO NOT MODIFY THIS FILE.

//-----------------------------------------------------------------------------
// Filename:    system_s01_regslice_4_stub.sv
// Description: This HDL file is intended to be used with Xilinx Vivado Simulator (XSIM) only.
//-----------------------------------------------------------------------------
`ifdef XILINX_SIMULATOR

`ifndef XILINX_SIMULATOR_BITASBOOL
`define XILINX_SIMULATOR_BITASBOOL
typedef bit bit_as_bool;
`endif

(* SC_MODULE_EXPORT *)
module system_s01_regslice_4 (
  input bit_as_bool aclk,
  input bit_as_bool aresetn,
  input bit [31 : 0] s_axi_araddr,
  input bit [7 : 0] s_axi_arlen,
  input bit [2 : 0] s_axi_arsize,
  input bit [1 : 0] s_axi_arburst,
  input bit [0 : 0] s_axi_arlock,
  input bit [3 : 0] s_axi_arcache,
  input bit [2 : 0] s_axi_arprot,
  input bit [3 : 0] s_axi_arregion,
  input bit [3 : 0] s_axi_arqos,
  input bit_as_bool s_axi_arvalid,
  output bit_as_bool s_axi_arready,
  output bit [63 : 0] s_axi_rdata,
  output bit [1 : 0] s_axi_rresp,
  output bit_as_bool s_axi_rlast,
  output bit_as_bool s_axi_rvalid,
  input bit_as_bool s_axi_rready,
  output bit [31 : 0] m_axi_araddr,
  output bit [7 : 0] m_axi_arlen,
  output bit [2 : 0] m_axi_arsize,
  output bit [1 : 0] m_axi_arburst,
  output bit [0 : 0] m_axi_arlock,
  output bit [3 : 0] m_axi_arcache,
  output bit [2 : 0] m_axi_arprot,
  output bit [3 : 0] m_axi_arregion,
  output bit [3 : 0] m_axi_arqos,
  output bit_as_bool m_axi_arvalid,
  input bit_as_bool m_axi_arready,
  input bit [63 : 0] m_axi_rdata,
  input bit [1 : 0] m_axi_rresp,
  input bit_as_bool m_axi_rlast,
  input bit_as_bool m_axi_rvalid,
  output bit_as_bool m_axi_rready
);
endmodule
`endif
