
LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY mwtxmac IS
  GENERIC (
    -- MAC address of this FPGA
    MWMACADDR1 : INTEGER := 16#00#;
    MWMACADDR2 : INTEGER := 16#0A#;
    MWMACADDR3 : INTEGER := 16#35#;
    MWMACADDR4 : INTEGER := 16#02#;
    MWMACADDR5 : INTEGER := 16#21#;
    MWMACADDR6 : INTEGER := 16#8A#;
    -- IP address of this FPGA
    MWIPADDR1  : INTEGER := 192;
    MWIPADDR2  : INTEGER := 168;
    MWIPADDR3  : INTEGER :=   0;
    MWIPADDR4  : INTEGER :=   2;
    BUFFERADDRWIDTH : INTEGER RANGE 12 TO 16 := 12);   --Min 12, Max 16

  PORT( txclk                             :   IN    std_logic;
        txreset                           :   IN   std_logic;
        txclk_en                          :   IN std_logic;
        --
        txData                            :   IN    std_logic_vector(7 DOWNTO 0);
        txDataValid                       :   IN    std_logic;
        txEOP                             :   IN    std_logic;
        txReady                           :   OUT   std_logic;
        txDataLength                      :   IN    std_logic_vector(BUFFERADDRWIDTH DOWNTO 0);
        -- From the received packet
        hostmacaddr1                      :   IN    std_logic_vector(7 DOWNTO 0);
        hostmacaddr2                      :   IN    std_logic_vector(7 DOWNTO 0);
        hostmacaddr3                      :   IN    std_logic_vector(7 DOWNTO 0);
        hostmacaddr4                      :   IN    std_logic_vector(7 DOWNTO 0);
        hostmacaddr5                      :   IN    std_logic_vector(7 DOWNTO 0);
        hostmacaddr6                      :   IN    std_logic_vector(7 DOWNTO 0);
        -- From the received packet
        hostipaddr1                       :   IN    std_logic_vector(7 DOWNTO 0);
        hostipaddr2                       :   IN    std_logic_vector(7 DOWNTO 0);        
        hostipaddr3                       :   IN    std_logic_vector(7 DOWNTO 0);
        hostipaddr4                       :   IN    std_logic_vector(7 DOWNTO 0);
        -- From the received packet 
        udpsrcport1                       :   IN    std_logic_vector(7 DOWNTO 0);
        udpsrcport2                       :   IN    std_logic_vector(7 DOWNTO 0);
        udpdstport1                       :   IN    std_logic_vector(7 DOWNTO 0);
        udpdstport2                       :   IN    std_logic_vector(7 DOWNTO 0);
        -- From the received packet for ping
        pingrdaddr                        :   OUT   std_logic_vector(8 DOWNTO 0);  -- Read Address for ping data
        pingrddata                        :   IN    std_logic_vector(7 DOWNTO 0);  -- Read Data for ping data
        -- Control
        rxaddrvalid                       :   IN    std_logic;
        replyping                         :   IN    std_logic;
        replyarp                          :   IN    std_logic;
        -- GMII interface
        gmii_txd                          :   OUT   std_logic_vector(7 DOWNTO 0);
        gmii_tx_en                        :   OUT   std_logic;
        gmii_tx_er                        :   OUT   std_logic;
        gmii_col                          :   IN    std_logic;  --collision 
        gmii_crs                          :   IN    std_logic  --carrier sense
        );
END mwtxmac;

