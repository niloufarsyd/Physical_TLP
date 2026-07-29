----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    02:58:14 03/30/2020 
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
library UNISIM;
use UNISIM.VComponents.all;

entity my_counter is
		port (
		clk : in std_logic;
		PULSE_IN : in STD_LOGIC;---signal of ring oscillator that selected by multiplexer and comes in counter
		CE : in STD_LOGIC;---Counting Enable
		CLR : in STD_LOGIC;
		Q : out STD_LOGIC_VECTOR(31 downto 0)
		);
end my_counter;

architecture arch_count of my_counter is
signal COUNT : STD_LOGIC_VECTOR(31 downto 0) := (others => '0');
signal previous_value,previous_value2 : std_logic := '0';

begin
	process(clk, CLR,PULSE_IN)
	begin
	
		if (clk'event and clk='1') then
			
			if (CLR='1') then
				   COUNT <= (others => '0');
			elsif ( previous_value = '1'    ) then
					if (previous_value2 = '0') then 
						if (CE='1') then
						COUNT <= COUNT+1;
						end if;
					end if;
			else
				  COUNT <= COUNT;
			end if;
		previous_value <= PULSE_IN;-------previous_value: value of PULSE_IN in last rising edge of clk
		previous_value2<=previous_value;--previous_value2:value of PULSE_IN in two rising edge clk ago
	   end if; 	
		
	end process;
	
	Q <= COUNT;
end arch_count;
