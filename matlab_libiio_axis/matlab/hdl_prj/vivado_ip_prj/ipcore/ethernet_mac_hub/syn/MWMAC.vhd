library IEEE;
use IEEE.std_logic_1164.all;
ENTITY MWMAC IS 
GENERIC (
         MWMACADDR1: integer := 0;
         MWMACADDR2: integer := 10;
         MWMACADDR3: integer := 53;
         MWMACADDR4: integer := 2;
         MWMACADDR5: integer := 33;
         MWMACADDR6: integer := 138;
         MWIPADDR1: integer := 192;
         MWIPADDR2: integer := 168;
         MWIPADDR3: integer := 0;
         MWIPADDR4: integer := 2;
         BUFFERADDRWIDTH: integer := 12
);

PORT (
      rxclk                           : IN  std_logic;
      rxclk_en                        : IN  std_logic;
      RxReset                         : IN  std_logic;

      txclk                           : IN  std_logic;
      txclk_en                        : IN  std_logic;
      TxReset                         : IN  std_logic;
	  
	  gmii_rxd                        : IN  std_logic_vector(7 DOWNTO 0);
      gmii_rx_dv                      : IN  std_logic;
      gmii_rx_er                      : IN  std_logic;
      gmii_col                        : IN  std_logic;
      gmii_crs                        : IN  std_logic;
      
	  TxData                          : IN  std_logic_vector(7 DOWNTO 0);
      TxDataValid                     : IN  std_logic;
      TxEOP                           : IN  std_logic;
      TxDataLength                    : IN  std_logic_vector(12 DOWNTO 0);
      udpsrcport1                     : IN  std_logic_vector(7 DOWNTO 0);
      udpsrcport2                     : IN  std_logic_vector(7 DOWNTO 0);
      udpdstport1                     : IN  std_logic_vector(7 DOWNTO 0);
      udpdstport2                     : IN  std_logic_vector(7 DOWNTO 0);
      
	  gmii_txd                        : OUT std_logic_vector(7 DOWNTO 0);
      gmii_tx_en                      : OUT std_logic;
      gmii_tx_er                      : OUT std_logic;
      
	  RxData                          : OUT std_logic_vector(7 DOWNTO 0);
      RxDataValid                     : OUT std_logic;
      RxEOP                           : OUT std_logic;
      RxCRCOK                         : OUT std_logic;
      RxCRCBad                        : OUT std_logic;
      
	  TxReady                         : OUT std_logic
);
END MWMAC;

ARCHITECTURE rtl of MWMAC IS

COMPONENT mwrxmac IS 
GENERIC (MWMACADDR1: integer := 0;
MWMACADDR2: integer := 10;
MWMACADDR3: integer := 53;
MWMACADDR4: integer := 2;
MWMACADDR5: integer := 33;
MWMACADDR6: integer := 138;
MWIPADDR1: integer := 192;
MWIPADDR2: integer := 168;
MWIPADDR3: integer := 0;
MWIPADDR4: integer := 2
);
PORT (
      rxclk                           : IN  std_logic;
      rxclk_en                        : IN  std_logic;
      rxreset                         : IN  std_logic;

      gmii_rx_dv                      : IN  std_logic;
      gmii_rxd                        : IN  std_logic_vector(7 DOWNTO 0);
      gmii_rx_er                      : IN  std_logic;
      
	  rxdatavalid                     : OUT std_logic;
      rxdata                          : OUT std_logic_vector(7 DOWNTO 0);
      rxeop                           : OUT std_logic;
      rxcrcok                         : OUT std_logic;
      rxcrcbad                        : OUT std_logic;
      
      pingwraddr                      : OUT std_logic_vector(8 DOWNTO 0);
      pingwrdata                      : OUT std_logic_vector(7 DOWNTO 0);
      pingwren                        : OUT std_logic;
      
	  rxaddrvalid                     : OUT std_logic;
	  replyping                       : OUT std_logic;
      replyarp                        : OUT std_logic;
      
	  hostmacaddr1                    : OUT std_logic_vector(7 DOWNTO 0);
      hostmacaddr2                    : OUT std_logic_vector(7 DOWNTO 0);
      hostmacaddr3                    : OUT std_logic_vector(7 DOWNTO 0);
      hostmacaddr4                    : OUT std_logic_vector(7 DOWNTO 0);
      hostmacaddr5                    : OUT std_logic_vector(7 DOWNTO 0);
      hostmacaddr6                    : OUT std_logic_vector(7 DOWNTO 0);
      
	  hostipaddr1                     : OUT std_logic_vector(7 DOWNTO 0);
      hostipaddr2                     : OUT std_logic_vector(7 DOWNTO 0);
      hostipaddr3                     : OUT std_logic_vector(7 DOWNTO 0);
      hostipaddr4                     : OUT std_logic_vector(7 DOWNTO 0)
);
END COMPONENT;