ARCHITECTURE rtl OF mwtxmac IS

  FUNCTION compute_fcs (fcs    : std_logic_vector(31 DOWNTO 0);
                        indata : std_logic_vector(7 DOWNTO 0))
    RETURN std_logic_vector IS
    VARIABLE tmpfcs       : std_logic_vector(31 DOWNTO 0);  -- Used to compute FCS
  BEGIN
    tmpfcs( 0)  := fcs(24) XOR indata(0) XOR fcs(26) XOR indata(2) XOR
                   fcs(28) XOR indata(4) XOR fcs(29) XOR indata(5) XOR
                   fcs(31) XOR indata(7);
    tmpfcs( 1)  := fcs(25) XOR indata(1) XOR fcs(26) XOR indata(2) XOR
                   fcs(27) XOR indata(3) XOR fcs(29) XOR indata(5) XOR
                   fcs(30) XOR fcs(24) XOR indata(0) XOR indata(6);
    tmpfcs( 2)  := fcs(26) XOR indata(2) XOR fcs(27) XOR indata(3) XOR
                   fcs(28) XOR indata(4) XOR fcs(30) XOR fcs(24) XOR
                   indata(0) XOR indata(6) XOR fcs(31) XOR fcs(25) XOR
                   indata(1) XOR indata(7);
    tmpfcs( 3)  := fcs(27) XOR indata(3) XOR fcs(28) XOR indata(4) XOR
                   fcs(29) XOR indata(5) XOR fcs(31) XOR fcs(25) XOR
                   indata(1) XOR indata(7);
    tmpfcs( 4)  := fcs(28) XOR indata(4) XOR fcs(29) XOR indata(5) XOR
                   fcs(30) XOR fcs(24) XOR indata(0) XOR indata(6);
    tmpfcs( 5)  := fcs(29) XOR indata(5) XOR fcs(30) XOR fcs(24) XOR
                   indata(0) XOR indata(6) XOR fcs(31) XOR fcs(25) XOR
                   indata(1) XOR indata(7);
    tmpfcs( 6)  := fcs(30) XOR fcs(24) XOR indata(0) XOR indata(6) XOR
                   fcs(31) XOR fcs(25) XOR indata(1) XOR indata(7);
    tmpfcs( 7)  := fcs(31) XOR fcs(25) XOR indata(1) XOR indata(7);
    tmpfcs( 8)  := fcs( 0) XOR fcs(24) XOR indata(0) XOR fcs(26) XOR
                   indata(2) XOR fcs(27) XOR indata(3) XOR fcs(28) XOR indata(4);
    tmpfcs(10)  := fcs( 2) XOR fcs(25) XOR indata(1) XOR fcs(26) XOR
                   indata(2) XOR fcs(28) XOR indata(4) XOR fcs(29) XOR
                   indata(5) XOR fcs(30) XOR fcs(24) XOR indata(0) XOR indata(6);
    tmpfcs( 9)  := fcs( 1) XOR fcs(24) XOR indata(0) XOR fcs(25) XOR
                   indata(1) XOR fcs(27) XOR indata(3) XOR fcs(28) XOR
                   indata(4) XOR fcs(29) XOR indata(5);
    tmpfcs(11)  := fcs( 3) XOR fcs(26) XOR indata(2) XOR fcs(27) XOR
                   indata(3) XOR fcs(29) XOR indata(5) XOR fcs(30) XOR
                   indata(6) XOR fcs(31) XOR fcs(25) XOR indata(1) XOR indata(7);
    tmpfcs(12)  := fcs( 4) XOR fcs(27) XOR indata(3) XOR fcs(28) XOR
                   indata(4) XOR fcs(30) XOR indata(6) XOR fcs(31) XOR indata(7);
    tmpfcs(13)  := fcs( 5) XOR fcs(26) XOR indata(2) XOR fcs(28) XOR
                   indata(4) XOR fcs(29) XOR indata(5) XOR fcs(31) XOR indata(7);
    tmpfcs(14)  := fcs( 6) XOR fcs(26) XOR indata(2) XOR fcs(27) XOR
                   indata(3) XOR fcs(29) XOR indata(5) XOR fcs(30) XOR indata(6);
    tmpfcs(15)  := fcs( 7) XOR fcs(27) XOR indata(3) XOR fcs(28) XOR
                   indata(4) XOR fcs(30) XOR indata(6) XOR fcs(31) XOR indata(7);
    tmpfcs(16)  := fcs( 8) XOR fcs(30) XOR indata(6) XOR fcs(31) XOR
                   fcs(25) XOR indata(1) XOR indata(7);
    tmpfcs(17)  := fcs( 9) XOR fcs(31) XOR indata(7);
    tmpfcs(18)  := fcs(10) XOR fcs(26) XOR indata(2);
    tmpfcs(19)  := fcs(11) XOR fcs(27) XOR indata(3);
    tmpfcs(20)  := fcs(12) XOR fcs(24) XOR indata(0) XOR fcs(28) XOR
                   indata(4);
    tmpfcs(21)  := fcs(13) XOR fcs(24) XOR indata(0) XOR fcs(25) XOR
                   indata(1) XOR fcs(29) XOR indata(5);
    tmpfcs(22)  := fcs(14) XOR fcs(25) XOR indata(1) XOR fcs(26) XOR
                   indata(2) XOR fcs(30) XOR indata(6);
    tmpfcs(23)  := fcs(15) XOR fcs(26) XOR indata(2) XOR fcs(27) XOR
                   indata(3) XOR fcs(31) XOR indata(7);
    tmpfcs(24)  := fcs(16) XOR fcs(26) XOR indata(2);
    tmpfcs(25)  := fcs(17) XOR fcs(24) XOR indata(0) XOR fcs(27) XOR indata(3);
    tmpfcs(26)  := fcs(18) XOR fcs(24) XOR indata(0) XOR fcs(25) XOR
                   indata(1) XOR fcs(28) XOR indata(4);
    tmpfcs(27)  := fcs(19) XOR fcs(25) XOR indata(1) XOR fcs(26) XOR
                   indata(2) XOR fcs(29) XOR indata(5);
    tmpfcs(28)  := fcs(20) XOR fcs(26) XOR indata(2) XOR fcs(27) XOR
                   indata(3) XOR fcs(30) XOR fcs(24) XOR indata(0) XOR indata(6);
    tmpfcs(29)  := fcs(21) XOR fcs(27) XOR indata(3) XOR fcs(28) XOR
                   indata(4) XOR fcs(31) XOR fcs(25) XOR indata(1) XOR indata(7);
    tmpfcs(30)  := fcs(22) XOR fcs(28) XOR indata(4) XOR fcs(29) XOR
                   indata(5);
    tmpfcs(31)  := fcs(23) XOR fcs(29) XOR indata(5) XOR fcs(30) XOR
                   fcs(24) XOR indata(0) XOR indata(6);

    RETURN (tmpfcs);
  END;

  CONSTANT MYMACADDR1 : std_logic_vector(7 DOWNTO 0) := std_logic_vector(to_unsigned(MWMACADDR1, 8));
  constant MYMACADDR2 : std_logic_vector(7 DOWNTO 0) := std_logic_vector(to_unsigned(MWMACADDR2, 8));
  CONSTANT MYMACADDR3 : std_logic_vector(7 DOWNTO 0) := std_logic_vector(to_unsigned(MWMACADDR3, 8));
  CONSTANT MYMACADDR4 : std_logic_vector(7 DOWNTO 0) := std_logic_vector(to_unsigned(MWMACADDR4, 8));
  CONSTANT MYMACADDR5 : std_logic_vector(7 DOWNTO 0) := std_logic_vector(to_unsigned(MWMACADDR5, 8));
  CONSTANT MYMACADDR6 : std_logic_vector(7 DOWNTO 0) := std_logic_vector(to_unsigned(MWMACADDR6, 8));

  CONSTANT MYIPADDR1  : std_logic_vector(7 DOWNTO 0) := std_logic_vector(to_unsigned(MWIPADDR1, 8));
  CONSTANT MYIPADDR2  : std_logic_vector(7 DOWNTO 0) := std_logic_vector(to_unsigned(MWIPADDR2, 8));
  CONSTANT MYIPADDR3  : std_logic_vector(7 DOWNTO 0) := std_logic_vector(to_unsigned(MWIPADDR3, 8));
  CONSTANT MYIPADDR4  : std_logic_vector(7 DOWNTO 0) := std_logic_vector(to_unsigned(MWIPADDR4, 8));

  CONSTANT PREAMBLE1VALUE      : std_logic_vector(7 DOWNTO 0) := X"55";  -- First bytes of preamble
  CONSTANT PREAMBLE2VALUE      : std_logic_vector(7 DOWNTO 0) := X"D5";  -- Last byte of preamble
  CONSTANT ETHERTYPE1VALUE     : std_logic_vector(7 DOWNTO 0) := X"08";  -- First byte of ethertype for IP packets
  CONSTANT ETHERTYPE2VALUE     : std_logic_vector(7 DOWNTO 0) := X"00";  -- Second byte
  CONSTANT ETHERTYPE2ARPVALUE  : std_logic_vector(7 DOWNTO 0) := X"06";  -- Second byte for ARP

  CONSTANT IPVERHDRLENVALUE    : std_logic_vector(7 DOWNTO 0) := X"45";  -- Version 4, Header length 5*32
  CONSTANT IPDIFFVALUE         : std_logic_vector(7 DOWNTO 0) := X"00";  -- Differentiated Services
  CONSTANT IPID1VALUE          : std_logic_vector(7 DOWNTO 0) := X"00";  -- ID field 0x0000
  CONSTANT IPID2VALUE          : std_logic_vector(7 DOWNTO 0) := X"00";
  CONSTANT IPFLAGSVALUE        : std_logic_vector(7 DOWNTO 0) := X"00";
  CONSTANT IPTTLVALUE          : std_logic_vector(7 DOWNTO 0) := X"80";  -- TTL=128 0x80

  CONSTANT IPPROTOCOLUDPVALUE  : std_logic_vector(7 DOWNTO 0) := X"11";  -- UDP is protocol number 17 (0x11)
  CONSTANT IPPROTOCOLICMPVALUE : std_logic_vector(7 DOWNTO 0) := X"01";  -- ICMP is protocol number 1 (0x01)

  CONSTANT MYIPADDRCHKSUM       : unsigned(16 DOWNTO 0) := resize(unsigned(MYIPADDR1 & MYIPADDR2), 17)  + resize(unsigned(MYIPADDR3 & MYIPADDR4),17);
  CONSTANT IPVERCHKSUM          : unsigned(16 DOWNTO 0) := resize(unsigned(IPVERHDRLENVALUE & IPDIFFVALUE),17) + resize(unsigned(IPID1VALUE & IPID2VALUE),17);
  CONSTANT IPPROTOCOLUDPCHKSUM  : unsigned(16 DOWNTO 0) := resize(unsigned(IPFLAGSVALUE & IPFLAGSVALUE),17)    + resize(unsigned(IPTTLVALUE & IPPROTOCOLUDPVALUE),17);
  CONSTANT IPPROTOCOLICMPCHKSUM : unsigned(16 DOWNTO 0) := resize(unsigned(IPFLAGSVALUE & IPFLAGSVALUE), 17)    + resize(unsigned(IPTTLVALUE & IPPROTOCOLICMPVALUE), 17);

  CONSTANT TMPHDRUDPCHKSUM       : unsigned(20 DOWNTO 0) := resize(IPVERCHKSUM,21) + resize(IPPROTOCOLUDPCHKSUM,21) + resize(MYIPADDRCHKSUM,21);
  CONSTANT IPHDRCHECKSUMUDPVALUE : unsigned(15 DOWNTO 0) := TMPHDRUDPCHKSUM(15 DOWNTO 0) + resize(TMPHDRUDPCHKSUM(20 DOWNTO 16), 16);

  CONSTANT TMPHDRICMPCHKSUM      : unsigned(20 DOWNTO 0) := resize(IPVERCHKSUM,21)+ resize(IPPROTOCOLICMPCHKSUM, 21) + resize(MYIPADDRCHKSUM,21);
  CONSTANT IPHDRCHECKSUMICMPVALUE: unsigned(15 DOWNTO 0) := TMPHDRICMPCHKSUM(15 DOWNTO 0) + TMPHDRICMPCHKSUM(20 DOWNTO 16);

  CONSTANT ICMPPINGTYPEVALUE   : std_logic_vector(7 DOWNTO 0) := X"00";  -- ICMP ping reply 

  CONSTANT PING_TOTALLEN1      : std_logic_vector(7 DOWNTO 0) := X"00";  -- first byte ping length
  CONSTANT PING_TOTALLEN2      : std_logic_vector(7 DOWNTO 0) := X"3C";  --second byte ping length

  CONSTANT MYUDPPORT1          : std_logic_vector(7 DOWNTO 0) := X"00";  -- MSByte of src port
  CONSTANT MYUDPPORT2          : std_logic_vector(7 DOWNTO 0) := X"00";  -- LSByte of src port

  CONSTANT MAXDATALENGTH       : unsigned(15 DOWNTO 0) := to_unsigned(1472, 16);
  CONSTANT ZEROEXT             : unsigned(15 DOWNTO 0) := (others =>'0');

  -- States for tx state machine
  TYPE tx_state_type IS (idle, cooldown, udp_pending,
                         preamble1, preamble2, preamble3, preamble4,
                         preamble5, preamble6, preamble7, preamble8,
                         --dstmac1, dstmac2, dstmac3, dstmac4, dstmac5, dstmac6,
                         --srcmac1, srcmac2, srcmac3, srcmac4, srcmac5, srcmac6,
                         --ethertype1, 
                         macSrcDst, ethertype2,
                         iphdr1, iphdr2, iptotal_len1, iptotal_len2,
                         ipid1, ipid2, iphdr3, iphdr4,
                         ipttl, ipprotocol, iphdrchecksum1, iphdrchecksum2,
                         ipAddr,
                         --srcip1, srcip2, srcip3, srcip4,
                         --dstip1, dstip2, dstip3, dstip4,
                         --UDP states
                         --udpsrc1, udpsrc2, udpdst1, udpdst2,
                         udplen1, udplen2, udpchecksum1, udpchecksum2,
                         udpdata,
                         --
                         ippadding,
                         ipfcs1, ipfcs2, ipfcs3, ipfcs4,
                         ----Ping states
                         --pingiphdr1, pingiphdr2,
                         --pingiptotallen1, pingiptotallen2,
                         --pingipid1, pingipid2,
                         --pingiphdr3, pingiphdr4,
                         --pingipttl, pingipprotocol,
                         --pingiphdrchecksum1,pingiphdrchecksum2,
                         --pingipsrc1, pingipsrc2, pingipsrc3, pingipsrc4,
                         --pingipdst1, pingipdst2, pingipdst3, pingipdst4,
                         ping_pkt,
                         pingicmp1, pingicmp2,
                         pingicmpchecksum1, pingicmpchecksum2,
                         pingicmpdata, 
                         --ARP States
                         arp_pkt);
                        -- arp_htype1, arp_htype2, arp_ptype1,  arp_ptype2,               
                        -- arp_hlen, arp_plen, arp_oper1, arp_oper2,
                        -- arp_sha1, arp_sha2, arp_sha3, arp_sha4, arp_sha5, arp_sha6, 
                        -- arp_spa1, arp_spa2, arp_spa3, arp_spa4, 
                        -- arp_tha1, arp_tha2, arp_tha3, arp_tha4, arp_tha5, arp_tha6, 
                        -- arp_tpa1, arp_tpa2, arp_tpa3, arp_tpa4);

  
  SIGNAL current_state               : tx_state_type;  -- state register for transmit state machine
  SIGNAL rxaddrvalid_sync1           : std_logic;
  SIGNAL rxaddrvalid_sync2           : std_logic;
  --
  SIGNAL replyping_sync1             : std_logic;
  SIGNAL replyping_sync2             : std_logic;
  SIGNAL replyping_sync3             : std_logic;
  SIGNAL ping_pending                : std_logic;
  SIGNAL pingflag                    : std_logic;
  --
  SIGNAL replyarp_sync1              : std_logic;
  SIGNAL replyarp_sync2              : std_logic;
  SIGNAL replyarp_sync3              : std_logic;
  SIGNAL arp_pending                 : std_logic;
  SIGNAL arpflag                     : std_logic;
  --
  SIGNAL iptotallenreg               : unsigned(15 DOWNTO 0);
  --
  SIGNAL hdrchecksum                 : unsigned(16 DOWNTO 0); --17-bit accumulator
  --
  SIGNAL byte_count                  : unsigned(15 DOWNTO 0);
  SIGNAL udp_count                   : unsigned(15 DOWNTO 0);
  SIGNAL pingdatavalue               : unsigned(7  DOWNTO 0);
  SIGNAL pingaddr                    : unsigned(8 DOWNTO 0);
  SIGNAL incpingflag                 : std_logic;
  SIGNAL fcs                         : std_logic_vector(31 DOWNTO 0); -- Frame check seq. or CRC
  SIGNAL fcs_tx_value                : std_logic_vector(31 DOWNTO 0);
  SIGNAL gmii_col_reg                : std_logic;
  SIGNAL gmii_crs_reg                : std_logic;
  SIGNAL tx_en                       : std_logic;
  SIGNAL dataTxFlag                  : std_logic;
  SIGNAL arp_clear                   : std_logic;
  SIGNAL ping_clear                  : std_logic;

  SIGNAL TxDataLength_unsigned       : unsigned(15 DOWNTO 0);
  SIGNAL EthHeader                   : std_logic_vector(399 DOWNTO 0);
  SIGNAL ipAddrCnt                   : unsigned(3 downto 0);
  SIGNAL arpCnt                      : unsigned(4 downto 0);
  SIGNAL macSrcDstCnt                : unsigned(3 downto 0);
  SIGNAL pingCnt                     : unsigned(4 downto 0);

