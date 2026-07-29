----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    20:04:29 01/03/2021 
-- Design Name: 
-- Module Name:    COUNTER_OF_TEST - Behavioral 
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
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity COUNTER_OF_TEST is
PORT(
		I_COUNT: IN  STD_LOGIC;
		O_COUNT: OUT STD_LOGIC
		);
end COUNTER_OF_TEST;

architecture Behavioral of COUNTER_OF_TEST is

signal PULSE : std_logic:='0' ;
SIGNAL COUNTER:STD_LOGIC_VECTOR(19 DOWNTO 0):="00000000000000000000";
begin

PROCESS(I_COUNT)
BEGIN
	IF (COUNTER<500) THEN
		COUNTER<=COUNTER+1;
	ELSE
		PULSE<=NOT PULSE;
		COUNTER<="00000000000000000000";
	END IF;
END PROCESS;
O_COUNT<=PULSE;
end Behavioral;