COMPONENT mwtxmac IS 
GENERIC (MWMACADDR1: integer := 0;
MWMACADDR2: integer := 10;
MWMACADDR3: integer := 53;
MWMACADDR4: integer := 2;
MWMACADDR5: integer := 33;
MWMACADDR6: integer := 138;
MWIPADDR1: integer := 192;
MWIPADDR2: integer := 168;
MWIPADDR3: integer := 0;
MWIPADDR4: integer := 2;
BUFFERADDRWIDTH: integer := 12
);
PORT (
      hostmacaddr3                    : IN  std_logic_vector(7 DOWNTO 0);
      txreset                         : IN  std_logic;
      pingrddata                      : IN  std_logic_vector(7 DOWNTO 0);
      txdatalength                    : IN  std_logic_vector(12 DOWNTO 0);
      gmii_crs                        : IN  std_logic;
      txeop                           : IN  std_logic;
      hostmacaddr6                    : IN  std_logic_vector(7 DOWNTO 0);
      rxaddrvalid                     : IN  std_logic;
      hostmacaddr5                    : IN  std_logic_vector(7 DOWNTO 0);
      replyarp                        : IN  std_logic;
      udpsrcport1                     : IN  std_logic_vector(7 DOWNTO 0);
      udpsrcport2                     : IN  std_logic_vector(7 DOWNTO 0);
      udpdstport1                     : IN  std_logic_vector(7 DOWNTO 0);
      udpdstport2                     : IN  std_logic_vector(7 DOWNTO 0);
      txclk                           : IN  std_logic;
      hostmacaddr4                    : IN  std_logic_vector(7 DOWNTO 0);
      txclk_en                        : IN  std_logic;
      hostipaddr2                     : IN  std_logic_vector(7 DOWNTO 0);
      hostmacaddr1                    : IN  std_logic_vector(7 DOWNTO 0);
      gmii_col                        : IN  std_logic;
      hostipaddr4                     : IN  std_logic_vector(7 DOWNTO 0);
      txdatavalid                     : IN  std_logic;
      replyping                       : IN  std_logic;
      hostmacaddr2                    : IN  std_logic_vector(7 DOWNTO 0);
      hostipaddr3                     : IN  std_logic_vector(7 DOWNTO 0);
      hostipaddr1                     : IN  std_logic_vector(7 DOWNTO 0);
      txdata                          : IN  std_logic_vector(7 DOWNTO 0);
      txready                         : OUT std_logic;
      gmii_tx_er                      : OUT std_logic;
      gmii_txd                        : OUT std_logic_vector(7 DOWNTO 0);
      gmii_tx_en                      : OUT std_logic;
      pingrdaddr                      : OUT std_logic_vector(8 DOWNTO 0)
);
END COMPONENT;

COMPONENT mwpingram IS 
PORT (
      rxclk                           : IN  std_logic;
      txclk                           : IN  std_logic;
      txclk_en                        : IN  std_logic;
      pingwraddr                      : IN  std_logic_vector(8 DOWNTO 0);
      pingwren                        : IN  std_logic;
      pingrdaddr                      : IN  std_logic_vector(8 DOWNTO 0);
      pingwrdata                      : IN  std_logic_vector(7 DOWNTO 0);
      pingrddata                      : OUT std_logic_vector(7 DOWNTO 0)
);
END COMPONENT;

  SIGNAL hostmacaddr1                     : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL hostmacaddr2                     : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL hostmacaddr3                     : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL hostmacaddr4                     : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL hostmacaddr5                     : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL hostmacaddr6                     : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL hostipaddr1                      : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL hostipaddr2                      : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL hostipaddr3                      : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL hostipaddr4                      : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL rxaddrvalid                      : std_logic; -- boolean
  SIGNAL replyping                        : std_logic; -- boolean
  SIGNAL replyarp                         : std_logic; -- boolean
  SIGNAL pingrdaddr                       : std_logic_vector(8 DOWNTO 0); -- std9
  SIGNAL pingrddata                       : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL pingwraddr                       : std_logic_vector(8 DOWNTO 0); -- std9
  SIGNAL pingwrdata                       : std_logic_vector(7 DOWNTO 0); -- std8
  SIGNAL pingwren                         : std_logic; -- boolean

