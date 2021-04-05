-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj/hdlsrc/model_biquad_wfa/axis_goertzel_ip.vhd
-- Created: 2021-03-26 18:29:38
-- 
-- Generated by MATLAB 9.9 and HDL Coder 3.17
-- 
-- 
-- -------------------------------------------------------------
-- Rate and Clocking Details
-- -------------------------------------------------------------
-- Model base rate: -1
-- Target subsystem base rate: -1
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: axis_goertzel_ip
-- Source Path: axis_goertzel_ip
-- Hierarchy Level: 0
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY axis_goertzel_ip IS
  PORT( IPCORE_CLK                        :   IN    std_logic;  -- ufix1
        IPCORE_RESETN                     :   IN    std_logic;  -- ufix1
        AXI4_Stream_Master_TREADY         :   IN    std_logic;  -- ufix1
        AXI4_Stream_Slave_TDATA           :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        AXI4_Stream_Slave_TVALID          :   IN    std_logic;  -- ufix1
        AXI4_Lite_ACLK                    :   IN    std_logic;  -- ufix1
        AXI4_Lite_ARESETN                 :   IN    std_logic;  -- ufix1
        AXI4_Lite_AWADDR                  :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
        AXI4_Lite_AWVALID                 :   IN    std_logic;  -- ufix1
        AXI4_Lite_WDATA                   :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
        AXI4_Lite_WSTRB                   :   IN    std_logic_vector(3 DOWNTO 0);  -- ufix4
        AXI4_Lite_WVALID                  :   IN    std_logic;  -- ufix1
        AXI4_Lite_BREADY                  :   IN    std_logic;  -- ufix1
        AXI4_Lite_ARADDR                  :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
        AXI4_Lite_ARVALID                 :   IN    std_logic;  -- ufix1
        AXI4_Lite_RREADY                  :   IN    std_logic;  -- ufix1
        AXI4_Stream_Master_TDATA          :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
        AXI4_Stream_Master_TVALID         :   OUT   std_logic;  -- ufix1
        AXI4_Stream_Master_TLAST          :   OUT   std_logic;  -- ufix1
        AXI4_Stream_Slave_TREADY          :   OUT   std_logic;  -- ufix1
        AXI4_Lite_AWREADY                 :   OUT   std_logic;  -- ufix1
        AXI4_Lite_WREADY                  :   OUT   std_logic;  -- ufix1
        AXI4_Lite_BRESP                   :   OUT   std_logic_vector(1 DOWNTO 0);  -- ufix2
        AXI4_Lite_BVALID                  :   OUT   std_logic;  -- ufix1
        AXI4_Lite_ARREADY                 :   OUT   std_logic;  -- ufix1
        AXI4_Lite_RDATA                   :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
        AXI4_Lite_RRESP                   :   OUT   std_logic_vector(1 DOWNTO 0);  -- ufix2
        AXI4_Lite_RVALID                  :   OUT   std_logic  -- ufix1
        );
END axis_goertzel_ip;


