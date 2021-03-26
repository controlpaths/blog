LIBRARY IEEE;
USE IEEE.std_logic_1164.ALL;
USE IEEE.numeric_std.ALL;

ENTITY mwrxmac IS
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
    MWIPADDR4  : INTEGER :=   2);

  PORT( rxclk                             :   IN     std_logic;
        rxreset                           :   IN     std_logic;
        rxclk_en                          :   IN     std_logic;
        -- GMII interface
        gmii_rxd                          :   IN     std_logic_vector(7 DOWNTO 0);
        gmii_rx_dv                        :   IN     std_logic;
        gmii_rx_er                        :   IN     std_logic;
        --
        RxData                            :   OUT    std_logic_vector(7 DOWNTO 0);  
        RxDataValid                       :   OUT    std_logic;
        RxEOP                             :   OUT    std_logic;
        RxCRCOK                           :   OUT    std_logic;
        RxCRCBad                          :   OUT    std_logic;
        -- From the received packet
        hostmacaddr1                      :   OUT    std_logic_vector(7 DOWNTO 0);
        hostmacaddr2                      :   OUT    std_logic_vector(7 DOWNTO 0);
        hostmacaddr3                      :   OUT    std_logic_vector(7 DOWNTO 0);
        hostmacaddr4                      :   OUT    std_logic_vector(7 DOWNTO 0);
        hostmacaddr5                      :   OUT    std_logic_vector(7 DOWNTO 0);
        hostmacaddr6                      :   OUT    std_logic_vector(7 DOWNTO 0);
        -- From the received packet
        hostipaddr1                       :   OUT    std_logic_vector(7 DOWNTO 0);
        hostipaddr2                       :   OUT    std_logic_vector(7 DOWNTO 0);        
        hostipaddr3                       :   OUT    std_logic_vector(7 DOWNTO 0);
        hostipaddr4                       :   OUT    std_logic_vector(7 DOWNTO 0);
        --
        pingwraddr                        :   OUT    std_logic_vector(8 DOWNTO 0);
        pingwrdata                        :   OUT    std_logic_vector(7 DOWNTO 0);
        pingwren                          :   OUT    std_logic;
        --
        rxaddrvalid                       :   OUT    std_logic;
        replyping                         :   OUT    std_logic;
        replyarp                          :   OUT    std_logic
        );
END mwrxmac;

