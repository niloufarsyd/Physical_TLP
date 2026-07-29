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



entity counter is
		port (
		Clk : in STD_LOGIC;

		Q : out STD_LOGIC
		);
end counter;

architecture arch_count of counter is
signal COUNT : STD_LOGIC_VECTOR(63 downto 0) := (others => '0');
signal qq:std_logic:='0';
begin
	process(Clk)
	begin

		if (Clk'event and Clk = '1') then
			if (count<1000000) then
				COUNT <= COUNT+1;
			   qq<='0';
		   elsif (count<=10000000) then
				COUNT <= COUNT+1;
			   qq<='1';
			elsif (count<=1000000000) then
				COUNT <= COUNT+1;
			   qq<='0';
			else
				count<=(others => '0');
				qq<='0';
		   end if;
		
		end if;
		
	end process;
	Q <= qq;
end arch_count;