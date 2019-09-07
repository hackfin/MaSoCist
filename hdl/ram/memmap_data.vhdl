library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

library work;
use work.memory_initialization.all;
use work.memory.all;
use work.ram.all;

entity lb_dma_memory is
	
	port(
		clk      	  : in std_ulogic;

		lb_we         : in std_ulogic;
		lb_size_select: in unsigned(1 downto 0);
		lb_addr       : in unsigned(31 downto 0);
		lb_data_in    : in  unsigned(31 downto 0);
		lb_data_out   : out unsigned(31 downto 0);

		-- 16 bit DMA only for now:
		dma_mode      : in  unsigned(1 downto 0);
		dma_addr      : in  unsigned(31 downto 0); -- 8 bit addr
		dma_datain    : in  unsigned(15 downto 0);
		dma_dataout   : out unsigned(15 downto 0);
		dma_we        : in  std_ulogic
	);
end entity lb_dma_memory;

architecture behaviour of lb_dma_memory is

	signal daddr	  : unsigned(ADDR_W_8-1 downto 0);
	signal dram_we    : std_logic_vector(0 to 3);
	signal iram_wren  : std_logic;
	signal sel_dram   : std_logic;
	signal sel_dram_d : std_logic;

	subtype byte_t is unsigned(7 downto 0);
	type bus_bytes_t is array(natural range 0 to 3) of unsigned(7 downto 0);

	signal dram_data8_wr : bus_bytes_t;
	signal dram_data8_rd : bus_bytes_t;

	-- MDMA channel:
	signal dma_data8_wr  : bus_bytes_t;
	signal dma_data8_rd  : bus_bytes_t;
	signal dma_addr32    : unsigned(ADDR_W_8-1 downto 0) := (others => '0');
	signal dma_data8_we  : std_logic_vector(0 to 3) := (others => '0');
	signal dma_dataout_w : unsigned(15 downto 0);
	signal dma_dataout_b : unsigned(7 downto 0);

	-- Byte/Word selection: 0: lower, 1: higher word
	signal dma_bytesel     : std_logic_vector(1 downto 0);
	signal dma_bytesel_d1  : std_logic_vector(1 downto 0);

	signal size_d	  : unsigned(1 downto 0);
	alias  addr  	  : unsigned(1 downto 0) is lb_addr(1 downto 0);
	signal addr_d	  : unsigned(1 downto 0);

	constant UNDEFINED_8 : unsigned(7 downto 0) := "XXXXXXXX";
begin

loop_bram:
	for i in 0 to 3 generate
		bram: DPRAM16_init
		generic map (
			ADDR_W => ADDR_W_8,
			DATA_W => 8,
			INIT_DATA => ram16_init_t(BOOTROM_DATA_A_INIT(i))
		)
		port map (
			clk		=> clk,
			-- Port A used by CPU:
			a_we	=> dram_we(i),
			a_addr	=> daddr,
			a_write => dram_data8_wr(i),
			a_read	=> dram_data8_rd(i),
			-- Port B used by DMA:
			b_we	=> dma_data8_we(i),
			b_addr	=> dma_addr32,
			b_write => dma_data8_wr(i),
			b_read	=> dma_data8_rd(i)
		);
	end generate;

	daddr  <= unsigned(lb_addr(ADDR_W_8+1 downto 2));


----------------------------------------------------------------------------
-- 

read_select_delay:
	process(clk)
	begin
		if rising_edge(clk) then
			dma_bytesel_d1 <= dma_bytesel;
			-- sel_iram_d     <= sel_iram;
			sel_dram_d     <= sel_dram;
			addr_d <= lb_addr(1 downto 0);
			size_d <= lb_size_select;
		end if;
	end process;

----------------------------------------------------------------------------
-- DRAM access width control

dram_access_control:
	process(lb_we, addr, lb_data_in, lb_size_select, dram_data8_rd)
		variable data : unsigned(31 downto 0);
		variable size : unsigned(1 downto 0);
	begin
		data := lb_data_in;
		size := lb_size_select;
