library ieee;
use ieee.std_logic_1164.all;
----
entity my_or is
 port ( A, B : in std_logic;
		  REZ  : out std_logic);
	attribute LUT_MAP: string;
	attribute LUT_MAP of my_or: entity is "yes";
end my_or;
----
architecture beh of my_or is
begin
	REZ <= A or B;
end beh;