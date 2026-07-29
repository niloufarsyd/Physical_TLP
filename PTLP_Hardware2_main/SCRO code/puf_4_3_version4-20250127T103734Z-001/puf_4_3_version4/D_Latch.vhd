library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity D_latch is
    Port ( clk: in  STD_LOGIC;
			  en : in  STD_LOGIC;
           D  : in  STD_LOGIC;
           Q  : out STD_LOGIC);
end D_latch;

architecture Behavioral of D_latch is
begin

process (clk, D)
begin
    if (clk'event and clk='1' ) then
		  if(en='1') then
			  Q <= D;
		  end if;
    end if;
end process;

end Behavioral;