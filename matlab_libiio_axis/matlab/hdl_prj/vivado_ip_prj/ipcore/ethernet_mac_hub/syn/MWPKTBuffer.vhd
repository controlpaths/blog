
-- ----------------------------------------------
-- File Name: MWPKTBuffer.vhd
-- Created:   09-Nov-2017 08:56:45
-- Copyright  2017 MathWorks, Inc.
-- ----------------------------------------------

-- Functions:
-- * data buffer for UDP pakcet builder

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity MWPKTBuffer is
  generic (DATA_BUF_WIDTH    : integer :=  12;
           PKTINFO_BUF_WIDTH : integer :=  4);
  port(
        clk                  : in  std_logic;
        reset                : in  std_logic;
        --------------- from AXIS IF ------------------- 
        dataIn               : in  std_logic_vector(7 downto 0);
        dataVldIn            : in  std_logic;
        EOP                  : in  std_logic;
        dataPort             : in  std_logic_vector(31 downto 0);
        --------------- from AXIS IF ------------------- 
        bufferReady          : out std_logic;
        ----------------from pkt builer ----------------
        rdEn                 : in std_logic;  -- read enable for data buffer
        PKTLoad              : in std_logic;  -- read enable for pkt info buffer
        ----------------to pkt builer ----------------
        dataOut              : out std_logic_vector(7 downto 0);
        dataVldOut           : out std_logic;
        PKTReady             : out std_logic; -- at least one pkt is ready in the buffer
        PKTLen               : out unsigned(DATA_BUF_WIDTH downto 0); -- current pkt length
        PKTPort              : out std_logic_vector(31 downto 0)  -- current pkt port (used for Tx/Rx status)
        );
end MWPKTBuffer;

architecture rtl of MWPKTBuffer is

  component MWDPRAM
    generic (
      DATAWIDTH : INTEGER;
      ADDRWIDTH : INTEGER);
    port (
      clkA     : in  std_logic;
      enbA     : in  std_logic;
      wr_dinA  : in  std_logic_vector(DATAWIDTH-1 downto 0);
      wr_addrA : in  std_logic_vector(ADDRWIDTH-1 downto 0);
      wr_enA   : in  std_logic;
      clkB     : in  std_logic;
      enbB     : in  std_logic;
      rd_addrB : in  std_logic_vector(ADDRWIDTH-1 downto 0);
      rd_doutB : out std_logic_vector(DATAWIDTH-1 downto 0));
  end component;
  
  constant FULLWATERMARK      : integer := (2**DATA_BUF_WIDTH) - 4;
  constant PKTINFO_BUF_DWIDTH : integer := DATA_BUF_WIDTH+33;
  
  signal wrAddr           : unsigned(DATA_BUF_WIDTH downto 0); 
  signal rdAddr           : unsigned(DATA_BUF_WIDTH downto 0);
  signal payloadLen       : unsigned(DATA_BUF_WIDTH downto 0);
  signal dataLen          : unsigned(DATA_BUF_WIDTH downto 0);
  signal empty            : std_logic;

  -- signals for pkt info buffer
  signal pktInfo_wrAddr    : unsigned(PKTINFO_BUF_WIDTH downto 0); 
  signal pktInfo_rdAddr    : unsigned(PKTINFO_BUF_WIDTH downto 0); 
  signal pktInfo_wrData    : std_logic_vector(PKTINFO_BUF_DWIDTH-1 downto 0);
  signal pktInfo_rdData    : std_logic_vector(PKTINFO_BUF_DWIDTH-1 downto 0);
  signal pktInfo_wrDataVld : std_logic;
  
