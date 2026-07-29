--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;

--library UNISIM;
--use UNISIM.VComponents.ALL;

--entity my_or is
--  port (
--    A, B : in std_logic;
--    REZ  : out std_logic
--  );
--end entity;

--architecture Behavioral of my_or is
--signal dummy2, dummy3, dummy4, dummy5 : std_logic := '0';

--  attribute DONT_TOUCH : string;
--  attribute DONT_TOUCH of or_LUT6 : label is "TRUE";
--begin
--  or_LUT6 : LUT6_2
--    generic map (
--      INIT => X"FFFFFFFFFFFFFFFE"  -- or
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