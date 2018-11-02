-------------------------------------------------------------------------------
--
-- Projekt         I2C SLAVE
--
-- Compiler        ALTERA ModelSim 5.8e
--                 QUARTUS II 5.0
--
-- Autor           FPGA-USER
--
-- Datum           26/08/2005
--
-- Sprache         VHDL 93
--
-- Info            I2C Package fuer Synthese
--                 enthaelt hauptsaechlich Typ-Deklarationen
--                 (Fehlertypen ...)
--
-- Historie         
--
-------------------------------------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;

package i2c_syn_pkg is


   -- Typen -----------------------------------------------------
   
   subtype BYTE is std_logic_vector(7 downto 0);
   
   subtype SLV_ADR_TYPE is integer range 0 to 127;
   
   type TRX_TYPE is (WRITE_DATA, READ_DATA); -- I2C Transfer-Typ 
   
	type I2C_SLV_ERROR_TYPE is (NO_ERROR,
										 RX_OVFLW,
										 TX_UNFLW,
										 RESERVED);

end package;