begin
  ------------------- buffer to hold packets -------------------------------------
  u_MWDPRAM: MWDPRAM
  generic map (
               DATAWIDTH => 8,
               ADDRWIDTH => DATA_BUF_WIDTH)
  port map (
            clkA     => clk,
            enbA     => '1',
            wr_dinA  => dataIn,
            wr_addrA => std_logic_vector(wrAddr(DATA_BUF_WIDTH - 1 downto 0)),
            wr_enA   => dataVldIn,
            clkB     => clk,
            enbB     => '1',
            rd_addrB => std_logic_vector(rdAddr(DATA_BUF_WIDTH - 1  downto 0)),
            rd_doutB => dataOut
            );

  -- buffer wr
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        wrAddr       <= (others => '0');
      elsif dataVldIn = '1' then
        wrAddr       <= wrAddr + 1;
      end if;
    end if;
  end process;
  
  -- buffer rd
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        rdAddr     <= (others => '0');
        dataVldOut <= '0';
      else
        if rdEn = '1' and empty = '0'then
           rdAddr     <= rdAddr + 1;
           dataVldOut <= '1';
        else
          rdAddr     <= rdAddr;
          dataVldOut <= '0';
        end if;
      end if;
    end if;
  end process;
  
  empty <= '1' when wrAddr = rdAddr else '0';
  
  dataLen <= to_unsigned(2**(DATA_BUF_WIDTH+1)-1,DATA_BUF_WIDTH+1) - rdAddr + wrAddr
           when (rdAddr(DATA_BUF_WIDTH) = '1' and wrAddr(DATA_BUF_WIDTH) = '0')
           else  wrAddr - rdAddr;
  bufferReady <= '0' when dataLen >= to_unsigned(FULLWATERMARK, DATA_BUF_WIDTH+1)  else '1';
  ------------------- buffer to hold packet info (payloadLen and port) -------------------
  -- payload length for each pkt
  process(clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        payloadLen <= (others => '0');
      else
        if dataVldIn = '1' then
          if EOP = '0' then
            payloadLen <= payloadLen + 1;
          else
            payloadLen <= (others => '0');
          end if;
        else
          payloadLen <= payloadLen;
        end if;
      end if;
    end if;      
  end process;

  -- infoBuffer input: 'port (32)| payloadLen (13)'
  pktInfo_wrData <= dataPort & std_logic_vector(payloadLen+1);
  -- if EOP is received, assert pktInfo_wrDataVld
  pktInfo_wrDataVld <= '1' when (EOP = '1') and (dataVldIn = '1')
                           else '0';
  
  u_PKTINFO: MWDPRAM
  generic map (
               DATAWIDTH => PKTINFO_BUF_DWIDTH,
               ADDRWIDTH => PKTINFO_BUF_WIDTH)
  port map (
            clkA     => clk,
            enbA     => '1',
            wr_dinA  => pktInfo_wrData,
            wr_addrA => std_logic_vector(pktInfo_wrAddr(PKTINFO_BUF_WIDTH - 1 downto 0)),
            wr_enA   => '1',
            clkB     => clk,
            enbB     => '1',
            rd_addrB => std_logic_vector(pktInfo_rdAddr(PKTINFO_BUF_WIDTH - 1  downto 0)),
            rd_doutB => pktInfo_rdData
            );
  
  -- save pkt info when one pkt is received
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        pktInfo_wrAddr       <= (others => '0');
      elsif pktInfo_wrDataVld = '1' then
         pktInfo_wrAddr      <= pktInfo_wrAddr + 1;
      end if;
    end if;
  end process;

  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        pktInfo_rdAddr       <= (others => '0');
      elsif PKTLoad = '1' then
         pktInfo_rdAddr      <= pktInfo_rdAddr + 1;
      end if;
    end if;
  end process;
  
  PKTReady  <= '0' when pktInfo_wrAddr = pktInfo_rdAddr else '1';  -- if pktinfo buffer not empty, assert PKTReady
  PKTLen    <= unsigned(pktInfo_rdData(DATA_BUF_WIDTH downto 0)); 
  PKTPort   <= pktInfo_rdData(DATA_BUF_WIDTH+32 downto DATA_BUF_WIDTH+1);
  
end rtl;