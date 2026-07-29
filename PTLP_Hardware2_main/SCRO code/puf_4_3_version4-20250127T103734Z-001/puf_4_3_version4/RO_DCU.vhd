----------------------------------------------------------------------------------
-- Company: 
-- Engineer: 
-- 
-- Create Date:    13:31:39 11/22/2020 
-- Design Name: 
-- Module Name:    RO_DCU - Behavioral 
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
library UNISIM;
use UNISIM.VComponents.all;

entity RO_DCU is
    Port ( CI    : in  STD_LOGIC_VECTOR (4 downto 0);
           RO_EN : in  STD_LOGIC;
           RO_F  : out STD_LOGIC);
end RO_DCU;

architecture Behavioral of RO_DCU is

component my_nand
port ( A, B : in std_logic;
		 REZ : out std_logic
		 );
end component;
-----------------------------
	COMPONENT DCU1
	PORT(
		DCU_IN : IN std_logic;
		C : IN std_logic;          
		DCU_OUT : OUT std_logic
		);
	END COMPONENT;
-----------------------------
	COMPONENT DCU2
	PORT(
		DCU_IN : IN std_logic;
		C : IN std_logic;          
		DCU_OUT : OUT std_logic
		);
	END COMPONENT;
-----------------------------
	COMPONENT DCU3
	PORT(
		DCU_IN : IN std_logic;
		C : IN std_logic;          
		DCU_OUT : OUT std_logic
		);
	END COMPONENT;
-----------------------------
	COMPONENT DCU4
	PORT(
		DCU_IN : IN std_logic;
		C : IN std_logic;          
		DCU_OUT : OUT std_logic
		);
	END COMPONENT;
-----------------------------
signal S:std_logic_vector(5 downto 0);


attribute KEEP: string ;
attribute KEEP of S: signal  is  " true " ; 

attribute rloc: string;

attribute rloc of Inst_DCU3   : label is "X13Y2";
attribute rloc of Inst_DCU2_1 : label is "X14Y2";
attribute rloc of Inst_DCU1   : label is "X15Y2";
attribute rloc of Inst_DCU4   : label is "X16Y2";
attribute rloc of Inst_DCU2_2 : label is "X17Y2";	
attribute rloc of Inst_nand	: label is "X12Y2";

begin
--	Inst_my_nand: my_nand PORT MAP(
--		A =>RO_EN ,
--		B => S(5),
--		REZ => S(0)
--	);
		inst_nand : LUT2
		generic map (
		INIT => X"7") -- initialized as a NAND
		port map (
		O => S(0) , -- LUT general output
		I0 => RO_EN, -- LUT input
		I1 => S(5) -- LUT input
		);
----------------------------
	Inst_DCU3: DCU3 PORT MAP(
		DCU_IN =>S(0) ,
		C =>CI(0) ,
		DCU_OUT =>S(1) 
	);
-----------------------------
	Inst_DCU2_1: DCU2 PORT MAP(
		DCU_IN =>S(1) ,
		C =>CI(1) ,
		DCU_OUT => S(2)
	);
-----------------------------
	Inst_DCU1: DCU1 PORT MAP(
		DCU_IN =>S(2) ,
		C =>CI(2) ,
		DCU_OUT =>S(3) 
	);
-----------------------------
	Inst_DCU4: DCU4 PORT MAP(
		DCU_IN =>S(3) ,
		C =>CI(3) ,
		DCU_OUT => S(4)
	);
-----------------------------
	Inst_DCU2_2: DCU2 PORT MAP(
		DCU_IN =>S(4) ,
		C =>CI(4) ,
		DCU_OUT =>S(5) 
	);
-----------------------------
RO_F<=S(5);

end Behavioral;

