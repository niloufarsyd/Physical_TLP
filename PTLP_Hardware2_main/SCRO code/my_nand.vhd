----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
----
entity my_nand is
 port ( A, B : in std_logic;
		  REZ  : out std_logic);
	attribute LUT_MAP: string;
	attribute LUT_MAP of my_nand: entity is "yes";
end my_nand;
----
architecture beh of my_nand is
signal S:std_logic;
attribute KEEP: string ;
attribute KEEP of S: signal  is  " true " ; 
begin
	s <= A and B;
	REZ<= not s;
end beh;