ARCHITECTURE rtl OF mwrxmac IS

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
  CONSTANT ETHERTYPE2ARPVALUE  : std_logic_vector(7 DOWNTO 0) := X"06";  -- Second byte
  CONSTANT IPPROTOCOLUDPVALUE  : std_logic_vector(7 DOWNTO 0) := X"11";  -- UDP is protocol number 17 (0x11)
  CONSTANT IPPROTOCOLICMPVALUE : std_logic_vector(7 DOWNTO 0) := X"01";  -- ICMP is protocol number 1 (0x01)
  CONSTANT ICMPPINGTYPEVALUE   : std_logic_vector(7 DOWNTO 0) := X"08";  -- ICMP ping request is 8

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


  -- States for rx state machine
  TYPE rx_state_type IS (idle, flush_packet,
                         preamble,
                         dstmac1, dstmac2, dstmac3, dstmac4, dstmac5, dstmac6,
                         dstmacbroadcast2, dstmacbroadcast3, dstmacbroadcast4,
                         dstmacbroadcast5, dstmacbroadcast6,
                         srcmac1, srcmac2, srcmac3, srcmac4, srcmac5, srcmac6,
                         ethertype1, ethertype2,
                         iphdr1, iphdr2, iptotal_len1, iptotal_len2,
                         ipid1, ipid2, iphdr3, iphdr4,
                         ipttl, ipprotocol, iphdrchecksum1, iphdrchecksum2,
                         srcip1, srcip2, srcip3, srcip4,
                         dstip1, dstip2, dstip3, dstip4,
                         udpsrc1, udpsrc2, udpdst1, udpdst2,
                         udplen1, udplen2, udpchecksum1, udpchecksum2,
                         udpdata,
                         ippadding,
                         ipfcs1, ipfcs2, ipfcs3, ipfcs4,
                         --Ping states
                         pinghdrchecksum1, pinghdrchecksum2,
                         pingsrcip1, pingsrcip2, pingsrcip3, pingsrcip4,
                         pingdstip1, pingdstip2, pingdstip3, pingdstip4,
                         pingicmptype, pingicmpcode,
                         pingicmpchecksum1, pingicmpchecksum2,
                         pingicmpid1, pingicmpid2,
                         pingicmpseq1, pingicmpseq2,
                         pingdata,
                         pingfcs1, pingfcs2, pingfcs3, pingfcs4,
                         --ARP states
                         arp_htype1, arp_htype2, arp_ptype1,  arp_ptype2,               
                         arp_hlen, arp_plen, arp_oper1, arp_oper2,
                         arp_sha1, arp_sha2, arp_sha3, arp_sha4, arp_sha5, arp_sha6, 
                         arp_spa1, arp_spa2, arp_spa3, arp_spa4, 
                         arp_tha1, arp_tha2, arp_tha3, arp_tha4, arp_tha5, arp_tha6, 
                         arp_tpa1, arp_tpa2, arp_tpa3, arp_tpa4,
                         arppadding,
                         arpfcs1, arpfcs2, arpfcs3, arpfcs4);

  SIGNAL gmii_rxd_reg     : std_logic_vector(7 DOWNTO 0);
  SIGNAL gmii_rx_dv_reg   : std_logic;
  SIGNAL gmii_rx_er_reg   : std_logic;
  SIGNAL current_state    : rx_state_type;
  --
  SIGNAL rxaddrvalidreg   : std_logic;
  SIGNAL replypingreg     : std_logic;
  SIGNAL replyarpreg      : std_logic;
  --
  SIGNAL hostmacaddr1reg  : std_logic_vector(7 DOWNTO 0); --Send to tx side
  SIGNAL hostmacaddr2reg  : std_logic_vector(7 DOWNTO 0);
  SIGNAL hostmacaddr3reg  : std_logic_vector(7 DOWNTO 0);
  SIGNAL hostmacaddr4reg  : std_logic_vector(7 DOWNTO 0);
  SIGNAL hostmacaddr5reg  : std_logic_vector(7 DOWNTO 0);
  SIGNAL hostmacaddr6reg  : std_logic_vector(7 DOWNTO 0);
  --
  SIGNAL hostipaddr1reg   : std_logic_vector(7 DOWNTO 0); --Send to tx side
  SIGNAL hostipaddr2reg   : std_logic_vector(7 DOWNTO 0);
  SIGNAL hostipaddr3reg   : std_logic_vector(7 DOWNTO 0);
  SIGNAL hostipaddr4reg   : std_logic_vector(7 DOWNTO 0);
  --
  SIGNAL fcs              : std_logic_vector(31 DOWNTO 0);
  SIGNAL fcs_check_value  : std_logic_vector(31 DOWNTO 0);

  -- Holds the length field in the IP packet header
  SIGNAL iplen1reg        : std_logic_vector(7 DOWNTO 0);
  SIGNAL iplen2reg        : std_logic_vector(7 DOWNTO 0);
  --
  SIGNAL udplen1reg       : std_logic_vector(7 DOWNTO 0);  -- Holds the MSByte length from the packet
  SIGNAL udplen2reg       : std_logic_vector(7 DOWNTO 0);  -- Holds the LSByte length from the packet  
  SIGNAL udplencount      : unsigned(15 DOWNTO 0); -- General counter to count the bytes

  SIGNAL pingaddr         : unsigned(8 DOWNTO 0);  -- Address for ping ram

  SIGNAL udpsrcport0_1reg : std_logic_vector(7 DOWNTO 0);
  SIGNAL udpsrcport0_2reg : std_logic_vector(7 DOWNTO 0);
  SIGNAL udpdstport0_1reg : std_logic_vector(7 DOWNTO 0);
  SIGNAL udpdstport0_2reg : std_logic_vector(7 DOWNTO 0);

  SIGNAL udpsrcport1_1reg : std_logic_vector(7 DOWNTO 0);
  SIGNAL udpsrcport1_2reg : std_logic_vector(7 DOWNTO 0);
  SIGNAL udpdstport1_1reg : std_logic_vector(7 DOWNTO 0);
  SIGNAL udpdstport1_2reg : std_logic_vector(7 DOWNTO 0);

  SIGNAL udpsrcport2_1reg : std_logic_vector(7 DOWNTO 0);
  SIGNAL udpsrcport2_2reg : std_logic_vector(7 DOWNTO 0);
  SIGNAL udpdstport2_1reg : std_logic_vector(7 DOWNTO 0);
  SIGNAL udpdstport2_2reg : std_logic_vector(7 DOWNTO 0);

  SIGNAL udpsrcport3_1reg : std_logic_vector(7 DOWNTO 0);
  SIGNAL udpsrcport3_2reg : std_logic_vector(7 DOWNTO 0);
  SIGNAL udpdstport3_1reg : std_logic_vector(7 DOWNTO 0);
  SIGNAL udpdstport3_2reg : std_logic_vector(7 DOWNTO 0);
  --
  SIGNAL replypingregdelay  : std_logic;
  SIGNAL pingpulse1         : std_logic;
  SIGNAL pingpulse2         : std_logic;
  SIGNAL pingpulse3         : std_logic;
  SIGNAL pingpulse4         : std_logic;
  SIGNAL pinglencount       : unsigned(15 DOWNTO 0);
  --
  SIGNAL replyarpregdelay  : std_logic;
  SIGNAL arppulse1         : std_logic;
  SIGNAL arppulse2         : std_logic;
  SIGNAL arppulse3         : std_logic;
  SIGNAL arppulse4         : std_logic;
  SIGNAL arplencount       : unsigned(15 DOWNTO 0);


  
