-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj/hdlsrc/model_biquad_wfa/axis_goertzel_ip_dut.vhd
-- Created: 2021-03-20 23:59:33
-- 
-- Generated by MATLAB 9.9 and HDL Coder 3.17
-- 
-- -------------------------------------------------------------


-- -------------------------------------------------------------
-- 
-- Module: axis_goertzel_ip_dut
-- Source Path: axis_goertzel_ip/axis_goertzel_ip_dut
-- Hierarchy Level: 1
-- 
-- -------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY axis_goertzel_ip_dut IS
  PORT( clk                               :   IN    std_logic;
        reset                             :   IN    std_logic;
        dut_enable                        :   IN    std_logic;  -- ufix1
        axis_input_tvalid                 :   IN    std_logic;  -- ufix1
        axis_input_tdata                  :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        axi4_wkn                          :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        axi4_incos                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
        ce_out                            :   OUT   std_logic;  -- ufix1
        axis_output_tvalid                :   OUT   std_logic;  -- ufix1
        axis_output_tdata                 :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En16
        );
END axis_goertzel_ip_dut;


ARCHITECTURE rtl OF axis_goertzel_ip_dut IS

  -- Component Declarations
  COMPONENT axis_goertzel_ip_src_model_biquad_wfa
    PORT( clk                             :   IN    std_logic;
          clk_enable                      :   IN    std_logic;
          reset                           :   IN    std_logic;
          axis_input_tvalid               :   IN    std_logic;  -- ufix1
          axis_input_tdata                :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          axi4_wkn                        :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          axi4_incos                      :   IN    std_logic_vector(31 DOWNTO 0);  -- sfix32_En16
          ce_out                          :   OUT   std_logic;  -- ufix1
          axis_output_tvalid              :   OUT   std_logic;  -- ufix1
          axis_output_tdata               :   OUT   std_logic_vector(31 DOWNTO 0)  -- sfix32_En16
          );
  END COMPONENT;

  -- Component Configuration Statements
  FOR ALL : axis_goertzel_ip_src_model_biquad_wfa
    USE ENTITY work.axis_goertzel_ip_src_model_biquad_wfa(rtl);

  -- Signals
  SIGNAL enb                              : std_logic;
  SIGNAL axis_input_tvalid_sig            : std_logic;  -- ufix1
  SIGNAL ce_out_sig                       : std_logic;  -- ufix1
  SIGNAL axis_output_tvalid_sig           : std_logic;  -- ufix1
  SIGNAL axis_output_tdata_sig            : std_logic_vector(31 DOWNTO 0);  -- ufix32

BEGIN
  u_axis_goertzel_ip_src_model_biquad_wfa : axis_goertzel_ip_src_model_biquad_wfa
    PORT MAP( clk => clk,
              clk_enable => enb,
              reset => reset,
              axis_input_tvalid => axis_input_tvalid_sig,  -- ufix1
              axis_input_tdata => axis_input_tdata,  -- sfix32_En16
              axi4_wkn => axi4_wkn,  -- sfix32_En16
              axi4_incos => axi4_incos,  -- sfix32_En16
              ce_out => ce_out_sig,  -- ufix1
              axis_output_tvalid => axis_output_tvalid_sig,  -- ufix1
              axis_output_tdata => axis_output_tdata_sig  -- sfix32_En16
              );

  axis_input_tvalid_sig <= axis_input_tvalid;

  enb <= dut_enable;

  ce_out <= ce_out_sig;

  axis_output_tvalid <= axis_output_tvalid_sig;

  axis_output_tdata <= axis_output_tdata_sig;

END rtl;

