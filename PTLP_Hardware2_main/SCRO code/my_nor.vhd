----------------------------------------------------
library ieee;
use ieee.std_logic_1164.all;
----
entity my_nor is
 port ( A, B : in std_logic;
		  REZ  : out std_logic);
	attribute LUT_MAP: string;
	attribute LUT_MAP of my_nor: entity is "yes";
end my_nor;
----
architecture beh of my_nor is
signal S:std_logic;
attribute KEEP: string ;
attribute KEEP of S: signal  is  " true " ; 
begin
	s <= A or B;
	REZ<= not s;
end beh;
