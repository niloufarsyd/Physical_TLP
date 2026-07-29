----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    19:33:21 01/03/2021 
-- Design Name: 
-- Module Name:    TEST_led_RO_DCU_HardMacro2 - Behavioral 
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

entity TEST_led_RO_DCU_HardMacro2 is
    Port ( 
			--RO_EN   : in  STD_LOGIC;--USE i_CI(0) AS RO_EN

			i_CI:in STD_LOGIC_vector(4 downto 0);
			---------------------
			LED1,LED2,LED3,LED4 : out  STD_LOGIC
			---------------------			
			  );
end TEST_led_RO_DCU_HardMacro2;

architecture Behavioral of TEST_led_RO_DCU_HardMacro2 is
	COMPONENT COUNTER_OF_TEST
	PORT(
		I_COUNT : IN std_logic;          
		O_COUNT : OUT std_logic
		);
	END COMPONENT;
-------------------------------------------------------
component RingOscillator_DCU is
    Port ( 
	
	 CI      : in  STD_LOGIC_VECTOR (4 downto 0);
    RO_EN   : in  STD_LOGIC;
    RO_F    : out STD_LOGIC);
	 END COMPONENT;
-------------------------------------------------------
signal RO_F : std_logic;
signal PULSE : std_logic:='0';
-------------------------------------------------------

begin

	Inst_RO_DCU_MACRO_1: RingOscillator_DCU PORT MAP(
		
		CI => i_CI,
		RO_EN =>i_CI(2),
		RO_F => RO_F
	);
	Inst_COUNTER_OF_TEST: COUNTER_OF_TEST PORT MAP(
		I_COUNT => RO_F,
		O_COUNT => PULSE
	);
	
LED1<= NOT PULSE;	
LED2<= NOT RO_F;

LED3<=NOT i_CI(3);
LED4<=NOT i_CI(0);
end Behavioral;

