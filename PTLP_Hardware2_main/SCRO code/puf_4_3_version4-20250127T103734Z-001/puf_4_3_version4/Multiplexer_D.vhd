----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:23:49 12/05/2020 
-- Design Name: 
-- Module Name:    Multiplexer_D - Behavioral 
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

entity Multiplexer_D is
		PORT (Sel  : IN STD_LOGIC_Vector(5 downto 0);
				dati : IN STD_LOGIC_Vector(63 downto 0);
				dato : OUT STD_LOGIC
				);
end Multiplexer_D;

architecture Behavioral of Multiplexer_D is

begin
	dato <= dati(conv_integer(sel));
end Behavioral;

