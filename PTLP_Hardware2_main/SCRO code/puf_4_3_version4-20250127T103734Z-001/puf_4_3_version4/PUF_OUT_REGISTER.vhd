----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    06:07:33 02/01/2021 
-- Design Name: 
-- Module Name:    PUF_OUT_REGISTER - Behavioral 
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

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity PUF_OUT_REGISTER is
    Port ( reg_clr : in   STD_LOGIC;
			  PUF_i : in   STD_LOGIC;
           EN    : in   STD_LOGIC;
			  CLK   : in   STD_LOGIC;
           PUF_o : out  STD_LOGIC_VECTOR(63 DOWNTO 0) 
			  );
end PUF_OUT_REGISTER;

architecture Behavioral of PUF_OUT_REGISTER is
SIGNAL TEMP:STD_LOGIC_VECTOR(63 DOWNTO 0) ;
signal shift:std_logic:='0';
begin

	process(clk, EN)
	begin
	
		if (clk'event and clk='1') then
			if (reg_clr='1') then
				temp <= (others=>'0');
			elsif (EN='1') then
			  if (shift='0') then
				TEMP<= PUF_i&(TEMP(63 DOWNTO 1) );
				shift<='1';
				end if;
			else
			 shift<='0';
			END IF;
			
		END IF;
  END PROCESS;
  
  PUF_o<=TEMP;
  
end Behavioral;

