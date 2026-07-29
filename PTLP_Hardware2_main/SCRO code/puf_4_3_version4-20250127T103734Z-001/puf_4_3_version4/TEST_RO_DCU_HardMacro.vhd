----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:23:33 12/29/2020 
-- Design Name: 
-- Module Name:    TEST_RO_DCU_HardMacro - Behavioral 
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

entity TEST_RO_DCU_HardMacro is
	PORT(
		CI : IN std_logic_vector(4 downto 0);
		RO_EN  : IN  std_logic;         
		RO_F  :  OUT std_logic
		);
end TEST_RO_DCU_HardMacro;

architecture Behavioral of TEST_RO_DCU_HardMacro is
component RO_DCU_HardMacro2 is
    Port ( 
	
	 CI      : in  STD_LOGIC_VECTOR (4 downto 0);
    RO_EN   : in  STD_LOGIC;
    RO_F    : out STD_LOGIC);
end component;

--
--attribute loc: string;
----attribute loc of Inst_RO_DCU_MACRO_1  :   label is "X10Y2";
----attribute loc of Inst_RO_DCU_MACRO_2  :   label is "X8Y2";
--attribute loc of Inst_RO_DCU_MACRO_3  :   label is "X2Y2";

begin

	
--	Inst_RO_DCU_MACRO_1: RO_DCU_HardMacro1 PORT MAP(
--		
--		CI => CI,
--		RO_EN =>RO_EN,
--		RO_F => RO_F(0)
--	);
--
--	Inst_RO_DCU_MACRO_2: RO_DCU_HardMacro1 PORT MAP(
--		
--		CI => CI,
--		RO_EN =>RO_EN,
--		RO_F => RO_F(1)
--	);

	Inst_RO_DCU_MACRO_3: RO_DCU_HardMacro2 PORT MAP(
		
		CI => CI,
		RO_EN =>RO_EN,
		RO_F => RO_F
	);
end Behavioral;

