----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    12:11:12 01/26/2020 
-- Design Name: 
-- Module Name:    my_counter - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;



entity counterNew is
		port (
		Clk : in STD_LOGIC;

		Q : out STD_LOGIC_VECTOR(15 downto 0)
		);
end counterNew;

architecture arch_count of counterNew is
signal C,COUNT2 : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
----signal sCOuNT : STD_LOGIC_VECTOR(15 downto 0) := (others => '0');
--signal qq:std_logic:='0';
begin
--	process(Clk)
--	begin
--
--		if (Clk'event and Clk = '1') then
----			if (COuNT<10) then
----				COuNT <= COUNT+1;
----			   qq<='0';
----		   elsif (COuNT<=100) then
----				COUNT <= COUNT+1;
----			   qq<='1';
----			elsif (count<=1000) then
----				COUNT <= COUNT+1;
----			   qq<='0';
----			else
----				COUNT<=(others => '0');
----				qq<='0';
----		   end if;
--		COuNT<=COuNT+1;
--		sCOuNT<=sCOuNT+1;
--		end if;
-- 
--	end process;
--Q<=	COuNT	;

	process(Clk)
	begin

		if (Clk'event and Clk = '1') then
		
		  C<=C+"0000000000000001";
		  IF (C="0000000000001010") THEN
		  -- COUNT2<=COUNT2+"0000000000000001";
			C<=(others => '0');
		  END IF;
		 
		end if;
 
	end process;
Q<=	C	;
end arch_count;