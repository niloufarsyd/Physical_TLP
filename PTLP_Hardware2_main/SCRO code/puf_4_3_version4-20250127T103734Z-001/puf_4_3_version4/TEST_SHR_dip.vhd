----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:48:12 12/17/2020 
-- Design Name: 
-- Module Name:    test_shiftREG_DIP - Behavioral 
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

entity test_shiftREG_DIP is
port(
		--SELB:IN STD_LOGIC_VECTOR(7 DOWNTO 4);
		i_CLK :IN STD_LOGIC;
		i_DIPData : in  STD_LOGIC;
		
		o_PSCLK:OUT STD_LOGIC;
		o_DIPLatch:OUT STD_LOGIC;
		LED1	 :OUT STD_LOGIC;
		LED2	 :OUT STD_LOGIC;
		LED3	 :OUT STD_LOGIC;
		LED4	 :OUT STD_LOGIC
    );
end test_shiftREG_DIP;

architecture Behavioral of test_shiftREG_DIP is
-------------------------------------------------------
----Serial Input,Parallel Output used for Dip Switches:
COMPONENT SIPO
generic (g_DataWidth : integer);
PORT(
	i_CLK : IN std_logic;
	i_Data : IN std_logic;          
	o_Data : OUT std_logic_vector(15 downto 0);
	o_CLK : OUT std_logic;
	o_Latch : OUT std_logic
	);
END COMPONENT;	

component DCM1
port
 (-- Clock in ports
  CLK_IN1           : in     std_logic;
  -- Clock out ports
  CLK_5M          : out    std_logic;
  CLK_20M          : out    std_logic;
  CLK_50M          : out    std_logic;
  CLK_100M          : out    std_logic
 );
end component;


	signal s_DIP    :std_logic_vector(15 downto 0);
	signal S_CLK_5M :std_logic;
	
	
begin

o_PSCLK <= 	not S_CLK_5M;

your_instance_name : DCM1
  port map
   (-- Clock in ports
    CLK_IN1 => i_CLK,
    -- Clock out ports
    CLK_5M => S_CLK_5M,
    CLK_20M => OPEN,
    CLK_50M => OPEN,
    CLK_100M => OPEN);
	 
Inst_SIPO_DIP: 
		SIPO generic map (g_DataWidth => 16)
	   PORT MAP(
		i_CLK => S_CLK_5M,
		o_Data => s_DIP,

		i_Data => i_DIPData,
		o_CLK => open,
		o_Latch => o_DIPLatch
	);
---------------
LED1<=NOT s_DIP(8);
LED2<=NOT s_DIP(13);
LED3<=NOT s_DIP(14);
LED4<=NOT s_DIP(15);
---------------
end Behavioral;

