library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity Multiplexer_2to1 is
		PORT (A    : IN STD_LOGIC;
				B 	  : IN STD_LOGIC;
				sel  : IN STD_LOGIC;
				dato : OUT STD_LOGIC
				);
--	attribute LUT_MAP: string;
--	attribute LUT_MAP of Multiplexer_2to1: entity is "yes";
end Multiplexer_2to1;

architecture Behavioral of Multiplexer_2to1 is

begin
	 dato <= B when (SEL = '1') else A;

end Behavioral;

