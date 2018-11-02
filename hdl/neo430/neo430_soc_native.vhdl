library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
library neo430;
use neo430.neo430_package.all;
library work;
use work.global_config.all;
entity SoC is
  generic (
    -- general configuration --
    CLOCK_SPEED : natural := 100000000; -- main clock in Hz
    IMEM_SIZE : natural := 4*1024; -- internal IMEM size in bytes, max 48kB (default=4kB)
    DMEM_SIZE : natural := 2*1024; -- internal DMEM size in bytes, max 12kB (default=2kB)
    -- additional configuration --
    USER_CODE : std_ulogic_vector(15 downto 0) := x"0000"; -- custom user code
    -- module configuration --
    DADD_USE : boolean := CONFIG_NEO430_DADD; -- implement DADD instruction? (default=true)
    MULDIV_USE : boolean := CONFIG_NEO430_MULDIV; -- implement multiplier/divider unit? (default=true)
    WB32_USE : boolean := false; -- implement WB32 unit? (default=true)
    WDT_USE : boolean := CONFIG_NEO430_WDT; -- implement WDT? (default=true)
    GPIO_USE : boolean := CONFIG_NEO430_GPIO; -- implement GPIO unit? (default=true)
    TIMER_USE : boolean := CONFIG_NEO430_TIMER; -- implement timer? (default=true)
    USART_USE : boolean := CONFIG_NEO430_USART; -- implement USART? (default=true)
    CRC_USE : boolean := CONFIG_NEO430_CRC; -- implement CRC unit? (default=true)
    CFU_USE : boolean := false; -- implement custom functions unit? (default=false)
    PWM_USE : boolean := CONFIG_NEO430_PWM; -- implement PWM controller? (default=true)
    TRNG_USE : boolean := CONFIG_NEO430_TRNG; -- implement true random number generator? (default=false)
    -- boot configuration --
    BOOTLD_USE : boolean := CONFIG_NEO430_BOOTLD; -- implement and use bootloader? (default=true)
    IMEM_AS_ROM : boolean := CONFIG_NEO430_IMEM_RO -- implement IMEM as read-only memory? (default=false)
  );
  port (
    -- global control --
    clk : in std_ulogic; -- global clock, rising edge
    reset : in std_ulogic; -- global reset, async, LOW-active
    -- parallel io --
-- gpio_o : out std_ulogic_vector(15 downto 0); -- parallel output
-- gpio_i : in std_ulogic_vector(15 downto 0); -- parallel input
-- -- pwm channels --
-- pwm_o : out std_ulogic_vector(02 downto 0); -- pwm channels
-- -- serial com --
-- uart_txd_o : out std_ulogic; -- UART send data
-- uart_rxd_i : in std_ulogic; -- UART receive data
-- spi_sclk_o : out std_ulogic; -- serial clock line
-- spi_mosi_o : out std_ulogic; -- serial data line out
-- spi_miso_i : in std_ulogic; -- serial data line in
-- spi_cs_o : out std_ulogic_vector(05 downto 0); -- SPI CS 0..5
-- -- 32-bit wishbone interface --
-- wb_adr_o : out std_ulogic_vector(31 downto 0); -- address
-- wb_dat_i : in std_ulogic_vector(31 downto 0); -- read data
-- wb_dat_o : out std_ulogic_vector(31 downto 0); -- write data
-- wb_we_o : out std_ulogic; -- read/write
-- wb_sel_o : out std_ulogic_vector(03 downto 0); -- byte enable
-- wb_stb_o : out std_ulogic; -- strobe
-- wb_cyc_o : out std_ulogic; -- valid cycle
-- wb_ack_i : in std_ulogic; -- transfer acknowledge
    -- external interrupt --
    irq_i : in std_ulogic; -- external interrupt request line
    irq_ack_o : out std_ulogic -- external interrupt request acknowledge
  );