BEGIN

  -- purpose: dual rank sync indicators from receive side
  dualsync_proc: PROCESS (txclk)
  BEGIN  
    IF txclk'event AND txclk = '1' THEN
      IF txreset = '1' THEN
        rxaddrvalid_sync1 <= '0';
        rxaddrvalid_sync2 <= '0';
        replyping_sync1   <= '0';
        replyping_sync2   <= '0';
        replyping_sync3   <= '0';
        ping_pending      <= '0';
        replyarp_sync1    <= '0';
        replyarp_sync2    <= '0';
        arp_pending       <= '0';
      ELSIF  txclk_en = '1' then
        rxaddrvalid_sync1 <= rxaddrvalid;
        rxaddrvalid_sync2 <= rxaddrvalid_sync1;
        replyping_sync1   <= replyping;
        replyping_sync2   <= replyping_sync1;
        replyping_sync3   <= replyping_sync2;
        IF replyping_sync3 = '0' AND replyping_sync2 = '1' AND ping_pending = '0' THEN 
          ping_pending <= '1';
        ELSIF ping_clear = '1' THEN
          ping_pending <= '0';
        END IF;

        replyarp_sync1 <= replyarp;
        replyarp_sync2 <= replyarp_sync1;
        replyarp_sync3 <= replyarp_sync2;
        IF replyarp_sync3 = '0' AND replyarp_sync2 = '1' AND arp_pending = '0' THEN 
          arp_pending <= '1';
        ELSIF arp_clear = '1' THEN
          arp_pending <= '0';
        END IF;

      END IF;
    END IF;
  END PROCESS dualsync_proc;    

  -- purpose: Input register for collision and carrier sense
  inputreg: PROCESS (txclk)
  BEGIN
    IF txclk'event AND txclk = '1' THEN
      IF txreset = '0' THEN           
        gmii_col_reg <= '0';
        gmii_crs_reg <= '0';
      ELSIF  txclk_en = '1' then
        gmii_col_reg <= gmii_col;
        gmii_crs_reg <= gmii_crs;
      END IF;
    END IF;
  END PROCESS inputreg;

  TxDataLength_unsigned <= resize(unsigned(TxDataLength), 16);

  tx_fsm: PROCESS (txclk)
  BEGIN
    IF txclk'event AND txclk = '1' THEN  -- rising clock edge
      IF txreset = '1' THEN
        current_state <= idle;
        byte_count  <= (OTHERS => '0');
        udp_count   <= (OTHERS => '0');
        pingflag    <= '0';
        gmii_txd    <= (OTHERS => '0');
        tx_en       <= '0';
        gmii_tx_er  <= '0';
        iptotallenreg <= (OTHERS => '0');
        pingaddr    <= (OTHERS => '0');
        incpingflag <= '0';
        --
        hdrchecksum <= (OTHERS => '0');
        fcs         <= (OTHERS => '1'); --initialize to all 1's
        dataTxFlag  <= '0';
        arpflag     <= '0';
        arp_clear   <= '0';
        ping_clear  <= '0'; 
        EthHeader   <= (others => '0');
        ipAddrCnt   <= (others => '0');
        arpCnt      <= (others => '0');
        macSrcDstCnt<= (others => '0');
        pingCnt      <= (others => '0');
      ELSIF  txclk_en = '1' then
        IF current_state = preamble1 OR tx_en = '1' THEN
              EthHeader(399 DOWNTO 8) <= EthHeader(391 DOWNTO 0);
              EthHeader(7 DOWNTO 0 )  <= (others => '0'); 
        ELSIF current_state = cooldown OR current_state = idle THEN
              EthHeader <= (others => '0');
        END IF;
        IF gmii_col_reg = '1' AND tx_en = '1' THEN
          current_state <= cooldown;
          pingaddr <= (OTHERS => '0');
          tx_en      <= '0';
          pingflag   <= '0';
          arpflag    <= '0';
          arp_clear  <= '0';
          ping_clear <= '0'; 
          dataTxFlag <= '0';
        ELSE
          CASE current_state IS
            WHEN idle =>
              gmii_txd <= (OTHERS => '0');
              tx_en <= '0';
              incpingflag <= '0';
              arp_clear  <= '0';
              ping_clear <= '0';
              --ICMP echo (ping) has priority here! Do not reorder this code.
              IF ping_pending = '1' AND gmii_crs_reg = '0' THEN 
                current_state <= preamble1;
                pingaddr <= (OTHERS => '0');
                pingflag <= '1';
                ping_clear <= '1';
                EthHeader(399 DOWNTO 224) <= PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE &
                           PREAMBLE2VALUE &
                           hostmacaddr1 & hostmacaddr2 & hostmacaddr3 & hostmacaddr4 & hostmacaddr5 & hostmacaddr6 &
                           MYMACADDR1 & MYMACADDR2 & MYMACADDR3 & MYMACADDR4 & MYMACADDR5  & MYMACADDR6 &
                           ETHERTYPE1VALUE & ETHERTYPE2VALUE; -- 176 bits.
              ELSIF arp_pending = '1' AND gmii_crs_reg = '0' THEN
                current_state <= preamble1;
                pingaddr <= (OTHERS => '0');
                arpflag <= '1';
                arp_clear <= '1';
                EthHeader(399 DOWNTO 0) <= PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE &
                           PREAMBLE2VALUE &
                           hostmacaddr1 & hostmacaddr2 & hostmacaddr3 & hostmacaddr4 & hostmacaddr5 & hostmacaddr6 &
                           MYMACADDR1 & MYMACADDR2 & MYMACADDR3 & MYMACADDR4 & MYMACADDR5  & MYMACADDR6 &
                           ETHERTYPE1VALUE & ETHERTYPE2ARPVALUE &
                           X"00" & X"01" & X"08" & X"00" & X"06" & X"04" & X"00" & X"02" & 
                           MYMACADDR1 & MYMACADDR2 & MYMACADDR3 & MYMACADDR4 & MYMACADDR5 & MYMACADDR6 &
                           MYIPADDR1 & MYIPADDR2 & MYIPADDR3 & MYIPADDR4 &
                           hostmacaddr1 & hostmacaddr2 & hostmacaddr3 & hostmacaddr4 & hostmacaddr5 & hostmacaddr6 &
                           hostipaddr1 & hostipaddr2 & hostipaddr3 & hostipaddr4; -- 400 bits.
              ELSIF (TxEOP = '1' OR TxDataLength_unsigned >= MAXDATALENGTH) AND rxaddrvalid_sync2 = '1' AND gmii_crs_reg = '0' THEN
                current_state <= udp_pending;
                pingflag   <= '0';
                arpflag    <= '0';
                arp_clear  <= '0';
                ping_clear <= '0';
                dataTxFlag <= '0';
                byte_count <= TxDataLength_unsigned;
                EthHeader(399 DOWNTO 16) <= PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE & PREAMBLE1VALUE &
                           PREAMBLE2VALUE &
                           hostmacaddr1 & hostmacaddr2 & hostmacaddr3 & hostmacaddr4 & hostmacaddr5 & hostmacaddr6 &
                           MYMACADDR1 & MYMACADDR2 & MYMACADDR3 & MYMACADDR4 & MYMACADDR5  & MYMACADDR6 &
                           ETHERTYPE1VALUE & ETHERTYPE2VALUE &
                           IPVERHDRLENVALUE & IPDIFFVALUE & X"0000" & IPID1VALUE & IPID2VALUE & IPFLAGSVALUE & IPFLAGSVALUE & IPTTLVALUE & IPPROTOCOLUDPVALUE & 
                           X"0000" & MYIPADDR1 & MYIPADDR2 & MYIPADDR3 & MYIPADDR4 & hostipaddr1 & hostipaddr2 & hostipaddr3 & hostipaddr4 & 
                           udpdstport1 & udpdstport2 & udpsrcport1 & udpsrcport2 &  X"0000"; -- 384 bits.
              ELSE
                current_state <= idle;
                pingflag   <= '0';
                arpflag    <= '0';
                arp_clear  <= '0';
                ping_clear <= '0';
                dataTxFlag <= '0';
                EthHeader  <= (Others => '0');
              END IF;
              --
            WHEN cooldown =>
              tx_en <= '0';
              IF byte_count = 0 THEN
                current_state <= idle;
              ELSE
                current_state <= cooldown;
                byte_count <= byte_count - 1;
              END IF;
              --
            WHEN udp_pending =>
              iptotallenreg <= byte_count + 28; --20-byte IP header and 8-byte UDP header
              udp_count     <= byte_count + 8;
              current_state <= preamble1; --cannot read RAM for >1 cycle
              hdrchecksum   <= resize(IPHDRCHECKSUMUDPVALUE,17);--unsigned("0" & IPHDRCHECKSUMUDPVALUE);
            WHEN preamble1 =>
              gmii_txd <=  EthHeader(399 DOWNTO 392); -- PREAMBLE1VALUE; -- EthHeader(399 DOWNTO 392);
              tx_en <= '1';
              arp_clear  <= '0';
              ping_clear <= '0';
              current_state <= preamble2;
             hdrchecksum <= resize(hdrchecksum(15 DOWNTO 0),17) +
                            unsigned("0" & hostipaddr1 & hostipaddr2) +
                            unsigned(ZEROEXT & hdrchecksum(16));
             -- hdrchecksum <= ("0" & hdrchecksum(15 DOWNTO 0)) +
             --                unsigned("0" & hostipaddr1 & hostipaddr2) +
             --                ("0" & hdrchecksum(16));
            WHEN preamble2 =>
              gmii_txd <= EthHeader(399 DOWNTO 392); --PREAMBLE1VALUE;
              current_state <= preamble3;
              hdrchecksum <= resize(hdrchecksum(15 DOWNTO 0),17) +
                            unsigned("0" & hostipaddr3 & hostipaddr4) +
                            unsigned(ZEROEXT & hdrchecksum(16));
              --hdrchecksum <= ("0" & hdrchecksum(15 DOWNTO 0)) +
              --               unsigned("0" & hostipaddr3 & hostipaddr4) +
              --               ("0" & hdrchecksum(16));
            WHEN preamble3 =>
              gmii_txd <= EthHeader(399 DOWNTO 392); --PREAMBLE1VALUE;
              current_state <= preamble4;
              hdrchecksum <= resize(hdrchecksum(15 DOWNTO 0),17) +
                             resize(iptotallenreg, 16) +
                             unsigned(ZEROEXT & hdrchecksum(16));
              --hdrchecksum <= ("0" & hdrchecksum(15 DOWNTO 0)) +
              --               ("0" & iptotallenreg) +
              --               ("0" & hdrchecksum(16));
            WHEN preamble4 =>
              gmii_txd <= EthHeader(399 DOWNTO 392); --PREAMBLE1VALUE;
              hdrchecksum <= resize(hdrchecksum(15 DOWNTO 0),17) +
                             unsigned(ZEROEXT & hdrchecksum(16));
              --hdrchecksum <= ("0" & hdrchecksum(15 DOWNTO 0)) +
              --              ("0" & hdrchecksum(16));
              current_state <= preamble5;
            WHEN preamble5 =>
              gmii_txd <= EthHeader(399 DOWNTO 392); --PREAMBLE1VALUE;
              current_state <= preamble6;
            WHEN preamble6 =>
              gmii_txd <= EthHeader(399 DOWNTO 392); --PREAMBLE1VALUE;
              current_state <= preamble7;
            WHEN preamble7 =>
              gmii_txd <= EthHeader(399 DOWNTO 392); --PREAMBLE1VALUE;
              current_state <= preamble8;
            WHEN preamble8 =>
              gmii_txd <= EthHeader(399 DOWNTO 392); --PREAMBLE2VALUE;
              current_state <= macSrcDst; --dstmac1;
              fcs <= (OTHERS => '1'); --initialize to all 1's
              ---------------------------------------------------------------------
            WHEN macSrcDst => 
              gmii_txd <= EthHeader(399 DOWNTO 392); 
              fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); 
              if macSrcDstCnt < to_unsigned(12, 4) then
                 macSrcDstCnt <= macSrcDstCnt + 1;
              else
                 current_state <= ethertype2; -- dstmac2;  
                 macSrcDstCnt <= (others => '0'); 
              end if;             
            WHEN ethertype2 =>
               IF arpflag = '1' THEN
                current_state <= arp_pkt; -- arp_htype1;                
                gmii_txd <= EthHeader(399 DOWNTO 392); --ETHERTYPE2ARPVALUE;
                fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); --ETHERTYPE2ARPVALUE);
              ELSIF pingflag = '1' THEN
                gmii_txd <= EthHeader(399 DOWNTO 392); --ETHERTYPE2VALUE;
                fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); --ETHERTYPE2VALUE);
                current_state <= ping_pkt; -- pingiphdr1;
                pingaddr <= pingaddr + 1;
              ELSE
                current_state <= iphdr1;
                gmii_txd <= EthHeader(399 DOWNTO 392); --ETHERTYPE2VALUE;
                fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); --ETHERTYPE2VALUE);
              END IF;
              ---------------------------------------------------------------------
              -- Start of ping section
              ---------------------------------------------------------------------
              WHEN ping_pkt =>
                gmii_txd <= pingrddata; 
                fcs <= compute_fcs(fcs, pingrddata);   
                pingaddr <= pingaddr + 1;
                if pingCnt = to_unsigned(11, 5) then
                   pingaddr <= pingaddr + 5;     -- swap src and dst IP address
                elsif pingCnt = to_unsigned(14, 5) then
                   pingaddr <= pingaddr - 7;     -- swap src and dst IP address
                elsif pingCnt = to_unsigned(18, 5) then
                   pingaddr <= pingaddr + 5;     -- swap src and dst IP address
                end if;

                if pingCnt < to_unsigned(19,5) then 
                   pingCnt <= pingCnt + 1;
                else
                   pingCnt <= (others => '0');
                   current_state <= pingicmp1;
                end if;
                
                if pingCnt = to_unsigned(2, 5) then
                   byte_count(15 DOWNTO 8) <= unsigned(pingrddata(7 DOWNTO 0));
                elsif pingCnt = to_unsigned(3, 5) then
                   byte_count(7 DOWNTO 0) <= unsigned(pingrddata);
                elsif pingCnt = to_unsigned(4,5) then
                   byte_count <= byte_count - 25; --adjust count for IP header and ICMP header
                end if;

              ---------------------------------------------------------------------
            WHEN pingicmp1 =>     
              gmii_txd <= X"00"; --force echo reply type
              fcs <= compute_fcs(fcs, X"00");   
              pingaddr <= pingaddr + 1;
              current_state <= pingicmp2;
            WHEN pingicmp2 =>     
              gmii_txd <= pingrddata;
              fcs <= compute_fcs(fcs, pingrddata);   
              pingaddr <= pingaddr + 1;
              current_state <= pingicmpchecksum1;
            WHEN pingicmpchecksum1 =>     
              gmii_txd <= std_logic_vector(unsigned(pingrddata) + 8);  -- force checksum for type change
              fcs <= compute_fcs(fcs, std_logic_vector(unsigned(pingrddata) + 8));   
              IF pingrddata(7 DOWNTO 3) = "11111" THEN
                incpingflag <= '1';
              END IF;
              pingaddr <= pingaddr + 1;
              current_state <= pingicmpchecksum2;
            WHEN pingicmpchecksum2 =>     
              gmii_txd <= std_logic_vector(unsigned(pingrddata) + ("0" & incpingflag)); -- wrap carry
              fcs <= compute_fcs(fcs, std_logic_vector(unsigned(pingrddata) + ("0" & incpingflag)));
              incpingflag <= '0';
              pingaddr <= pingaddr + 1;
              current_state <= pingicmpdata;
              -- Just ship out ping RAM data from here to FCS
            WHEN pingicmpdata =>     
              gmii_txd <= pingrddata;
              fcs <= compute_fcs(fcs, pingrddata);   
              pingaddr <= pingaddr + 1;
              IF byte_count = 0 THEN
                current_state <= ipfcs1;
              ELSE
                current_state <= pingicmpdata;
                byte_count <= byte_count - 1;
              END IF;

              ---------------------------------------------------------------------
              -- Start of UDP Section
              ---------------------------------------------------------------------
            WHEN iphdr1 =>
              gmii_txd <=  EthHeader(399 DOWNTO 392); --IPVERHDRLENVALUE;
              fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); --IPVERHDRLENVALUE);   
              current_state <= iphdr2;
            WHEN iphdr2 =>
              gmii_txd <=  EthHeader(399 DOWNTO 392); --IPDIFFVALUE;
              fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); --IPDIFFVALUE);   
              current_state <= iptotal_len1;
            WHEN iptotal_len1 =>
              gmii_txd <= std_logic_vector(iptotallenreg(15 DOWNTO 8));
              fcs <= compute_fcs(fcs, std_logic_vector(iptotallenreg(15 DOWNTO 8)));
              current_state <= iptotal_len2;
            WHEN iptotal_len2 =>
              gmii_txd <= std_logic_vector(iptotallenreg(7 DOWNTO 0));
              fcs <= compute_fcs(fcs, std_logic_vector(iptotallenreg(7 DOWNTO 0)));
              current_state <= ipid1;
            WHEN ipid1 =>
              gmii_txd <=  EthHeader(399 DOWNTO 392); --IPID1VALUE;
              fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); --IPID1VALUE);
              current_state <= ipid2;
            WHEN ipid2 => 
              gmii_txd <=  EthHeader(399 DOWNTO 392); --IPID2VALUE;
              fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); --IPID2VALUE);
              current_state <= iphdr3;
            WHEN iphdr3 => 
              gmii_txd <=  EthHeader(399 DOWNTO 392); --IPFLAGSVALUE;
              fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); --IPFLAGSVALUE);
              current_state <= iphdr4;
            WHEN iphdr4 => 
              gmii_txd <=  EthHeader(399 DOWNTO 392); --IPFLAGSVALUE;
              fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); --IPFLAGSVALUE);
              current_state <= ipttl;
            WHEN ipttl => 
              gmii_txd <=  EthHeader(399 DOWNTO 392); --IPTTLVALUE;
              fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); --IPTTLVALUE);
              current_state <= ipprotocol;
            WHEN ipprotocol =>
              gmii_txd <=  EthHeader(399 DOWNTO 392); --IPPROTOCOLUDPVALUE;
              fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); --IPPROTOCOLUDPVALUE);
              current_state <= iphdrchecksum1;
            WHEN iphdrchecksum1 =>
              gmii_txd <= NOT std_logic_vector(hdrchecksum(15 DOWNTO 8));
              fcs <= compute_fcs(fcs, NOT std_logic_vector(hdrchecksum(15 DOWNTO 8)));
              current_state <= iphdrchecksum2;
            WHEN iphdrchecksum2 =>
              gmii_txd <= NOT std_logic_vector(hdrchecksum(7 DOWNTO 0));
              fcs <= compute_fcs(fcs, NOT std_logic_vector(hdrchecksum(7 DOWNTO 0)));
              current_state <= ipAddr; --srcip1;
              --
            WHEN ipAddr =>
              gmii_txd <=  EthHeader(399 DOWNTO 392); --MYIPADDR1;
              fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392));
              if ipAddrCnt < to_unsigned(11, 4) then
                 ipAddrCnt <= ipAddrCnt + 1;
              else
                 ipAddrCnt <= (others => '0');
                 current_state <= udplen1;
              end if; 
              --if ipAddrCnt >= to_unsigned(10, 4) then 
                 --dataTxFlag    <= '1'; -- Activate the data read from ram, inorder to get the data at right time.
              --else
                 --dataTxFlag    <= '0';
              --end if;
            WHEN udplen1 =>
              gmii_txd <= std_logic_vector(udp_count(15 DOWNTO 8));
              fcs <= compute_fcs(fcs, std_logic_vector(udp_count(15 DOWNTO 8)));
              current_state <= udplen2;
			  dataTxFlag <= '1';
            WHEN udplen2 =>
              gmii_txd <= std_logic_vector(udp_count(7 DOWNTO 0));
              fcs <= compute_fcs(fcs, std_logic_vector(udp_count(7 DOWNTO 0)));
              current_state <= udpchecksum1;
            WHEN udpchecksum1 => 
              gmii_txd <= (OTHERS => '0');
              fcs <= compute_fcs(fcs, (OTHERS => '0'));
              current_state <= udpchecksum2;
            WHEN udpchecksum2 =>
              gmii_txd <= (OTHERS => '0');
              fcs      <= compute_fcs(fcs, (OTHERS => '0'));
              current_state <= udpdata;
            WHEN udpdata => 
              current_state <= udpdata;
              IF txDataValid = '1' then
                gmii_txd   <= txData;
                fcs        <= compute_fcs(fcs, txData);
                byte_count <= byte_count - 1;
                IF byte_count <= to_unsigned(4, byte_count'length) then
                   dataTxFlag <= '0';
                END IF;
              END IF;

              IF byte_count = to_unsigned(0, byte_count'length) then
                IF iptotallenreg < to_unsigned(45, iptotallenreg'LENGTH) THEN
                   gmii_txd <= X"00";
                   fcs <= compute_fcs(fcs, X"00");
                   iptotallenreg <= iptotallenreg + 1;
                   current_state <= ippadding;
                ELSIF iptotallenreg = to_unsigned(45, iptotallenreg'LENGTH) THEN
                   gmii_txd <= X"00";
                   fcs <= compute_fcs(fcs, X"00");
                   iptotallenreg <= iptotallenreg + 1;
                   current_state <= ipfcs1;
                ELSE
                   gmii_txd <= fcs_tx_value(31 DOWNTO 24);
                   current_state <= ipfcs2;
                   pingaddr <= (OTHERS => '0');
                                  
                END IF;
              END IF;
              
              -----------------------------------------------------------------
              -- IP padding to 64-byte minimum packet
              -----------------------------------------------------------------
            WHEN ippadding =>
              gmii_txd <= X"00";
              fcs <= compute_fcs(fcs, X"00");
              iptotallenreg <= iptotallenreg + 1;
              IF iptotallenreg = to_unsigned(45, iptotallenreg'LENGTH) THEN
                current_state <= ipfcs1;
              ELSE
                current_state <= ippadding;
              END IF;
              
              ---------------------------------------------------------------------
              -- Frame Check Sequence (CRC) handling section
              ---------------------------------------------------------------------
            WHEN ipfcs1 =>
              gmii_txd <= fcs_tx_value(31 DOWNTO 24);
              current_state <= ipfcs2;
              pingaddr <= (OTHERS => '0');
            WHEN ipfcs2 =>
              gmii_txd <= fcs_tx_value(23 DOWNTO 16);
              current_state <= ipfcs3;
            WHEN ipfcs3 =>
              gmii_txd <= fcs_tx_value(15 DOWNTO 8);
              current_state <= ipfcs4;
            WHEN ipfcs4 => 
              gmii_txd <= fcs_tx_value(7 DOWNTO 0);
              byte_count <= to_unsigned(12, byte_count'length); --twelve cycles
              current_state <= cooldown;
              
              -----------------------------------------------------------------
              -- ARP Reply
              -----------------------------------------------------------------
            WHEN arp_pkt =>
              gmii_txd <= EthHeader(399 DOWNTO 392); -- X"00";
              fcs <= compute_fcs(fcs, EthHeader(399 DOWNTO 392)); --X"00");
              if arpCnt < to_unsigned(28, 5) then
                 arpCnt <= arpCnt + 1;
              else
                 iptotallenreg <= to_unsigned(28, iptotallenreg'LENGTH);
                 current_state <= ippadding;
                 arpCnt <= (others => '0'); 
              end if;
              if arpCnt = to_unsigned(18,5) then
                 byte_count <= to_unsigned(6, byte_count'LENGTH);
              end if;
                            
            WHEN OTHERS =>
              current_state <= idle;
          END CASE;
        END IF;
      END IF;
    END IF; 
  END PROCESS tx_fsm;

  fcs_tx_value <= NOT fcs;

  pingrdaddr <= std_logic_vector(pingaddr);

  TxReady <= rxaddrvalid_sync2 AND (NOT (pingflag OR arpflag)) AND dataTxFlag;

  gmii_tx_en <= tx_en;

END rtl;

