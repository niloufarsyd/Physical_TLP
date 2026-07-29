--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

--library UNISIM;
--use UNISIM.VComponents.ALL;

--entity my_and is
--  port (
--    A, B : in std_logic;
--    REZ  : out std_logic
--  );
--end entity;

--architecture Behavioral of my_and is
--signal dummy2, dummy3, dummy4, dummy5 : std_logic := '0';

--  attribute DONT_TOUCH : string;
--  attribute DONT_TOUCH of and_LUT6 : label is "TRUE";
--begin
--  and_LUT6 : LUT6_2
--    generic map (
--      INIT => X"8000000000000000"  -- AND
--    )
--    port map (
--      O6 => REZ,
--      O5 => open,
--      I0 => A,
--      I1 => B,
--      I2 => dummy2,
--      I3 => dummy3,
--      I4 => dummy4,
--      I5 => dummy5
--    );
--end architecture;

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