BEGIN

  inreg_proc: PROCESS (rxclk)
  BEGIN  -- PROCESS inreg_proc
    IF rxclk'event AND rxclk = '1' THEN
      IF rxreset = '1' THEN
        gmii_rxd_reg     <= (OTHERS => '0');
        gmii_rx_dv_reg   <= '0';
        gmii_rx_er_reg   <= '0';
      ELSIF rxclk_en = '1' then
        gmii_rxd_reg     <= gmii_rxd;
        gmii_rx_dv_reg   <= gmii_rx_dv;
        gmii_rx_er_reg   <= gmii_rx_er;
      END IF;
    END IF;
  END PROCESS inreg_proc;

  fsm_proc: PROCESS (rxclk)
  BEGIN  
    IF rxclk'event AND rxclk = '1' THEN
      IF rxreset = '1' THEN
        current_state <= idle;
        rxaddrvalidreg <= '0';
        replypingreg   <= '0';
        --
        hostmacaddr1reg <= (OTHERS => '0');
        hostmacaddr2reg <= (OTHERS => '0');
        hostmacaddr3reg <= (OTHERS => '0');
        hostmacaddr4reg <= (OTHERS => '0');
        hostmacaddr5reg <= (OTHERS => '0');
        hostmacaddr6reg <= (OTHERS => '0');
        --
        hostipaddr1reg  <= (OTHERS => '0');
        hostipaddr2reg  <= (OTHERS => '0');
        hostipaddr3reg  <= (OTHERS => '0');
        hostipaddr4reg  <= (OTHERS => '0');
        --
        fcs             <= (OTHERS => '1');
        --
        iplen1reg       <= (OTHERS => '0');
        iplen2reg       <= (OTHERS => '0');
        --
        udplen1reg      <= (OTHERS => '0');
        udplen2reg      <= (OTHERS => '0'); 
        --      
        udplencount     <= (OTHERS => '0');
        pinglencount    <= (OTHERS => '0');
        arplencount     <= (OTHERS => '0');
        --
        pingaddr        <= (OTHERS => '0');
        pingwren        <= '0';
        --
        RxData          <= (OTHERS => '0');
        RxDataValid     <= '0';
        RxEOP           <= '0';
        RxCRCOK         <= '0';
        RxCRCBad        <= '0';
      ELSIF rxclk_en = '1' then
        IF gmii_rx_er_reg = '1' THEN      --priority: error goes to flush
          current_state <= flush_packet;
          replypingreg <= '0';
          pingwren <= '0';
          pingaddr <= (OTHERS => '0');
        ELSE
          CASE current_state IS
            WHEN flush_packet =>
              replypingreg <= '0';
              pingwren <= '0';
              pingaddr <= (OTHERS => '0');
              RxEOP    <= '1';
              RxCRCBad <= '1';
              fcs      <= (OTHERS => '1');
              IF gmii_rx_dv_reg = '1' THEN   --otherwise must be low to leave flush
                current_state <= flush_packet;
              ELSE
                current_state <= idle;
              END IF;
              -----------------------------------------------------------------
            WHEN idle =>
              RxDataValid <= '0';
              RxEOP   <= '0';
              RxCRCOK <= '0';
              RxCRCBad <= '0';
              fcs <= (OTHERS => '1');
              replypingreg <= '0';
              replyarpreg  <= '0';
              pingwren <= '0';
              pingaddr <= (OTHERS => '0');
              IF gmii_rx_dv_reg = '1' AND gmii_rxd_reg = PREAMBLE1VALUE THEN
                current_state <= preamble;
              ELSIF gmii_rx_dv_reg = '1' AND gmii_rxd_reg = PREAMBLE2VALUE THEN
                current_state <= dstmac1;
              ELSIF gmii_rx_dv_reg = '1' THEN
                current_state <= flush_packet; --Didn't start in preamble
              END IF;
              -------------------------------------------------------------------
            WHEN preamble =>
              replypingreg <= '0';      
              replyarpreg  <= '0';
              IF gmii_rxd_reg = PREAMBLE1VALUE THEN
                current_state <= preamble;
              ELSIF gmii_rxd_reg = PREAMBLE2VALUE THEN
                current_state <= dstmac1;
                fcs <= (OTHERS => '1');   --initialize CRC to all 1's
              ELSE
                current_state <= flush_packet;
              END IF;
              -------------------------------------------------------------------
            WHEN dstmac1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"FF" THEN --broadcast
                current_state <= dstmacbroadcast2;
              ELSIF gmii_rxd_reg = MYMACADDR1 THEN
                current_state <= dstmac2;
              ELSE
                current_state <= flush_packet;
              END IF;

            WHEN dstmac2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYMACADDR2 THEN
                current_state <= dstmac3;
              ELSE
                current_state <= flush_packet;
              END IF;

            WHEN dstmac3 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYMACADDR3 THEN
                current_state <= dstmac4;
              ELSE
                current_state <= flush_packet;
              END IF;

            WHEN dstmac4 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYMACADDR4 THEN
                current_state <= dstmac5;
              ELSE
                current_state <= flush_packet;
              END IF;

            WHEN dstmac5 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYMACADDR5 THEN
                current_state <= dstmac6;
              ELSE
                current_state <= flush_packet;
              END IF;

            WHEN dstmac6 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYMACADDR6 THEN
                current_state <= srcmac1;
              ELSE
                current_state <= flush_packet;
              END IF;

              -------------------------------------------------------------------
              -- Begin Broadcast Destination MAC address
              -------------------------------------------------------------------
              
            WHEN dstmacbroadcast2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"FF" THEN
                current_state <= dstmacbroadcast3;
              ELSE
                current_state <= flush_packet;
              END IF;

            WHEN dstmacbroadcast3 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"FF" THEN
                current_state <= dstmacbroadcast4;
              ELSE
                current_state <= flush_packet;
              END IF;

            WHEN dstmacbroadcast4 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"FF" THEN
                current_state <= dstmacbroadcast5;
              ELSE
                current_state <= flush_packet;
              END IF;

            WHEN dstmacbroadcast5 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"FF" THEN
                current_state <= dstmacbroadcast6;
              ELSE
                current_state <= flush_packet;
              END IF;

            WHEN dstmacbroadcast6 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"FF" THEN
                current_state <= srcmac1;
              ELSE
                current_state <= flush_packet;
              END IF;

              -------------------------------------------------------------------
            WHEN srcmac1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostmacaddr1reg <= gmii_rxd_reg;
              END IF;
              current_state <= srcmac2;
              
            WHEN srcmac2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostmacaddr2reg <= gmii_rxd_reg;
              END IF;
              current_state <= srcmac3;
              
            WHEN srcmac3 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostmacaddr3reg <= gmii_rxd_reg;
              END IF;
              current_state <= srcmac4;
              
            WHEN srcmac4 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostmacaddr4reg <= gmii_rxd_reg;
              END IF;
              current_state <= srcmac5;
              
            WHEN srcmac5 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostmacaddr5reg <= gmii_rxd_reg;
              END IF;
              current_state <= srcmac6;
              
            WHEN srcmac6 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostmacaddr6reg <= gmii_rxd_reg;
              END IF;
              current_state <= ethertype1;

              -------------------------------------------------------------------
              -- Ping packets are written starting here at ethertype
              -------------------------------------------------------------------
            WHEN ethertype1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = ETHERTYPE1VALUE THEN
                current_state <= ethertype2;
              ELSE
                current_state <= flush_packet;
              END IF;

            WHEN ethertype2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = ETHERTYPE2VALUE THEN
                current_state <= iphdr1;
                pingwren <= '1';
              ELSIF gmii_rxd_reg = ETHERTYPE2ARPVALUE THEN
                current_state <= arp_htype1;
              ELSE
                current_state <= flush_packet;
              END IF;

            WHEN iphdr1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= iphdr2;
              pingaddr <= pingaddr + 1;
            WHEN iphdr2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= iptotal_len1;
              pingaddr <= pingaddr + 1;
            WHEN iptotal_len1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= iptotal_len2;
              iplen1reg <= gmii_rxd_reg;
              pingaddr <= pingaddr + 1;
            WHEN iptotal_len2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= ipid1;
              iplen2reg <= gmii_rxd_reg;
              pingaddr <= pingaddr + 1;
            WHEN ipid1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= ipid2;
              pingaddr <= pingaddr + 1;
            WHEN ipid2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= iphdr3;
              pingaddr <= pingaddr + 1;
            WHEN iphdr3 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= iphdr4;
              pingaddr <= pingaddr + 1;
            WHEN iphdr4 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= ipttl;
              pingaddr <= pingaddr + 1;
            WHEN ipttl =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= ipprotocol;
              pingaddr <= pingaddr + 1;
            WHEN ipprotocol =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = IPPROTOCOLUDPVALUE THEN
                current_state <= iphdrchecksum1;
                pingwren <= '0';
                pingaddr <= (OTHERS => '0');
              ELSIF gmii_rxd_reg = IPPROTOCOLICMPVALUE THEN
                current_state <= pinghdrchecksum1;    --see branch point for ICMP echo (ping)
                pingwren <= '1';
                pingaddr <= pingaddr + 1;
              ELSE
                current_state <= flush_packet;                
              END IF;

              -------------------------------------------------------------------
              -- Branch here for ICMP echo (ping) handling
              -------------------------------------------------------------------
            WHEN pinghdrchecksum1 => 
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pinghdrchecksum2;
              pingaddr <= pingaddr + 1;

            WHEN pinghdrchecksum2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pingsrcip1;
              pingaddr <= pingaddr + 1;

            WHEN pingsrcip1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pingsrcip2;
              pingaddr <= pingaddr + 1;
              IF rxaddrvalidreg = '0' THEN
                hostipaddr1reg <= gmii_rxd_reg;
              END IF;            

            WHEN pingsrcip2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pingsrcip3;
              pingaddr <= pingaddr + 1;
              IF rxaddrvalidreg = '0' THEN
                hostipaddr2reg <= gmii_rxd_reg;
              END IF;            

            WHEN pingsrcip3 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pingsrcip4;
              pingaddr <= pingaddr + 1;
              IF rxaddrvalidreg = '0' THEN
                hostipaddr3reg <= gmii_rxd_reg;
              END IF;            

            WHEN pingsrcip4 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pingdstip1;
              pingaddr <= pingaddr + 1;
              IF rxaddrvalidreg = '0' THEN
                hostipaddr4reg <= gmii_rxd_reg;
              END IF;            

            WHEN pingdstip1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYIPADDR1 THEN
                current_state <= pingdstip2;
                pingaddr <= pingaddr + 1;
              ELSE
                current_state <= flush_packet;
              END IF;            

            WHEN pingdstip2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYIPADDR2 THEN
                current_state <= pingdstip3;
                pingaddr <= pingaddr + 1;
              ELSE
                current_state <= flush_packet;
              END IF;            

            WHEN pingdstip3 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYIPADDR3 THEN
                current_state <= pingdstip4;
                pingaddr <= pingaddr + 1;
              ELSE
                current_state <= flush_packet;
              END IF;            

            WHEN pingdstip4 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYIPADDR4 THEN
                current_state <= pingicmptype;
                rxaddrvalidreg <= '1';     --Done with assignment
                pingaddr <= pingaddr + 1;
              ELSE
                current_state <= flush_packet;
              END IF;            

            WHEN pingicmptype =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = ICMPPINGTYPEVALUE THEN
                current_state <= pingicmpcode;
                pingaddr <= pingaddr + 1;
              ELSE
                current_state <= flush_packet;
              END IF;

            WHEN pingicmpcode =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pingicmpchecksum1;
              pingaddr <= pingaddr + 1;

            WHEN pingicmpchecksum1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pingicmpchecksum2;
              pingaddr <= pingaddr + 1;

            WHEN pingicmpchecksum2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pingicmpid1;
              pingaddr <= pingaddr + 1;

            WHEN pingicmpid1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pingicmpid2;
              pingaddr <= pingaddr + 1;
            WHEN pingicmpid2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pingicmpseq1;
              pingaddr <= pingaddr + 1;
            WHEN pingicmpseq1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pingicmpseq2;
              pingaddr <= pingaddr + 1;
            WHEN pingicmpseq2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= pingdata;
              pingaddr      <= pingaddr + 1;
              pinglencount  <= (OTHERS => '0');

            WHEN pingdata =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              -- count to see if we have reached IP packet total length
              pingaddr <= pingaddr + 1;
              IF unsigned((iplen1reg & iplen2reg)) - pinglencount = 29 THEN
                current_state <= pingfcs1;
                pinglencount  <= (OTHERS => '0');
                pingwren <= '0';
                pingaddr <= (OTHERS => '0');
              ELSE
                pinglencount  <= pinglencount + 1;                
                current_state <= pingdata;
              END IF;
              
              -- Assert replyping for 4 cycles to guarantee synchronization
            WHEN pingfcs1 =>
              pingwren <= '0';            -- make sure it is off
              IF gmii_rxd_reg = fcs_check_value(31 DOWNTO 24) THEN
                current_state <= pingfcs2;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN pingfcs2 =>
              IF gmii_rxd_reg = fcs_check_value(23 DOWNTO 16) THEN
                current_state <= pingfcs3;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN pingfcs3 =>
              IF gmii_rxd_reg = fcs_check_value(15 DOWNTO 8) THEN
                current_state <= pingfcs4;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN pingfcs4 =>
              current_state <= idle;
              IF gmii_rxd_reg = fcs_check_value(7 DOWNTO 0) THEN
                replypingreg <= '1';        
              END IF;

              -------------------------------------------------------------------
              -- Continue here for regular (non-ping) handling
              -------------------------------------------------------------------
            WHEN iphdrchecksum1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= iphdrchecksum2;

            WHEN iphdrchecksum2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= srcip1;
              
            WHEN srcip1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= srcip2;            
              IF rxaddrvalidreg = '0' THEN
                hostipaddr1reg <= gmii_rxd_reg;
              END IF;

            WHEN srcip2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= srcip3;            
              IF rxaddrvalidreg = '0' THEN
                hostipaddr2reg <= gmii_rxd_reg;
              END IF;

            WHEN srcip3 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= srcip4;            
              IF rxaddrvalidreg = '0' THEN
                hostipaddr3reg <= gmii_rxd_reg;
              END IF;

            WHEN srcip4 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= dstip1;            
              IF rxaddrvalidreg = '0' THEN
                hostipaddr4reg <= gmii_rxd_reg;
                rxaddrvalidreg <= '1';     --Done with assignment
              END IF;

            WHEN dstip1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYIPADDR1 THEN
                current_state <= dstip2;
              ELSE
                current_state <= flush_packet;
              END IF;            

            WHEN dstip2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYIPADDR2 THEN
                current_state <= dstip3;
              ELSE
                current_state <= flush_packet;
              END IF;            

            WHEN dstip3 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYIPADDR3 THEN
                current_state <= dstip4;
              ELSE
                current_state <= flush_packet;
              END IF;            

            WHEN dstip4 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYIPADDR4 THEN
                current_state <= udpsrc1;
              ELSE
                current_state <= flush_packet;
              END IF;            

            WHEN udpsrc1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              RxData <= gmii_rxd_reg;
              RxDataValid <= '1';
              current_state <= udpsrc2;

            WHEN udpsrc2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              RxData <= gmii_rxd_reg;
              RxDataValid <= '1';
              current_state <= udpdst1;

            WHEN udpdst1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              RxData <= gmii_rxd_reg;
              RxDataValid <= '1';
              current_state <= udpdst2;

            WHEN udpdst2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              RxData <= gmii_rxd_reg;
              RxDataValid <= '1';
              current_state <= udplen1;

            WHEN udplen1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              RxDataValid <= '0';
              current_state <= udplen2;
              udplen1reg <= gmii_rxd_reg;

            WHEN udplen2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= udpchecksum1;
              udplen2reg <= gmii_rxd_reg;

            WHEN udpchecksum1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= udpchecksum2;

            WHEN udpchecksum2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= udpdata;
              udplencount <= (OTHERS => '0');
            WHEN udpdata =>
              --Send data to RAM
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              RxData <= gmii_rxd_reg;
              RxDataValid <= '1';
              IF unsigned((udplen1reg & udplen2reg)) - udplencount = 9 THEN
                RxEOP <= '1';
                IF unsigned(iplen1reg) = 0 AND unsigned(iplen2reg) < 46 THEN -- 64-byte packet
                  udplencount   <= to_unsigned(46, 16) - unsigned(iplen1reg & iplen2reg);
                  current_state <= ippadding;
                ELSE
                  current_state <= ipfcs1;
                END IF;
              ELSE
                RxEOP <= '0';
                udplencount   <= udplencount + 1;                
                current_state <= udpdata;
              END IF;
              
              -----------------------------------------------------------------
              -- Padding 
              -----------------------------------------------------------------
            WHEN ippadding =>
              RxDataValid <= '0';
              RxEOP <= '0';
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF udplencount = 1 THEN
                current_state <= ipfcs1;
                udplencount   <= (others => '0');
              ELSE
                udplencount   <= udplencount - 1;
                current_state <= ippadding;
              END IF;
                

              -------------------------------------------------------------------
              -- Handle CRC testing
              -------------------------------------------------------------------
            WHEN ipfcs1 =>
              RxDataValid <= '0';
              RxEOP <= '0';
              IF gmii_rxd_reg = fcs_check_value(31 DOWNTO 24) THEN
                current_state <= ipfcs2;
              ELSE
                RxCRCBad <= '1';
                current_state <= flush_packet;
              END IF;

            WHEN ipfcs2 =>
              IF gmii_rxd_reg = fcs_check_value(23 DOWNTO 16) THEN
                current_state <= ipfcs3;            
              ELSE
                RxCRCBad <= '1';
                current_state <= flush_packet;
              END IF;

            WHEN ipfcs3 =>
              IF gmii_rxd_reg = fcs_check_value(15 DOWNTO 8) THEN
                current_state <= ipfcs4;            
              ELSE
                RxCRCBad <= '1';
                current_state <= flush_packet;
              END IF;

            WHEN ipfcs4 =>
              IF gmii_rxd_reg = fcs_check_value(7 DOWNTO 0) THEN
                current_state <= idle;
                RxCRCOK <= '1';
              ELSE
                RxCRCBad <= '1';
                current_state <= flush_packet;
              END IF;

              -----------------------------------------------------------------
              -- ARP States
              -----------------------------------------------------------------
            WHEN arp_htype1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"00" THEN
                current_state <= arp_htype2;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arp_htype2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"01" THEN
                current_state <= arp_ptype1;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arp_ptype1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"08" THEN
                current_state <= arp_ptype2;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arp_ptype2 =>              
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"00" THEN
                current_state <= arp_hlen;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arp_hlen =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"06" THEN
                current_state <= arp_plen;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arp_plen =>              
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"04" THEN
                current_state <= arp_oper1;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arp_oper1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"00" THEN
                current_state <= arp_oper2;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arp_oper2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = X"01" THEN
                current_state <= arp_sha1;
              ELSE
                current_state <= flush_packet;
              END IF;
              --
            WHEN arp_sha1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostmacaddr1reg <= gmii_rxd_reg;
              END IF;
              current_state <= arp_sha2;
            WHEN arp_sha2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostmacaddr2reg <= gmii_rxd_reg;
              END IF;
              current_state <= arp_sha3;
            WHEN arp_sha3 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostmacaddr3reg <= gmii_rxd_reg;
              END IF;
              current_state <= arp_sha4;
            WHEN arp_sha4 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostmacaddr4reg <= gmii_rxd_reg;
              END IF;
              current_state <= arp_sha5;
            WHEN arp_sha5 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostmacaddr5reg <= gmii_rxd_reg;
              END IF;
              current_state <= arp_sha6;
            WHEN arp_sha6 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostmacaddr6reg <= gmii_rxd_reg;
              END IF;
              current_state <= arp_spa1;
              --
            WHEN arp_spa1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostipaddr1reg <= gmii_rxd_reg;
              END IF;
              current_state <= arp_spa2;
            WHEN arp_spa2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostipaddr2reg <= gmii_rxd_reg;
              END IF;
              current_state <= arp_spa3;
            WHEN arp_spa3 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostipaddr3reg <= gmii_rxd_reg;
              END IF;
              current_state <= arp_spa4;
            WHEN arp_spa4 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF rxaddrvalidreg = '0' THEN
                hostipaddr4reg <= gmii_rxd_reg;
              END IF;
              current_state <= arp_tha1;
              -- Target Hardware Address is ignored
            WHEN arp_tha1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= arp_tha2;
            WHEN arp_tha2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= arp_tha3;
            WHEN arp_tha3 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= arp_tha4;
            WHEN arp_tha4 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= arp_tha5;
            WHEN arp_tha5 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= arp_tha6;
            WHEN arp_tha6 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              current_state <= arp_tpa1;
              --
            WHEN arp_tpa1 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYIPADDR1 THEN
                current_state <= arp_tpa2;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arp_tpa2 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYIPADDR2 THEN
                current_state <= arp_tpa3;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arp_tpa3 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYIPADDR3 THEN
                current_state <= arp_tpa4;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arp_tpa4 =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF gmii_rxd_reg = MYIPADDR4 THEN
                current_state <= arppadding;
                arplencount <= to_unsigned(18, arplencount'LENGTH);
              ELSE
                current_state <= flush_packet;
              END IF;
              --
            WHEN arppadding =>
              fcs <= compute_fcs(fcs, gmii_rxd_reg);
              IF arplencount = 1 THEN
                current_state <= arpfcs1;
                arplencount   <= (others => '0');
              ELSE
                arplencount   <= arplencount - 1;
                current_state <= arppadding;
              END IF;
              --
            WHEN arpfcs1 =>
              pingwren <= '0';            -- make sure it is off
              IF gmii_rxd_reg = fcs_check_value(31 DOWNTO 24) THEN
                current_state <= arpfcs2;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arpfcs2 =>
              IF gmii_rxd_reg = fcs_check_value(23 DOWNTO 16) THEN
                current_state <= arpfcs3;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arpfcs3 =>
              IF gmii_rxd_reg = fcs_check_value(15 DOWNTO 8) THEN
                current_state <= arpfcs4;
              ELSE
                current_state <= flush_packet;
              END IF;
            WHEN arpfcs4 =>
              current_state <= idle;
              IF gmii_rxd_reg = fcs_check_value(7 DOWNTO 0) THEN
                replyarpreg <= '1';        
                rxaddrvalidreg <= '1';
              END IF;
            WHEN OTHERS => NULL;
          END CASE;
        END IF;
      END IF;
    END IF;
  END PROCESS fsm_proc;

  fcs_check_value <= NOT fcs;

  hostmacaddr1 <= hostmacaddr1reg;
  hostmacaddr2 <= hostmacaddr2reg;
  hostmacaddr3 <= hostmacaddr3reg;
  hostmacaddr4 <= hostmacaddr4reg;
  hostmacaddr5 <= hostmacaddr5reg;
  hostmacaddr6 <= hostmacaddr6reg;

  hostipaddr1  <= hostipaddr1reg;
  hostipaddr2  <= hostipaddr2reg;
  hostipaddr3  <= hostipaddr3reg;
  hostipaddr4  <= hostipaddr4reg;

  pingwraddr   <= std_logic_vector(pingaddr);
  pingwrdata   <= gmii_rxd_reg;

  rxaddrvalid  <= rxaddrvalidreg;

  replyping_proc: PROCESS (rxclk)
  BEGIN 
    IF rxclk'event AND rxclk = '1' THEN  -- rising clock edge
      IF rxreset = '1' THEN               -- synchronous reset (active high)
        replypingregdelay <= '0';
        pingpulse1 <= '0';
        pingpulse2 <= '0';
        pingpulse3 <= '0';
        pingpulse4 <= '0';
        replyping  <= '0';
        --
        replyarpregdelay <= '0';
        arppulse1 <= '0';
        arppulse2 <= '0';
        arppulse3 <= '0';
        arppulse4 <= '0';
        replyarp  <= '0';
      ELSIF rxclk_en = '1' then
        replypingregdelay <= replypingreg;           --delay
        pingpulse1 <= NOT replypingregdelay AND replypingreg; --rising edge detect
        pingpulse2 <= pingpulse1;
        pingpulse3 <= pingpulse2;
        pingpulse4 <= pingpulse3;
        replyping  <= pingpulse1 OR pingpulse2 OR pingpulse3 OR pingpulse4;
        --
        replyarpregdelay <= replyarpreg;           --delay
        arppulse1 <= NOT replyarpregdelay AND replyarpreg; --rising edge detect
        arppulse2 <= arppulse1;
        arppulse3 <= arppulse2;
        arppulse4 <= arppulse3;
        replyarp  <= arppulse1 OR arppulse2 OR arppulse3 OR arppulse4;
      END IF;
    END IF;
  END PROCESS replyping_proc;

END rtl;
