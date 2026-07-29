library ieee;
use ieee.std_logic_1164.all;
----
entity my_and is
	port ( A, B : in std_logic;
			 REZ  : out std_logic);
	attribute LUT_MAP: string;
	attribute LUT_MAP of my_and: entity is "yes";
end my_and;
----
architecture beh of my_and is
begin
	REZ <= A and B;
end beh;