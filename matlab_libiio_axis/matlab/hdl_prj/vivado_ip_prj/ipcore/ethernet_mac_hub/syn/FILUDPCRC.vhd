-- Functions:  
-- * udp packet crc check.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.std_logic_unsigned.all;

    
entity FILUDPCRC is

  generic(
          BUFFERADDRWIDTH: INTEGER :=  11
          );
  port(
        clk        : in  std_logic;
        clk_en     : in  std_logic;
        reset      : in  std_logic;
        -----------------------------------------------------------------------
        dataIn     : in std_logic_vector(7 downto 0);
        dataVldIn  : in std_logic;
        EOPIn      : in std_logic;
        CRCOK      : in std_logic;
        CRCBad     : in std_logic;
        -----------------------------------------------------------------------
        dataOut    : out std_logic_vector(7 downto 0);
        dataVldOut : out std_logic;
        EOPOut     : out std_logic
        );
end FILUDPCRC;

architecture rtl of FILUDPCRC is

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

  type WR_STATE_TYPE  is (WR_IDLE, WR_DATA, WR_CHECKCRC);

  signal dataVldIn_d  : std_logic;
  signal dataVldIn_l  : std_logic;
  signal wrData       : std_logic_vector(8 downto 0); -- eop(1) data (8)
  signal rdData       : std_logic_vector(8 downto 0);
  signal wrAddr       : std_logic_vector(BUFFERADDRWIDTH-1 downto 0);
  signal wrAddrFirst  : std_logic_vector(BUFFERADDRWIDTH-1 downto 0); -- wrAddr for first byte of pkt
  signal wrAddrLast   : std_logic_vector(BUFFERADDRWIDTH-1 downto 0); -- wrAddr for last byte of pkt
  signal rdAddr       : std_logic_vector(BUFFERADDRWIDTH-1 downto 0);
  signal empty        : std_logic;
  signal pktStart     : std_logic;
  signal wrState      : WR_STATE_TYPE;
  signal rdDataVld    : std_logic;

begin
  dataVldIn_l <= dataVldIn and clk_en; -- clk_en will toggle for 100M Eth
  
  -- DPRAM component
  u_MWDPRAM: MWDPRAM
  generic map (
    DATAWIDTH => 9,
    ADDRWIDTH => BUFFERADDRWIDTH)
  port map (
    clkA     => clk,
    enbA     => '1',
    wr_dinA  => wrData,
    wr_addrA => wrAddr, 
    wr_enA   => dataVldIn_l,
    clkB     => clk,
    enbB     => '1',
    rd_addrB => rdAddr,
    rd_doutB => rdData);
    
  -- Detect start point of the packet (posedge of dataVldIn_l)
  process (clk)
  begin
    if rising_edge(clk) then 
      dataVldIn_d <= dataVldIn_l;
    end if;
  end process;
  pktStart <= (not dataVldIn_d) and dataVldIn_l;
  
  -- DPRAM write FSM
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        wrState      <= WR_IDLE;
        wrAddr       <= (others => '0');
        wrAddrFirst  <= (others => '0');
        wrAddrLast   <= (others => '0');
      else
        case wrState is
          when WR_IDLE =>
            if pktStart = '1' then
              wrAddr      <= wrAddr + 1;
              wrAddrFirst <= wrAddr;
              wrState     <= WR_DATA;
            end if;
          when WR_DATA =>
            if dataVldIn_l = '1' then
              wrAddr <= wrAddr + 1;
              if EOPIn = '1' then -- crc check after EOP
                wrState <= WR_CHECKCRC;
              end if;
            end if;
          when WR_CHECKCRC =>
            if CRCOK = '1' then
              wrAddrLast <= wrAddr; -- if crc ok, update wrAddrLast
              wrState    <= WR_IDLE;
            elsif CRCBad = '1' then -- if crc bad, discard the packet by adjusting wrAddr
              wrAddr  <= wrAddrFirst;
              wrState <= WR_IDLE;
            end if;
        end case;
      end if;
    end if;
  end process;
  
  -- DPRAM status
  empty <= '1' when rdAddr = wrAddrLast else '0';
  
  -- DPRAM read
  process (clk)
  begin
    if rising_edge(clk) then
      if reset = '1' then
        rdAddr      <= (others => '0');
        rdDataVld   <= '0'; 
      else
        if empty = '1' then
          rdAddr     <= rdAddr;
          rdDataVld  <= '0';
        else
          rdAddr     <= rdAddr +1;
          rdDataVld  <= '1';
        end if;
      end if;
    end if;
  end process;

  -- DPRAM data in
  wrData <= EOPIn & dataIn; -- 9 bits 
  
  -- DPRAM data out
  dataOut    <= rdData(7 downto 0);
  EOPOut     <= rdData(8);
  dataVldOut <= rdDataVld;
  
end rtl;