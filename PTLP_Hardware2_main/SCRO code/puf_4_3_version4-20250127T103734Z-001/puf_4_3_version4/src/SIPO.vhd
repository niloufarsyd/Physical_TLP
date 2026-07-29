------------------------------------------------------------------------------------
----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    11:03:44 01/17/2010 
-- Design Name: 
-- Module Name:    SIPO - Behavioral 
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
USE ieee.std_logic_arith.ALL;
USE ieee.std_logic_unsigned.ALL;

-- Uncomment the following library declaration if using
-- arithmetic functions with Signed or Unsigned values
--use IEEE.NUMERIC_STD.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx primitives in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity SIPO is
	Port ( 
		i_CLK : in  STD_LOGIC;
		o_Data : out  STD_LOGIC_VECTOR (15 downto 0);		
		i_Data : in  STD_LOGIC;
		o_CLK : out  STD_LOGIC;
		o_Latch : out  STD_LOGIC
		  );
end SIPO;

architecture Behavioral of SIPO is

signal s_Counter : integer range 0 to 15 := 0;
signal s_Reg : STD_LOGIC_VECTOR (15 downto 0);

begin

o_CLK <= not i_CLK ;

process(i_CLK)
begin
	if rising_edge(i_CLK) then
		o_Latch <= '1';
		if s_Counter = 15 then
			o_Latch <= '0';
			o_Data <= s_Reg(14 downto 0)&i_Data;
			s_Counter <= 0;
		else
			s_Reg(0) <= i_Data;
			s_Reg(15 downto 1) <= s_Reg(14 downto 0);
			s_Counter <= s_Counter + 1;
		end if;
		
	end if;
end process;


end Behavioral;


---- Company: 
---- Engineer: 
---- 
---- Create Date:    11:03:44 01/17/2010 
---- Design Name: 
---- Module Name:    SIPO - Behavioral 
---- Project Name: 
---- Target Devices: 
---- Tool versions: 
---- Description: 
----
---- Dependencies: 
----
---- Revision: 
---- Revision 0.01 - File Created
---- Additional Comments: 
----
------------------------------------------------------------------------------------
--library IEEE;
--use IEEE.STD_LOGIC_1164.ALL;
--USE ieee.std_logic_arith.ALL;
--USE ieee.std_logic_unsigned.ALL;
--
---- Uncomment the following library declaration if using
---- arithmetic functions with Signed or Unsigned values
----use IEEE.NUMERIC_STD.ALL;
--
---- Uncomment the following library declaration if instantiating
---- any Xilinx primitives in this code.
----library UNISIM;
----use UNISIM.VComponents.all;
--
--entity SIPO is
--	generic (
--				g_DataWidth : integer := 16
--			);
--	Port ( 
--		i_CLK : in  STD_LOGIC;
--		o_Data : out  STD_LOGIC_VECTOR (g_DataWidth-1 downto 0);		
--		i_Data : in  STD_LOGIC;
--		o_CLK : out  STD_LOGIC;
--		o_Latch : out  STD_LOGIC
--		  );
--end SIPO;
--
--architecture Behavioral of SIPO is
--
--signal s_Counter : integer range 0 to (g_DataWidth-1) := 0;
--signal s_Reg : STD_LOGIC_VECTOR (g_DataWidth-1 downto 0);
--
--begin
--
--o_CLK <= not i_CLK ;
--
--process(i_CLK)
--begin
--	if rising_edge(i_CLK) then
--		o_Latch <= '1';
--		if s_Counter = (g_DataWidth-1) then
--			o_Latch <= '0';
--			o_Data <= s_Reg(g_DataWidth-2 downto 0)&i_Data;
--			s_Counter <= 0;
--		else
--			s_Reg(0) <= i_Data;
--			s_Reg(g_DataWidth-1 downto 1) <= s_Reg(g_DataWidth-2 downto 0);
--			s_Counter <= s_Counter + 1;
--		end if;
--		
--	end if;
--end process;
--
--
--end Behavioral;
--