end SoC;
architecture neo430_top_rtl of SoC is
  -- generators --
  signal rst_gen : std_ulogic_vector(03 downto 0) := (others => '0'); -- perform reset on bitstream upload
  signal rst_gen_sync : std_ulogic_vector(01 downto 0);
  signal ext_rst : std_ulogic;
  signal sys_rst : std_ulogic;
  signal wdt_rst : std_ulogic;
  signal clk_div : std_ulogic_vector(11 downto 0);
  signal clk_div_ff : std_ulogic_vector(11 downto 0);
  signal clk_gen : std_ulogic_vector(07 downto 0);
  signal timer_cg_en : std_ulogic;
  signal usart_cg_en : std_ulogic;
  signal wdt_cg_en : std_ulogic;
  signal pwm_cg_en : std_ulogic;
  type cpu_bus_t is record
    rd_en : std_ulogic;
    wr_en : std_ulogic_vector(01 downto 0);
    addr : std_ulogic_vector(15 downto 0);
    rdata : std_ulogic_vector(15 downto 0);
    wdata : std_ulogic_vector(15 downto 0);
  end record;
  -- main CPU communication bus --
  signal cpu_bus : cpu_bus_t;
  signal io_acc : std_ulogic;
  signal io_wr_en : std_ulogic;
  signal io_rd_en : std_ulogic;
  -- read-back data buses --
  signal rom_rdata : std_ulogic_vector(15 downto 0);
  signal ram_rdata : std_ulogic_vector(15 downto 0);
  signal muldiv_rdata : std_ulogic_vector(15 downto 0);
  signal wb_rdata : std_ulogic_vector(15 downto 0);
  signal boot_rdata : std_ulogic_vector(15 downto 0);
  signal wdt_rdata : std_ulogic_vector(15 downto 0);
  signal timer_rdata : std_ulogic_vector(15 downto 0);
  signal usart_rdata : std_ulogic_vector(15 downto 0);
  signal gpio_rdata : std_ulogic_vector(15 downto 0);
  signal crc_rdata : std_ulogic_vector(15 downto 0);
  signal cfu_rdata : std_ulogic_vector(15 downto 0);
  signal pwm_rdata : std_ulogic_vector(15 downto 0);
  signal trng_rdata : std_ulogic_vector(15 downto 0);
  signal sysconfig_rdata : std_ulogic_vector(15 downto 0);
  -- interrupt system --
  signal irq : std_ulogic_vector(03 downto 0);
  signal irq_ack : std_ulogic_vector(03 downto 0);
  signal timer_irq : std_ulogic;
  signal usart_irq : std_ulogic;
  signal gpio_irq : std_ulogic;
  signal xirq_sync : std_ulogic_vector(01 downto 0);
  -- misc --
  signal imem_up_en : std_ulogic;
