library IEEE;
use IEEE.std_logic_1164.all;

entity usrmclk_wrapper is
  port (
    usrmclki :   in  std_logic;
    usrmclkts :   in  std_logic;
    spi_mclk_dummy :   out  std_logic  );
end usrmclk_wrapper;

architecture dummy of usrmclk_wrapper is

begin

end architecture;

