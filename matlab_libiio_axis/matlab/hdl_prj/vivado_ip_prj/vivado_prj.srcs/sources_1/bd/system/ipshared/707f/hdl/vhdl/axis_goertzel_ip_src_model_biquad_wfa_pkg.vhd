-- -------------------------------------------------------------
-- 
-- File Name: hdl_prj/hdlsrc/model_biquad_wfa/axis_goertzel_ip_src_model_biquad_wfa_pkg.vhd
-- Created: 2021-03-20 23:59:29
-- 
-- Generated by MATLAB 9.9 and HDL Coder 3.17
-- 
-- -------------------------------------------------------------


LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

PACKAGE axis_goertzel_ip_src_model_biquad_wfa_pkg IS
  TYPE vector_of_std_logic_vector32 IS ARRAY (NATURAL RANGE <>) OF std_logic_vector(31 DOWNTO 0);
  TYPE vector_of_signed32 IS ARRAY (NATURAL RANGE <>) OF signed(31 DOWNTO 0);
END axis_goertzel_ip_src_model_biquad_wfa_pkg;