BEGIN

u_mwrxmac: mwrxmac 
GENERIC MAP (MWMACADDR1 => MWMACADDR1,
MWMACADDR2 => MWMACADDR2,
MWMACADDR3 => MWMACADDR3,
MWMACADDR4 => MWMACADDR4,
MWMACADDR5 => MWMACADDR5,
MWMACADDR6 => MWMACADDR6,
MWIPADDR1 => MWIPADDR1,
MWIPADDR2 => MWIPADDR2,
MWIPADDR3 => MWIPADDR3,
MWIPADDR4 => MWIPADDR4
)
PORT MAP(

        rxclk                => rxclk,
        rxclk_en             => rxclk_en,
        rxreset              => RxReset,

        gmii_rxd             => gmii_rxd,
        gmii_rx_dv           => gmii_rx_dv,
        gmii_rx_er           => gmii_rx_er,
		
		rxdata               => RxData,
        rxdatavalid          => RxDataValid,
        rxeop                => RxEOP,
        rxcrcok              => RxCRCOK,
        rxcrcbad             => RxCRCBad,

        hostmacaddr1         => hostmacaddr1,
        hostmacaddr2         => hostmacaddr2,
        hostmacaddr3         => hostmacaddr3,
        hostmacaddr4         => hostmacaddr4,
        hostmacaddr5         => hostmacaddr5,
        hostmacaddr6         => hostmacaddr6,
        
        pingwraddr           => pingwraddr,
        pingwren             => pingwren,
        pingwrdata           => pingwrdata,

        replyping            => replyping,
        rxaddrvalid          => rxaddrvalid,
        replyarp             => replyarp,

        hostipaddr1          => hostipaddr1,
        hostipaddr2          => hostipaddr2,
        hostipaddr3          => hostipaddr3,
        hostipaddr4          => hostipaddr4
);

u_mwtxmac: mwtxmac 
GENERIC MAP (MWMACADDR1 => MWMACADDR1,
MWMACADDR2 => MWMACADDR2,
MWMACADDR3 => MWMACADDR3,
MWMACADDR4 => MWMACADDR4,
MWMACADDR5 => MWMACADDR5,
MWMACADDR6 => MWMACADDR6,
MWIPADDR1 => MWIPADDR1,
MWIPADDR2 => MWIPADDR2,
MWIPADDR3 => MWIPADDR3,
MWIPADDR4 => MWIPADDR4,
BUFFERADDRWIDTH => BUFFERADDRWIDTH
)
PORT MAP(
        hostmacaddr3         => hostmacaddr3,
        txreset              => TxReset,
        pingrddata           => pingrddata,
        txdatalength         => TxDataLength,
        txready              => TxReady,
        gmii_crs             => gmii_crs,
        txeop                => TxEOP,
        hostmacaddr6         => hostmacaddr6,
        gmii_tx_er           => gmii_tx_er,
        rxaddrvalid          => rxaddrvalid,
        hostmacaddr5         => hostmacaddr5,
        gmii_txd             => gmii_txd,
        replyarp             => replyarp,
        udpsrcport1          => udpsrcport1,
        udpsrcport2          => udpsrcport2,
        udpdstport1          => udpdstport1,
        udpdstport2          => udpdstport2,
        txclk                => txclk,
        hostmacaddr4         => hostmacaddr4,
        txclk_en             => txclk_en,
        hostipaddr2          => hostipaddr2,
        hostmacaddr1         => hostmacaddr1,
        gmii_col             => gmii_col,
        gmii_tx_en           => gmii_tx_en,
        hostipaddr4          => hostipaddr4,
        pingrdaddr           => pingrdaddr,
        txdatavalid          => TxDataValid,
        replyping            => replyping,
        hostmacaddr2         => hostmacaddr2,
        hostipaddr3          => hostipaddr3,
        hostipaddr1          => hostipaddr1,
        txdata               => TxData
);

u_mwpingram: mwpingram 
PORT MAP(
        pingrddata           => pingrddata,
        rxclk                => rxclk,
        txclk                => txclk,
        txclk_en             => txclk_en,
        pingwraddr           => pingwraddr,
        pingwren             => pingwren,
        pingrdaddr           => pingrdaddr,
        pingwrdata           => pingwrdata
);

END;
