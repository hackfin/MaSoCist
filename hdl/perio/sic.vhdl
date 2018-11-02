-- System Interrupt Controller
--
-- Has four input channels and maps to four prioritized output
-- channels. The mapping is done using the SIC_IAR register.
--
-- (c) 2012-2015 Martin Strubel <hackfin@section5.ch>
--
-- This code is subject to the GPL v2 license and part of the
-- Pyps SoC distribution
--
-- Note: The input IRQ line requires a minimum pulse length of one
-- system clock cycle. If very short IRQ pulse detection is required,
-- a StrobePulse entity will have to be inserted after the input buffer
-- from the I/O logic.

-- The SICv2 has an extra exception input 'nmi' that is not maskable and
-- overrides all other pending interrupts.

library ieee;
	use ieee.std_logic_1164.all;
	use ieee.numeric_std.all;

library work;
	use work.system_map.all;
	use work.global_config.all;

entity sic_core is
	generic (ADDR_WIDTH : natural := CONFIG_BRAM_ADDR_WIDTH; NUM_CHANNELS : natural := 4);
	port (
		ctrl : in  sic_WritePort;
		stat : out sic_ReadPort;

		nmi      :  in std_ulogic;
		irq_in   :  in unsigned(NUM_CHANNELS-1 downto 0);
		irq_out  :  out std_logic;
		irq_ovr  :  out std_logic;

		ivaddr   :  out unsigned(ADDR_WIDTH-1 downto 0);

		reset    : in std_logic;
		clk      : in std_logic
	);
end entity;

architecture behaviour of sic_core is
	signal ilat    : unsigned(NUM_CHANNELS-1 downto 0) := (others => '0');
	signal ipend   : unsigned(NUM_CHANNELS-1 downto 0) := (others => '0');
	signal imiss   : unsigned(NUM_CHANNELS-1 downto 0) := (others => '0');
	signal irq     : unsigned(4-1 downto 0);
	signal irq_d   : unsigned(4   downto 0);
	signal nmi_d   : std_logic;


	signal irqo    : std_logic := '0';

	type irq_t is array (integer range 0 to NUM_CHANNELS-1) of unsigned(4-1 downto 0);

	type irqor_t is array (integer range 0 to 4-1) of unsigned(NUM_CHANNELS-1 downto 0);

	signal imap : irq_t;
	signal itmp : irqor_t;

	signal dbg_sel : std_logic;

	signal override  : std_logic;

	constant REG_MSB : natural := (NUM_CHANNELS-1);

	function or_reduce (v: in unsigned) return std_logic is
		variable rv : std_logic := '0';
	begin
		for i in v'range loop
			rv := rv or v(i);
		end loop;
		return rv;
	end function;

begin

irq_mask:
	process (clk)
		function to_irqpins(x: unsigned) return unsigned is
		begin
			return unsigned(x(REG_MSB downto 0));
		end function;
	begin
		if rising_edge(clk) then
			if reset = '1' then
				ipend <= (others => '0');
				ilat <= (others => '0');
				imiss <= (others => '0');
			else
				if ctrl.select_sic_ilat_w1c = '1' then
					ilat <= ilat and not to_irqpins(ctrl.sic_ilat_w1c); -- W1C
				else
					ilat <= (ilat or irq_in) and not ipend;
				end if;
				-- Software clear of IPEND:
				if ctrl.select_sic_ipend_w1c = '1' then
					ipend <= ipend and not to_irqpins(ctrl.sic_ipend_w1c); -- W1C
				else
					ipend <= ipend or (ilat and to_irqpins(ctrl.sic_imask));
				end if;
				if ctrl.select_sic_miss_w1c = '1' then
					imiss <= imiss and not to_irqpins(ctrl.sic_miss_w1c); -- W1C
				else
					imiss <= (ipend and irq_in);
				end if;

			end if;
		end if;
	end process;

	-- Assign status port to signals:
	stat.sic_ilat(REG_MSB downto 0) <= unsigned(ilat);
	stat.sic_ipend(REG_MSB downto 0) <= unsigned(ipend);

	dbg_sel <= ctrl.select_sic_ipend_w1c;

gen_irqmap:
for i in 0 to 4-1 generate
	irq(i) <= or_reduce(itmp(i));
end generate;

gen_or:
for i in 0 to NUM_CHANNELS-1 generate
	flip:
	for j in 0 to 4-1 generate
		itmp(j)(i) <= imap(i)(j);
	end generate;
end generate;

-- Generate priority assignment map:
gen_map:
for i in 0 to NUM_CHANNELS-1 generate
	irq_map:
		process (clk)
		begin
			-- IRQ channel assignment:
			if rising_edge(clk) then
				imap(i) <= (others => '0');
				imap(i)(to_integer(ctrl.iar(i*2+1 downto i*2))) <= ipend(i);
			end if;
		end process;
end generate;

-- Generate a pulse when an IRQ with lower priority occurs
-- while others are still pending
prio_glitch:
	process (clk)
	begin
		if rising_edge(clk) then
			nmi_d <= nmi;

			if ctrl.select_sic_ipend_w1c = '1' then
				irq_d <= (others => '0');
			else
				irq_d <= irq & '0';
			end if;
			-- Here we prioritize:
			-- A NMI change fires an override.
			if nmi = '1' and nmi_d = '0' then
				override <= '1';
			-- Only allow override during a cleared interrupt
			elsif nmi = '0' and (irq < irq_d and irq_d(4 downto 1) < irq) then
				override <= '1';
			else
				override <= '0';
			end if;
		end if;
	end process;

irq_vector_generate:
	process (clk)
	begin
		if rising_edge(clk) then
			if override = '1' then
				irqo <= '0';
			elsif nmi = '1' then
				ivaddr <= resize(ctrl.sic_ev0, ADDR_WIDTH);
				irqo <= '1';
			elsif irq(0) = '1' then
				ivaddr <= resize(ctrl.sic_iv0, ADDR_WIDTH);
				irqo <= '1';
			elsif irq(1) = '1' then
				ivaddr <= resize(ctrl.sic_iv1, ADDR_WIDTH);
				irqo <= '1';
			elsif irq(2) = '1' then
				ivaddr <= resize(ctrl.sic_iv2, ADDR_WIDTH);
				irqo <= '1';
			elsif irq(3) = '1' then
				ivaddr <= resize(ctrl.sic_iv3, ADDR_WIDTH);
				irqo <= '1';
			else
				irqo <= '0';
			end if;
		end if;
	end process;

	irq_out <= irqo;
	irq_ovr <= override;

end architecture;
