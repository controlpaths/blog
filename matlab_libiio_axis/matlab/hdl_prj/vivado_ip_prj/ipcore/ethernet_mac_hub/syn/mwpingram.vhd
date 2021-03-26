
-- ----------------------------------------------
-- File Name: mwpingram.vhd
-- Created:   09-Nov-2017 08:56:45
-- Copyright  2017 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY mwpingram IS
  
  PORT (
    txclk      : IN  std_logic;
	 txclk_en   : IN  std_logic;
    rxclk      : IN  std_logic;
    pingrdaddr : IN  std_logic_vector(8 DOWNTO 0);  -- Read Address for ping data
    pingrddata : OUT std_logic_vector(7 DOWNTO 0);  -- Read Data for ping data
    pingwraddr : IN  std_logic_vector(8 DOWNTO 0);  -- Write address for ping data
    pingwrdata : IN  std_logic_vector(7 DOWNTO 0);  -- Write data for ping data
    pingwren   : IN  std_logic);         -- Write enable for ping data

END mwpingram;

ARCHITECTURE rtl OF mwpingram IS
  COMPONENT MWDPRAM
    GENERIC (
      DATAWIDTH : INTEGER;
      ADDRWIDTH : INTEGER);
    PORT (
      clkA     : IN  std_logic;
      enbA     : IN  std_logic;
      wr_dinA  : IN  std_logic_vector(DATAWIDTH-1 DOWNTO 0);
      wr_addrA : IN  std_logic_vector(ADDRWIDTH-1 DOWNTO 0);
      wr_enA   : IN  std_logic;
      clkB     : IN  std_logic;
      enbB     : IN  std_logic;
      rd_addrB : IN  std_logic_vector(ADDRWIDTH-1 DOWNTO 0);
      rd_doutB : OUT std_logic_vector(DATAWIDTH-1 DOWNTO 0));
  END COMPONENT;

  CONSTANT zeros : STD_LOGIC_VECTOR(8 DOWNTO 0) := (OTHERS => '0');

BEGIN  -- rtl

  dpram_1: MWDPRAM
    GENERIC MAP (
      DATAWIDTH => 8,
      ADDRWIDTH => 9)
    PORT MAP (
      clkA     => rxclk,
      enbA     => '1',
      wr_dinA  => pingwrdata,
      wr_addrA => pingwraddr,
      wr_enA   => pingwren,
      --rd_addrA => zeros,
      --rd_doutA => rd_doutA,
      clkB     => txclk,
      enbB     => txclk_en,
      rd_addrB => pingrdaddr,
      rd_doutB => pingrddata);

END rtl;
