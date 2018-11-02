--
-- This is a VHDL package file generated from /home/strubi/src/jtag/uniemu/tap/tap.xml
-- using vhdlregs.xsl
-- Changes to this file WILL BE LOST. Edit the source file.
--
-- Implements a 'msb+1' bit address wide register map as VHDL package
--
-- Set the msb by specifying the --param msb `number` option to xsltproc
--
-- (c) 2007-2014, Martin Strubel // hackfin@section5.ch
--
--

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

library work; use work.stdtap.all;

package zpu_small is
	subtype  regaddr_t is unsigned(7 downto 0);

	subtype  REG_SIZE1B is integer range 7 downto 0;
	subtype  REG_SIZE2B is integer range 15 downto 0;
	subtype  REG_SIZE3B is integer range 23 downto 0;
	subtype  REG_SIZE4B is integer range 31 downto 0;



-------------------------------------------------------------------------
-- Address segment 'ZPU'
--         Offset: 

-- These are the core specific bits of the EMUSTAT register
	constant R_ZPU_EMUSTAT           : regaddr_t := x"04";
-- Idim flag is set
	constant              B_ZPU_IDIM : natural := 15;
-- Hit and stopped by breakpoint instruction
	constant              B_ZPU_BREAK : natural := 14;
-- Memory is busy
	constant              B_ZPU_MEMBUSY : natural := 9;
-- Core is being reset
	constant              B_ZPU_INRESET : natural := 8;

-------------------------------------------------------------------------
-- Address segment 'REG'
--         Offset: 

	constant R_REG_PC                : regaddr_t := x"00";
	constant R_REG_SP                : regaddr_t := x"01";


	-- Access records:

	type zpuemu_WritePort is record
		--! Exported value for register 'R_ZPU_EMUSTAT'
		--! Exported value for bit (vector) 'ZPU_IDIM'
		zpu_idim : std_logic;
		--! Exported value for bit (vector) 'ZPU_BREAK'
		zpu_break : std_logic;
		--! Exported value for bit (vector) 'ZPU_MEMBUSY'
		zpu_membusy : std_logic;
		--! Exported value for bit (vector) 'ZPU_INRESET'
		zpu_inreset : std_logic;
	end record;

	type regs_WritePort is record
		--! Exported value for register 'R_REG_PC'
		pc : std_logic_vector(REG_SIZE4B);
		--! Exported value for register 'R_REG_SP'
		sp : std_logic_vector(REG_SIZE4B);
	end record;


end zpu_small;