-- WRITING:
		if lb_we = '1' then
			case lb_addr(1 downto 0) is
			when "00" =>
				case size is
				when "01" => -- 8bit
					dram_data8_wr(3) <= (others => 'X');
					dram_data8_wr(2) <= (others => 'X');
					dram_data8_wr(1) <= (others => 'X');
					dram_data8_wr(0) <= data(BYTE0);
					dram_we <= "1000";
				when "10" => -- 16bit
					dram_data8_wr(3) <= (others => 'X');
					dram_data8_wr(2) <= (others => 'X');
					dram_data8_wr(1) <= data(BYTE1);
					dram_data8_wr(0) <= data(BYTE0);
					dram_we <= "1100";
				when "00" => -- 32bit
					dram_data8_wr(3) <= data(BYTE3);
					dram_data8_wr(2) <= data(BYTE2);
					dram_data8_wr(1) <= data(BYTE1);
					dram_data8_wr(0) <= data(BYTE0);
					dram_we <= "1111";
				when others =>
					dram_data8_wr <= (others => (others => 'X'));
					dram_we <= "0000";
				end case;
			when "01" =>
				--only 8 bit allowed
				dram_data8_wr(3) <= (others => 'X');
				dram_data8_wr(2) <= (others => 'X');
				dram_data8_wr(1) <= data(BYTE0);
				dram_data8_wr(0) <= (others => 'X');
				dram_we <= "0100";
			when "10" =>
				case size is
				when "00" => --8 bit
					dram_data8_wr(3) <= (others => 'X');
					dram_data8_wr(2) <= data(BYTE0);
					dram_data8_wr(1) <= (others => 'X');
					dram_data8_wr(0) <= (others => 'X');
					dram_we <= "0010";
				when "01" => --16 bit
					dram_data8_wr(3) <= data(BYTE1);
					dram_data8_wr(2) <= data(BYTE0);
					dram_data8_wr(1) <= (others => 'X');
					dram_data8_wr(0) <= (others => 'X');
					dram_we <= "0011";
				when others =>
					dram_data8_wr <= (others => (others => 'X'));
					dram_we <= "0000";
				end case;
			when "11" =>
				--only 8 bit allowed
				dram_data8_wr(3) <= data(BYTE0);
				dram_data8_wr(2) <= (others => 'X');
				dram_data8_wr(1) <= (others => 'X');
				dram_data8_wr(0) <= (others => 'X');
				dram_we <= "0001";
			when others =>
				dram_data8_wr <= (others => (others => 'X'));
				dram_we <= "0000";
			end case;
			lb_data_out <= (others => 'X');
		else
			dram_data8_wr <= (others => (others => 'X'));
			dram_we <= "0000";

-- READING

			case addr_d is
			when "00" =>
				case size_d is
				when "01" => -- 8bit
					lb_data_out <=  UNDEFINED_8 &
									UNDEFINED_8 &
									UNDEFINED_8 &
									dram_data8_rd(0);
				when "10" => -- 16bit
					lb_data_out <=  UNDEFINED_8 &
									UNDEFINED_8 &
									dram_data8_rd(1) &
									dram_data8_rd(0);
				when "00" => -- 32bit
					lb_data_out <=  dram_data8_rd(3) &
									dram_data8_rd(2) &
									dram_data8_rd(1) &
									dram_data8_rd(0);
				when others =>
					lb_data_out <=  (others => 'X');
				end case;
			when "01" =>
				case size_d is
				when "01" => -- 8bit
					lb_data_out <=  UNDEFINED_8 &
									UNDEFINED_8 &
									UNDEFINED_8 &
									dram_data8_rd(1);
				when others =>
					lb_data_out <=  (others => 'X');
				end case;

			when "10" =>
				case size_d is
				when "01" => -- 8bit
					lb_data_out <=  UNDEFINED_8 &
									UNDEFINED_8 &
									UNDEFINED_8 &
									dram_data8_rd(2);
				when "10" => -- 16bit
					lb_data_out <=  UNDEFINED_8 &
									UNDEFINED_8 &
									dram_data8_rd(3) &
									dram_data8_rd(2);
				when others =>
					lb_data_out <=  (others => 'X');
				end case;

			when others =>
				case size_d is
				when "01" => -- 8bit
					lb_data_out <=  UNDEFINED_8 &
									UNDEFINED_8 &
									UNDEFINED_8 &
									dram_data8_rd(3);
				when others =>
					lb_data_out <=  (others => 'X');
				end case;



			end case;
		end if;
	end process; 

end behaviour;
