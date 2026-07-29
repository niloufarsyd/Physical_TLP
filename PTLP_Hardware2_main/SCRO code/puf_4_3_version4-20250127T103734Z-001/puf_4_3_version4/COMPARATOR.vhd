library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.std_logic_unsigned.all;

entity CPMPARATOR is
port(
	A, B : in std_logic_vector(31 downto 0);
	GTh : out std_logic
	);
end CPMPARATOR;
architecture arch_comp of CPMPARATOR is
begin
	GTh <= '1' when ( A > B ) else '0';
end arch_comp;