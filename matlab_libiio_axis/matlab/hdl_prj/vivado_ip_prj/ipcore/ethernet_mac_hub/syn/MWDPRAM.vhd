
-- ----------------------------------------------
-- File Name: MWDPRAM.vhd
-- Created:   09-Nov-2017 08:56:45
-- Copyright  2017 MathWorks, Inc.
-- ----------------------------------------------


-- ----------------------------------------------
-- File Name: MWDPRAM.vhd
-- Created:   02-Dec-2013 13:33:07
-- Copyright  2013 MathWorks, Inc.
-- ----------------------------------------------

LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY MWDPRAM IS
  GENERIC (
    DATAWIDTH : INTEGER := 10;          -- RAM Dataport width
    ADDRWIDTH : INTEGER := 12);         -- RAM Address port width

  PORT( clkA                              :   IN    std_logic;
        enbA                              :   IN    std_logic;
        wr_dinA                           :   IN    std_logic_vector(DATAWIDTH-1 DOWNTO 0); 
        wr_addrA                          :   IN    std_logic_vector(ADDRWIDTH-1 DOWNTO 0);
        wr_enA                            :   IN    std_logic;
        clkB                              :   IN    std_logic;
        enbB                              :   IN    std_logic;
        rd_addrB                          :   IN    std_logic_vector(ADDRWIDTH-1 DOWNTO 0);
        rd_doutB                          :   OUT   std_logic_vector(DATAWIDTH-1 DOWNTO 0)
        );
END MWDPRAM;


ARCHITECTURE rtl OF MWDPRAM IS

  TYPE memoryT IS ARRAY (2**ADDRWIDTH-1 DOWNTO 0) OF std_logic_vector(DATAWIDTH-1 DOWNTO 0);
  SIGNAL memory : memoryT := (OTHERS => (OTHERS => '0'));

BEGIN

  --clkA port is read-write
  clka_proc: PROCESS (clkA)
  BEGIN  -- PROCESS clka_proc
    IF clkA'event AND clkA = '1' THEN
      IF enbA = '1' THEN
        IF wr_enA = '1' THEN
          memory(to_integer(unsigned(wr_addrA))) <= wr_dinA;
        END IF;
      END IF;
    END IF;
  END PROCESS clka_proc;
 
  --clkB port is read-only
  clkb_proc: PROCESS (clkB)
  BEGIN  -- PROCESS clkb_proc
    IF clkB'event AND clkB = '1' THEN  -- rising clock edge
      IF enbB = '1' THEN
        rd_doutB <= memory(to_integer(unsigned(rd_addrB)));
      END IF;
    END IF;
  END PROCESS clkb_proc;

END rtl;

