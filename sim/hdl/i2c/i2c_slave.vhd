------------------------------------------------------------------------------------------------------------------
--
-- Projekt         I2C SLAVE
--
-- Compiler        ALTERA ModelSim 5.8e
--                 Quartus II 5.0
--
-- Autor           FPGA-USER
--
-- Datum           26/08/2005
--
-- Sprache         VHDL 93
--
-- Info            *** I2C-Slave-Funktion ***
--
--                 1. )Eigenschaften:
--                     - frei waehlbare Slave-Adresse
--                     - schreib- und lesbar
--                     - Sniffer-Mode (nur Bytes lesen, kein Acknowledge
--
--                 2.)  Bedeutung der Signale:
--
--                 clk           : Systemtakt, sollte ausreichend groesser als I2C-Freq sein
--                 Reset_n         : Hi-aktiv, asynchroner Reset
--                 
--                 scl           : I2C-Clock, nur Eingang
--                 sda           : I2C-Daten, wird fuer Acknowledge und Datentransfer bidirektional benutzt
--                 slv_adr       : Slave-Adresse, frei konfigurierbar, 0 ... 127
--                               : kann auch im laufenden Betrieb geaendert werden
--
--                 sniffer_on    : FALSE : normaler Slave-Betrieb
--                                 TRUE  : nur Daten mitlesen, kein Acknowledge
--                 
--                 tx_data       : Datenbytes, die zum Master gesendet werden sollen
--                 tx_wr         : Write-Strobe, damit wird ein Byte eingeschrieben,
--                                 wenn tx_empty aktiv ist                                 
--                 tx_empty      : aktiv, wenn der TX-buffer leer ist
--                 
--                 rx_data       : Datenbytes, die vom Master empfangen wurden
--                 rx_vld        : aktiv, wenn gueltiges Byte im RX-Buffer
--                 rx_ack        : Signal sollte gesetzt werden, wenn ein Byte aus dem
--                                 RX-Buffer gelesen wurde, damit wird rx_vld inaktiv
--                                 und der RX-Buffer ist wieder frei
--                 
--                 busy          : wird gesetzt, wenn der Slave einen Transfer beginnt,
--                                 am Ende des Transfers entsprechend zurueckgesetzt
--                 
--                 error         : Statusinfo ueber aufgetretene Fehler, gueltig am Ende des Transfers(!)
--                 
--                 rx_pointer_q  : zeigt an, wieviele Bytes im RX-Pointer zum Auslesen bereitstehen
--                 
--                 rd_n_wr_q     : zeigt die Richtung des letzten Transfers an
--                 
--                 3.)  Das Einlesen von SDA kann (1 .. 16)+3 Clocks vor dem Erkennen der fallenden Flanke von     
--                      SCL erfolgen und wird mit SDA_DELAY eingestellt
--                 
--                 
-- Historie         
------------------------------------------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
use work.i2c_syn_pkg.all;

entity i2c_slave is
   
   generic (SDA_DELAY : integer range 1 to 16 := 5);
				
   port
   (
      clk            : in std_logic;
      Reset_n          : in std_logic;

      -- I2C Takt und Daten (SDA ist open Drain)
      scl            : in std_logic;
      sda            : inout std_logic;

      -- I2C Slave-Adresse, 7 Bit
      slv_adr        : in SLV_ADR_TYPE;
      sniffer_on     : in boolean;

      -- TX-Buffer-Signale 
      tx_data        : in BYTE;
      tx_wr          : in std_logic;
      tx_empty       : out std_logic;

      -- RX-Buffer-Signale
      rx_data        : out BYTE;
      rx_vld         : buffer std_logic;
      rx_ack         : in std_logic;

      -- Slave-Status
      dbg_stat       : out unsigned(7 downto 0);
      busy           : out std_logic;
      error          : out I2C_SLV_ERROR_TYPE
   );
end;

architecture behave of i2c_slave is

   signal rx_buf_ena_q    : std_logic;
   signal sda_q           : std_logic;

   signal rx_shiftreg_q   : BYTE;
   signal tx_shiftreg_q   : BYTE;
   signal wr_buf_q        : BYTE;

   -- Event-Signale
   signal sda_1_q         : std_logic;
   signal sda_2_q         : std_logic;
   signal scl_1_q         : std_logic;
   signal scl_2_q         : std_logic;
   signal start_cnd_q     : boolean;
   signal stop_cnd_q      : boolean;
   signal scl_f_q         : boolean;
   signal sda_del_in      : std_logic_vector(0 downto 0);
   signal sda_del_in_q    : std_logic;
   signal sda_in_q        : std_logic_vector(0 downto 0);

   type TRANSFER_TYPE is (READ, WRITE);