begin
  -- Reset Generator ----------------------------------------------------------
  -- -----------------------------------------------------------------------------
  reset_generator: process(reset, clk)
  begin
    if (reset = '1') then
      rst_gen <= (others => '0');
    elsif rising_edge(clk) then
      rst_gen <= rst_gen(rst_gen'left-1 downto 0) & '1';
    end if;
  end process reset_generator;
  -- one extra sync ff to prevent weird glitches on the reset net
  -- and another one to avoid metastability
  reset_generator_sync_ff: process(clk)
  begin
    if rising_edge(clk) then
      rst_gen_sync <= rst_gen_sync(0) & rst_gen(rst_gen'left);
    end if;
  end process reset_generator_sync_ff;
  ext_rst <= rst_gen_sync(1);
  sys_rst <= ext_rst and wdt_rst;
  -- Clock Generator ----------------------------------------------------------
  -- -----------------------------------------------------------------------------
  clock_generator: process(sys_rst, clk)
  begin
    if (sys_rst = '0') then
      clk_div <= (others => '0');
    elsif rising_edge(clk) then
      if ((timer_cg_en or usart_cg_en or wdt_cg_en or pwm_cg_en) = '1') then -- anybody needing clocks?
        clk_div <= std_ulogic_vector(unsigned(clk_div) + 1);
      end if;
    end if;
  end process clock_generator;
  clock_generator_buf: process(clk)
  begin
    if rising_edge(clk) then
      clk_div_ff <= clk_div;
    end if;
  end process clock_generator_buf;
  neo430_cpu_inst: neo430_cpu
  generic map (
    DADD_USE => DADD_USE, -- implement DADD instruction? (default=true)
    BOOTLD_USE => BOOTLD_USE, -- implement and use bootloader? (default=true)
    IMEM_AS_ROM => IMEM_AS_ROM -- implement IMEM as read-only memory?
  )
  port map (
    -- global control --
    clk_i => clk, -- global clock, rising edge
    rst_i => sys_rst, -- global reset, low-active, async
    -- memory interface --
    mem_rd_o => cpu_bus.rd_en, -- memory read
    mem_imwe_o => imem_up_en, -- allow writing to IMEM
    mem_wr_o => cpu_bus.wr_en, -- memory write
    mem_addr_o => cpu_bus.addr, -- address
    mem_data_o => cpu_bus.wdata, -- write data
    mem_data_i => cpu_bus.rdata, -- read data
    -- interrupt system --
    irq_i => irq, -- interrupt request lines
    irq_ack_o => irq_ack -- IRQ acknowledge
  );
  -- final CPU read data --
  cpu_bus.rdata <= rom_rdata or ram_rdata or boot_rdata ;
-- cpu_bus.rdata <= rom_rdata or ram_rdata or boot_rdata or muldiv_rdata or wb_rdata or
-- usart_rdata or gpio_rdata or timer_rdata or wdt_rdata or sysconfig_rdata or
-- crc_rdata or cfu_rdata or pwm_rdata or trng_rdata;
  -- sync for external IRQ --
  external_irq_sync: process(clk)
  begin
    if rising_edge(clk) then
      xirq_sync <= xirq_sync(0) & irq_i;
    end if;
  end process external_irq_sync;
  -- interrupt priority assignment --
  irq(0) <= timer_irq; -- timer match (highest priority)
  irq(1) <= usart_irq; -- UART Rx available [OR] UART Tx done [OR] SPI RTX done
  irq(2) <= gpio_irq; -- GPIO input pin change
  irq(3) <= xirq_sync(1); -- external interrupt request (lowest priority)
  -- external interrupt acknowledge --
  irq_ack_o <= irq_ack(3); -- the internal irq sources do not require an acknowledge
  -- Main Memory (ROM/IMEM & RAM/DMEM) ----------------------------------------
  -- -----------------------------------------------------------------------------
  neo430_imem_inst: neo430_imem
  generic map (
    IMEM_SIZE => IMEM_SIZE, -- internal IMEM size in bytes, max 32kB (default=4kB)
    IMEM_AS_ROM => IMEM_AS_ROM, -- implement IMEM as read-only memory?
    BOOTLD_USE => BOOTLD_USE -- implement and use bootloader? (default=true)
  )
  port map (
    clk_i => clk, -- global clock line
    rden_i => cpu_bus.rd_en, -- read enable
    wren_i => cpu_bus.wr_en, -- write enable
    upen_i => imem_up_en, -- update enable
    addr_i => cpu_bus.addr, -- address
    data_i => cpu_bus.wdata, -- data in
    data_o => rom_rdata -- data out
  );
  neo430_dmem_inst: neo430_dmem
  generic map (
    DMEM_SIZE => DMEM_SIZE -- internal DMEM size in bytes, max 28kB (default=2kB)
  )
  port map (
    clk_i => clk, -- global clock line
    rden_i => cpu_bus.rd_en, -- read enable
    wren_i => cpu_bus.wr_en, -- write enable
    addr_i => cpu_bus.addr, -- address
    data_i => cpu_bus.wdata, -- data in
    data_o => ram_rdata -- data out
  );
  -- Boot ROM -----------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  neo430_boot_rom_inst_true:
  if (BOOTLD_USE = true) generate
    neo430_boot_rom_inst: neo430_boot_rom
    port map (
      clk_i => clk, -- global clock line
      rden_i => cpu_bus.rd_en, -- read enable
      addr_i => cpu_bus.addr, -- address
      data_o => boot_rdata -- data out
    );
  end generate;
  neo430_boot_rom_inst_false:
  if (BOOTLD_USE = false) generate
    boot_rdata <= (others => '0');
  end generate;
  -- IO Access? ---------------------------------------------------------------
  -- -----------------------------------------------------------------------------
  io_acc <= '1' when (cpu_bus.addr(15 downto index_size_f(io_size_c)) = io_base_c(15 downto index_size_f(io_size_c))) else '0';
  io_rd_en <= cpu_bus.rd_en and io_acc;
  io_wr_en <= (cpu_bus.wr_en(0) or cpu_bus.wr_en(1)) and io_acc;
-- neo430_muldiv_inst_false:
-- if (MULDIV_USE = false) generate
-- muldiv_rdata <= (others => '0');
-- end generate;
--
--
-- neo430_wb32_if_inst_false:
-- if (WB32_USE = false) generate
    wb_rdata <= (others => '0');
-- wb_adr_o <= (others => '0');
-- wb_dat_o <= (others => '0');
-- wb_we_o <= '0';
-- wb_sel_o <= (others => '0');
-- wb_stb_o <= '0';
-- wb_cyc_o <= '0';
-- end generate;
--
--
--
-- neo430_usart_inst_false:
-- if (USART_USE = false) generate
-- usart_rdata <= (others => '0');
-- usart_irq <= '0';
-- usart_cg_en <= '0';
-- uart_txd_o <= '1';
-- spi_sclk_o <= '0';
-- spi_mosi_o <= '0';
-- spi_cs_o <= (others => '1');
-- end generate;
--
-- neo430_gpio_inst_false:
-- if (GPIO_USE = false) generate
-- gpio_rdata <= (others => '0');
-- gpio_o <= (others => '0');
-- gpio_irq <= '0';
-- end generate;
  neo430_timer_inst_false:
  if (TIMER_USE = false) generate
    timer_rdata <= (others => '0');
    timer_irq <= '0';
    timer_cg_en <= '0';
  end generate;
  neo430_wdt_inst_false:
  if (WDT_USE = false) generate
    wdt_rdata <= (others => '0');
    wdt_rst <= '1';
    wdt_cg_en <= '0';
  end generate;
-- neo430_crc_inst_false:
-- if (CRC_USE = false) generate
-- crc_rdata <= (others => '0');
-- end generate;
--
-- neo430_cfu_inst_false:
-- if (CFU_USE = false) generate
-- cfu_rdata <= (others => '0');
-- end generate;
--
-- neo430_pwm_inst_false:
-- if (PWM_USE = false) generate
-- pwm_cg_en <= '0';
-- pwm_rdata <= (others => '0');
-- pwm_o <= (others => '0');
-- end generate;
--
-- neo430_trng_inst_false:
-- if (TRNG_USE = false) generate
-- trng_rdata <= (others => '0');
-- end generate;
-- System Configuration -----------------------------------------------------
  -- -----------------------------------------------------------------------------
  neo430_sysconfig_inst: neo430_sysconfig
  generic map (
    -- general configuration --
    CLOCK_SPEED => CLOCK_SPEED, -- main clock in Hz
    IMEM_SIZE => IMEM_SIZE, -- internal IMEM size in bytes
    DMEM_SIZE => DMEM_SIZE, -- internal DMEM size in bytes
    -- additional configuration --
    USER_CODE => USER_CODE, -- custom user code
    -- module configuration --
    DADD_USE => DADD_USE, -- implement DADD instruction?
    MULDIV_USE => MULDIV_USE, -- implement multiplier/divider unit?
    WB32_USE => WB32_USE, -- implement WB32 unit?
    WDT_USE => WDT_USE, -- implement WDT?
    GPIO_USE => GPIO_USE, -- implement GPIO unit?
    TIMER_USE => TIMER_USE, -- implement timer?
    USART_USE => USART_USE, -- implement USART?
    CRC_USE => CRC_USE, -- implement CRC unit?
    CFU_USE => CFU_USE, -- implement CFU?
    PWM_USE => PWM_USE, -- implement PWM?
    TRNG_USE => TRNG_USE, -- implement TRNG?
    -- boot configuration --
    BOOTLD_USE => BOOTLD_USE, -- implement and use bootloader?
    IMEM_AS_ROM => IMEM_AS_ROM -- implement IMEM as read-only memory?
  )
  port map (
    clk_i => clk, -- global clock line
    rden_i => io_rd_en, -- read enable
    wren_i => io_wr_en, -- write enable
    addr_i => cpu_bus.addr, -- address
    data_i => cpu_bus.wdata, -- data in
    data_o => sysconfig_rdata -- data out
  );
end neo430_top_rtl;
