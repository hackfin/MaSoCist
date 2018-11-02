library IEEE;
use IEEE.std_logic_1164.all;

library ghdlex;
	use ghdlex.txt_util.all;

library std;
	use std.textio.all;

entity efb_core is
    port (
        wb_clk_i: in  std_logic; 
        wb_rst_i: in  std_logic; 
        wb_cyc_i: in  std_logic; 
        wb_stb_i: in  std_logic; 
        wb_we_i: in  std_logic; 
        wb_adr_i: in  std_logic_vector(7 downto 0); 
        wb_dat_i: in  std_logic_vector(7 downto 0); 
        wb_dat_o: out  std_logic_vector(7 downto 0); 
        wb_ack_o: out  std_logic; 
        wbc_ufm_irq: out  std_logic);
end efb_core;


architecture simulation of efb_core is
begin

debug:
	process (wb_clk_i)
	begin
		if rising_edge(wb_clk_i) and wb_stb_i = '1' then
			if wb_we_i = '1' then
				print(output, "WR> " & hstr(wb_adr_i) & "  :  " & hstr(wb_dat_i));
			else
				print(output, "RD> " & hstr(wb_adr_i));
			end if;
		end if;
	end process;

gen_ack:
	process (wb_clk_i)
	begin
		if rising_edge(wb_clk_i) then
			wb_ack_o <= wb_stb_i;
		end if;
	end process;
				
	wb_dat_o <= x"55";

end architecture simulation;
