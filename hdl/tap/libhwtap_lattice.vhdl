library ieee;
	use ieee.std_logic_1164.all;

library work;
	use work.stdtap.all;

package hwtap is

attribute syn_black_box : boolean;
attribute black_box_pad_pin : string;


component TAP_Lattice_Glue is
	port (
		itck         : in  std_logic;
		itdi         : in  std_logic;
		tdo1         : out std_logic;
		tdo2         : out std_logic;
		reset        : in  std_logic;
		shift        : in  std_logic;
		update       : in  std_logic;
		ce1          : in  std_logic;
		ce2          : in  std_logic;
		emuctrl      : out std_logic_vector(EMUCTRL_SIZE-1 downto 0);
		emustat      : in  std_logic_vector(EMUCTRL_SIZE-1 downto 0);
		emudata_i    : in  emudata_t;
		emudata_o    : out emudata_t
	);
end component;

attribute syn_black_box of TAP_Lattice_Glue : component is true;
attribute black_box_pad_pin of TAP_Lattice_Glue : component is 
	"itck,itdi,shift,update,ce1,ce2,emustat,emudata_i";


end package;
