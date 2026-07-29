----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:56:44 03/30/2020 
-- Design Name: 
-- Module Name:    mux_gen - Behavioral 
-- Project Name: 
-- Target Devices: 
-- Tool versions: 
-- Description: 
--
-- Dependencies: 
--
-- Revision: 
-- Revision 0.01 - File Created
-- Additional Comments: 
--
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.std_logic_arith.all;
use IEEE.std_logic_unsigned.all;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;


ENTITY mux_gen IS
GENERIC (Sel_Size : INTEGER :=8);
			PORT (Sel  : IN STD_LOGIC_Vector(Sel_Size-1 downto 0);
					dati : IN STD_LOGIC_Vector(2**Sel_Size-1 downto 0);
					dato : OUT STD_LOGIC
					);
END mux_gen;

ARCHITECTURE archmux OF mux_gen IS
BEGIN
	dato <= dati(conv_integer(sel));
END archmux;