ARCHITECTURE rtl OF axis_goertzel_ip IS

  -- Component Declarations
  COMPONENT axis_goertzel_ip_reset_sync
    PORT( clk                             :   IN    std_logic;  -- ufix1
          reset_in                        :   IN    std_logic;  -- ufix1
          reset_out                       :   OUT   std_logic
          );
  END COMPONENT;

  COMPONENT axis_goertzel_ip_axi_lite
    PORT( reset                           :   IN    std_logic;
          AXI4_Lite_ACLK                  :   IN    std_logic;  -- ufix1
          AXI4_Lite_ARESETN               :   IN    std_logic;  -- ufix1
          AXI4_Lite_AWADDR                :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
          AXI4_Lite_AWVALID               :   IN    std_logic;  -- ufix1
          AXI4_Lite_WDATA                 :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          AXI4_Lite_WSTRB                 :   IN    std_logic_vector(3 DOWNTO 0);  -- ufix4
          AXI4_Lite_WVALID                :   IN    std_logic;  -- ufix1
          AXI4_Lite_BREADY                :   IN    std_logic;  -- ufix1
          AXI4_Lite_ARADDR                :   IN    std_logic_vector(15 DOWNTO 0);  -- ufix16
          AXI4_Lite_ARVALID               :   IN    std_logic;  -- ufix1
          AXI4_Lite_RREADY                :   IN    std_logic;  -- ufix1
          read_ip_timestamp               :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          AXI4_Lite_AWREADY               :   OUT   std_logic;  -- ufix1
          AXI4_Lite_WREADY                :   OUT   std_logic;  -- ufix1
          AXI4_Lite_BRESP                 :   OUT   std_logic_vector(1 DOWNTO 0);  -- ufix2
          AXI4_Lite_BVALID                :   OUT   std_logic;  -- ufix1
          AXI4_Lite_ARREADY               :   OUT   std_logic;  -- ufix1
          AXI4_Lite_RDATA                 :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
          AXI4_Lite_RRESP                 :   OUT   std_logic_vector(1 DOWNTO 0);  -- ufix2
          AXI4_Lite_RVALID                :   OUT   std_logic;  -- ufix1
          write_axi_enable                :   OUT   std_logic;  -- ufix1
          write_packet_size_axi4_stream_master :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
          write_axi4_incos                :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          write_axi4_wkn                  :   OUT   std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          reset_internal                  :   OUT   std_logic  -- ufix1
          );
  END COMPONENT;

  COMPONENT axis_goertzel_ip_axi4_stream_slave
    PORT( clk                             :   IN    std_logic;  -- ufix1
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          AXI4_Stream_Slave_TDATA         :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          AXI4_Stream_Slave_TVALID        :   IN    std_logic;  -- ufix1
          auto_ready                      :   IN    std_logic;  -- ufix1
          AXI4_Stream_Slave_TREADY        :   OUT   std_logic;  -- ufix1
          user_data                       :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
          user_valid                      :   OUT   std_logic  -- ufix1
          );
  END COMPONENT;

  COMPONENT axis_goertzel_ip_dut
    PORT( clk                             :   IN    std_logic;  -- ufix1
          reset                           :   IN    std_logic;
          dut_enable                      :   IN    std_logic;  -- ufix1
          axis_input_tvalid               :   IN    std_logic;  -- ufix1
          axis_input_tdata                :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          axi4_wkn                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          axi4_incos                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          ce_out                          :   OUT   std_logic;  -- ufix1
          axis_output_tvalid              :   OUT   std_logic;  -- ufix1
          axis_output_tdata               :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En16
          );
  END COMPONENT;

  COMPONENT axis_goertzel_ip_axi4_stream_master
    PORT( clk                             :   IN    std_logic;  -- ufix1
          reset                           :   IN    std_logic;
          enb                             :   IN    std_logic;
          AXI4_Stream_Master_TREADY       :   IN    std_logic;  -- ufix1
          user_data                       :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          user_valid                      :   IN    std_logic;  -- ufix1
          write_packet_size_axi4_stream_master :   IN    std_logic_vector(31 DOWNTO 0);  -- ufix32
          AXI4_Stream_Master_TDATA        :   OUT   std_logic_vector(31 DOWNTO 0);  -- ufix32
          AXI4_Stream_Master_TVALID       :   OUT   std_logic;  -- ufix1
          AXI4_Stream_Master_TLAST        :   OUT   std_logic;  -- ufix1
          auto_ready                      :   OUT   std_logic  -- ufix1
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : axis_goertzel_ip_reset_sync
    USE ENTITY work.axis_goertzel_ip_reset_sync(rtl);

  FOR ALL : axis_goertzel_ip_axi_lite
    USE ENTITY work.axis_goertzel_ip_axi_lite(rtl);

  FOR ALL : axis_goertzel_ip_axi4_stream_slave
    USE ENTITY work.axis_goertzel_ip_axi4_stream_slave(rtl);

  FOR ALL : axis_goertzel_ip_dut
    USE ENTITY work.axis_goertzel_ip_dut(rtl);

  FOR ALL : axis_goertzel_ip_axi4_stream_master
    USE ENTITY work.axis_goertzel_ip_axi4_stream_master(rtl);

  -- Signals
  SIGNAL reset                            : std_logic;
  SIGNAL enb                              : std_logic;
  SIGNAL ip_timestamp                     : unsigned(31 DOWNTO 0);  -- ufix32
  SIGNAL reset_cm                         : std_logic;  -- ufix1
  SIGNAL reset_internal                   : std_logic;  -- ufix1
  SIGNAL reset_before_sync                : std_logic;  -- ufix1
  SIGNAL AXI4_Lite_BRESP_tmp              : std_logic_vector(1 DOWNTO 0);  -- ufix2
  SIGNAL AXI4_Lite_RDATA_tmp              : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL AXI4_Lite_RRESP_tmp              : std_logic_vector(1 DOWNTO 0);  -- ufix2
  SIGNAL write_axi_enable                 : std_logic;  -- ufix1
  SIGNAL write_packet_size_axi4_stream_master : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL write_axi4_incos                 : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL write_axi4_wkn                   : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL const_1_1                        : std_logic;  -- ufix1
  SIGNAL axis_output_tvalid_sig           : std_logic;  -- ufix1
  SIGNAL top_user_valid                   : std_logic;  -- ufix1
  SIGNAL top_user_data                    : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL top_user_data_unsigned           : unsigned(31 DOWNTO 0);  -- ufix32
  SIGNAL axis_input_tdata_sig             : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL auto_ready_axi4_stream_master    : std_logic;  -- ufix1
  SIGNAL top_user_valid_1                 : std_logic;  -- ufix1
  SIGNAL axis_input_tvalid_sig            : std_logic;  -- ufix1
  SIGNAL auto_ready_dut_enb               : std_logic;  -- ufix1
  SIGNAL dut_enable                       : std_logic;  -- ufix1
  SIGNAL ce_out_sig                       : std_logic;  -- ufix1
  SIGNAL axis_output_tdata_sig            : std_logic_vector(31 DOWNTO 0);  -- ufix32
  SIGNAL axis_output_tdata_sig_signed     : signed(31 DOWNTO 0);  -- sfix32_En16
  SIGNAL top_user_data_1                  : unsigned(31 DOWNTO 0);  -- ufix32
  SIGNAL AXI4_Stream_Master_TDATA_tmp     : std_logic_vector(31 DOWNTO 0);  -- ufix32

BEGIN
  u_axis_goertzel_ip_reset_sync_inst : axis_goertzel_ip_reset_sync
    PORT MAP( clk => IPCORE_CLK,  -- ufix1
              reset_in => reset_before_sync,  -- ufix1
              reset_out => reset
              );

  u_axis_goertzel_ip_axi_lite_inst : axis_goertzel_ip_axi_lite
    PORT MAP( reset => reset,
              AXI4_Lite_ACLK => AXI4_Lite_ACLK,  -- ufix1
              AXI4_Lite_ARESETN => AXI4_Lite_ARESETN,  -- ufix1
              AXI4_Lite_AWADDR => AXI4_Lite_AWADDR,  -- ufix16
              AXI4_Lite_AWVALID => AXI4_Lite_AWVALID,  -- ufix1
              AXI4_Lite_WDATA => AXI4_Lite_WDATA,  -- ufix32
              AXI4_Lite_WSTRB => AXI4_Lite_WSTRB,  -- ufix4
              AXI4_Lite_WVALID => AXI4_Lite_WVALID,  -- ufix1
              AXI4_Lite_BREADY => AXI4_Lite_BREADY,  -- ufix1
              AXI4_Lite_ARADDR => AXI4_Lite_ARADDR,  -- ufix16
              AXI4_Lite_ARVALID => AXI4_Lite_ARVALID,  -- ufix1
              AXI4_Lite_RREADY => AXI4_Lite_RREADY,  -- ufix1
              read_ip_timestamp => std_logic_vector(ip_timestamp),  -- ufix32
              AXI4_Lite_AWREADY => AXI4_Lite_AWREADY,  -- ufix1
              AXI4_Lite_WREADY => AXI4_Lite_WREADY,  -- ufix1
              AXI4_Lite_BRESP => AXI4_Lite_BRESP_tmp,  -- ufix2
              AXI4_Lite_BVALID => AXI4_Lite_BVALID,  -- ufix1
              AXI4_Lite_ARREADY => AXI4_Lite_ARREADY,  -- ufix1
              AXI4_Lite_RDATA => AXI4_Lite_RDATA_tmp,  -- ufix32
              AXI4_Lite_RRESP => AXI4_Lite_RRESP_tmp,  -- ufix2
              AXI4_Lite_RVALID => AXI4_Lite_RVALID,  -- ufix1
              write_axi_enable => write_axi_enable,  -- ufix1
              write_packet_size_axi4_stream_master => write_packet_size_axi4_stream_master,  -- ufix32
              write_axi4_incos => write_axi4_incos,  -- sfix32_En16
              write_axi4_wkn => write_axi4_wkn,  -- sfix32_En16
              reset_internal => reset_internal  -- ufix1
              );

  u_axis_goertzel_ip_axi4_stream_slave_inst : axis_goertzel_ip_axi4_stream_slave
    PORT MAP( clk => IPCORE_CLK,  -- ufix1
              reset => reset,
              enb => const_1_1,
              AXI4_Stream_Slave_TDATA => AXI4_Stream_Slave_TDATA,  -- ufix32
              AXI4_Stream_Slave_TVALID => AXI4_Stream_Slave_TVALID,  -- ufix1
              auto_ready => auto_ready_axi4_stream_master,  -- ufix1
              AXI4_Stream_Slave_TREADY => AXI4_Stream_Slave_TREADY,  -- ufix1
              user_data => top_user_data,  -- ufix32
              user_valid => top_user_valid_1  -- ufix1
              );

  u_axis_goertzel_ip_dut_inst : axis_goertzel_ip_dut
    PORT MAP( clk => IPCORE_CLK,  -- ufix1
              reset => reset,
              dut_enable => dut_enable,  -- ufix1
              axis_input_tvalid => axis_input_tvalid_sig,  -- ufix1
              axis_input_tdata => std_logic_vector(axis_input_tdata_sig),  -- sfix32_En16
              axi4_wkn => write_axi4_wkn,  -- sfix32_En16
              axi4_incos => write_axi4_incos,  -- sfix32_En16
              ce_out => ce_out_sig,  -- ufix1
              axis_output_tvalid => axis_output_tvalid_sig,  -- ufix1
              axis_output_tdata => axis_output_tdata_sig  -- sfix32_En16
              );

  u_axis_goertzel_ip_axi4_stream_master_inst : axis_goertzel_ip_axi4_stream_master
    PORT MAP( clk => IPCORE_CLK,  -- ufix1
              reset => reset,
              enb => const_1_1,
              AXI4_Stream_Master_TREADY => AXI4_Stream_Master_TREADY,  -- ufix1
              user_data => std_logic_vector(top_user_data_1),  -- ufix32
              user_valid => top_user_valid,  -- ufix1
              write_packet_size_axi4_stream_master => write_packet_size_axi4_stream_master,  -- ufix32
              AXI4_Stream_Master_TDATA => AXI4_Stream_Master_TDATA_tmp,  -- ufix32
              AXI4_Stream_Master_TVALID => AXI4_Stream_Master_TVALID,  -- ufix1
              AXI4_Stream_Master_TLAST => AXI4_Stream_Master_TLAST,  -- ufix1
              auto_ready => auto_ready_axi4_stream_master  -- ufix1
              );

  ip_timestamp <= to_unsigned(2103261829, 32);

  reset_cm <=  NOT IPCORE_RESETN;

  reset_before_sync <= reset_cm OR reset_internal;

  const_1_1 <= '1';

  enb <= const_1_1;

  top_user_valid <= axis_output_tvalid_sig;

  top_user_data_unsigned <= unsigned(top_user_data);

  axis_input_tdata_sig <= signed(top_user_data_unsigned);

  axis_input_tvalid_sig <= top_user_valid_1;

  reg_process : PROCESS (IPCORE_CLK, reset)
  BEGIN
    IF reset = '1' THEN
      auto_ready_dut_enb <= '0';
    ELSIF IPCORE_CLK'EVENT AND IPCORE_CLK = '1' THEN
      IF enb = '1' THEN
        auto_ready_dut_enb <= auto_ready_axi4_stream_master;
      END IF;
    END IF;
  END PROCESS reg_process;


  dut_enable <= write_axi_enable AND auto_ready_dut_enb;

  axis_output_tdata_sig_signed <= signed(axis_output_tdata_sig);

  top_user_data_1 <= unsigned(axis_output_tdata_sig_signed);

  AXI4_Stream_Master_TDATA <= AXI4_Stream_Master_TDATA_tmp;

  AXI4_Lite_BRESP <= AXI4_Lite_BRESP_tmp;

  AXI4_Lite_RDATA <= AXI4_Lite_RDATA_tmp;

  AXI4_Lite_RRESP <= AXI4_Lite_RRESP_tmp;

END rtl;