--   signal transfer_q : TRANSFER_TYPE; -- derzeit nicht benutzt

   signal tx_empty_q : std_logic;
   signal busy_q     : boolean;
   signal error_q    : I2C_SLV_ERROR_TYPE;
   
begin

   -- SDA ist Open Drain
   sda <= 'Z' when sda_q='1' else '0';

   ------------------------------------------------------------------------------
   -- Verzoegerung von SDA um eine feste Anzahl Clocks,
   -- damit SDA gelesen wird, waehrend SCL High ist
   -- -> kann durch FPGA-spezifische Elemente (SRG_16...) optimiert werden
   ------------------------------------------------------------------------------
   DELAY_SDA : block
      signal delay_line : std_logic_vector(SDA_DELAY-1 downto 0);
   begin
      process(Reset_n, clk)
      begin
         if Reset_n='0' then
            delay_line    <= (others=>'0');

         elsif rising_edge(clk) then

            delay_line <= delay_line(SDA_DELAY-2 downto 0) & sda_2_q; -- Links schieben
         end if;
      end process;

      sda_del_in_q <= delay_line(delay_line'HIGH); -- MSB = Ausgang
   end block;



	-----------------------------------------------------
	-- SDA und SCL einclocken,
	-- Events Start, Stop, Falling_Edge_Scl
	-----------------------------------------------------
   process(Reset_n, clk)
      variable sda_rising  : boolean;
      variable sda_falling : boolean;
      function my_to_X01(oc : std_logic) return std_logic is
      begin
          if oc = '0' then
             return '0';
          else
             return '1';
          end if;
      end function;
   begin
      if Reset_n='0' then
         scl_1_q     <= '1';
         scl_2_q     <= '1';
         sda_1_q     <= '1';
         sda_2_q     <= '1';
         start_cnd_q <= false;
         stop_cnd_q  <= false;
         scl_f_q     <= false;

      elsif rising_edge(clk) then
         -- SDA und SCL jeweils in 2 aufeinanderfolgende FFs einschieben
         scl_1_q <= my_to_X01(scl);
         scl_2_q <= scl_1_q;
         sda_1_q <= my_to_X01(sda);
         sda_2_q <= sda_1_q;

         sda_rising  := sda_1_q='1' and sda_2_q='0';
         sda_falling := sda_1_q='0' and sda_2_q='1';

         -- Start Condition
         start_cnd_q <= sda_falling and scl_1_q='1';

         -- Stop Condition
         stop_cnd_q  <= sda_rising  and scl_1_q='1';

         -- Falling Edge SCL
         scl_f_q     <= scl_1_q='0' and scl_2_q ='1';
      end if;
   end process;

	
	-- Statemachine I2C-Slave
   states : block
      type STATE_TYPE is (IDLE,
                          WT_SCL_LO,
                          RD_SLV_ADR,
                          CHECK_STS_FOR_ACK,
                          CHECK_ACK,
                          BRANCH,
                          MSTR_WR,
                          MSTR_RD,
                          WR_ACK,
                          CHECK_STOP);
                          
      signal state_q          : STATE_TYPE;
      signal bit_cnt_q        : integer range 0 to 8;
      signal slv_ack_q        : std_logic;
      signal ld_tx_2_q        : boolean;
      signal ld_tx_3_q        : boolean;
      signal ld_tx_shiftreg_q : boolean;
   begin
      process(Reset_n, clk)
         variable ld_bit_cnt     : boolean;
      begin
         if Reset_n='0' then
            state_q          <= IDLE;
            error_q          <= NO_ERROR;
            --transfer_q       <= READ;
            rx_shiftreg_q    <= (others=>'0');
            tx_shiftreg_q    <= (others=>'0');
            rx_data          <= (others=>'0');
            wr_buf_q         <= (others=>'0');
            ld_tx_shiftreg_q <= false;
            ld_tx_2_q        <= false;
            ld_tx_3_q        <= false;
            busy_q           <= false;
            tx_empty_q       <= '1';
            sda_q            <= '1';
            slv_ack_q        <= '1';
            rx_buf_ena_q     <= '0';
            rx_vld           <= '0';
            bit_cnt_q        <= 0;
				
         elsif rising_edge(clk) then
         
            -- Defaults fuer Variablen
            ld_bit_cnt := false;

            case state_q is

               when IDLE =>
                  busy_q    <= false;
                  slv_ack_q <= '1'; -- Default
                  if stop_cnd_q then
                     state_q <= IDLE;
                  elsif start_cnd_q then
                     busy_q  <= true;
                     state_q <= WT_SCL_LO;
                  end if;

               when WT_SCL_LO =>
                  if stop_cnd_q then
                     state_q <= IDLE;
                  elsif start_cnd_q then 
                     state_q <= WT_SCL_LO;
                  elsif scl_f_q then -- SCL geht Lo
                     if sniffer_on then -- SNIFFER Mode ??
                        state_q <= MSTR_WR;
                     else
                        state_q <= RD_SLV_ADR;
                     end if;
                     ld_bit_cnt := true;
                  end if;

               when RD_SLV_ADR =>
                  if stop_cnd_q then
                     state_q <= IDLE;
                  elsif start_cnd_q then
                     state_q <= WT_SCL_LO;
                  elsif bit_cnt_q = 0 then
                     -- Pruefen, ob Slave-Adresse stimmt
                     if slv_adr = to_integer(unsigned(rx_shiftreg_q(7 downto 1))) then
                        state_q <= CHECK_STS_FOR_ACK;
                        -- If rx_shiftreg_q(0)='1' THEN tx_empty_q <= '1'; END IF; --fho: only assert tx_empty at read cycle
                        --fho: use tx_empty to request for data to write into TX_data. Acknowledge with tx_wr
                     else
                        -- Zurueck, falls andere Adresse 
                        state_q <= IDLE;
                     end if;
                  end if;
						
               when CHECK_STS_FOR_ACK =>
                  -- Pruefen, ob die benötigten Buffer frei sind
                  -- beim Schreiben Master -> Slave : RX-Buffer
                  -- beim Lesen Master <- Slave     : TX-Buffer
                  if stop_cnd_q then
                     state_q <= IDLE;
                  elsif start_cnd_q then
                     state_q <= WT_SCL_LO;
                  elsif (rx_shiftreg_q(0)='1' and tx_empty_q = '1') or   -- Master Read
                     (rx_shiftreg_q(0)='0' and rx_vld='1') then -- Master Write
                     state_q <= IDLE; -- Buffer fuer den Transfer nicht frei
                                -- oder keine TX-Daten vorhanden
                  else
                     slv_ack_q <= '0'; -- Acknowledge senden
                     state_q <= BRANCH;
                  end if; 

               when BRANCH =>
                  -- Verzweigen je nach Transfer Master Read oder Write
                  if stop_cnd_q then
                     state_q <= IDLE;
                     slv_ack_q <= '1';
                  elsif start_cnd_q then
                     state_q <= WT_SCL_LO;
                     slv_ack_q <= '1';
                  elsif scl_f_q then
                     slv_ack_q <= '1';
                     if rx_shiftreg_q(0) = '0' then -- Master Write
                        --transfer_q <= WRITE;
                        state_q    <= MSTR_WR;
                        ld_bit_cnt := true;
                     else                  
                        state_q     <= MSTR_RD;  -- Master Read 
                        --transfer_q  <= READ;
                        ld_bit_cnt  := true;
                        ld_tx_shiftreg_q <= true;
                     end if;
                  end if;

               when MSTR_WR =>
                  if stop_cnd_q then
                     state_q    <= IDLE;
                     error_q    <= NO_ERROR; -- normaler Abbruch Wr-Transfer durch Stop-Cond
                  elsif start_cnd_q then
                     state_q    <= WT_SCL_LO;
                  elsif bit_cnt_q = 0 then

                     if rx_vld ='1' then -- letztes Byte nicht abgeholt
                        state_q      <= IDLE;
                        error_q      <= RX_OVFLW; -- Fehlercode ausgeben
                     else
                        rx_buf_ena_q <= '1';
                        state_q      <= WR_ACK;
                        if sniffer_on then
                           slv_ack_q    <= '1';
                        else
                           slv_ack_q    <= '0';
                        end if;
                        
                     end if;
                  end if;

               when MSTR_RD =>
                  ld_tx_shiftreg_q <= false;
                  if tx_empty_q = '1' then 
                     error_q <= TX_UNFLW;
                  else
                     error_q <= NO_ERROR;
                  end if;

                  if stop_cnd_q then
                     state_q <= IDLE;
                  elsif start_cnd_q then
                     state_q <= WT_SCL_LO;
                  elsif bit_cnt_q = 0 then
                     state_q <= CHECK_ACK;
                  end if;
						
               when CHECK_ACK =>
                  if stop_cnd_q then
                     state_q <= IDLE;
                     -- Error-Code einfuegen
                  elsif start_cnd_q then
                     state_q <= WT_SCL_LO;
                  elsif scl_f_q then
                     if sda_del_in_q = '0' then -- Ack vom Master
                        state_q <= MSTR_RD;
                        ld_tx_shiftreg_q <= true;
                        ld_bit_cnt := true;
                     else
                        -- kein Ack vom Master, es wird geprueft, ob eine Stop-Cond folgt
                        state_q <= CHECK_STOP; -- kein Master-Ack
                     end if;
                  end if;

               when CHECK_STOP =>
                  if stop_cnd_q then
                     state_q <= IDLE;
                     error_q <= NO_ERROR; -- Normaler Abbruch Read-Transfer
                  elsif start_cnd_q then
                     state_q <= WT_SCL_LO;
                  end if;

               when WR_ACK =>
                  rx_buf_ena_q <= '0';
                  if stop_cnd_q then
                     state_q <= IDLE;
                  elsif start_cnd_q then
                     state_q <= WT_SCL_LO;
                  elsif scl_f_q then
                     slv_ack_q <= '1';
                     state_q   <= MSTR_WR;
                     ld_bit_cnt := true;
                  end if;

            end case;
				
            -- Zaehler fuer Anzahl fallende Flanken SCL
            if ld_bit_cnt then
               bit_cnt_q <= 8;
            elsif bit_cnt_q > 0 and scl_f_q then
               bit_cnt_q <= bit_cnt_q -1;
            end if;

            -- Schieberegister fuer RX-Daten
            if scl_f_q then -- fallende Flanke SCL
               rx_shiftreg_q(7 downto 0) <= rx_shiftreg_q(6 downto 0) & sda_del_in_q;
            end if;

            -- Steuersignal fuer TX-SRG um 2 Clocks verzoegern, damit
            -- auf das Signal tx_empty (?) reagiert werden kann
            ld_tx_2_q <= ld_tx_shiftreg_q;
            ld_tx_3_q <= ld_tx_2_q;

            -- RX-Buffer schreiben (nur wenn Daten abgeholt wurden!)
            if rx_buf_ena_q='1' and rx_vld='0' then
               rx_data   <= rx_shiftreg_q;
               rx_vld  <= '1';
            elsif rx_ack='1' then
               rx_vld  <= '0';
            end if;
            

            -- TX-Teil ist doppelt gepuffert, damit kann schon ein Byte geschrieben
            -- werden, während das vorherige noch zum Master übertragen wird
            -- 1. TX-Buffer vom ext. Controller/FSM schreiben
            if tx_wr='1' then
               wr_buf_q   <= tx_data;
               tx_empty_q <= '0';
            elsif ld_tx_3_q then
               tx_empty_q <= '1';
            end if; 

            -- 2. TX-Buffer : Schieberegister fuer TX-Daten
            -- Laden mit dem um 2 Clocks verzoegerten ld-signal
            if ld_tx_3_q then
               tx_shiftreg_q <= wr_buf_q; --tx_data;   --fho: a little bug? tx_data replaced by wr_buf_q
            elsif scl_f_q then
               tx_shiftreg_q(7 downto 1) <= tx_shiftreg_q(6 downto 0); -- linksschieben
            end if;


            -- Multiplexer fuer Slave-Acknowledge und Slave-Daten
            if state_q = MSTR_RD then -- Daten anlegen
               sda_q <= tx_shiftreg_q(7);
            else
               sda_q <= slv_ack_q;
            end if;
				
         end if;
      end process;

   dbg_stat <= to_unsigned(STATE_TYPE'pos(state_q), 4) &
               to_unsigned(I2C_SLV_ERROR_TYPE'pos(error_q), 4);

   end block;
   
   -- interne Signale mit Entity verbinden
   tx_empty <= tx_empty_q; --'1' when tx_empty_q else '0';
   busy     <= '1' when busy_q     else '0';
   error    <= error_q;
end;
