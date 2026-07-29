----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    22:06:33 12/21/2020 
-- Design Name: 
-- Module Name:    RO_ARRAY - Behavioral 
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

entity RO_ARRAY is
PORT( CI		:in std_logic_vector(4 downto 0);
		RO_EN :OUT std_logic_vector(63 downto 0);
		RO_F  :OUT std_logic_vector(63 downto 0)
	);
end RO_ARRAY;

architecture Behavioral of RO_ARRAY is
	COMPONENT RO_DCU_MACRO
	PORT(
		CI : IN std_logic_vector(4 downto 0);
		RO_EN : IN std_logic;          
		RO_F  : OUT std_logic
		);
	END COMPONENT;	
	 attribute LOC : string;
begin
Generate_RO1:
	for I in 0 to 50 generate
		---Sets the location of RO on the  FPGA
		attribute LOC of inst_RO_HardMACRO1 : label is "SLICE_X"&INTEGER'image(2 )&"Y"& INTEGER'image(I+2);--ro_row*4 last time!(with error)
	begin
		inst_RO_HardMACRO1 : RO_DCU_MACRO
			port map(CI, RO_En(I), RO_F(I));
	end generate Generate_RO1;
------	
	Generate_RO2:
	for I in 51 to 63 generate
		---Sets the location of RO on the  FPGA
		attribute LOC of inst_RO_HardMACRO2 : label is "SLICE_X"&INTEGER'image(4 )&"Y"& INTEGER'image(I-49);--ro_row*4 last time!(with error)
	begin
		inst_RO_HardMACRO2 : RO_DCU_MACRO
			port map(CI, RO_En(I), RO_F(I));
	end generate Generate_RO2;

end Behavioral;

